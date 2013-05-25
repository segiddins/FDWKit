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
    item->_feedItemID = dictionary[@"feed_item_id"];
    item->_publishedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"published_at"] floatValue]];
    item->_createdAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"created_at"] floatValue]];
    item->_versionKey = dictionary[@"version_key"];
    item->_updatedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"updated_at"] floatValue]];
    item->_url = dictionary[@"url"];
    item->_title = dictionary[@"title"];
    item->_starred = dictionary[@"starred"];
    item->_read = dictionary[@"read"];
    item->_readLater = dictionary[@"readLater"];
    item->_body = dictionary[@"body"];
    item->_author = dictionary[@"author"];
    item->_feedID = dictionary[@"feed_id"];
    item->_feedName = dictionary[@"feed_name"];
    return item;
}

- (void)setRead:(NSNumber *)read {
    if ([read isEqual:_read]) return;
    _read = read;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)read starred:(NSNumber *)nil readLater:(NSNumber *)nil completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {

    }];
}

- (void)setStarred:(NSNumber *)starred {
    if ([starred isEqual:_starred]) return;
    _starred = starred;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)starred readLater:(NSNumber *)nil completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {

    }];
}

- (void)setReadLater:(NSNumber *)readLater {
    if ([readLater isEqual:_readLater]) return;
    _readLater = readLater;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)nil readLater:(NSNumber *)readLater completionHandler:^(BOOL success, FDWItem *feedItem, NSError *error) {

    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%@, %@)", NSStringFromClass([self class]), self, self.title, self.author, self.publishedAt];
}

@end
