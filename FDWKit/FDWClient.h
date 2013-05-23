#import "AFNetworking.h"

@interface FDWClient : AFHTTPClient

+ (NSURL *)APIBaseURL; // defaults to "https://feedwrangler.net/api/v2/"
+ (instancetype)sharedClient;

@property (readonly, strong) FDWUser *authenticatedUser;

#pragma mark -
#pragma mark Authentication

- (void)authenticateEmail:(NSString *)email password:(NSString *)password clientKey:(NSString *)clientKey completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@property (readonly, strong) NSString *accessToken;

- (BOOL)isAuthenticated;
- (void)logOut;

@end