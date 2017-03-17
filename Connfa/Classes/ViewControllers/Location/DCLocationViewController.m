
#import "DCLocationViewController.h"
#import "UIConstants.h"
#import <MapKit/MapKit.h>
#import "DCPin.h"
#import "DCLocation.h"
#import "DCMainProxy.h"
#import "DCConstants.h"
#import "DCFontItem.h"

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
    [self createNewLocation];
  self.titlesContainerView.backgroundColor =
      [DCAppConfiguration navigationBarColor];
  [self setCustomFonts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerScreenLoadAtGA:[NSString stringWithFormat:@"%@", self.navigationItem.title]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appBecameActive) name:@"applicationDidBecomeActive" object:nil];
  [self.view layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View appearance

- (void)arrangeNavigationBar {
  [super arrangeNavigationBar];

  self.navigationController.navigationBar.barTintColor =
      [DCAppConfiguration navigationBarColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void)createNewLocation {
    self.location =
    [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLocation class]
                                           inMainQueue:YES] lastObject];
    [self updateLocation];
}

- (void)updateLocation {
  [self setAnnotation];
  
  NSArray* parts;
  
  if (self.location.address)
    parts = [self.location.address componentsSeparatedByString:@","];
  
  if (parts.count) {
    
    NSMutableArray *tempArr = [NSMutableArray new];
    for (NSString *string in parts) {
      NSString *finalString = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
      [tempArr addObject:finalString];
    }
    
    parts = [NSArray arrayWithArray:tempArr];
    
    self.addressLabel.text = self.location.name;
    
    NSString *street = [parts objectAtIndex:0];
    NSString *city = [parts objectAtIndex:1];
    NSString *state = [parts objectAtIndex:2];
    
    self.streetAndNumberLabel.text = street;
    self.cityAndProvinceLabel.text = city;
    self.stateLabel.text = state;
    
  } else {
    
    self.addressLabel.text = @"The address is not specified";
    self.streetAndNumberLabel.text = @"";
    self.cityAndProvinceLabel.text = @"";
    self.stateLabel.text = @"";
  }
}

#define METERS_PER_MILE 1609.344

- (void)setAnnotation {
  if (self.location.address) {
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
      [_mapView setRegion:viewRegion animated:NO];
    }
  }
}

- (void)setCustomFonts {
  
   DCFontItem *fonts = [DCConstants appFonts].firstObject;
  
  self.addressLabel.font = [UIFont fontWithName:fonts.titleFont size:self.addressLabel.font.pointSize];
  self.streetAndNumberLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.streetAndNumberLabel.font.pointSize];
  self.cityAndProvinceLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.cityAndProvinceLabel.font.pointSize];
  self.stateLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.stateLabel.font.pointSize];
  
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

#pragma mark - Notification handler

- (void)appBecameActive {
    [self createNewLocation];
}

@end
