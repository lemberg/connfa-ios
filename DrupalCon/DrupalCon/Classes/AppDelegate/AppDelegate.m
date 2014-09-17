//
//  AppDelegate.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "AppDelegate.h"
#import "DCMainProxy.h"

@interface AppDelegate ()
@property (nonatomic, strong) UILocalNotification *localNotification;
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[DCMainProxy sharedProxy] setDataReady:NO];
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        self.localNotification = locationNotification;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        [[DCMainProxy sharedProxy] setDataReady:NO];
        UINavigationController * natigator = (UINavigationController*)self.window.rootViewController;
        [natigator popToRootViewControllerAnimated:NO];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.localNotification) {
        [[DCMainProxy sharedProxy] openLocalNotification:self.localNotification];
        self.localNotification = nil;
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        self.localNotification = notification;
    }
    
    NSLog(@"Push notification come");
    application.applicationIconBadgeNumber = 0;
}




@end
