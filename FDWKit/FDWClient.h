#import "AFNetworking.h"

@class FDWUser, FDWFeed, FDWItem, FDWStream;

/// Handles interaction with the FeedWrangler API, as documented at https://feedwrangler.net/developers
/// ## Multi-User Support
/// To support multiple users, all you have to do is use one distinct FDWClient per user

@interface FDWClient : AFHTTPClient

/// @name API Defaults

/// The API's base URL
/// Defaults to "https://feedwrangler.net/api/v2/"
/// @return The API's base URL
+ (NSURL *)APIBaseURL;

/// @name Initialization

/// Returns the singleton shared client, with no default accessToken set
/// @return The shared client
+ (instancetype)sharedClient;

/// Returns the singleton shared client, with the access token set to `accessToken`
/// @param accessToken The initial access token
/// @return The shared client
+ (instancetype)sharedClientWithAccessToken:(NSString *)accessToken; // Seeds the shared client with an access token

/// Initializes a client with the given baseURL and access token
/// @note This is the suggested way to implement multi-user support (by `init`ing multiple clients, one per user - can also be done with any other `init` method)
/// @param accessToken The initial access token for the client
/// @param baseURL The baseURL for the client (should be set to `[FDWClient APIBaseURL]` unless you have a reason not to)
/// @return A client with the given access token and base url
- (id)initWithAccessToken:(NSString *)accessToken baseURL:(NSURL *)baseURL;

#pragma mark -
#pragma mark Authentication

/**---------------------------------------------------------------------------------------
 * @name Authentication
 *  ---------------------------------------------------------------------------------------
 */

/** Authenticates a FeedWrangler user, must be called (and completed) before any other requests can be made

 Authenticates the user, setting up the client with a valid access key so that all the other requests can succeed
 
 Documentation: https://feedwrangler.net/developers/users#login
 
 @note As a side effect, this method will cache the user's list of subscriptions
 
 @param email The user's email
 @param password The user's password
 @param clientKey Your FeedWrangler client key
 
 Go to https://feedwrangler.net/developers/clients to manake your client keys
 @param completionHandler Completion handler that fires after the request finishes
 @note This method is currently the only way to create an FDWUser object
 */

- (void)authenticateEmail:(NSString *)email
                 password:(NSString *)password
                clientKey:(NSString *)clientKey
        completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

/// The access token that the FeedWrangler API requires for all calls (outside of authenticate)
/// This property will be set upon authentication, or upon initialization (via sharedClientWithAccessToken: or initWithAccessToken:baseURL:)
@property (readonly, strong) NSString *accessToken;

/// Returns true if and only if the client has an access token and can make calls to the API
- (BOOL)isAuthenticated;

/// The client's authenticatd user, or nil
@property (readonly, strong) FDWUser *authenticatedUser;

/// Logs the user out of the API, invalidating the access token, canceling all pending operations, and flushing the cache
///
/// Documentation: https://feedwrangler.net/developers/users#logout
- (void)logOut;

#pragma mark -
#pragma mark Subscriptions

/// @name Subscriptions

/// Fetches the user's current list of subscriptions
///
/// Documentation: https://feedwrangler.net/developers/subscriptions#list
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWFeed objects, and an error
- (void)fetchCurrentSubscriptionsWithCompletionHandler:(void (^)(BOOL success, NSArray *subscriptions, NSError *error))completionHandler;

/// Subscribes the user to a feed
///
/// Documentation: https://feedwrangler.net/developers/subscriptions#add_feed
/// @param url The URL to subscribe to
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes two arguments: the request's success and an error
- (void)subscribeToURL:(NSString *)url
     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

/// Unsubscribes the user from a feed
///
/// Documentation: https://feedwrangler.net/developers/subscriptions#remove_feed
/// @param feed The feed to unsubscribe from
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes two arguments: the request's success and an error
- (void)unsubscribeFromFeed:(FDWFeed *)feed
          completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

#pragma mark -
#pragma mark Feed Items

/// @name Feed Items

/// Fetches feed items based on the passed criterion
///
/// Documentation: https://feedwrangler.net/developers/feed_items#list
/// @param read filter based on read status (`@YES` or `@NO`), or dont filter if `nil`
/// @param starred filter based on starred status (`@YES` or `@NO`), or dont filter if `nil`
/// @param feedID the feed ID to restrict request to, or `nil` if all feeds
/// @note this method is the same as fetchFeedItemsWithRead:starred:feed:createdSince:updatedSince:limit:offset:completionHandler, except it takes a raw feed id instead of an FDWFeed object
/// @param createdSince the oldest created date to fetch from, or no limit if `nil`
/// @param updatedSince the oldest updated date to fetch from, or no limit if `nil`
/// @param limit Maximum number of items to return, or API max if `nil`
/// @param offset Number of items to skip before returning results, or none if `nil`
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWItem objects, and an error
- (void)fetchFeedItemsWithRead:(NSNumber *)read
                       starred:(NSNumber *)starred
                        feedID:(NSString *)feedID
                  createdSince:(NSDate *)createdSince
                  updatedSince:(NSDate *)updatedSince
                         limit:(NSNumber *)limit
                        offset:(NSNumber *)offset
             completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

