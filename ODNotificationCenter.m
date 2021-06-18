//
//  ODNotificationCenter.m
//  OpenDriver
//
//  Created on 2019/9/10.
//

#import "ODNotificationCenter.h"

static ODNotificationCenter *_instance = nil;

@interface ODNotification ()
@property (nonatomic,copy) NSString *name;
@property (nonatomic) BOOL abortFlag;
@property (nonatomic) BOOL responseFlag;
@end

@implementation ODNotification

-(instancetype)initObject:(id)obj userInfo:(NSDictionary *)userInfo{
    self = [super init];
    if (self) {
        _object = obj;
        _userInfo = userInfo;
        self.abortFlag = NO;
        self.responseFlag = NO;
    }
    return self;
}

-(void)abort{
    self.abortFlag = YES;
}

-(void)response{
    self.responseFlag = YES;
}

@end

@interface ODNotificationCenter ()
@property (nonatomic,strong) NSMutableArray *observers;
@property (nonatomic,strong) NSMutableArray *cacheNotifications;
@end

@implementation ODNotificationCenter

+(instancetype)notificationCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ODNotificationCenter alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.observers = [NSMutableArray array];
        self.cacheNotifications = [NSMutableArray array];
    }
    return self;
}

-(BOOL)addObserver:(NSString *)name key:(NSString *)key priority:(NSUInteger)priority callBack:(ODObserverBlock)callback{
    ODNotificationObserver *obs = [[ODNotificationObserver alloc] initWithPriority:priority];
    obs.name = name;
    obs.key = key;
    obs.callBack = callback;
    return [self addObserver:obs];
}

-(BOOL)addObserver:(NSString *)name responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback{
    ODNotificationObserver *obs = [[ODNotificationObserver alloc] initWithPriority:priority];
    obs.name = name;
    obs.responser = responser;
    obs.callBack = callback;
    return [self addObserver:obs];
}

-(BOOL)addObserver:(NSString *)name keyName:(NSString*)keyName responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback{
    ODNotificationObserver *obs = [[ODNotificationObserver alloc] initWithPriority:priority];
    obs.name = name;
    obs.key = keyName;
    obs.responser = responser;
    obs.callBack = callback;
    return [self addObserver:obs];
}

-(BOOL)addOneTimeObserver:(NSString *)name responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback{
    ODNotificationObserver *obs = [[ODNotificationObserver alloc] initWithPriority:priority];
    obs.name = name;
    obs.responser = responser;
    obs.callBack = callback;
    obs.oneTime = YES;
    return [self addObserver:obs];
}

-(BOOL)addObserver:(ODNotificationObserver *)observer{
    if (!observer.name) {
        return NO;
    }
    
    if (!observer.key && !observer.responser) {
        NSAssert(!observer.key&&!observer.responser, @"no key and responser for observer");
        return NO;
    }
    
    NSUInteger index = 0;
    for (ODNotificationObserver *obs in self.observers) {
        if (observer.priority>obs.priority) {
            break;
        }else{
            index++;
        }
    }
    
    [self.observers insertObject:observer atIndex:index];
    
    //触发缓存的必达通知.
    [self triggerResponseNotification:observer.name];
    
    return YES;
}

-(void)triggerResponseNotification:(NSString*)name{
    NSMutableArray *notis = [NSMutableArray array];
    for (ODNotification *noti in self.cacheNotifications) {
        if ([noti.name isEqualToString:name]) {
            [notis addObject:noti];
        }
    }
    
    [self.cacheNotifications removeObjectsInArray:notis];
    
    for (ODNotification *noti in notis) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotification:noti.name object:noti.object userInfo:noti.userInfo type:ODNotificationType_Response];
        });
    }
}

-(void)removeObserver:(NSString *)key{
    ODNotificationObserver *observer = nil;
    for (ODNotificationObserver *obs in self.observers) {
        if ([obs.key isEqualToString:key]) {
            observer = obs;
            break;
        }
    }
    if (observer) {
        [self.observers removeObject:observer];
    }
}

-(void)removeObserverIn:(id)responser{
    if (responser==nil) {
        return;
    }
    
    NSMutableArray *rmobs = [NSMutableArray array];
    for (ODNotificationObserver *obs in self.observers) {
        if (obs.responser == responser) {
            [rmobs addObject:obs];
        }else if (obs.responser == nil && obs.key == nil){
            [rmobs addObject:obs];
        }
    }
    
    if (rmobs.count>0) {
        [self.observers removeObjectsInArray:rmobs];
    }
}

-(void)postNotification:(NSString *)name object:(id)object{
    [self postNotification:name object:object userInfo:nil];
}

-(void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo{
    [self postNotification:name object:object userInfo:userInfo type:ODNotificationType_Normal];
}

-(void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo type:(ODNotificationType)notitype{
    
    NSMutableArray *recivers = [NSMutableArray arrayWithCapacity:self.observers.count];
    for (ODNotificationObserver *obs in self.observers) {
        if ([obs.name isEqualToString:name]) {
            [recivers addObject:obs];
        }
    }
    
    ODNotification *notification = [[ODNotification alloc] initObject:object userInfo:userInfo];
    notification.name = name;
    
    for (ODNotificationObserver *obs in recivers) {
        if (obs.callBack) {
            obs.callBack(notification);
            if (notification.abortFlag) {
                break;
            }
        }
        
        if (obs.oneTime) {
            [self.observers removeObject:obs];
        }
    }
    
    if (notitype == ODNotificationType_Response && notification.responseFlag == NO) {
        //cache notification
        [self.cacheNotifications addObject:notification];
    }
}

@end
