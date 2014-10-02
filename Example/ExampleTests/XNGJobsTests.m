#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>
#import <OCMock/OCMock.h>

@interface XNGJobsTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGJobsTests

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

- (void)testGetJobDetails {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobDetailsForJobID:@"1"
                                                 userFields:nil
                                                    success:nil
                                                    failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/jobs/1");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetJobDetailsWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobDetailsForJobID:@"1"
                                                 userFields:@"display_name"
                                                    success:nil
                                                    failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/jobs/1");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetJobSearchResultsInvokedWithDifferentSignature {
    id classUnderTestMock = [self mockedAPIClient];

    [[classUnderTestMock expect] getJobSearchResultsForString:@"bla"
                                                        limit:0
                                                       offset:0
                                                   userFields:nil
                                            requestedByHeader:nil
                                                      success:nil
                                                      failure:nil];

    [classUnderTestMock getJobSearchResultsForString:@"bla"
                                               limit:0
                                              offset:0
                                          userFields:nil
                                             success:nil
                                             failure:nil];

    [classUnderTestMock verify];
}

- (void)testGetJobSearchResults {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobSearchResultsForString:@"bla"
                                                             limit:0
                                                            offset:0
                                                        userFields:nil
                                                           success:nil
                                                           failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/jobs/find");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"query"]).to.equal(@"bla");
         [query removeObjectForKey:@"query"];
         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetJobSearchResultsWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobSearchResultsForString:@"bla"
                                                             limit:20
                                                            offset:40
                                                        userFields:@"display_name"
                                                 requestedByHeader:@"jobs.top"
                                                           success:nil
                                                           failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/jobs/find");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"query"]).to.equal(@"bla");
         [query removeObjectForKey:@"query"];
         expect([query valueForKey:@"limit"]).to.equal(@"20");
         [query removeObjectForKey:@"limit"];
         expect([query valueForKey:@"offset"]).to.equal(@"40");
         [query removeObjectForKey:@"offset"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];
         expect([[request allHTTPHeaderFields] valueForKey:@"Request-Triggered-By"]).to.equal(@"jobs.top");

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetJobRecommendationsInvokedWithDifferentSignature {
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

- (void)testGetJobRecommendations {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobRecommendationsWithLimit:0
                                                              offset:0
                                                          userFields:nil
                                                             success:nil
                                                             failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/jobs/recommendations");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetJobRecommendationsWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getJobRecommendationsWithLimit:20
                                                              offset:40
                                                          userFields:@"display_name"
                                                   requestedByHeader:@"jobs"
                                                             success:nil
                                                             failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/jobs/recommendations");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"limit"]).to.equal(@"20");
         [query removeObjectForKey:@"limit"];
         expect([query valueForKey:@"offset"]).to.equal(@"40");
         [query removeObjectForKey:@"offset"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];
         expect([[request allHTTPHeaderFields] valueForKey:@"Request-Triggered-By"]).to.equal(@"jobs");

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
