//
// Copyright (c) 2013 XING AG (http://xing.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XNGAPIClient.h"
#import <XNGOAuth1Client/XNGOAuthToken.h>
#import "NSDictionary+Typecheck.h"

typedef void(^XNGAPILoginOpenURLBlock)(NSURL*openURL);

NSString * const kXNGApplicationLaunchedWithURLNotification = @"kAFApplicationLaunchedWithURLNotification";
#if __IPHONE_OS_VERSION_MIN_REQUIRED
NSString * const kXNGApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
#else
NSString * const kAFApplicationLaunchOptionsURLKey = @"NSApplicationLaunchOptionsURLKey";
#endif

@interface XNGAPIClient()
@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSString *callbackScheme;
@property (nonatomic, copy) XNGAPILoginOpenURLBlock loginOpenURLBlock;
@end

@implementation XNGAPIClient

NSString * const XNGAPIClientInvalidTokenErrorNotification = @"com.xing.apiClient.error.invalidToken";
NSString * const XNGAPIClientDeprecationErrorNotification = @"com.xing.apiClient.error.deprecatedAPI";
NSString * const XNGAPIClientDeprecationWarningNotification = @"com.xing.apiClient.warning.deprecatedAPI";

static XNGAPIClient *_sharedClient = nil;

+ (XNGAPIClient *)clientWithBaseURL:(NSURL *)url {
    return [[XNGAPIClient alloc] initWithBaseURL:url];
}

+ (XNGAPIClient *)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_sharedClient == nil) {
            NSURL *baseURL = [NSURL URLWithString:@"https://api.xing.com"];
            _sharedClient = [[XNGAPIClient alloc] initWithBaseURL:baseURL];
        }
    });
    return _sharedClient;
}

+ (void)setSharedClient:(XNGAPIClient *)sharedClient {
    _sharedClient = sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        _oAuthHandler = [[XNGOAuthHandler alloc] init];
//        self.signatureMethod = AFHMACSHA1SignatureMethod;
        self.responseSerializer = [[AFJSONRequestSerializer alloc] init];
#ifndef TARGET_OS_MAC
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
#endif
    }
    return self;
}

+ (void)addAcceptableContentTypes:(NSSet *)set {
    // TODO: is this needed?
//    [XNGJSONRequestOperation addAcceptableContentTypes:set];
}

#pragma mark - Getters / Setters

- (NSString *)callbackScheme {
    if (!_callbackScheme) {
        _callbackScheme =[NSString stringWithFormat:@"xingapp%@", self.requestSerializer.accessToken.token];
    }
    return _callbackScheme;
}

- (void)setUserAgent:(NSString *)userAgent {
    // TODO: needs to be tested
    [self.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
}

#pragma mark - handling login / logout

- (BOOL)isLoggedin {
    return self.requestSerializer.accessToken != nil;
}

- (void)logout {
    [self.requestSerializer removeAccessToken];
}

static inline void XNGAPIClientCanLoginTests(XNGAPIClient *client) {
    if (client.isLoggedin) {
        [[client exceptionForUserAlreadyLoggedIn] raise];
        return;
    }
    
    if ([client.requestSerializer.accessToken.token length] == 0) {
        [[client exceptionForNoConsumerKey] raise];
        return;
    }
    
    if ([client.requestSerializer.accessToken.secret length] == 0) {
        [[client exceptionForNoConsumerSecret] raise];
        return;
    }
}

static NSString * const XNGAPIClientOAuthRequestTokenPath = @"v1/request_token";
static NSString * const XNGAPIClientOAuthAuthorizationPath = @"v1/authorize";
static NSString * const XNGAPIClientOAuthAccessTokenPath = @"v1/access_token";


- (void)loginOAuthWithSuccess:(void (^)(void))success
                      failure:(void (^)(NSError *error))failure {
    
    XNGAPIClientCanLoginTests(self);
    
    NSURL *callbackURL = [self oauthCallbackURL];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self authorizeUsingOAuthWithRequestTokenPath:XNGAPIClientOAuthRequestTokenPath
                            userAuthorizationPath:XNGAPIClientOAuthAuthorizationPath
                                      callbackURL:callbackURL
                                  accessTokenPath:XNGAPIClientOAuthAccessTokenPath
                                     accessMethod:@"POST"
                                            scope:nil
                                          success:
     ^(XNGOAuthToken *accessToken, id responseObject) {
         NSString *userID = [accessToken.userInfo xng_stringForKey:@"user_id"];
         [weakSelf.requestSerializer saveAccessToken:accessToken];
     } failure:^(NSError *error) {
         failure(error);
     }];
}


