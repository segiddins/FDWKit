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
    feed.title = dictionary[@"title"];
    feed.feedID = dictionary[@"feed_id"];
    feed.feedURL = dictionary[@"feed_url"];
    feed.siteURL = dictionary[@"site_url"];
    return feed;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%@, %@)", NSStringFromClass([self class]), self, self.title, self.siteURL, self.feedURL];
}

- (void)unsubscribe {
    [[FDWClient sharedClient] unsubscribeFromFeed:self completionHandler:^(BOOL success, NSError *error) {
        
    }];
}

@end