/// Fetches feed items based on the passed criterion
///
/// Documentation: https://feedwrangler.net/developers/feed_items#list
/// @param read filter based on read status (`@YES` or `@NO`), or dont filter if `nil`
/// @param starred filter based on starred status (`@YES` or `@NO`), or dont filter if `nil`
/// @param feed the feed to restrict request to, or `nil` if all feeds
/// @note this method is the same as fetchFeedItemsWithRead:starred:feedID:createdSince:updatedSince:limit:offset:completionHandler, except it takes an FDWFeed object instead of a raw feed id
/// @param createdSince the oldest created date to fetch from, or no limit if `nil`
/// @param updatedSince the oldest updated date to fetch from, or no limit if `nil`
/// @param limit Maximum number of items to return, or API max if `nil`
/// @param offset Number of items to skip before returning results, or none if `nil`
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWItem objects, and an error
- (void)fetchFeedItemsWithRead:(NSNumber *)read
                       starred:(NSNumber *)starred
                          feed:(FDWFeed *)feed
                  createdSince:(NSDate *)createdSince
                  updatedSince:(NSDate *)updatedSince
                         limit:(NSNumber *)limit
                        offset:(NSNumber *)offset
             completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

/// Searches for items matching a search term
///
/// Documentation: https://feedwrangler.net/developers/feed_items#search
/// @param searchTerm String to match for the search
/// @param limit Maximum number of items to return, or API max if `nil`
/// @param offset Number of items to skip before returning results, or none if `nil`
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWItem objects, and an error
- (void)searchForFeedItemsWithTerm:(NSString *)searchTerm
                             limit:(NSNumber *)limit
                            offset:(NSString *)offset
                 completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

/// Updates a feed item
///
/// Documentation: https://feedwrangler.net/developers/feed_items#update
/// @param feedItem The feed item to update
/// @param read Changes the read status to @YES or @NO, or pass `nil` if no change
/// @param starred Changes the starred status to @YES or @NO, or pass `nil` if no change
/// @param readLater Changes the read later status to @YES or @NO, or pass `nil` if no change
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWItem objects, and an error
/// @note This method only changes the feed item upon success
- (void)updateFeedItem:(FDWItem *)feedItem
              withRead:(NSNumber *)read
               starred:(NSNumber *)starred
             readLater:(NSNumber *)readLater
     completionHandler:(void (^)(BOOL success, FDWItem *feedItem, NSError *error))completionHandler;

/// Marks an array of feed items as read
///
/// Documentation: https://feedwrangler.net/developers/feed_items#mark_all_read
/// @param feedItems Array of `FDWItem`s to mark as read, or `nil` if no limit
/// @param feed Only update items within a particular feed, or `nil` if no limit
/// @param createdBefore Limit the application to items created on or before, or `nil` if no limit
///
/// It is recommended that you pass in a `createdBefore` date of the last time you fetched the specific goup of items from the server
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes two arguments: the request's success and an error
/// @note This method only marks the items as read upon success
- (void)markFeedItemsAsRead:(NSArray *)feedItems
                       feed:(FDWFeed *)feed
              createdBefore:(NSDate *)createdBefore
          completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

#pragma mark -
#pragma mark Streams


/// @name Streams

/// Fetch the user's current smart streams
///
/// Documentation: https://feedwrangler.net/developers/streams#list
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWStream objects, and an error
- (void)fetchCurrentStreamsWithCompletionHandler:(void (^)(BOOL success, NSArray *streams, NSError *error))completionHandler;

/// Fetch a smart stream's items
///
/// Documentation: https://feedwrangler.net/developers/streams#stream_items
/// @param stream The stream whose items are to be fetched
/// @param limit Maximum number of items to return, or `nil` for API default
/// @param offset Number of items to skip before returning results, or `nil` for no offset
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes three arguments: the request's success, an NSArray of FDWItem objects, and an error
- (void)fetchStreamItems:(FDWStream *)stream
                   limit:(NSNumber *)limit
                  offset:(NSNumber *)offset
       completionHandler:(void (^)(BOOL success, NSArray *feedItems, NSError *error))completionHandler;

/// Destroys a smart stream
///
/// Documentation: https://feedwrangler.net/developers/streams#destroy
/// @param stream The smart stream to destroy
/// @param completionHandler A block object to be executed when the request finishes. The block has no return value and takes two arguments: the request's success and an error
- (void)destroyStream:(FDWStream *)stream
    completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end
