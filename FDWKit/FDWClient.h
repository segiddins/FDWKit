#import "AFNetworking.h"

@class FDWUser, FDWFeed, FDWItem, FDWStream;

@interface FDWClient : AFHTTPClient

+ (NSURL *)APIBaseURL; // defaults to "https://feedwrangler.net/api/v2/"
+ (instancetype)sharedClient;

@property (readonly, strong) FDWUser *authenticatedUser;

#pragma mark -
#pragma mark Authentication

/** Authenticates a FeedWrangler user, must be called (and completed) before any other requests can be made
 
Authenticates the user, setting up the client with a valid access key so that all the other requests can succeed
 
 @param email The user's email
 @param password The user's password
 @param clientKey Your FeedWrangler client key
 @param completionHandler Completion handler that fires after the request finishes
*/

- (void)authenticateEmail:(NSString *)email 
                 password:(NSString *)password 
                clientKey:(NSString *)clientKey 
        completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@property (readonly, strong) NSString *accessToken;

- (BOOL)isAuthenticated;
- (void)logOut;

#pragma mark -
#pragma mark Subscriptions

- (void)fetchCurrentSubscriptionsWithCompletionHandler:(void (^)(BOOL success, NSArray *subscriptions, NSError *error))completionHandler;

- (void)subscribeToURL:(NSString *)url 
     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)unsubscribeFromFeed:(FDWFeed *)feed 
          completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

#pragma mark -
#pragma mark Feed Items

- (void)fetchFeedItemsWithRead:(NSNumber *)read 
                       starred:(NSNumber *)starred 
                        feedID:(NSString *)feedID 
                  createdSince:(NSDate *)createdSince 
                  updatedSince:(NSDate *)updatedSince 
                         limit:(NSNumber *)limit 
                        offset:(NSNumber *)offset 
             completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

- (void)fetchFeedItemsWithRead:(NSNumber *)read 
                       starred:(NSNumber *)starred 
                          feed:(FDWFeed *)feed 
                  createdSince:(NSDate *)createdSince 
                  updatedSince:(NSDate *)updatedSince 
                         limit:(NSNumber *)limit 
                        offset:(NSNumber *)offset 
             completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

- (void)searchForFeedItemsWithTerm:(NSString *)searchTerm 
                             limit:(NSNumber *)limit 
                            offset:(NSString *)offset 
                 completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

- (void)updateFeedItem:(FDWItem *)feedItem 
              withRead:(NSNumber *)read 
               starred:(NSNumber *)starred
             readLater:(NSNumber *)readLater
     completionHandler:(void (^)(BOOL success, FDWItem *feedItem, NSError *error))completionHandler;

- (void)markFeedItemsAsRead:(NSArray *)feedItems 
                       feed:(FDWFeed *)feed
              createdBefore:(NSDate *)createdBefore
          completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

#pragma mark -
#pragma mark Streams

- (void)fetchCurrentStreamsWithCompletionHandler:(void (^)(BOOL success, NSArray *streams, NSError *error))completionHandler;

- (void)fetchStreamItems:(FDWStream *)stream
                   limit:(NSNumber *)limit
                  offset:(NSNumber *)offset
       completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

- (void)destroyStream:(FDWStream *)stream
    completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end
