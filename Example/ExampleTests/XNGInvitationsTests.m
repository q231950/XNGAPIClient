#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>

@interface XNGInvitationsTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGInvitationsTests

- (void)setUp {
    [super setUp];

    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testPostSendInvitations {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] postSendInvitationsToEmails:@"invite@someone.com"
                                                          message:@"inviting text"
                                                          success:nil
                                                          failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/invite");
         expect(request.HTTPMethod).to.equal(@"POST");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body valueForKey:@"message"]).to.equal(@"inviting%20text");
         [body removeObjectForKey:@"message"];
         expect([body valueForKey:@"user_fields"]).to.equal(@"id");
         [body removeObjectForKey:@"user_fields"];
         expect([body valueForKey:@"to_emails"]).to.equal(@"invite%40someone.com");
         [body removeObjectForKey:@"to_emails"];

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