- (void)loginOAuthAuthorize:(void (^)(NSURL *))authorizeBlock
                   loggedIn:(void (^)())loggedInBlock
                   failuire:(void (^)(NSError *))failureBlock {

    XNGAPIClientCanLoginTests(self);
    
    NSURL *callbackURL = [self oauthCallbackURL];
    __weak __typeof(&*self)weakSelf = self;

    [self acquireOAuthRequestTokenWithPath:XNGAPIClientOAuthAccessTokenPath
                               callbackURL:callbackURL
                              accessMethod:@"POST"
                              requestToken:self.requestSerializer.requestToken
                                     scope:nil
                                   success:
    ^(XNGOAuthToken *requestToken, id responseObject) {
        weakSelf.loginOpenURLBlock = [weakSelf loginOpenURLBlockWithRequestToken:requestToken loggedIn:loggedInBlock failuire:failureBlock];
//         NSDictionary *parameters = @{@"oauth_token": requestToken.key};
//         NSURL *authURL = [weakSelf oAuthAuthorizationURLWithParameters:parameters];
//         authorizeBlock(authURL);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

- (XNGAPILoginOpenURLBlock) loginOpenURLBlockWithRequestToken:(XNGOAuthToken *)requestToken
                                                     loggedIn:(void (^)())loggedInBlock
                                                     failuire:(void (^)(NSError *))failureBlock  {
    __weak __typeof(&*self)weakSelf = self;
    
    return ^(NSURL*openURL){

        [weakSelf acquireOAuthRequestTokenWithPath:XNGAPIClientOAuthAccessTokenPath
                                       callbackURL:nil
                                      accessMethod:@"POST"
                                      requestToken:requestToken
                                             scope:nil
                                           success:^(XNGOAuthToken *accessToken, id responseObject) {
                                               [weakSelf saveAuthDataFromToken:accessToken success:loggedInBlock failure:failureBlock];
                                               loggedInBlock();
                                           } failure:failureBlock];
    };
}
- (void) saveAuthDataFromToken:(XNGOAuthToken *)accessToken
                       success:(void (^)(void))success
                       failure:(void (^)(NSError *error))failure  {
    [self.requestSerializer saveAccessToken:accessToken];
    // TODO: save user ID
    [self.oAuthHandler saveUserID:userID
                      accessToken:accessToken.key
                           secret:accessToken.secret
                          success:success
                          failure:failure];
//    NSString *userID = [accessToken.userInfo xng_stringForKey:@"user_id"];
}


- (BOOL)handleOpenURL:(NSURL *)URL {
    if([[URL scheme] isEqualToString:self.callbackScheme] == NO) {
        return NO;
    }
    
    if (self.loginOpenURLBlock) {
        self.loginOpenURLBlock(URL);
        self.loginOpenURLBlock = nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:URL forKey:kXNGApplicationLaunchOptionsURLKey];
    NSNotification *notification = [NSNotification notificationWithName:kXNGApplicationLaunchedWithURLNotification
                                                                 object:nil
                                                               userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}

- (void)loginXAuthWithUsername:(NSString*)username
                      password:(NSString*)password
                       success:(void (^)(void))success
                       failure:(void (^)(NSError *error))failure {
    
    XNGAPIClientCanLoginTests(self);
    
    [self postRequestXAuthAccessTokenWithUsername:username
                                         password:password
                                          success:
     ^(AFHTTPRequestOperation *operation, id responseJSON) {
         NSString *body = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
         XNGOAuthToken *authToken = [[XNGOAuthToken alloc] initWithQueryString:body];
         [self.requestSerializer saveAccessToken:authToken];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure(error);
     }];
}

- (void)postRequestXAuthAccessTokenWithUsername:(NSString*)username
                                       password:(NSString*)password
                                        success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSParameterAssert(username);
    NSParameterAssert(password);
    
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"x_auth_username"] = username;
    parameters[@"x_auth_password"] = password;
    parameters[@"x_auth_mode"] = @"client_auth";
    
    NSString* path = [NSString stringWithFormat:@"%@/v1/xauth", self.baseURL];
    [self POST:path parameters:parameters success:success failure:failure];
}

#pragma mark - block-based GET / PUT / POST / DELETE

- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error))failure {
    [self getJSONPath:path
           parameters:parameters
         acceptHeader:nil
              success:success
              failure:failure];
}

