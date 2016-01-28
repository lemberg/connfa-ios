
#import "AppDelegate.h"
#import "DCMainProxy.h"
#import "UIConstants.h"
#import "DCAlertsManager.h"
#import "GAI.h"
#import "DCLevel+DC.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "NSUserDefaults+DC.h"

@interface AppDelegate ()

@property(strong, nonatomic) id<GAITracker> tracker;

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  // Initialise crashlytics
  [Fabric with:@[ CrashlyticsKit ]];

  [self initializeGoogleAnalytics];
  [self handleUpdateData];
  
  [[DCMainProxy sharedProxy] update];

#ifdef DEBUG_MODE
  NSLog(@"====================");
  NSLog(@"====DEBUG MODE======");
  NSLog(@"====================");
#endif

  return YES;
}

- (void)handleUpdateData {
  // Handle it only when application start
  [[DCMainProxy sharedProxy] setDataUpdatedCallback:^(DCMainProxyState mainProxyState) {
    NSTimeZone *eventTimeZone = [[DCMainProxy sharedProxy]
                                 isSystemTimeCoincidencWithEventTimezone];
    if (eventTimeZone && [NSUserDefaults isEnabledTimeZoneAlert]) {
      [DCAlertsManager
       showTimeZoneAlertForTimeZone:eventTimeZone
       withSuccess:^(BOOL isSuccess){
         if (isSuccess) {
           [NSUserDefaults disableTimeZoneNotification];
         }
         [[DCMainProxy sharedProxy] setDataUpdatedCallback:nil];
       }];
    }

  }];
}

- (void)applicationWillResignActive:(UIApplication*)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
  if ([self.window.rootViewController
          isKindOfClass:[UINavigationController class]]) {
    [[DCMainProxy sharedProxy] update];
  }
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
}

- (void)applicationWillTerminate:(UIApplication*)application {
}

- (void)initializeGoogleAnalytics {
  [[GAI sharedInstance]
      setDispatchInterval:[DCAppConfiguration dispatchInvervalGA]];
  [[GAI sharedInstance] setDryRun:[DCAppConfiguration dryRunGA]];
  self.tracker = [[GAI sharedInstance]
      trackerWithTrackingId:[DCAppConfiguration googleAnalyticsID]];
}

@end
