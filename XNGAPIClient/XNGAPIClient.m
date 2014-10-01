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
#import "NSString+URLEncoding.h"
#import "NSDictionary+Typecheck.h"
#import "AFOAuth1Client.h"
#import "XNGOAuthHandler.h"
#import "XNGJSONRequestOperation.h"
#import "NSError+XWS.h"

typedef void(^XNGAPILoginOpenURLBlock)(NSURL*openURL);
static NSDictionary * XNGParametersFromQueryString(NSString *queryString);

@interface AFOAuth1Client (private)
@property (readwrite, nonatomic, copy) NSString *key;
@property (readwrite, nonatomic, copy) NSString *secret;
@end

@interface XNGAPIClient()
@property(nonatomic, strong, readwrite) XNGOAuthHandler *oAuthHandler;
@property(nonatomic, strong, readwrite) NSString *callbackScheme;
@property(nonatomic, copy, readwrite) XNGAPILoginOpenURLBlock loginOpenURLBlock;
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
        self.signatureMethod = AFHMACSHA1SignatureMethod;
        [self registerHTTPOperationClass:[XNGJSONRequestOperation class]];
#ifndef TARGET_OS_MAC
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
#endif
        self.accessToken = [self accessTokenFromKeychain];
    }
    return self;
}

+ (void)addAcceptableContentTypes:(NSSet *)set {
    [XNGJSONRequestOperation addAcceptableContentTypes:set];
}

#pragma mark - Getters / Setters

- (NSString *)callbackScheme {
    if (!_callbackScheme) {
        _callbackScheme =[NSString stringWithFormat:@"xingapp%@",self.key];
    }
    return _callbackScheme;
}

- (void)setUserAgent:(NSString *)userAgent {
    [self setDefaultHeader:@"User-Agent" value:userAgent];
}

#pragma mark - handling login / logout

- (BOOL)isLoggedin {
    return [self.oAuthHandler hasAccessToken];
}

- (void)logout {
    [self.oAuthHandler deleteKeychainEntries];
    self.accessToken = nil;
}

static inline void XNGAPIClientCanLoginTests(XNGAPIClient *client) {
    if (client.isLoggedin) {
        [[client exceptionForUserAlreadyLoggedIn] raise];
        return;
    }
    
    if ([client.key length] == 0) {
        [[client exceptionForNoConsumerKey] raise];
        return;
    }
    
    if ([client.secret length] == 0) {
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
     ^(AFOAuth1Token *accessToken, id responseObject) {
         NSString *userID = [accessToken.userInfo xng_stringForKey:@"user_id"];
         [weakSelf.oAuthHandler saveUserID:userID
                               accessToken:accessToken.key
                                    secret:accessToken.secret
                                   success:success
                                   failure:failure];
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
    
    [self acquireOAuthRequestTokenWithPath:XNGAPIClientOAuthRequestTokenPath
                               callbackURL:callbackURL
                              accessMethod:@"POST"
                                     scope:nil
                                   success:
     ^(AFOAuth1Token *requestToken, id responseObject) {
         
         weakSelf.loginOpenURLBlock = [weakSelf loginOpenURLBlockWithRequestToken:requestToken loggedIn:loggedInBlock failuire:failureBlock];

         NSDictionary *parameters = @{@"oauth_token": requestToken.key};
         NSURL *authURL = [weakSelf oAuthAuthorizationURLWithParameters:parameters];
         authorizeBlock(authURL);
     }
                                   failure:
     ^(NSError *error) {
         failureBlock(error);
     }];
    
}

- (XNGAPILoginOpenURLBlock) loginOpenURLBlockWithRequestToken:(AFOAuth1Token*)requestToken
                                                     loggedIn:(void (^)())loggedInBlock
                                                     failuire:(void (^)(NSError *))failureBlock  {
    __weak __typeof(&*self)weakSelf = self;
    
    return ^(NSURL*openURL){
        
        NSDictionary *queryDictionary = XNGParametersFromQueryString(openURL.query);
        requestToken.verifier = queryDictionary[@"oauth_verifier"];
        
        [weakSelf acquireOAuthAccessTokenWithPath:XNGAPIClientOAuthAccessTokenPath
                                 requestToken:requestToken
                                 accessMethod:@"POST"
                                      success:^(AFOAuth1Token *accessToken, id responseObject) {
                                          [weakSelf saveAuthDataFromToken:accessToken success:loggedInBlock failure:failureBlock];
                                          loggedInBlock();
                                      } failure:failureBlock];
    };
}
- (void) saveAuthDataFromToken:(AFOAuth1Token*)accessToken
                       success:(void (^)(void))success
                       failure:(void (^)(NSError *error))failure  {
    self.accessToken = accessToken;
    NSString *userID = [accessToken.userInfo xng_stringForKey:@"user_id"];
    [self.oAuthHandler saveUserID:userID
                      accessToken:accessToken.key
                           secret:accessToken.secret
                          success:success
                          failure:failure];
}


- (BOOL)handleOpenURL:(NSURL *)URL {
    if([[URL scheme] isEqualToString:self.callbackScheme] == NO) {
        return NO;
    }
    
    if (self.loginOpenURLBlock) {
        self.loginOpenURLBlock(URL);
        self.loginOpenURLBlock = nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:URL forKey:kAFApplicationLaunchOptionsURLKey];
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification
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
         NSDictionary *xAuthResponseFields = [NSString xng_URLDecodedDictionaryFromString:body];
         
         [self.oAuthHandler saveXAuthResponseParametersToKeychain:xAuthResponseFields
                                                          success:^{
                                                              self.accessToken = [self accessTokenFromKeychain];
                                                              if (success) success();
                                                          }
                                                          failure:failure];
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
    [self postPath:path parameters:parameters success:success failure:failure];
}

- (AFOAuth1Token*)accessTokenFromKeychain {
    if (self.oAuthHandler.accessToken && self.oAuthHandler.tokenSecret) {
        return [[AFOAuth1Token alloc] initWithKey:self.oAuthHandler.accessToken secret:self.oAuthHandler.tokenSecret session:nil expiration:nil renewable:YES];
    }
    return nil;
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
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

- (void)putJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

- (void)postJSONPath:(NSString *)path
          parameters:(NSDictionary *)parameters
        acceptHeader:(NSString *)acceptHeader
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
          acceptHeader:(NSString *)acceptHeader
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

#pragma mark - block-based GET / PUT / POST / DELETE with optional request tracking headers

- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
  requestedByHeader:(NSString *)requestedByHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    [self getJSONPath:path
           parameters:parameters
         acceptHeader:nil
    requestedByHeader:requestedByHeader
              success:success
              failure:failure];
}

- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
     requestedByHeader:(NSString *)requestedByHeader
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error))failure {
    [self deleteJSONPath:path
              parameters:parameters
            acceptHeader:nil
       requestedByHeader:requestedByHeader
                 success:success
                 failure:failure];
}

