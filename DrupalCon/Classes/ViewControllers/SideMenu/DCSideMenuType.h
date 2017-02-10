
#ifndef DrupalCon_DCSideMenuType_h
#define DrupalCon_DCSideMenuType_h
#define kMenuItemTitle @"MenuItemTitle"
#define kMenuItemIcon @"MenuItemIcon"
#define kMenuItemSelectedIcon @"MenuItemSelectedIcon"
#define kMenuItemControllerId @"MenuItemControllerId"
#define kMenuType @"MenuType"

#define kFontEventListScreen @"kFontEventListScreen"
#define kFontEventDetailsScreen @"kFontEventDetailsScreen"
#define kFontSpeakerListScreen @"kFontSpeakerListScreen"
#define kFontSpeakerDetailsScreen @"kFontSpeakerDetailsScreen"
#define kFontMenuItemsScreen @"kFontMenuItemsScreen"
#define kFontMapItemsScreen @"kFontMapItemsScreen"

#define kFontTitle @"kFontTitle"
#define kFontDescription @"kFontDescription"
#define kFontName @"kFontName"

typedef NS_ENUM(int, DCMenuSection) {
  DCMENU_PROGRAM_ITEM = 0,
  DCMENU_BOFS_ITEM,
  DCMENU_SOCIAL_EVENTS_ITEM,
  DCMENU_SPEAKERS_ITEM,
  DCMENU_MYSCHEDULE_ITEM,
  DCMENU_FLOORPLAN_ITEM,
  DCMENU_LOCATION_ITEM,
  // DCMENU_INTERESTS_ITEM,
  DCMENU_SOCIALMEDIA_ITEM,
  DCMENU_INFO_ITEM,
  DCMENU_SIZE
};

#endif
