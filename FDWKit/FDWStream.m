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
    stream.streamID = dictionary[@"stream_id"];
    stream.title = dictionary[@"title"];
    stream.allFeeds = dictionary[@"all_feeds"];
    stream.onlyUnread = dictionary[@"only_unread"];
    stream.searchTerm = dictionary[@"search_term"];
    stream.feeds = [[FDWClient sharedClient] feedArrayFromDictionaryArray:dictionary[@"feeds"]];
    return stream;
}

- (void)destroy {
    [[FDWClient sharedClient] destroyStream:self
                          completionHandler:^(BOOL success, NSError *error) {
                              
                          }];
}

@end
