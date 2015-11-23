
#import "DCAppConfiguration.h"
#import "DCSideMenuViewController.h"
#import "DCSideMenuType.h"
#import "UIColor+Helper.h"

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
  NSArray* menuItems;

  menuItems = @[
    @{
      kMenuItemTitle : @"Sessions",
      kMenuItemIcon : @"menu_icon_program",
      kMenuItemSelectedIcon : @"menu_icon_program_sel",
      kMenuItemControllerId : @"DCProgramViewController",
      kMenuType : @(DCMENU_PROGRAM_ITEM)
    },
    @{
      kMenuItemTitle : @"BoFs",
      kMenuItemIcon : @"menu_icon_bofs",
      kMenuItemSelectedIcon : @"menu_icon_bofs_sel",
      kMenuItemControllerId : @"DCProgramViewController",
      kMenuType : @(DCMENU_BOFS_ITEM)
    },
    @{
      kMenuItemTitle : @"Social Events",
      kMenuItemIcon : @"menu_icon_social",
      kMenuItemSelectedIcon : @"menu_icon_social_sel",
      kMenuItemControllerId : @"DCProgramViewController",
      kMenuType : @(DCMENU_SOCIAL_EVENTS_ITEM)
    },
    @{
      kMenuItemTitle : @"Speakers",
      kMenuItemIcon : @"menu_icon_speakers",
      kMenuItemSelectedIcon : @"menu_icon_speakers_sel",
      kMenuItemControllerId : @"SpeakersViewController",
      kMenuType : @(DCMENU_SPEAKERS_ITEM)
    },
    @{
      kMenuItemTitle : @"My Schedule",
      kMenuItemIcon : @"menu_icon_my_schedule",
      kMenuItemSelectedIcon : @"menu_icon_my_schedule_sel",
      kMenuItemControllerId : @"DCProgramViewController",
      kMenuType : @(DCMENU_MYSCHEDULE_ITEM)
    },
    @{
      kMenuItemTitle : @"Location",
      kMenuItemIcon : @"menu_icon_location",
      kMenuItemSelectedIcon : @"menu_icon_location_sel",
      kMenuItemControllerId : @"LocationViewController",
      kMenuType : @(DCMENU_LOCATION_ITEM)
    },
    @{
      kMenuItemTitle : @"Info",
      kMenuItemIcon : @"menu_icon_about",
      kMenuItemSelectedIcon : @"menu_icon_about_sel",
      kMenuItemControllerId : @"InfoViewController",
      kMenuType : @(DCMENU_INFO_ITEM)
    },
    @{
      kMenuItemTitle : @"Time and event place"
    }
  ];

  return menuItems;
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
  return NSBundle.mainBundle
      .infoDictionary[@"GoogleAnalytics"][@"GoogleAnalyticsID"];
}

@end
