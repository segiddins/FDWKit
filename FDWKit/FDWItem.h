//
//  FDWItem.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

/// Represents a single feed item in the FeedWrangler API

@interface FDWItem : NSObject

/// @name Properties

/// The item's feed item ID
@property (strong) NSString *feedItemID;

/// The date the item was published at
@property (strong) NSDate   *publishedAt;

/// The date the item was created in FeedWrangler at
@property (strong) NSDate   *createdAt;

/// Represents a particular version of a feed item, it will change if the contents of the item change. Similar to a hash key
@property (strong) NSString *versionKey;

/// The date the item was last updated
@property (strong) NSDate   *updatedAt;

/// The item's URL
@property (strong) NSURL    *url;

/// The item's title
@property (strong) NSString *title;

/// Whether the item is starred or not (@BOOL)
/// Setting the property to a different value will trigger a request to update the value on the server
@property (nonatomic, strong) NSNumber *starred;

/// Whether the item is read or not (@BOOL)
/// Setting the property to a different value will trigger a request to update the value on the server
@property (nonatomic, strong) NSNumber *read;

/// Whether the item has been sent to the user's read later service or not (@BOOL)
/// Setting the property to a different value will trigger a request to update the value on the server
@property (nonatomic, strong) NSNumber *readLater;

/// The body of the item, as an HTML string
@property (strong) NSString *body;

/// The item's author
@property (strong) NSString *author;

/// The ID of the item's parent feed
@property (strong) NSString *feedID;

/// The name of the item's parent feed
@property (strong) NSString *feedName;

/// @name Initialization

/// Creates an FDWItem object from the JSON representation that the API returns
/// @param dictionary The dictionary to create the item from
+ (instancetype)feedItemWithDictionary:(NSDictionary *)dictionary;

@end
