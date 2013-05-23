#import "FDWClient.h"

@interface FDWClient ()

@property (readwrite) FDWUser *authenticatedUser;
@property (readwrite) NSString *accessToken;

@end

@implementation FDWClient

+ (NSURL *)APIBaseURL {
    static NSURL *baseURL = [NSURL URLWithString:@"https://feedwrangler.net/api/v2/"];
    return baseURL;
}

+ (instancetype)sharedClient {
    static FDWClient *sharedFDWClient;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedFDWClient = [[FDWClient alloc] init];
        sharedFDWClient.baseURL = [self baseURL];
    });
    return sharedFDWClient;
}

#pragma mark -
#pragma mark Authentication

- (void)authenticateEmail:(NSString *)email password:(NSString *)password clientKey:(NSString *)clientKey completionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    // https://feedwrangler.net/developers/users#login
    NSURL *requestURL = [self.baseURL URLByAppendingPathComponent:@"users/authorize"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *authenticationOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:(void ( ^ ) ( NSURLRequest *request , NSHTTPURLResponse *response , id JSON )) {
        completionHandler(YES, nil);
    } failure:(void ( ^ ) ( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON )) {
        completionHandler(NO, error);
    }];
}

- (BOOL)isAuthenticated {
    return self.accessToken != nil;
}

- (void)logOut {
    self.accessToken = nil;
    self.authenticatedUser = nil;
}


@end