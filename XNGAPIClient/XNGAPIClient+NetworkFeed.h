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

@interface XNGAPIClient (NetworkFeed)

#pragma mark - handling activity / load more and new

/**
 Returns the stream of activities recently performed by the user's network....

 https://dev.xing.com/docs/get/users/:user_id/network_feed
 */
- (void)getNetworkFeedUntil:(NSString *)until
                 userFields:(NSString *)userFields
                    success:(void (^)(id JSON))success
                    failure:(void (^)(NSError *error))failure;

/**
 Cancel all network feed calls that are currently running/queued.
 */
- (void)cancelAllNetworkFeedHTTPOperations;

/**
 Returns the stream of activities recently performed by the corresponding user. These activities will not be aggregated. It's always possible to access a user's own feed, but a user might not be allowed to access another user's feed depending on their privacy settings....

 https://dev.xing.com/docs/get/users/:id/feed
 */
- (void)getUserFeedForUserID:(NSString *)userID
                       until:(NSString *)until
                  userFields:(NSString *)userFields
                     success:(void (^)(id JSON))success
                     failure:(void (^)(NSError *error))failure;

/**
 Cancel all user feed calls that are currently running/queued.
 */
- (void)cancelAllUserFeedHTTPOperationsForUserID:(NSString *)userID;

/**
 Posts a new status update for the specified user in the activity stream....

 https://dev.xing.com/docs/post/users/:id/status_message
 */
- (void)postStatusMessage:(NSString *)statusMessage
                  success:(void (^)(id JSON))success
                  failure:(void (^)(NSError *error))failure;

/**
 Create a new activity containing the link....

 https://dev.xing.com/docs/post/users/me/share/link
 */
- (void)postLink:(NSString*)uri
         success:(void (^)(id JSON))success
         failure:(void (^)(NSError *error))failure;

/**
 Returns a single activity. The response format is the same as the one in the network or user feed, even though a single activity will never be aggregated....

 https://dev.xing.com/docs/get/activities/:id
 */
- (void)getSingleActivityWithID:(NSString *)activityID
                     userFields:(NSString *)userFields
                        success:(void (^)(id JSON))success
                        failure:(void (^)(NSError *error))failure;

/**
 Cancel all single activity calls that are currently running/queued.
 */
- (void)cancelAllSingleActivityHTTPOperationsForActivityID:(NSString *)activityID;

/**
 Sharing an activity means recommending it to your network. This will then create a new activity for the current user. Only activities with SHARE in the possible_actions field can be shared.

 https://dev.xing.com/docs/post/activities/:id/share
 */
- (void)postRecommendActivityWithID:(NSString*)activityID
                            success:(void (^)(id JSON))success
                            failure:(void (^)(NSError *error))failure;

/**
 Deletes the activity with the given ID. Users can only delete their own activities, and only activities with DELETE in the possible_actions field can be deleted.

 https://dev.xing.com/docs/delete/activities/:id
 */
- (void)deleteActivityWithID:(NSString*)activityID
                     success:(void (^)(id JSON))success
                     failure:(void (^)(NSError *error))failure;

/**
 Returns a list of comments added to the activity with the given activity_id. This list is sorted by the creation date of the comments.

 https://dev.xing.com/docs/get/activities/:activity_id/comments
 */
- (void)getCommentsWithActivityID:(NSString*)activityID
                       userFields:(NSString *)userFields
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                          success:(void (^)(id JSON))success
                          failure:(void (^)(NSError *error))failure;

/**
 Creates a comment for a certain activity. Only activities with COMMENT in the possible_actions field can be commented on.

 https://dev.xing.com/docs/post/activities/:activity_id/comments
 */
- (void)postNewComment:(NSString*)comment
            activityID:(NSString*)activityID
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error))failure;

/**
 Deletes a comment for a certain activity. Users can only delete their own comments or comments for activities they own.

 https://dev.xing.com/docs/delete/activities/:activity_id/comments/:id
 */
- (void)deleteCommentWithID:(NSString*)commentID
                 activityID:(NSString*)activityID
                    success:(void (^)(id JSON))success
                    failure:(void (^)(NSError *error))failure;

/**
 Returns a list of users who liked a certain activity.

 https://dev.xing.com/docs/get/activities/:activity_id/likes
 */
- (void)getLikesForActivityID:(NSString*)activityID
                   userFields:(NSString *)userFields
                       offset:(NSInteger)offset
                        limit:(NSInteger)limit
                      success:(void (^)(id JSON))success
                      failure:(void (^)(NSError *error))failure;

/**
 Adds the current user to the list of likes for the given activity. It's only possible to like activities which have LIKE in the possible_actions field.

 https://dev.xing.com/docs/put/activities/:activity_id/like
 */
- (void)putLikeActivityWithID:(NSString*)activityID
                      success:(void (^)(id JSON))success
                      failure:(void (^)(NSError *error))failure;

/**
 Removes a like the current user already added to the given activity. It's only possible to like activities which have LIKE in the possible_actions field.

 https://dev.xing.com/docs/delete/activities/:activity_id/like
 */
- (void)deleteUnlikeActivityWithID:(NSString*)activityID
                           success:(void (^)(id JSON))success
                           failure:(void (^)(NSError *error))failure;

@end
