//
//  NSNumber+BoolToString.m
//  Pods
//
//  Created by Samuel E. Giddins on 5/23/13.
//
//

#import "NSNumber+BoolToString.h"

@implementation NSNumber (BoolToString)

- (NSString *)fdw_StringValueOfBool {
    return (self.boolValue) ? @"true" : @"false";
}

@end
