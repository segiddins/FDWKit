//
//  FDWFeed.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

/// Represents a feed in the FeedWrangler API

@interface FDWFeed : NSObject

/// @name Properties

/// The feed's feedID
@property (strong) NSString *feedID;

/// The feed's title
@property (strong) NSString *title;

/// The feed's URL
@property (strong) NSURL    *feedURL;

/// The feed's site URL
@property (strong) NSURL    *siteURL;

/// @name Convenience Methods

/// Unsubscribes the user from the feed
/// @note This method is a convenience on -[FDWClient unsubscribeFromFeed:completionHandler:]
- (void)unsubscribe;

/// @name Initialization

/// Creates an FDWFeed object from the JSON representation that the API returns
/// @param dictionary The dictionary to create the feed from
+ (instancetype)feedWithDictionary:(NSDictionary *)dictionary;

@end