- (void)putJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error))failure {
    [self putJSONPath:path
           parameters:parameters
         acceptHeader:nil
              success:success
              failure:failure];
}

- (void)postJSONPath:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(id JSON))success
             failure:(void (^)(NSError *error))failure {
    [self postJSONPath:path
            parameters:parameters
          acceptHeader:nil
               success:success
               failure:failure];
}

- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error))failure {
    [self deleteJSONPath:path
              parameters:parameters
            acceptHeader:nil
                 success:success
                 failure:failure];
}

#pragma mark - block-based GET / PUT / POST / DELETE with optional accept headers

- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    if (acceptHeader) [self.requestSerializer setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (success) {
              success(responseObject);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)putJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    if (acceptHeader) [self.requestSerializer setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postJSONPath:(NSString *)path
          parameters:(NSDictionary *)parameters
        acceptHeader:(NSString *)acceptHeader
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure {
    if (acceptHeader) [self.requestSerializer setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error) {
            failure(error);
        }
    }];
}

- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
          acceptHeader:(NSString *)acceptHeader
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    if (acceptHeader) [self.requestSerializer setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self DELETE:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - OAuth related methods

- (NSString *)currentUserID {
    // TODO: set user ID
    return @"0";
}

- (void)setConsumerKey:(NSString *)consumerKey {
    // TODO: set consumer key
}

- (void)setConsumerSecret:(NSString *)consumerSecret {
    // TODO: set consumer secret
}

#pragma mark - OAuth related methods (private)

- (NSURL*)oauthCallbackURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://success", self.callbackScheme]];
}

#pragma mark - checking methods

- (void)checkForGlobalErrors:(NSHTTPURLResponse *)response
                    withJSON:(id)JSON {
    if (response.statusCode == 410) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XNGAPIClientDeprecationErrorNotification object:nil];
        return;
    }
    if ([JSON isKindOfClass:[NSDictionary class]] &&
        [[JSON xng_stringForKey:@"error_name"] isEqualToString:@"INVALID_OAUTH_TOKEN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XNGAPIClientInvalidTokenErrorNotification object:nil];
        return;
    }
}

- (void)checkForDeprecation:(NSHTTPURLResponse *)response {
    if ([[response.allHeaderFields xng_stringForKey:@"X-Xing-Deprecation-Status"] isEqualToString:@"deprecated"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XNGAPIClientDeprecationWarningNotification object:nil];
    }
}

#pragma mark - cancel requests methods

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method paths:(NSArray *)paths {
    for (NSString* path in paths) {
        [self cancelAllHTTPOperationsWithMethod:method paths:@[path]];
    }
}

#pragma mark - Helper methods

- (NSException *)exceptionForUserAlreadyLoggedIn {
    return [NSException exceptionWithName:@"XNGUserLoginException" reason:@"A User is already loggedIn. Use the isLoggedin method to verify that no user is logged in before you use this method." userInfo:@{@"XNGLoggedInUserID":self.currentUserID}];
}

- (NSException *)exceptionForNoConsumerKey {
    return [NSException exceptionWithName:@"XNGNoConsumerKeyException"
                                   reason:@"There is no Consumer Key set yet. Please set it first before invoking login."
                                 userInfo:nil];
}

- (NSException *)exceptionForNoConsumerSecret {
    return [NSException exceptionWithName:@"XNGNoConsumerSecretException"
                                   reason:@"There is no Consumer Secret set yet. Please set it first before invoking login."
                                 userInfo:nil];
}

static NSDictionary * XNGParametersFromQueryString(NSString *queryString) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                parameters[[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }
    
    return parameters;
}

@end
