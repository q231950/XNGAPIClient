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

#import "XNGAPIClient+Jobs.h"

@implementation XNGAPIClient (Jobs)

#pragma mark - public methods

- (void)getJobDetailsForJobID:(NSString *)jobID
                   userFields:(NSString *)userFields
                      success:(void (^)(id JSON))success
                      failure:(void (^)(NSError *error))failure {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = [NSString stringWithFormat:@"v1/jobs/%@", jobID];

    [self getJSONPath:path
           parameters:parameters
              success:success
              failure:failure];
}

- (void)getJobSearchResultsForString:(NSString *)searchString
                               limit:(NSInteger)limit
                              offset:(NSInteger)offset
                          userFields:(NSString *)userFields
                             success:(void (^)(id JSON))success
                             failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"query"] = searchString;
    if (limit) {
        parameters[@"limit"] = @(limit);
    }
    if (offset) {
        parameters[@"offset"] = @(offset);
    }
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = [self HTTPOperationPathForJobSearch];
    [self getJSONPath:path
           parameters:parameters
              success:success
              failure:failure];
}

- (void)getJobSearchResultsForString:(NSString *)searchString
                               limit:(NSInteger)limit
                              offset:(NSInteger)offset
                          userFields:(NSString *)userFields
                   requestedByHeader:(NSString *)requestedByHeader
                             success:(void (^)(id JSON))success
                             failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"query"] = searchString;
    if (limit) {
        parameters[@"limit"] = @(limit);
    }
    if (offset) {
        parameters[@"offset"] = @(offset);
    }
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = [self HTTPOperationPathForJobSearch];
    [self getJSONPath:path
           parameters:parameters
    requestedByHeader:requestedByHeader
              success:success
              failure:failure];
}

- (void)getJobRecommendationsWithLimit:(NSInteger)limit
                                offset:(NSInteger)offset
                            userFields:(NSString *)userFields
                               success:(void (^)(id JSON))success
                               failure:(void (^)(NSError *error))failure {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (limit) {
        parameters[@"limit"] = @(limit);
    }
    if (offset) {
        parameters[@"offset"] = @(offset);
    }
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = @"v1/users/me/jobs/recommendations";
    [self getJSONPath:path
           parameters:parameters
              success:success
              failure:failure];
}

- (void)getJobRecommendationsWithLimit:(NSInteger)limit
                                offset:(NSInteger)offset
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
    if ([userFields length]) {
        parameters[@"user_fields"] = userFields;
    }

    NSString *path = @"v1/users/me/jobs/recommendations";
    [self getJSONPath:path
           parameters:parameters
    requestedByHeader:requestedByHeader
              success:success
              failure:failure];
}

- (void)cancelAllJobSearchHTTPOperations {
    [self cancelAllJobSearchHTTPOperationsWithMethod:@"GET"];
}

#pragma mark - private methods

- (NSString*)HTTPOperationPathForJobSearch {
    return @"v1/jobs/find";
}

- (void)cancelAllJobSearchHTTPOperationsWithMethod:(NSString *)method {
    NSString *path = [self HTTPOperationPathForJobSearch];
    [self cancelAllHTTPOperationsWithMethod:method path:path];
}

@end
