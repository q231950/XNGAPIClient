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

#import <Foundation/Foundation.h>
#import "AFOAuth1Client.h"

@interface XNGAPIClient : AFOAuth1Client

extern NSString * const XNGAPIClientInvalidTokenErrorNotification;
extern NSString * const XNGAPIClientDeprecationErrorNotification;
extern NSString * const XNGAPIClientDeprecationWarningNotification;

+ (XNGAPIClient *)clientWithBaseURL:(NSURL *)url;
+ (XNGAPIClient *)sharedClient;
+ (void)setSharedClient:(XNGAPIClient *)sharedClient;
+ (void)addAcceptableContentTypes:(NSSet *)set;


#pragma mark - Login / Logout

/**
 *  Login with automatic authorization step in Safari.
 *
 *  @note -handleOpenURL: must be called with the result url of the authorize website to finish login.
 *  @param success called when the whole login process is completed sucessfully.
 *  @param failure called anytime when an error happens.
 */
- (void)loginOAuthWithSuccess:(void (^)(void))success
                      failure:(void (^)(NSError *error))failure;

/**
 *  Use this method for manual handling of the authorization step.
 *
 *  This method can be used to display the authorization website in an web view with the option to open Safari instead of directly switching to Safari.
 *  @note When the acquiredTokenBlock is called, the authURL should opened in a web view or Safari.
 *  -handleOpenURL: must be called with the result url of the authorize website to finish the login process.
 *
 *  @param authorizeBlock  Called when the request token was sucessfully acquired, use authURL to open the authorization website.
 *  @param loggedInBlock   Called when the access token was sucessfilly acquired and the user is successfully logged in.
 *  @param failureBlock    Called when one step in the process fails.
 */
- (void)loginOAuthAuthorize:(void (^)(NSURL*authURL))authorizeBlock
                   loggedIn:(void (^)())loggedInBlock
                   failuire:(void (^)(NSError *error))failureBlock;

/**
 *  Must be called for to complete both -loginOAuthWithSuccess:failure and -loginOAuthAcquiredRequestToken:loggedIn:failure calls
 *
 *  @param URL url to open
 *
 *  @return YES on success, NO on failure.
 */
- (BOOL)handleOpenURL:(NSURL *)URL;


// XAuth
- (void)loginXAuthWithUsername:(NSString*)username
                      password:(NSString*)password
                       success:(void (^)(void))success
                       failure:(void (^)(NSError *error))failure;
- (BOOL)isLoggedin;
- (void)logout;

#pragma mark - block-based GET / PUT / POST / DELETE

/**
  default method to make a GET call to the public XING API.
  */
- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error))failure;

/**
 default method to make a PUT call to the public XING API.
 */
- (void)putJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error))failure;

/**
 default method to make a POST call to the public XING API.
 */
- (void)postJSONPath:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(id JSON))success
             failure:(void (^)(NSError *error))failure;

/**
 default method to make a DELETE call to the public XING API.
 */
- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error))failure;

#pragma mark - block-based GET / PUT / POST / DELETE with optional accept headers

/**
 use this method to make a GET call to a vendor resource of the XING API.
 */
- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

/**
 use this method to make a PUT call to a vendor resource of the XING API.
 */
- (void)putJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

/**
 use this method to make a POST call to a vendor resource of the XING API.
 */
- (void)postJSONPath:(NSString *)path
          parameters:(NSDictionary *)parameters
        acceptHeader:(NSString *)acceptHeader
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure;

/**
 use this method to make a DELETE call to a vendor resource of the XING API.
 */
- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
          acceptHeader:(NSString *)acceptHeader
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure;

#pragma mark - block-based GET / PUT / POST / DELETE with optional request tracking headers

/**
 default method to make a GET call to the public XING API with request tracking.
 */
- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
  requestedByHeader:(NSString *)requestedByHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

/**
 default method to make a DELETE call to the public XING API with request tracking.
 */
- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
     requestedByHeader:(NSString *)requestedByHeader
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error))failure;

#pragma mark - block-based GET / PUT / POST / DELETE with optional accept and request tracking headers

/**
 use this method to make a GET call to a vendor resource of the XING API with request tracking.
 */
- (void)getJSONPath:(NSString *)path
         parameters:(NSDictionary *)parameters
       acceptHeader:(NSString *)acceptHeader
  requestedByHeader:(NSString *)requestedByHeader
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

/**
 use this method to make a DELETE call to a vendor resource of the XING API with request tracking.
 */
- (void)deleteJSONPath:(NSString *)path
            parameters:(NSDictionary *)parameters
          acceptHeader:(NSString *)acceptHeader
     requestedByHeader:(NSString *)requestedByHeader
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure;

#pragma mark - HTTP Operation queue methods

- (void)enqueueJSONRequest:(NSMutableURLRequest *)request
                   success:(void (^)(id JSON))success
                   failure:(void (^)(NSError *error))failure;

#pragma mark - cancel requests methods

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method paths:(NSArray *)paths;
- (void)cancelAllHTTPOperations;

#pragma mark - OAuth related methods

- (NSString *)currentUserID;

- (void)setConsumerKey:(NSString *)consumerKey;
- (void)setConsumerSecret:(NSString *)consumerSecret;
- (void)setCallbackScheme:(NSString*)callbackScheme;
- (void)setUserAgent:(NSString *)userAgent;

@end
