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

@interface XNGAPIClient (UserProfiles)

/**
 Shows a particular user's profile. The data returned by this call will be checked against and filtered on the basis of the privacy settings of the requested user....

 https://dev.xing.com/docs/get/users/:id
 */
- (void)getUserWithID:(NSString *)userID
           userFields:(NSString *)userFields
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure;

/**
 Returns the list of users that belong directly to the given list of email addresses. The users will be returned in the same order as the corresponding email addresses. If addresses are invalid or no user was found, the user will be returned with the value null....

 https://dev.xing.com/docs/get/users/find_by_emails
 */
- (void)getSearchForUsersByEmail:(NSString *)searchString
                    hashFunction:(NSString *)hashFunction
                      userFields:(NSString *)userFields
                         success:(void (^)(id JSON))success
                         failure:(void (^)(NSError *error))failure;

/**
 Cancel all search by email calls that are currently running/queued.
 */
- (void)cancelAllSearchByEmailHTTPOperations;

/**
 Fetches the users legal information.

 https://dev.xing.com/docs/get/users/:user_id/legal_information
*/
- (void)getLegalInformationWithID:(NSString *)userID
                          success:(void (^)(id))success
                          failure:(void (^)(NSError *))failure;

@end
