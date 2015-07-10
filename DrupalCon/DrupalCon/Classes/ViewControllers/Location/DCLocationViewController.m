//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCLocationViewController.h"
#import "UIConstants.h"
#import <MapKit/MapKit.h>
#import "DCPin.h"
#import "DCLocation.h"
#import "DCMainProxy.h"


@interface DCLocationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetAndNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityAndProvinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) DCLocation *location;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end



@implementation DCLocationViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.location = [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLocation class] inMainQueue:YES] lastObject];
    [self updateLocation];
    
        // geocoder isn't used now because we use the ready data from local DB
        // if you want to use geocode just uncomment the proper code
//    self.geocoder = [[CLGeocoder alloc] init];
//    [self updateLocation: CLLocationCoordinate2DMake([self.location.latitude doubleValue],
//                                                     [self.location.longitude doubleValue])];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DCMainProxy sharedProxy] checkReachable];
}

#pragma mark - View appearance

- (void) arrangeNavigationBar
{
    [super arrangeNavigationBar];
    
    self.navigationController.navigationBar.barTintColor = MENU_SELECTION_COLOR;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void) updateLocation
{
    [self setAnnotation];
    
    NSArray *parts;
    
    if (self.location.address)
        parts = [self.location.address componentsSeparatedByString:@", "];
    
    if (parts.count)
    {
        NSString *streetAndHouse = parts[0];
        NSString *state = (parts.count > 1) ? parts.lastObject : @"";
        NSMutableString* cityAndProvince = [@"" mutableCopy];
        
        if (parts.count > 2)
        {
            [cityAndProvince appendString: parts[1]];
            
            for (int i = 2; i<parts.count-1; i++)
                [cityAndProvince appendFormat:@", %@", parts[i]];
        }
    
        self.addressLabel.text = self.location.name;
        self.streetAndNumberLabel.text = streetAndHouse.length ? [NSString stringWithFormat:@"%@,", streetAndHouse] : nil;
        self.cityAndProvinceLabel.text = cityAndProvince.length ? [NSString stringWithFormat:@"%@,", cityAndProvince] : nil;
        self.stateLabel.text = state;
    } else {
        self.addressLabel.text = @"Location is not available";
        self.streetAndNumberLabel.text = @"";//streetAndHouse.length ? [NSString stringWithFormat:@"%@,", streetAndHouse] : nil;
        self.cityAndProvinceLabel.text =@"";// cityAndProvince.length ? [NSString stringWithFormat:@"%@,", cityAndProvince] : nil;
        self.stateLabel.text = @"";
    }
}

//- (void) updateLocationWithGeocoding: (CLLocationCoordinate2D)location
//{
//    [self setAnnotation];
//    
//    CLLocation* startLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
//    
//    if (!self.geocoder)
//        self.geocoder = [[CLGeocoder alloc] init];
//    
//    [self.geocoder reverseGeocodeLocation:startLocation completionHandler:^(NSArray *placemarks, NSError *error)
//        {
//            if ([placemarks count] > 0)
//            {
//                CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                CLLocation *location = placemark.location;
//                CLLocationCoordinate2D coordinate = location.coordinate;
//                
//                NSString* house = placemark.subThoroughfare;
//                NSString* street = placemark.thoroughfare;
//                NSString* city = placemark.locality;
//                NSString* province = placemark.country;
//                NSString* state = placemark.administrativeArea;
//                NSString* businessName = placemark.name;
//                
//                self.addressLabel.text = businessName;
//                self.streetAndNumberLabel.text = [NSString stringWithFormat: @"%@ # %@", street, house];
//                self.cityAndProvinceLabel.text = [NSString stringWithFormat:@"%@, %@", city, province];
//                self.stateLabel.text = state;
//            }
//        }];
//}

#define METERS_PER_MILE 1609.344

- (void)setAnnotation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.location.latitude doubleValue],
                                                                   [self.location.longitude doubleValue]);
    DCPin *pinAnnotation = [[DCPin alloc] initWithCoordinate:coordinate title:@""];
    [self.mapView addAnnotation:pinAnnotation];

    // Set view region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
}

#pragma mark -
#pragma MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView = nil;
    static NSString *reuseIdentifier = @"annotationViewReuseId";
    
    if ([annotation isKindOfClass:[DCPin class]]) {
        // create pin
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:reuseIdentifier];
        } else {
            annotationView.annotation = annotation;
        }
    }
    return annotationView;
}

@end
