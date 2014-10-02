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

#import "XNGAPIClient+Recommendations.h"

@implementation XNGAPIClient (Recommendations)

#pragma mark - public methods

- (void)getContactRecommendationsWithLimit:(NSInteger)limit
                                    offset:(NSInteger)offset
                           similarToUserID:(NSString *)similarUserID
                                userFields:(NSString *)userFields
                                   success:(void (^)(id JSON))success
                                   failure:(void (^)(NSError *error))failure {
    [self getContactRecommendationsWithLimit:limit
                                      offset:offset
                             similarToUserID:similarUserID
                                  userFields:userFields
                           requestedByHeader:nil
                                     success:success
                                     failure:failure];
}

- (void)getContactRecommendationsWithLimit:(NSInteger)limit
                                    offset:(NSInteger)offset
                           similarToUserID:(NSString *)similarUserID
                                userFields:(NSString *)userFields
                         requestedByHeader:(NSString *)requestedByHeader
                                   success:(void (^)(id JSON))success
                                   failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (limit) {
        parameters[@"limit"] = @(limit);
    }
    if (offset) {
        parameters[@"offset"] = @(offset);
    }
    if ([similarUserID length]) {
        parameters[@"similar_user_id"] = similarUserID;
    }
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = [self pathForGetContactRecommendations];
    [self getJSONPath:path
           parameters:parameters
    requestedByHeader:requestedByHeader
              success:success
              failure:failure];
}

- (void)deleteContactRecommendationsForUserIDToIgnore:(NSString*)userIDToIgnore
                                              success:(void (^)(id JSON))success
                                              failure:(void (^)(NSError *error))failure {
    [self deleteContactRecommendationsForUserIDToIgnore:userIDToIgnore
                                      requestedByHeader:nil
                                                success:success
                                                failure:failure];
}

- (void)deleteContactRecommendationsForUserIDToIgnore:(NSString*)userIDToIgnore
                                    requestedByHeader:(NSString *)requestedByHeader
                                              success:(void (^)(id JSON))success
                                              failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"v1/users/me/network/recommendations/user/%@", userIDToIgnore];
    [self deleteJSONPath:path
              parameters:nil
       requestedByHeader:requestedByHeader
                 success:success
                 failure:failure];
}

- (void)cancelAllGetContactRecommendationsHTTPOperations {
    NSString *path = [self pathForGetContactRecommendations];
    [self cancelAllHTTPOperationsWithMethod:@"GET" path:path];
}

#pragma mark - private methods

- (NSString *)pathForGetContactRecommendations {
    return [NSString stringWithFormat:@"v1/users/me/network/recommendations"];
}

@end
