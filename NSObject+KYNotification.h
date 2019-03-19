//
//  NSObject+KYNotification.h
//  TestDemo
//
//  Created by Siding on 2019/1/26.
//  Copyright © 2019 Siding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KYNotificationBlock)(NSNotification *);

@interface NSObject (KYNotification)

- (void)ky_observeNotification:(NSString *)notificationName block:(KYNotificationBlock)block;
- (void)ky_observeNotification:(NSString *)notificationName sender:(id)sender block:(KYNotificationBlock)block;
- (void)ky_unobserveNotification:(NSString *)notificationName;
- (void)ky_unobserveNotification:(NSString *)notificationName sender:(id)sender;

@end
