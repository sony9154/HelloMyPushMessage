//
//  AppDelegate.m
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/1/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "AppDelegate.h"
#import "Communicator.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Ask user's permission
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge; //接受哪些類型的通知;Badge是小紅點數字
    
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    
    [application registerUserNotificationSettings:settings];//讓app跳出提醒問user同不同意同意
    [application registerForRemoteNotifications];//跟系統要求Device token
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"DeviceToken: %@",deviceToken.description);
    
    NSString *deviceTokenString = [deviceToken.description stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenString =[deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Final DeviceToken String:%@",deviceTokenString);
    
    // Report with Communicator
    Communicator *comm = [Communicator sharedInstance];
    
    comm.deviceToken = deviceTokenString;
    //comm.userName = @"KenTest";
    
    [comm reportDeviceToken];
    
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@",error.description);
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    NSLog(@"didReceiveRemoteNotification: %@",userInfo.description);
    
    NSDictionary *aps = userInfo[@"aps"];
    NSString *alert = aps[@"alert"];
    
    if(alert != nil) {
        // Will notify UI to update.
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_REFRESH_MESSAGES_NOTIFICATION object:nil];
        
        // Make Phone vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }
    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
