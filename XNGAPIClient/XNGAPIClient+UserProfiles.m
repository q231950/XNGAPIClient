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

#import "XNGAPIClient+UserProfiles.h"

@implementation XNGAPIClient (UserProfiles)

#pragma mark - public methods

- (void)getUserWithID:(NSString *)userID userFields:(NSString *)userFields success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSParameterAssert(userID);
    NSDictionary *parameters = nil;
    if ([userFields length]) {
        parameters = @{ @"fields" : userFields };
    }
    NSString* path = [NSString stringWithFormat:@"v1/users/%@", userID];
    [self getJSONPath:path
           parameters:parameters
              success:success
              failure:failure];
}

- (void)getSearchForUsersByEmail:(NSString *)searchString
                    hashFunction:(NSString *)hashFunction
                      userFields:(NSString *)userFields
                         success:(void (^)(id JSON))success
                         failure:(void (^)(NSError *error))failure {
    NSParameterAssert(searchString);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"emails"] = searchString;
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }
    if ([hashFunction length]) {
        parameters[@"hash_function"] = hashFunction;
    }

    NSString *path = [self HTTPOperationPathForSearchForUsersByEmail];
    [self getJSONPath:path
           parameters:parameters
              success:success
              failure:failure];
}

- (void)cancelAllSearchByEmailHTTPOperations {
    NSArray *pathsToBeCanceled = @[ [self HTTPOperationPathForSearchForUsersByEmail] ];
    [self cancelAllHTTPOperationsWithMethod:@"GET" paths:pathsToBeCanceled];
}

- (void)getLegalInformationWithID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSParameterAssert(userID);
    NSString* path = [NSString stringWithFormat:@"v1/users/%@/legal_information", userID];
    [self getJSONPath:path
           parameters:nil
              success:success
              failure:failure];
}

#pragma mark - private methods

- (NSString*)HTTPOperationPathForSearchForUsersByEmail {
    return @"v1/users/find_by_emails";
}

@end
