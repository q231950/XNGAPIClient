#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>

@interface XNGNetworkFeedTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGNetworkFeedTests

- (void)setUp {
    [super setUp];
    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testGetNetworkFeed {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getNetworkFeedUntil:nil
                                               userFields:nil
                                                  success:nil
                                                  failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network_feed");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetNetworkFeedWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getNetworkFeedUntil:@"1"
                                               userFields:@"display_name"
                                                  success:nil
                                                  failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network_feed");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"until"]).to.equal(@"1");
         [query removeObjectForKey:@"until"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetUserFeed {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getUserFeedForUserID:@"1"
                                                     until:nil
                                                userFields:nil
                                                  success:nil
                                                  failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/1/feed");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetUserFeedWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getUserFeedForUserID:@"1"
                                                     until:@"2"
                                                userFields:@"display_name"
                                                   success:nil
                                                   failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/1/feed");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"until"]).to.equal(@"2");
         [query removeObjectForKey:@"until"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testPostStatusMessage {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] postStatusMessage:@"status message"
                                                success:nil
                                                failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/status_message");
         expect(request.HTTPMethod).to.equal(@"POST");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body valueForKey:@"message"]).to.equal(@"status%20message");
         [body removeObjectForKey:@"message"];

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testPostLink {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] postLink:@"blalup"
                                       success:nil
                                       failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/share/link");
         expect(request.HTTPMethod).to.equal(@"POST");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body valueForKey:@"uri"]).to.equal(@"blalup");
         [body removeObjectForKey:@"uri"];

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetSingleActivity {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getSingleActivityWithID:@"1"
                                                   userFields:@"display_name"
                                                      success:nil
                                                      failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testRecommendActivity {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] postRecommendActivityWithID:@"1"
                                                          success:nil
                                                          failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/share");
         expect(request.HTTPMethod).to.equal(@"POST");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testDeleteActivity {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] deleteActivityWithID:@"1"
                                                   success:nil
                                                   failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1");
         expect(request.HTTPMethod).to.equal(@"DELETE");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetComments {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getCommentsWithActivityID:@"1"
                                                     userFields:nil
                                                         offset:0
                                                          limit:0
                                                        success:nil
                                                        failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/comments");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetCommentsWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getCommentsWithActivityID:@"1"
                                                     userFields:@"display_name"
                                                         offset:20
                                                          limit:40
                                                        success:nil
                                                        failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/comments");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"offset"]).to.equal(@"20");
         [query removeObjectForKey:@"offset"];
         expect([query valueForKey:@"limit"]).to.equal(@"40");
         [query removeObjectForKey:@"limit"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testPostNewComment {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] postNewComment:@"comment"
                                          activityID:@"1"
                                             success:nil
                                             failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/comments");
         expect(request.HTTPMethod).to.equal(@"POST");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body valueForKey:@"text"]).to.equal(@"comment");
         [body removeObjectForKey:@"text"];
         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testDeleteComment {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] deleteCommentWithID:@"1"
                                               activityID:@"2"
                                                  success:nil
                                                  failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/2/comments/1");
         expect(request.HTTPMethod).to.equal(@"DELETE");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetLikes {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getLikesForActivityID:@"1"
                                                 userFields:nil
                                                     offset:0
                                                      limit:0
                                                    success:nil
                                                    failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/likes");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetLikesWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getLikesForActivityID:@"1"
                                                 userFields:@"display_name"
                                                     offset:20
                                                      limit:40
                                                    success:nil
                                                    failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/likes");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"offset"]).to.equal(@"20");
         [query removeObjectForKey:@"offset"];
         expect([query valueForKey:@"limit"]).to.equal(@"40");
         [query removeObjectForKey:@"limit"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testLikeActivity {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] putLikeActivityWithID:@"1"
                                                    success:nil
                                                    failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/like");
         expect(request.HTTPMethod).to.equal(@"PUT");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testUnlikeActivity {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] deleteUnlikeActivityWithID:@"1"
                                                         success:nil
                                                         failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/activities/1/like");
         expect(request.HTTPMethod).to.equal(@"DELETE");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
