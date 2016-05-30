
#import <Foundation/Foundation.h>

#define SERVER_URL @"http://neworleans2016.drupalcon.uat.link"
#define BUNDLE_NAME @"DC-Theme"

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
