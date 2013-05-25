//
//  FDWStream.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/24/13.
//
//

/// Represents a FeedWrangler Stream (which is analogous to a smart folder)

@interface FDWStream : NSObject

/// @name Properties

/// The stream's ID
@property (strong) NSString *streamID;

/// The stream's title
@property (strong) NSString *title;

/// Whether the stream includes items from all feeds
///
/// @YES or @NO
@property (strong) NSNumber *allFeeds;

/// Whether the stream filters based on read status
///
/// - `@YES` if it only contains unread items
/// - `@NO` if it doesn't filter based on read status
@property (strong) NSNumber *onlyUnread;

/// The search term the stream filters on
///
/// Will be `nil` if the stream doesn't filter by a search term
@property (strong) NSString *searchTerm;

/// An array of `FDWFeed` objects that the stream contains
///
/// Will be `nil` if the stream doesn't filter based on feeds
@property (strong) NSArray  *feeds;

/// @name Convenience Methods

/// Destroys the smart stream
/// @note This method is a convenience on `-[FDWClient destroyStream:completionHandler:]`
- (void)destroy;

/// @name Initialization

/// Creates an FDWStream object from the JSON representation that the API returns
/// @param dictionary The dictionary to create the stream from
+ (instancetype)streamWithDictionary:(NSDictionary *)dictionary;

@end
