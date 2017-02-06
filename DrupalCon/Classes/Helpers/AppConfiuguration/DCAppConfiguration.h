
#import <Foundation/Foundation.h>

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
