#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>
#import <OCMock/OCMock.h>

@interface XNGRecommendationsTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGRecommendationsTests

- (XNGAPIClient *)mockedAPIClient {
    Class appsAPIClientClass = NSClassFromString(NSStringFromClass(XNGAPIClient.class));
    return [OCMockObject partialMockForObject:[appsAPIClientClass sharedClient]];
}

- (void)setUp {
    [super setUp];

    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testGetRecommendationsInvokedWithDifferentSignature {
    id classUnderTestMock = [self mockedAPIClient];

    [[classUnderTestMock expect] getJobRecommendationsWithLimit:0
                                                         offset:0
                                                     userFields:nil
                                              requestedByHeader:nil
                                                        success:nil
                                                        failure:nil];

    [classUnderTestMock getJobRecommendationsWithLimit:0
                                                offset:0
                                            userFields:nil
                                               success:nil
                                               failure:nil];

    [classUnderTestMock verify];
}

- (void)testGetRecommendations {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getContactRecommendationsWithLimit:0
                                                                  offset:0
                                                         similarToUserID:0
                                                              userFields:nil
                                                                 success:nil
                                                                 failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network/recommendations");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetRecommendationsWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getContactRecommendationsWithLimit:20
                                                                  offset:40
                                                         similarToUserID:@"1"
                                                              userFields:@"display_name"
                                                       requestedByHeader:@"contactrequests"
                                                                 success:nil
                                                                 failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network/recommendations");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"limit"]).to.equal(@"20");
         [query removeObjectForKey:@"limit"];
         expect([query valueForKey:@"offset"]).to.equal(@"40");
         [query removeObjectForKey:@"offset"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];
         expect([query valueForKey:@"similar_user_id"]).to.equal(@"1");
         [query removeObjectForKey:@"similar_user_id"];
         expect([[request allHTTPHeaderFields] valueForKey:@"Request-Triggered-By"]).to.equal(@"contactrequests");

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testDeleteRecommendationInvokedWithDifferentSignature {
    id classUnderTestMock = [self mockedAPIClient];

    [[classUnderTestMock expect] deleteContactRecommendationsForUserIDToIgnore:nil
                                                             requestedByHeader:nil
                                                                       success:nil
                                                                       failure:nil];

    [classUnderTestMock deleteContactRecommendationsForUserIDToIgnore:nil
                                                              success:nil
                                                              failure:nil];

    [classUnderTestMock verify];
}

- (void)testDeleteRecommendation {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] deleteContactRecommendationsForUserIDToIgnore:@"1"
                                                                            success:nil
                                                                            failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/network/recommendations/user/1");
         expect(request.HTTPMethod).to.equal(@"DELETE");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
