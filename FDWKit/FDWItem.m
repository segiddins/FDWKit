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
    [item updateWithDictionary:dictionary];
    return item;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    if (dictionary[@"feed_item_id"]) _feedItemID = dictionary[@"feed_item_id"];
    if (dictionary[@"published_at"]) _publishedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"published_at"] floatValue]];
    if (dictionary[@"created_at"]) _createdAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"created_at"] floatValue]];
    if (dictionary[@"version_key"]) _versionKey = dictionary[@"version_key"];
    if (dictionary[@"updated_at"]) _updatedAt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"updated_at"] floatValue]];
    if (dictionary[@"url"]) _url = dictionary[@"url"] != [NSNull null] ? [NSURL URLWithString:dictionary[@"url"]] : nil;
    if (dictionary[@"title"]) _title = dictionary[@"title"];
    if (dictionary[@"starred"]) _starred = dictionary[@"starred"];
    if (dictionary[@"read"]) _read = dictionary[@"read"];
    if (dictionary[@"readLater"]) _readLater = dictionary[@"readLater"];
    if (dictionary[@"body"]) _body = dictionary[@"body"];
    if (dictionary[@"author"]) _author = dictionary[@"author"];
    if (dictionary[@"feed_id"]) _feedID = dictionary[@"feed_id"];
    if (dictionary[@"feed_name"]) _feedName = dictionary[@"feed_name"];
}

- (void)setRead:(NSNumber *)read {
    if ([read isEqual:_read]) return;
    _read = read;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)read starred:(NSNumber *)nil readLater:(NSNumber *)nil completionHandler:nil];
}

- (void)setStarred:(NSNumber *)starred {
    if ([starred isEqual:_starred]) return;
    _starred = starred;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)starred readLater:(NSNumber *)nil completionHandler:nil];
}

- (void)setReadLater:(NSNumber *)readLater {
    if ([readLater isEqual:_readLater]) return;
    _readLater = readLater;
    [[FDWClient sharedClient] updateFeedItem:(FDWItem *)self withRead:(NSNumber *)nil starred:(NSNumber *)nil readLater:(NSNumber *)readLater completionHandler:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%@, %@)", NSStringFromClass([self class]), self, self.title, self.author, self.publishedAt];
}

@end
