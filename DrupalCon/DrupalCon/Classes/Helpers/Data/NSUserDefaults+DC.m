/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "NSUserDefaults+DC.h"

const NSString* kTimeStampSynchronisation = @"lastUpdate";
const NSString* kLastModify = @"kLastModify";
const NSString* kAboutInfo = @"aboutHTML";
const NSString* kBundleVersionMajor = @"kBundleVersionMajor";
const NSString* kBundleVersionMinor = @"kBundleVersionMinor";

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
