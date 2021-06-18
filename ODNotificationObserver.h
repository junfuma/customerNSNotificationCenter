//
//  ODNotificationObserver.h
//  OpenDriver
//
//  Created on 2019/9/10.
//

#import <Foundation/Foundation.h>

@class ODNotification;

typedef void(^ODObserverBlock)(ODNotification *notification);

@interface ODNotificationObserver : NSObject

-(instancetype)initWithPriority:(NSUInteger)priority;

@property (nonatomic,weak) id responser;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,readonly) NSUInteger priority;
@property (nonatomic,copy) ODObserverBlock callBack;
@property (nonatomic,assign) BOOL oneTime;

@end
