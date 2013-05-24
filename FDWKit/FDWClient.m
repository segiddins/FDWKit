#import "FDWClient.h"
#import "FDWUser.h"
#import "FDWFeed.h"

@interface FDWClient ()

@property (readwrite) FDWUser *authenticatedUser;
@property (readwrite) NSString *accessToken;

@property NSMutableArray *subscriptions;

@end

@implementation FDWClient

+ (NSURL *)APIBaseURL {
    static NSString *baseURL = @"https://feedwrangler.net/api/v2/";
    return [NSURL URLWithString:baseURL];
}

+ (instancetype)sharedClient {
    static FDWClient *sharedFDWClient;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedFDWClient = [[FDWClient alloc] initWithBaseURL:[self APIBaseURL]];
    });
    return sharedFDWClient;
}

#pragma mark -
#pragma mark Authentication

- (void)authenticateEmail:(NSString *)email password:(NSString *)password clientKey:(NSString *)clientKey completionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    // https://feedwrangler.net/developers/users#login
    NSString *requestString = [NSString stringWithFormat:@"users/authorize?email=%@&password=%@&client_key=%@", email, password, clientKey];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *authenticationOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        self.accessToken = JSON[@"access_token"];
        self.authenticatedUser = [FDWUser userWithDictionary:JSON[@"user"]];
        self.subscriptions = [self feedArrayFromDictionaryArray:JSON[@"feeds"]];
        completionHandler(YES, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, error);
    }];
    [self enqueueHTTPRequestOperation:authenticationOperation];
}

- (BOOL)isAuthenticated {
    return self.accessToken != nil;
}

- (void)logOut {
//    https://feedwrangler.net/developers/users#logout
    self.authenticatedUser = nil;
    self.subscriptions = nil;
    [self.operationQueue cancelAllOperations];
    
    NSString *requestString = [NSString stringWithFormat:@"users/logout?access_token=%@", self.accessToken];
    self.accessToken = nil;
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFHTTPRequestOperation *logoutOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self enqueueHTTPRequestOperation:logoutOperation];
}

#pragma mark -
#pragma mark Subscriptions

- (NSMutableArray *)feedArrayFromDictionaryArray:(NSArray *)array {
    NSMutableArray *feedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        [feedArray addObject:[FDWFeed feedWithDictionary:dict]];
    }
    return feedArray;
}

- (void)fetchCurrentSubscriptionsWithCompletionHandler:(void (^)(BOOL success, NSArray *subscriptions, NSError *error))completionHandler {
    if (self.subscriptions) {
        completionHandler(YES, self.subscriptions, nil);
        return;
    }
    
//    https://feedwrangler.net/developers/subscriptions#list
    NSString *requestString = [NSString stringWithFormat:@"subscriptions/list?access_token=%@", self.accessToken];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *listOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        self.subscriptions = [self feedArrayFromDictionaryArray:JSON[@"feeds"]];
        completionHandler(YES, self.subscriptions, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:listOperation];
}

- (void)subscribeToURL:(NSString *)url completionHandler:(void (^)(BOOL, NSError *))completionHandler {
//    https://feedwrangler.net/developers/subscriptions#add_feed
    NSString *requestString = [NSString stringWithFormat:@"subscriptions/add_feed?access_token=%@&feed_url=%@", self.accessToken, url];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *subscribeOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        self.subscriptions = nil;
        completionHandler(YES, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, error);
    }];
    [self enqueueHTTPRequestOperation:subscribeOperation];
}

- (void)unsubscribeFromFeed:(FDWFeed *)feed completionHandler:(void (^)(BOOL, NSError *))completionHandler {
    NSString *requestString = [NSString stringWithFormat:@"subscriptions/remove_feed?access_token=%@&feed_id=%@", self.accessToken, feed.feedID];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *unsubscribeOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        [self.subscriptions removeObject:feed];
        completionHandler(YES, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, error);
    }];
    [self enqueueHTTPRequestOperation:unsubscribeOperation];
}

#pragma mark -
#pragma mark Feed Item

@end