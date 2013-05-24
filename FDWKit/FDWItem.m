//
//  FDWItem.m
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

#import "FDWItem.h"
#import "FDWClient.h"

@implementation FDWItem

+ (instancetype)feedItemWithDictionary:(NSDictionary *)dictionary {
    FDWItem *item = [[self alloc] init];
    item.feedItemID = dictionary[@"feed_item_id"];
    item.publishedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"published_at"] floatValue]];
    item.createdAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"created_at"] floatValue]];
    item.versionKey = dictionary[@"version_key"];
    item.updatedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"updated_at"] floatValue]];
    item.url = dictionary[@"url"];
    item.title = dictionary[@"title"];
    item.starred = dictionary[@"starred"];
    item.read = dictionary[@"read"];
    item.readLater = dictionary[@"readLater"];
    item.body = dictionary[@"body"];
    item.author = dictionary[@"author"];
    item.feedID = dictionary[@"feed_id"];
    item.feedName = dictionary[@"feed_name"];
    return item;
}

- (void)setRead:(NSNumber *)read {
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)read starred:(NSNumber *)nil readLater:(NSNumber *)nil completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {
        
    }];
}

- (void)setStarred:(NSNumber *)starred {
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)starred readLater:(NSNumber *)nil completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {
        
    }];
}

- (void)setReadLater:(NSNumber *)readLater {
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)nil readLater:(NSNumber *)readLater completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {
        
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%@, %@)", NSStringFromClass([self class]), self, self.title, self.author, self.publishedAt];
}

@end
