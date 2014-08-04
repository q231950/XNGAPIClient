#import <XCTest/XCTest.h>
#import "XNGTestHelper.h"
#import <XNGAPIClient/XNGAPI.h>

@interface XNGGeoLocationsTests : XCTestCase

@property (nonatomic) XNGTestHelper *testHelper;

@end

@implementation XNGGeoLocationsTests

- (void)setUp {
    [super setUp];

    self.testHelper = [[XNGTestHelper alloc] init];
    [self.testHelper setup];
}

- (void)tearDown {
    [super tearDown];
    [self.testHelper tearDown];
}

- (void)testPutUpdateGeoLocation {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] putUpdateGeoLocationForUserID:@"1"
                                                           accuracy:0.5
                                                           latitude:1.5
                                                          longitude:2.5
                                                                ttl:0
                                                            success:nil
                                                            failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/1/geo_location");
         expect(request.HTTPMethod).to.equal(@"PUT");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"accuracy"]).to.equal(@"0.500000");
         [query removeObjectForKey:@"accuracy"];
         expect([query valueForKey:@"latitude"]).to.equal(@"1.500000");
         [query removeObjectForKey:@"latitude"];
         expect([query valueForKey:@"longitude"]).to.equal(@"2.500000");
         [query removeObjectForKey:@"longitude"];
         expect([query valueForKey:@"ttl"]).to.equal(@"0");
         [query removeObjectForKey:@"ttl"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

- (void)testGetNearbyUsers {
    [self.testHelper executeCall:
     ^{
         [[XNGAPIClient sharedClient] getNearbyUsersWithAge:100
                                                     radius:400
                                                 userFields:@"display_name"
                                                    success:nil
                                                    failure:nil];
     }
               withExpectations:
     ^(NSURLRequest *request, NSMutableDictionary *query, NSMutableDictionary *body) {
         expect(request.URL.host).to.equal(@"api.xing.com");
         expect(request.URL.path).to.equal(@"/v1/users/me/nearby_users");
         expect(request.HTTPMethod).to.equal(@"GET");

         [self.testHelper removeOAuthParametersInQueryDict:query];

         expect([query valueForKey:@"age"]).to.equal(@"100");
         [query removeObjectForKey:@"age"];
         expect([query valueForKey:@"radius"]).to.equal(@"400");
         [query removeObjectForKey:@"radius"];
         expect([query valueForKey:@"user_fields"]).to.equal(@"display_name");
         [query removeObjectForKey:@"user_fields"];

         expect([query allKeys]).to.haveCountOf(0);

         expect([body allKeys]).to.haveCountOf(0);
     }];
}

@end
