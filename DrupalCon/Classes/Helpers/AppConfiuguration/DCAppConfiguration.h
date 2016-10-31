
#import <Foundation/Foundation.h>

#define SERVER_URL @"http://dublin2016.drupalcon.uat.link"
#define BUNDLE_NAME @"DC-Theme"
#define GOOGLE_ANALYTICS_APP_ID @"Google Analytics API key stub"
#define TWITTER_API_KEY @"Twitter API key stub"
#define TWITTER_API_SECRET @"Twitter API secret stub"


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
