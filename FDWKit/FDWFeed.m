//
//  FDWFeed.m
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

#import "FDWFeed.h"

#import "FDWClient.h"

@implementation FDWFeed

+ (instancetype)feedWithDictionary:(NSDictionary *)dictionary {
    FDWFeed *feed = [[FDWFeed alloc] init];
    [feed updateWithDictionary:dictionary];
    return feed;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    _title = dictionary[@"title"];
    _feedID = dictionary[@"feed_id"];
    _feedURL = dictionary[@"feed_url"] != [NSNull null] ? [NSURL URLWithString:dictionary[@"feed_url"]] : nil;
    _siteURL = dictionary[@"site_url"] != [NSNull null] ? [NSURL URLWithString:dictionary[@"site_url"]] : nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%@, %@)", NSStringFromClass([self class]), self, self.title, self.siteURL, self.feedURL];
}

- (void)unsubscribe {
    [[FDWClient sharedClient] unsubscribeFromFeed:self completionHandler:^(BOOL success, NSError *error) {

    }];
}

@end
