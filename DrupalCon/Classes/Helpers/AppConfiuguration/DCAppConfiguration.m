
#import "DCAppConfiguration.h"
#import "DCSideMenuViewController.h"
#import "DCSideMenuType.h"
#import "UIColor+Helper.h"
#import "DCConstants.h"

const NSString*  kFontMontserratRegular = @"Montserrat-Regular";
const NSString*  kFontOpenSansBold = @"OpenSans-Bold";
const NSString*  kFontOpenSansCondBold = @"Open Sans Condensed";
const NSString*  kFontOpenSansRegular = @"Open Sans";

@implementation DCAppConfiguration

static NSString* const kNavigationBarColour = @"NavigationBarColour";
static NSString* const kFavoriteEventColour = @"FavoriteEventColour";
static NSString* const kEventDetailHeaderColour = @"EventDetailHeaderColour";
static NSString* const kEventDetailNavBarTextColour =
    @"EventDetailNavBarTextColour";
static NSString* const kIsFilterEnable = @"IsFilterEnable";
static NSString* const kSpeakerDetailBarColour = @"SpeakerDetailBarColour";
static NSString* const kEventDate = @"EventDate";
static NSString* const kEventPlace = @"EventPlace";

static NSBundle* themeBundle;


+ (void)initialize {
  NSString* bundlePath =
      [[NSBundle mainBundle] pathForResource:BUNDLE_NAME ofType:@"bundle"];
  themeBundle = [NSBundle bundleWithPath:bundlePath];
}

+ (UIColor*)navigationBarColor {
  NSString* colorId = [themeBundle infoDictionary][kNavigationBarColour];
  return [UIColor colorFromHexString:colorId];
}

+ (UIColor*)favoriteEventColor {
  NSString* colorId = [themeBundle infoDictionary][kFavoriteEventColour];
  return [UIColor colorFromHexString:colorId];
}

+ (UIColor*)eventDetailHeaderColour {
  NSString* colorId = [themeBundle infoDictionary][kEventDetailHeaderColour];
  return [UIColor colorFromHexString:colorId];
}

+ (UIColor*)eventDetailNavBarTextColor {
  NSString* colorId =
      [themeBundle infoDictionary][kEventDetailNavBarTextColour];
  return [UIColor colorFromHexString:colorId];
}

+ (UIColor*)speakerDetailBarColor {
  NSString* colorId = [themeBundle infoDictionary][kSpeakerDetailBarColour];
  return [UIColor colorFromHexString:colorId];
}

+ (NSString*)eventTime {
  NSString* eventTime = [themeBundle infoDictionary][kEventDate];
  return eventTime;
}

+ (NSString*)eventPlace {
  NSString* eventPlace = [themeBundle infoDictionary][kEventPlace];
  return eventPlace;
}

+ (BOOL)isFilterEnable {
  return [[themeBundle infoDictionary][kIsFilterEnable] boolValue];
}

+ (NSString*)appDisplayName {
  return
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSArray*)appMenuItems {
  return [DCConstants appMenuItems];
}

// GA

+ (NSInteger)dispatchInvervalGA {
  return [NSBundle.mainBundle.infoDictionary[@"GoogleAnalytics"][
      @"DispatchInterval"] integerValue];
}

+ (BOOL)dryRunGA {
  return [NSBundle.mainBundle
              .infoDictionary[@"GoogleAnalytics"][@"DryRun"] boolValue];
}

+ (NSString*)googleAnalyticsID {
  return GOOGLE_ANALYTICS_APP_ID;
}

+ (UIFont *)fontWithName:(NSString *)name andSize:(CGFloat)size {
  return [UIFont fontWithName:name size:size];
}

@end
