
#import <Foundation/Foundation.h>

#define SERVER_URL @"http://connfa-integration.uat.link"
#define BUNDLE_NAME @"DC-Theme"
#define GOOGLE_ANALYTICS_APP_ID @"UA-267362-67"
#define TWITTER_API_KEY @"Mxl1GoGSM98T3jTIWdlUuqXmh"
#define TWITTER_API_SECRET @"UM74rykaGhxPhhKED2KxJrd6zGBLNWgVsGdlzjdSwSNqLTiyqY"



#define BASE_URL [NSString stringWithFormat:@"%@/api/v2/", SERVER_URL]

extern NSString* kFontOpenSansBold;
extern NSString* kFontOpenSansCondBold;
extern NSString* kFontOpenSansRegular;

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

+ (UIFont *)fontWithName:(NSString *)name andSize:(CGFloat)size;

@end
