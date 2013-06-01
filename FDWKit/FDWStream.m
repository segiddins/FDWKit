//
//  FDWStream.m
//  Pods
//
//  Created by Samuel E. Giddins on 5/24/13.
//
//

#import "FDWStream.h"

@interface FDWClient ()

- (NSMutableArray *)feedArrayFromDictionaryArray:(NSArray *)array;

@end

@implementation FDWStream

+ (instancetype)streamWithDictionary:(NSDictionary *)dictionary {
    FDWStream *stream = [[self alloc] init];
    [stream updateWithDictionary:dictionary];
    return stream;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    _streamID = dictionary[@"stream_id"];
    _title = dictionary[@"title"];
    _allFeeds = dictionary[@"all_feeds"];
    _onlyUnread = dictionary[@"only_unread"];
    _searchTerm = dictionary[@"search_term"];
    _feeds = [[FDWClient sharedClient] feedArrayFromDictionaryArray:dictionary[@"feeds"]];
}

- (void)destroy {
    [[FDWClient sharedClient] destroyStream:self
                          completionHandler:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@", NSStringFromClass([self class]), self, self.title];
}

@end
