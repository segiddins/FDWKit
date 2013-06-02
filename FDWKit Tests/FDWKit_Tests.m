//
//  FDWKit_Tests.m
//  FDWKit Tests
//
//  Created by Samuel E. Giddins on 6/1/13.
//
//

#import "FDWKit_Tests.h"
#import <FDWKit.h>

@interface FDWKit_Tests ()

@property FDWClient *sharedClient;

@end

@implementation FDWKit_Tests

- (void)setUp
{
    [super setUp];
    _sharedClient = [FDWClient sharedClient];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    STAssertNotNil(@"", @"Unit tests are not implemented yet in FDWKit Tests");
}

- (void)testBaseURL {
    STAssertEqualObjects(self.sharedClient.baseURL, [NSURL URLWithString:@"https://feedwrangler.net/api/v2/"], @"");
}

@end
