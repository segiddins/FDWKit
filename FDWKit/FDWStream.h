//
//  FDWStream.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/24/13.
//
//

@interface FDWStream : NSObject

@property (strong) NSString *streamID;
@property (strong) NSString *title;
@property (strong) NSNumber *allFeeds;
@property (strong) NSNumber *onlyUnread;
@property (strong) NSString *searchTerm;
@property (strong) NSArray  *feeds;

+ (instancetype)streamWithDictionary:(NSDictionary *)dictionary;

@end
