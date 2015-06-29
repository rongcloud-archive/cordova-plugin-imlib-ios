//
//  RongCloudHandler.m
//  UZApp
//
//  Created by MiaoGuangfa on 1/20/15.
//  Copyright (c) 2015 APICloud. All rights reserved.
//

#import "RongCloudHandler.h"
#import <RongIMLib/RongIMLib.h>

NSString *const kAppBackgroundMode = @"kAppBackgroundMode";
NSString *const kDeviceToken = @"RongCloud_SDK_DeviceToken";


@implementation RongCloudHandler
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%s, deviceToken > %@", __FUNCTION__, deviceToken);
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                                               withString:@""]
                          stringByReplacingOccurrencesOfString:@">"
                          withString:@""]
                         stringByReplacingOccurrencesOfString:@" "
                         withString:@""];
   [[RCIMClient sharedRCIMClient]setDeviceToken:token];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults]setObject:@(YES) forKey:kAppBackgroundMode];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults]setObject:@(NO) forKey:kAppBackgroundMode];
    [[NSUserDefaults standardUserDefaults]synchronize];;
}
@end
