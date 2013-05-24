//
//  FDWFeed.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

@interface FDWFeed : NSObject

+ (instancetype)feedWithDictionary:(NSDictionary *)dictionary;

@property (strong) NSString *feedID;
@property (strong) NSString *title;
@property (strong) NSURL    *feedURL;
@property (strong) NSURL    *siteURL;

- (void)unsubscribe;

@end
