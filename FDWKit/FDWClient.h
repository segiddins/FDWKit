#import "AFNetworking.h"

@class FDWUser, FDWFeed, FDWItem, FDWStream;

@interface FDWClient : AFHTTPClient

+ (NSURL *)APIBaseURL; // defaults to "https://feedwrangler.net/api/v2/"
+ (instancetype)sharedClient;
+ (instancetype)sharedClientWithAccessToken:(NSString *)accessToken; // Seeds the shared client with an access token

- (id)initWithAccessToken:(NSString *)accessToken baseURL:(NSURL *)baseURL;

#pragma mark -
#pragma mark Authentication

/**---------------------------------------------------------------------------------------
 * @name Authentication
 *  ---------------------------------------------------------------------------------------
 */

/** Authenticates a FeedWrangler user, must be called (and completed) before any other requests can be made
 
Authenticates the user, setting up the client with a valid access key so that all the other requests can succeed

As a side effect, this method will cache the user's list of subscriptions
 
 @param email The user's email
 @param password The user's password
 @param clientKey Your FeedWrangler client key
 @param completionHandler Completion handler that fires after the request finishes
*/

- (void)authenticateEmail:(NSString *)email 
                 password:(NSString *)password 
                clientKey:(NSString *)clientKey 
        completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

/// The access token that the FeedWrangler API requires for all calls (outside of authenticate)
/// This property will be set upon authentication, or upon initialization (via sharedClientWithAccessToken: or initWithAccessToken:)
@property (readonly, strong) NSString *accessToken;

/// Returns true if and only if the client has an access token and can make calls to the API
- (BOOL)isAuthenticated;

/// The client's authenticatd user, or nil
@property (readonly, strong) FDWUser *authenticatedUser;

/// Logs the user out of the api, invalidating the access token, canceling all pending operations, and flushing the cache
- (void)logOut;

#pragma mark -
#pragma mark Subscriptions

/// @name Subscriptions

- (void)fetchCurrentSubscriptionsWithCompletionHandler:(void (^)(BOOL success, NSArray *subscriptions, NSError *error))completionHandler;

- (void)subscribeToURL:(NSString *)url 
     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)unsubscribeFromFeed:(FDWFeed *)feed 
          completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

#pragma mark -
#pragma mark Feed Items

/// @name Feed Items

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


/// @name Streams

- (void)fetchCurrentStreamsWithCompletionHandler:(void (^)(BOOL success, NSArray *streams, NSError *error))completionHandler;

- (void)fetchStreamItems:(FDWStream *)stream
                   limit:(NSNumber *)limit
                  offset:(NSNumber *)offset
       completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

- (void)destroyStream:(FDWStream *)stream
    completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end
