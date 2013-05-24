//
//  FDWUser.h
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

typedef NS_ENUM(NSInteger, FDWAccountStatus) {
    FDWAccountStatusActive,
    FDWAccountStatusInactive,
};

typedef NS_ENUM(NSInteger, FDWReadLaterService) {
    FDWReadLaterServiceNone,
    FDWReadLaterServiceInstapaper,
    FDWReadLaterServicePocket,
};

FDWAccountStatus FDWAccountStatusFromString(NSString* string);
FDWReadLaterService FDWReadLaterServiceFromString(NSString* string);

@interface FDWUser : NSObject

@property (strong) NSString *email;
@property FDWAccountStatus accountStatus;
@property FDWReadLaterService readLaterService;

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary;

@end

