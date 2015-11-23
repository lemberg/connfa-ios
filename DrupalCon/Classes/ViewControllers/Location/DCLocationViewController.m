
#import "DCLocationViewController.h"
#import "UIConstants.h"
#import <MapKit/MapKit.h>
#import "DCPin.h"
#import "DCLocation.h"
#import "DCMainProxy.h"

@interface DCLocationViewController ()

@property(weak, nonatomic) IBOutlet UILabel* addressLabel;
@property(weak, nonatomic) IBOutlet UILabel* streetAndNumberLabel;
@property(weak, nonatomic) IBOutlet UILabel* cityAndProvinceLabel;
@property(weak, nonatomic) IBOutlet UILabel* stateLabel;
@property(weak, nonatomic) IBOutlet MKMapView* mapView;

@property(nonatomic, strong) DCLocation* location;
@property(nonatomic, strong) CLGeocoder* geocoder;
@property(weak, nonatomic) IBOutlet UIView* titlesContainerView;

@end

@implementation DCLocationViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.location =
      [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLocation class]
                                             inMainQueue:YES] lastObject];
  [self updateLocation];
  self.titlesContainerView.backgroundColor =
      [DCAppConfiguration speakerDetailBarColor];

}

#pragma mark - View appearance

- (void)arrangeNavigationBar {
  [super arrangeNavigationBar];

  self.navigationController.navigationBar.barTintColor =
      [DCAppConfiguration speakerDetailBarColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void)updateLocation {
  [self setAnnotation];

  NSArray* parts;

  if (self.location.address)
    parts = [self.location.address componentsSeparatedByString:@", "];

  if (parts.count) {
    NSString* streetAndHouse = parts[0];
    NSString* state = (parts.count > 1) ? parts.lastObject : @"";
    NSMutableString* cityAndProvince = [@"" mutableCopy];

    if (parts.count > 2) {
      [cityAndProvince appendString:parts[1]];

      for (int i = 2; i < parts.count - 1; i++)
        [cityAndProvince appendFormat:@", %@", parts[i]];
    }

    self.addressLabel.text = self.location.name;
    self.streetAndNumberLabel.text =
        streetAndHouse.length
            ? [NSString stringWithFormat:@"%@,", streetAndHouse]
            : nil;
    self.cityAndProvinceLabel.text =
        cityAndProvince.length
            ? [NSString stringWithFormat:@"%@,", cityAndProvince]
            : nil;
    self.stateLabel.text = state;
  } else {
    self.addressLabel.text = @"Location is not available";
    self.streetAndNumberLabel.text = @"";
    self.cityAndProvinceLabel.text = @"";
    self.stateLabel.text = @"";
  }
}


#define METERS_PER_MILE 1609.344

- (void)setAnnotation {
  CLLocation* location = [[CLLocation alloc]
      initWithLatitude:[self.location.latitude doubleValue]
             longitude:[self.location.longitude doubleValue]];

  DCPin* pinAnnotation =
      [[DCPin alloc] initWithCoordinate:location.coordinate title:@""];
  [self.mapView addAnnotation:pinAnnotation];

  // Set view region
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(
      location.coordinate, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
  if (CLLocationCoordinate2DIsValid(location.coordinate)) {
    [_mapView setRegion:viewRegion animated:YES];
  }
}

#pragma mark -
#pragma MapView Delegate

- (MKAnnotationView*)mapView:(MKMapView*)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation {
  MKAnnotationView* annotationView = nil;
  static NSString* reuseIdentifier = @"annotationViewReuseId";

  if ([annotation isKindOfClass:[DCPin class]]) {
    // create pin
    annotationView = (MKPinAnnotationView*)
        [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];

    if (!annotationView) {
      annotationView =
          [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:reuseIdentifier];
    } else {
      annotationView.annotation = annotation;
    }
  }
  return annotationView;
}

@end
