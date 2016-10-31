
#import <UIKit/UIKit.h>

@interface UIImage (initWithColor)

// programmatically create an UIImage with 1 pixel of a given color
+ (UIImage*)imageWithColor:(UIColor*)color;

// implement additional methods here to create images with gradients etc.
//[..]

/**
 * Returns the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The splash image.
 **/
+ (UIImage*)splashImageForOrientation:(UIInterfaceOrientation)orientation;

/**
 * Return the name of the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The name of the splash image.
 **/
+ (NSString*)splashImageNameForOrientation:(UIInterfaceOrientation)orientation;

+ (UIImage*)imageNamedFromBundle:(NSString*)imageName;
@end
