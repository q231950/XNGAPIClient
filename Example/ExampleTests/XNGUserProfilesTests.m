#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>

@interface XNGUserProfilesTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGUserProfilesTests

- (void)setUp {
    [super setUp];

    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testGetUserWithParameters {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getUserWithID:@"1"
                                         userFields:@"display_name"
                                            success:nil
                                            failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/1");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testSearchForUserByEmail {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getSearchForUsersByEmail:@"blala@someone.com,blala2@someone.com"
                                                  hashFunction:@"MD5" userFields:@"display_name"
                                                       success:nil
                                                       failure:nil];
     }
              withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/find_by_emails");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];
         expect([query valueForKey:@"hash_function"]).to.equal(@"MD5");
         [query removeObjectForKey:@"hash_function"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];
         expect([query valueForKey:@"emails"]).to.equal(@"blala%40someone.com%2Cblala2%40someone.com");
         [query removeObjectForKey:@"emails"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetUserLegalInformation {
    [self.testHelper executeCall:^{
        [[XNGAPIClient sharedClient] getLegalInformationWithID:@"1234"
                                                       success:nil
                                                       failure:nil];
    } withExpectations:^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
        expect(request.URL.host).to.equal(@"api.xing.com");
        expect(request.URL.path).to.equal(@"/v1/users/1234/legal_information");
        expect(request.HTTPMethod).to.equal(@"GET");

        [self.testHelper removeOAuthParametersInQueryDict:query];
        expect([query allKeys]).to.haveCountOf(0);
        expect([body allKeys]).to.haveCountOf(0);
    }];
}

@end