#pragma mark - block-based GET / PUT / POST / DELETE with optional accept and request tracking headers

- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
  requestedByHeader:(NSString *)requestedByHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    if (requestedByHeader) [request setValue:requestedByHeader forHTTPHeaderField:@"Request-Triggered-By"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
          acceptHeader:(NSString *)acceptHeader
     requestedByHeader:(NSString *)requestedByHeader
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    if (acceptHeader) [request setValue:acceptHeader forHTTPHeaderField:@"Accept"];
    if (requestedByHeader) [request setValue:requestedByHeader forHTTPHeaderField:@"Request-Triggered-By"];
    [self enqueueJSONRequest:request success:success failure:failure];
}

#pragma mark - OAuth related methods

- (NSString *)currentUserID {
    return self.oAuthHandler.userID;
}

- (void)setConsumerKey:(NSString *)consumerKey {
    self.key = consumerKey;
}

- (void)setConsumerSecret:(NSString *)consumerSecret {
    self.secret = consumerSecret;
}

#pragma mark - OAuth related methods (private)


- (NSURL*)oauthCallbackURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://success",self.callbackScheme]];
}

- (NSURL*)oAuthAuthorizationURLWithParameters:(NSDictionary*)parameters {
    NSString *query = AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding);

    NSString *pathAndQuery = [XNGAPIClientOAuthAuthorizationPath stringByAppendingFormat:@"?%@",query];
    return [[NSURL URLWithString:pathAndQuery relativeToURL:self.baseURL] absoluteURL];
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
        [self cancelAllHTTPOperationsWithMethod:method path:path];
    }
}

- (void)cancelAllHTTPOperations {
    for (NSOperation *operation in self.operationQueue.operations) {
        operation.completionBlock = nil;
        [operation cancel];
    }
}

#pragma mark - HTTP Operation queue methods

- (void)enqueueJSONRequest:(NSMutableURLRequest *)request
                   success:(void (^)(id JSON))success
                   failure:(void (^)(NSError *error))failure {
    if (NO == [[[request allHTTPHeaderFields] allKeys] containsObject:@"Accept"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    __weak __typeof(&*self)weakSelf = self;
    XNGJSONRequestOperation *operation = nil;
    operation = [XNGJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                 success:
                 ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     [weakSelf checkForDeprecation:response];
                     if (success) {
                         success(JSON);
                     }
                 } failure:
                 ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     [weakSelf checkForDeprecation:response];
                     [weakSelf checkForGlobalErrors:response withJSON:JSON];
                     
                     if ([JSON isKindOfClass:[NSDictionary class]]) {
                         error = [NSError xwsErrorWithStatusCode:response.statusCode
                                                        userInfo:JSON];
                     }
                     
                     if (failure) {
                         failure(error);
                     }
                 }];
    [self enqueueHTTPRequestOperation:operation];
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
