
#import "NSUserDefaults+DC.h"

const NSString* kTimeStampSynchronisation = @"lastUpdate";
const NSString* kLastModify = @"kLastModify";
const NSString* kAboutInfo = @"aboutHTML";
const NSString* kBundleVersionMajor = @"kBundleVersionMajor";
const NSString* kBundleVersionMinor = @"kBundleVersionMinor";
const NSString* kNotShowTimeZoneEventAlert = @"kNotShowTimeZoneEventAlert";

@implementation NSUserDefaults (DC)

#pragma mark - last modified timestamp

+ (void)updateTimestampString:(NSString*)timestamp ForClass:(Class)aClass {
  [NSUserDefaults
      DC_saveObject:timestamp
             forKey:[NSUserDefaults DC_LastModifiedKeyStringForClass:aClass]];
}

+ (NSString*)lastUpdateForClass:(Class)aClass {
  NSString* result = [NSUserDefaults
      DC_savedValueForKey:[NSUserDefaults
                              DC_LastModifiedKeyStringForClass:aClass]];
  return (result ? result : @"");
}

#pragma mark - last-modify

+ (void)updateLastModify:(NSString*)lastModify {
  [self DC_saveObject:lastModify forKey:(NSString*)kLastModify];
}

+ (NSString*)lastModify {
  return [NSUserDefaults DC_savedValueForKey:(NSString*)kLastModify];
}

+ (void)disableTimeZoneNotification {
  [self DC_saveObject:@(YES) forKey:(NSString *)kNotShowTimeZoneEventAlert];
}

+ (BOOL)isEnabledTimeZoneAlert {
  return ![[self DC_savedValueForKey:(NSString *)kNotShowTimeZoneEventAlert] boolValue];
}
#pragma mark - about

+ (void)saveAbout:(NSString*)aboutString {
  [NSUserDefaults DC_saveObject:aboutString forKey:(NSString*)kAboutInfo];
}

+ (NSString*)aboutString {
  return [NSUserDefaults DC_savedValueForKey:(NSString*)kAboutInfo];
}

#pragma mark - private

+ (void)DC_saveObject:(NSObject*)obj forKey:(NSString*)key {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:obj forKey:key];
  [userDefaults synchronize];
}

+ (id)DC_savedValueForKey:(NSString*)key {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults objectForKey:key];
}

+ (NSString*)DC_LastModifiedKeyStringForClass:(Class)aClass {
  return [NSString stringWithFormat:@"%@_%@", NSStringFromClass(aClass),
                                    kTimeStampSynchronisation];
}

#pragma mark - bundle version

+ (void)saveBundleVersionMajor:(NSString*)major minor:(NSString*)minor {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:major forKey:(NSString*)kBundleVersionMajor];
  [userDefaults setObject:minor forKey:(NSString*)kBundleVersionMinor];
  [userDefaults synchronize];
}

+ (NSString*)bundleVersionMajor {
  return [NSUserDefaults DC_savedValueForKey:(NSString*)kBundleVersionMajor];
}

+ (NSString*)bundleVersionMinor {
  return [NSUserDefaults DC_savedValueForKey:(NSString*)kBundleVersionMinor];
}

@end
