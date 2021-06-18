//
//  ODNotificationObserver.m
//  OpenDriver
//
//  Created on 2019/9/10.
//

#import "ODNotificationObserver.h"

@implementation ODNotificationObserver

-(instancetype)initWithPriority:(NSUInteger)priority{
    self = [self init];
    if (self) {
        _priority = priority;
    }
    return self;
}

- (void)dealloc{
    self.callBack = nil;
}

@end
