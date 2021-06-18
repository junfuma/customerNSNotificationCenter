//
//  ODNotificationCenter.h
//  OpenDriver
//
//  Created on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import "ODNotificationObserver.h"

#define ODNC [ODNotificationCenter notificationCenter]

typedef NS_ENUM(NSInteger, ODNotificationType) {
    ODNotificationType_Normal = 1,
    ODNotificationType_Response,
};

@interface ODNotification : NSObject

-(instancetype)initObject:(id)obj userInfo:(NSDictionary*)userInfo;

@property (nonatomic,strong,readonly) id object;
@property (nonatomic,strong,readonly) NSDictionary *userInfo;

-(void)abort;
-(void)response;

@end

@interface ODNotificationCenter : NSObject

+(instancetype)notificationCenter;

-(BOOL)addObserver:(ODNotificationObserver*)observer;
-(BOOL)addObserver:(NSString*)name key:(NSString*)key priority:(NSUInteger)priority callBack:(ODObserverBlock)callback;
-(BOOL)addObserver:(NSString*)name responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback;
-(BOOL)addObserver:(NSString *)name keyName:(NSString*)keyName responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback;

-(BOOL)addOneTimeObserver:(NSString*)name responser:(id)responser priority:(NSUInteger)priority callBack:(ODObserverBlock)callback;

-(void)removeObserver:(NSString*)key;
-(void)removeObserverIn:(id)responser;

-(void)postNotification:(NSString*)name object:(id)object;
-(void)postNotification:(NSString*)name object:(id)object userInfo:(NSDictionary*)userInfo;
-(void)postNotification:(NSString*)name object:(id)object userInfo:(NSDictionary*)userInfo type:(ODNotificationType)notitype;

@end
