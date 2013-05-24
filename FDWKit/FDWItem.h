//
//  FDWItem.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

@interface FDWItem : NSObject

@property (strong) NSString *feedItemID;
@property (strong) NSDate   *publishedAt;
@property (strong) NSDate   *createdAt;
@property (strong) NSString *versionKey;
@property (strong) NSDate   *updatedAt;
@property (strong) NSURL    *url;
@property (strong) NSString *title;
@property (nonatomic, strong) NSNumber *starred;
@property (nonatomic, strong) NSNumber *read;
@property (nonatomic, strong) NSNumber *readLater;
@property (strong) NSString *body;
@property (strong) NSString *author;
@property (strong) NSString *feedID;
@property (strong) NSString *feedName;

+ (instancetype)feedItemWithDictionary:(NSDictionary *)dictionary;

@end
