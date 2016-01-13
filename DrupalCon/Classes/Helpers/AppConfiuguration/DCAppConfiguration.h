
#import <Foundation/Foundation.h>

#define SERVER_URL @"http://drupalconbarcelona2015.uat.link"
#define BUNDLE_NAME @"DC-Theme"

#define BASE_URL [NSString stringWithFormat:@"%@/api/v2/", SERVER_URL]

@interface DCAppConfiguration : NSObject

+ (NSArray*)appMenuItems;
+ (UIColor*)navigationBarColor;
+ (UIColor*)favoriteEventColor;
+ (UIColor*)eventDetailHeaderColour;
+ (UIColor*)eventDetailNavBarTextColor;
+ (UIColor*)speakerDetailBarColor;
+ (BOOL)isFilterEnable;
+ (NSString*)eventTime;
+ (NSString*)eventPlace;
+ (NSString*)appDisplayName;

+ (NSInteger)dispatchInvervalGA;
+ (BOOL)dryRunGA;
+ (NSString*)googleAnalyticsID;

@end
