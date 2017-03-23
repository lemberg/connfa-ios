
#import "DCPin.h"

@implementation DCPin
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString*)title {
  if (self = [super init]) {
    _title = title;
    _coordinate = coordinate;
  }

  return self;
}
@end
