#import "FDWClient.h"
#import "FDWUser.h"
#import "FDWFeed.h"
#import "FDWItem.h"
#import "FDWStream.h"

#import "NSNumber+BoolToString.h"

@interface FDWClient ()

@property (readwrite) FDWUser *authenticatedUser;
@property (readwrite) NSString *accessToken;

@property NSMutableArray *subscriptions;

@property NSMutableDictionary *feedItems;

@end

@implementation FDWClient

+ (NSURL *)APIBaseURL {
    static NSString *baseURL = @"https://feedwrangler.net/api/v2/";
    return [NSURL URLWithString:baseURL];
}

+ (instancetype)sharedClient {
    return [self sharedClientWithAccessToken:nil];
}

+ (instancetype)sharedClientWithAccessToken:(NSString *)accessToken {
    static FDWClient *sharedFDWClient;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedFDWClient = [[self alloc] initWithAccessToken:accessToken baseURL:[self APIBaseURL]];
    });
    return sharedFDWClient;
}

- (id)initWithAccessToken:(NSString *)accessToken baseURL:(NSURL *)baseURL {
    if (self = [self initWithBaseURL:baseURL]) {
        self.accessToken = accessToken;
    }
    return self;
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

- (void)fetchFeedItemsWithRead:(NSNumber *)read starred:(NSNumber *)starred feedID:(NSString *)feedID createdSince:(NSDate *)createdSince updatedSince:(NSDate *)updatedSince limit:(NSNumber *)limit offset:(NSNumber *)offset completionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"feed_items/list?access_token=%@", self.accessToken];
    if (read) [requestString appendFormat:@"&read=%@", [read fdw_StringValueOfBool]];
    if (starred) [requestString appendFormat:@"&starred=%@", [starred fdw_StringValueOfBool]];
    if (feedID) [requestString appendFormat:@"&feed_id=%@", feedID];
    if (createdSince) [requestString appendFormat:@"&created_since=%d", (NSInteger)[createdSince timeIntervalSince1970]];
    if (updatedSince) [requestString appendFormat:@"&updated_since=%d", (NSInteger)[updatedSince timeIntervalSince1970]];
    if (limit) [requestString appendFormat:@"&limit=%@", limit];
    if (offset) [requestString appendFormat:@"&offset=%@", offset];

    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *fetchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        completionHandler(YES, [self feedItemArrayFromDictionaryArray:JSON[@"feed_items"]], nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:fetchOperation];
}

- (void)fetchFeedItemsWithRead:(NSNumber *)read starred:(NSNumber *)starred feed:(FDWFeed *)feed createdSince:(NSDate *)createdSince updatedSince:(NSDate *)updatedSince limit:(NSNumber *)limit offset:(NSNumber *)offset completionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    [self fetchFeedItemsWithRead:read starred:starred feedID:feed.feedID createdSince:createdSince updatedSince:updatedSince limit:limit offset:offset completionHandler:completionHandler];
}

- (void)searchForFeedItemsWithTerm:(NSString *)searchTerm limit:(NSNumber *)limit offset:(NSString *)offset completionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"feed_items/search?access_token=%@&search_term=%@", self.accessToken, searchTerm];
    if (limit) [requestString appendFormat:@"&limit=%@", limit];
    if (offset) [requestString appendFormat:@"&offset=%@", offset];

    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *searchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        completionHandler(YES, [self feedItemArrayFromDictionaryArray:JSON[@"feed_items"]], nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:searchOperation];
}

- (void)updateFeedItem:(FDWItem *)feedItem withRead:(NSNumber *)read starred:(NSNumber *)starred readLater:(NSNumber *)readLater completionHandler:(void (^)(BOOL, FDWItem *, NSError *))completionHandler {
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"feed_items/update?access_token=%@&feed_item_id=%@", self.accessToken, feedItem.feedItemID];
    if (read) [requestString appendFormat:@"&read=%@", [read fdw_StringValueOfBool]];
    if (starred) [requestString appendFormat:@"&starred=%@", [starred fdw_StringValueOfBool]];
    if (readLater) [requestString appendFormat:@"&read_later=%@", [readLater fdw_StringValueOfBool]];

    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *updateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }

        NSDictionary *feedDict = JSON[@"feed_item"];
        [feedItem updateWithDictionary:feedDict];
        completionHandler(YES, feedItem, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:updateOperation];
}

- (void)markFeedItemsAsRead:(NSArray *)feedItems feed:(FDWFeed *)feed createdBefore:(NSDate *)createdBefore completionHandler:(void (^)(BOOL, NSError *))completionHandler {
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"feed_items/mark_all_read?access_token=%@", self.accessToken];
    if (feed) [requestString appendFormat:@"&feed_id=%@", feed.feedID];
    if (createdBefore) [requestString appendFormat:@"&created_on_before=%d", (NSInteger)[createdBefore timeIntervalSince1970]];
    if (feedItems) {
        [requestString appendString:@"&feed_item_ids="];
        for (NSInteger i = 0; i < feedItems.count; i++) {
            [requestString appendFormat:@"%@,", [feedItems[i] feedItemID]];
        }
        [requestString deleteCharactersInRange:NSMakeRange(requestString.length - 1, 1)];
    }

    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *updateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }

        for (NSDictionary *item in JSON[@"feed_items"])
            [self.feedItems[item[@"feed_item_id"]] setRead:item[@"read"]];

        completionHandler(YES, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, error);
    }];
    [self enqueueHTTPRequestOperation:updateOperation];
}

- (NSMutableArray *)feedItemArrayFromDictionaryArray:(NSArray *)array {
    NSMutableArray *feedItemArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        FDWItem *item = [FDWItem feedItemWithDictionary:dict];
        [feedItemArray addObject:item];
        self.feedItems[item.feedItemID] = item;
    }
    return feedItemArray;
}

#pragma mark -
#pragma mark Streams

- (void)fetchCurrentStreamsWithCompletionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    NSString *requestString = [NSString stringWithFormat:@"streams/list?access_token=%@", self.accessToken];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *listOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        completionHandler(YES, [self streamArrayFromDictionaryArray:JSON[@"streams"]], nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:listOperation];
}

- (void)fetchStreamItems:(FDWStream *)stream limit:(NSNumber *)limit offset:(NSNumber *)offset completionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"streams/stream_items?access_token=%@&stream_id=%@", self.accessToken, stream.streamID];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *listOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, nil, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        completionHandler(YES, [self feedItemArrayFromDictionaryArray:JSON[@"feed_items"]], nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, nil, error);
    }];
    [self enqueueHTTPRequestOperation:listOperation];
}

- (void)destroyStream:(FDWStream *)stream completionHandler:(void (^)(BOOL, NSError *))completionHandler {
    NSString *requestString = [NSString stringWithFormat:@"streams/destroy?access_token=%@&stream_id=%@", self.accessToken, stream.streamID];
    NSURL *requestURL = [NSURL URLWithString:requestString relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    AFJSONRequestOperation *destroyOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *result = JSON[@"result"];
        if (![result isEqualToString:@"success"]) {
            completionHandler(NO, [NSError errorWithDomain:JSON[@"error"] code:response.statusCode userInfo:nil]);
            return;
        }
        completionHandler(YES, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionHandler(NO, error);
    }];
    [self enqueueHTTPRequestOperation:destroyOperation];
}

- (NSMutableArray *)streamArrayFromDictionaryArray:(NSArray *)array {
    NSMutableArray *streamArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        [streamArray addObject:[FDWStream streamWithDictionary:dict]];
    }
    return streamArray;
}

@end