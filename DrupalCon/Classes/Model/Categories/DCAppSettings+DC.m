
#import "DCAppSettings+DC.h"
#import "NSManagedObject+DC.h"
#import "NSUserDefaults+DC.h"

@implementation DCAppSettings (DC)
static NSString* kDCAppSettingsTimeZoneValue = @"timezone";
static NSString* kDCAppSettings = @"settings";
static NSString* kDCTwitterWidgetHTML = @"twitterWidgetHTML";
static NSString* ksearchQuery = @"twitterSearchQuery";

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
  NSArray* settings =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCAppSettings class]
                                              inContext:context];
  DCAppSettings* appSettings;
  if (settings.count == 0) {
    appSettings = [DCAppSettings createManagedObjectInContext:context];
  } else if (settings.count > 1)  // There should be one info instance only.
  {
    NSLog(@"WARNING! info is not unique");
    appSettings = [settings lastObject];
  } else {
    appSettings = [settings lastObject];
  }

  if ([[dictionary allKeys] containsObject:kDCAppSettings]) {
    NSDictionary* settingsDict = dictionary[kDCAppSettings];
    NSString *eventTimeZoneName = settingsDict[kDCAppSettingsTimeZoneValue];
    appSettings.timeZoneName = eventTimeZoneName;
    appSettings.widgetHTML = settingsDict[kDCTwitterWidgetHTML];
    appSettings.searchQuery = settingsDict[ksearchQuery];
  }
}
@end
