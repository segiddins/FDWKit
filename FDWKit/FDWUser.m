//
//  FDWUser.m
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

#import "FDWUser.h"

@implementation FDWUser

+ (id)userWithEmail:(NSString *)email accountStatus:(FDWAccountStatus)accountStatus readLaterService:(FDWReadLaterService)readLaterService {
    FDWUser *user = [[self alloc] init];
    user.email = email;
    user.accountStatus = accountStatus;
    user.readLaterService = readLaterService;
    return user;
}

+ (id)userWithDictionary:(NSDictionary *)dictionary {
    return [self userWithEmail:dictionary[@"email"]
                 accountStatus:FDWAccountStatusFromString(dictionary[@"account_status"])
              readLaterService:FDWReadLaterServiceFromString(dictionary[@"read_later_service"])];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    _email = dictionary[@"email"];
    _accountStatus = FDWAccountStatusFromString(dictionary[@"account_status"]);
    _readLaterService = FDWReadLaterServiceFromString(dictionary[@"read_later_service"]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (%d)", NSStringFromClass([self class]), self, self.email, self.accountStatus];
}

@end

FDWAccountStatus FDWAccountStatusFromString(NSString *string) {
    if ([string isEqualToString:@"active"]) {
        return FDWAccountStatusActive;
    } else {
        return FDWAccountStatusInactive;
    }
}

FDWReadLaterService FDWReadLaterServiceFromString(NSString *string) {
    if ([string isEqualToString:@"instapaper"]) {
        return FDWReadLaterServiceInstapaper;
    } else if ([string isEqualToString:@"pocket"]) {
        return FDWReadLaterServicePocket;
    } else {
        return FDWReadLaterServiceNone;
    }
}
