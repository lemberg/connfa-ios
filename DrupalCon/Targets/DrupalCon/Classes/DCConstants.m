//
//  DCConstants.m
//  DrupalCon
//
//  Created by Roman Malinovskyi on 2/6/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCConstants.h"

@implementation DCConstants

NSString *const BASE_URL = @"http://dublin2016.drupalcon.uat.link/api/v2/";;
NSString *const SERVER_URL = @"http://dublin2016.drupalcon.uat.link";
NSString *const BUNDLE_NAME = @"DC-Theme";
NSString *const GOOGLE_ANALYTICS_APP_ID = @"UA-267362-67";
NSString *const TWITTER_API_KEY = @"Mxl1GoGSM98T3jTIWdlUuqXmh";
NSString *const TWITTER_API_SECRET = @"UM74rykaGhxPhhKED2KxJrd6zGBLNWgVsGdlzjdSwSNqLTiyqY";

+(NSArray*)appMenuItems {
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
    kMenuItemTitle : @"Social Media",
    kMenuItemIcon : @"menu_icon_social_media",
    kMenuItemSelectedIcon : @"menu_icon_social_media_sel",
    kMenuItemControllerId : @"DCSocialMediaViewController",
    kMenuType : @(DCMENU_SOCIALMEDIA_ITEM)
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
    kMenuItemTitle : @"Floor Plans",
    kMenuItemIcon : @"menu_icon_floor_plan",
    kMenuItemSelectedIcon : @"menu_icon_floor_plan_sel",
    kMenuItemControllerId : @"DCFloorPlanController",
    kMenuType : @(DCMENU_FLOORPLAN_ITEM)
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

+(NSDictionary*)appFonts {
  
  NSDictionary* fonts;

  fonts = @{  kFontEventListScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:20],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:13],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:15]
                  
                  },
              kFontEventDetailsScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:20],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:13],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:15]
                  
                  },
              kFontSpeakerListScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:22],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:11],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:15]

                  },
              kFontSpeakerDetailsScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:22],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:13],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:15]

                  },
              kFontMenuItemsScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:21],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:15],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:21]

                  },
              kFontMapItemsScreen : @{
                  kFontTitle : [UIFont fontWithName:kFontMontserratRegular size:28],
                  kFontDescription : [UIFont fontWithName:kFontOpenSansRegular size:17],
                  kFontName : [UIFont fontWithName:kFontOpenSansCondBold size:22]
                  
                  },
              };
  
  return fonts;
}

@end
