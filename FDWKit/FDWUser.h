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

/// Represents a FeedWrangler user
/// @warning As of now, the only way to get a user object from the API is by authenticating via -[FDWClient authenticateEmail:password:clientKey:completionHandler:]

@interface FDWUser : NSObject

/// @name Properties

/// The user's email address
@property (strong) NSString *email;

/// The user's account status, either `FDWAccountStatusActive` or `FDWAccountStatusInactive`
@property FDWAccountStatus accountStatus;

/// The read later service the user has associated with FeedWrangler, either `FDWReadLaterServiceNone`, `FDWReadLaterServiceInstapaper`, or `FDWReadLaterServicePocket`
@property FDWReadLaterService readLaterService;

/// @name Initialization

/// Creates an FDWUser object from the JSON representation that the API returns
/// @param dictionary The dictionary to create the user from
+ (instancetype)userWithDictionary:(NSDictionary *)dictionary;

@end

