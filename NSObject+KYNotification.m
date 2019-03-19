//
//  NSObject+KYNotification.m
//  TestDemo
//
//  Created by Siding on 2019/1/26.
//  Copyright © 2019 Siding. All rights reserved.
//

#import "NSObject+KYNotification.h"

#import <objc/runtime.h>

@interface _KYNotification : NSObject

@property (copy, nonatomic)     NSString *notificationName;
@property (strong, nonatomic)   id sender;
@property (strong, nonatomic)   id observer;

+ (_KYNotification *)notificationWithName:(NSString *)notificationName sender:(id)sender observer:(id)observer;

- (void)removeNotification;

@end

@implementation _KYNotification

+ (_KYNotification *)notificationWithName:(NSString *)notificationName sender:(id)sender observer:(id)observer {
    _KYNotification *notification = [[_KYNotification alloc] init];
    notification.notificationName = notificationName;
    notification.sender = sender;
    notification.observer = observer;
    return notification;
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter]  removeObserver:self.observer name:self.notificationName object:self.sender];
}

@end

/**
 observe dealloc
 */
@interface _KYNotificationInfo : NSObject

@property (strong, nonatomic)   NSMutableDictionary<NSString *, NSMutableArray<_KYNotification *> *> *observers;

- (void)addNotification:(_KYNotification *)notification;

- (void)removeNotification:(NSString *)notificationName sender:(id)sender;

@end

@implementation _KYNotificationInfo

- (instancetype)init {
    if (self = [super init]) {
        _observers = @{}.mutableCopy;
    }
    return self;
}

- (void)dealloc {
    for (NSMutableArray *notificationArray in _observers.allValues) {
        for (_KYNotification *aNotification in notificationArray) {
            [aNotification removeNotification];
        }
    }
}

- (void)addNotification:(_KYNotification *)notification {
    NSMutableArray *notificationArray = self.observers[notification.notificationName];
    if (!notificationArray) {
        notificationArray = @[].mutableCopy;
        self.observers[notification.notificationName] = notificationArray;
    }
    
    [notificationArray addObject:notification];
}

- (void)removeNotification:(NSString *)notificationName sender:(id)sender {
    NSMutableArray *notificationArray = self.observers[notificationName];
    if (!notificationArray) return;
    
    for (_KYNotification *notification in notificationArray) {
        if (notification.sender == sender) {
            [notification removeNotification];
        }
    }
}

@end

@implementation NSObject (KYNotification)

- (_KYNotificationInfo *)noitificationInfo {
    _KYNotificationInfo *notificationInfo = objc_getAssociatedObject(self, _cmd);
    if (!notificationInfo) {
        notificationInfo = [[_KYNotificationInfo alloc] init];
        objc_setAssociatedObject(self, _cmd, notificationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return notificationInfo;
}

- (void)ky_observeNotification:(NSString *)notificationName block:(KYNotificationBlock)block {
    [self ky_observeNotification:notificationName sender:nil block:block];
}

- (void)ky_observeNotification:(NSString *)notificationName sender:(id)sender block:(KYNotificationBlock)block {
    if (!notificationName) return;
    
    _KYNotificationInfo *notificationInfo = [self noitificationInfo];
    [notificationInfo removeNotification:notificationName sender:sender];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:sender queue:[NSOperationQueue mainQueue] usingBlock:block];
    _KYNotification *notification = [_KYNotification notificationWithName:notificationName sender:sender observer:observer];
    [notificationInfo addNotification:notification];
}

- (void)ky_unobserveNotification:(NSString *)notificationName {
    if (!notificationName) return;
    
    _KYNotificationInfo *notificationInfo = [self noitificationInfo];
    [notificationInfo removeNotification:notificationName sender:nil];
}

- (void)ky_unobserveNotification:(NSString *)notificationName sender:(id)sender {
    if (!notificationName) return;
    
    _KYNotificationInfo *notificationInfo = [self noitificationInfo];
    [notificationInfo removeNotification:notificationName sender:sender];
}

@end
