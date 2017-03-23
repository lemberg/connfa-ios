
#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface DCPin : NSObject<MKAnnotation>

@property(copy, nonatomic) NSString* title;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString*)title;
@end
