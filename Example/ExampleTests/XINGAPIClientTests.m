#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"

@interface XINGAPIClientTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XINGAPIClientTests

- (void)setUp {
    [super setUp];

    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setupOAuthCredentials];

    // stub all outgoing network requests
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return nil;
    }];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testLoginXAuth {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] loginXAuthWithUsername:@"username"
                                                    password:@"password"
                                                     success:^{}
                                                     failure:^(NSError *error) {}];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/xauth");
         expect(request.HTTPMethod).to.equal(@"POST");

         NSString *authHeader = [request.allHTTPHeaderFields valueForKey:@"Authorization"];
         expect([authHeader hasPrefix:@"OAuth oauth_consumer_key=\"123\""]).to.beTruthy;

         expect([body valueForKey:@"x_auth_mode"]).to.equal(@"client_auth");
         [body removeObjectForKey:@"x_auth_mode"];

         expect([body valueForKey:@"x_auth_password"]).to.equal(@"password");
         [body removeObjectForKey:@"x_auth_password"];

         expect([body valueForKey:@"x_auth_username"]).to.equal(@"username");
         [body removeObjectForKey:@"x_auth_username"];

         expect([body allKeys]).to.haveCountOf(0);

         expect([query allKeys]).to.haveCountOf(0);
     }];
}

- (void)testLoginOAuth {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] loginOAuthWithSuccess:^{}
                                                    failure:^(NSError *error) {}];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/request_token");
         expect(request.HTTPMethod).to.equal(@"POST");
         expect([query allKeys]).to.haveCountOf(0);
         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
