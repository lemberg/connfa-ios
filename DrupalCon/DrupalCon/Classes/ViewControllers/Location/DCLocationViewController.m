//
//  DCLocationViewController.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/2/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCLocationViewController.h"
#import "UIConstants.h"
#import <MapKit/MapKit.h>
#import "DCPin.h"
#import "DCLocation.h"

@interface DCLocationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressHeader;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) DCLocation *location;

@end

@implementation DCLocationViewController


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
    // Do any additional setup after loading the view.
    [self setLayout];
    self.location = [[[DCMainProxy sharedProxy] locationInstances] lastObject];
    [self updateLocation];

}
- (void)updateLocation {
    [self setAnnotation];
    self.addressHeader.attributedText = [self address];
}
- (void)setLayout {
    [self.view setBackgroundColor:NAV_BAR_COLOR];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define METERS_PER_MILE 1609.344

- (void)setAnnotation {
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

#pragma mark -

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSAttributedString *)streetAdress {
    // Select street name
    NSMutableAttributedString *streetName = [[NSMutableAttributedString alloc] initWithString:self.location.streetName];
    [streetName addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue-Light" size:32.0]
                       range:NSMakeRange(0, self.location.streetName.length)];
    // Select building number
    NSMutableAttributedString *buildingNum = [[NSMutableAttributedString alloc] initWithString:self.location.number];
    [buildingNum setAttributes:@{
                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin"
                                                                       size:23.0],
                                 NSBaselineOffsetAttributeName : @10
                                 }
                         range:NSMakeRange(0, self.location.number.length)];
    
    [streetName appendAttributedString:buildingNum];
    return streetName;
}

- (NSMutableAttributedString *)placeName {
    // Select building name
    NSArray *buildingNames = [self.location.name componentsSeparatedByString:@" "];
    
    NSMutableAttributedString *suffixName = nil;
    // If place name has suffix
    if ([buildingNames count] > 1) {

        // Select building name suffix
        NSString *lastName = [buildingNames lastObject];
        suffixName = [[NSMutableAttributedString alloc] initWithString:lastName];
        [suffixName addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-UltraLight"
                                              size:45.0]
                    range:NSMakeRange(0, lastName.length)];
    }

    NSString *firstName = [buildingNames firstObject];
    NSMutableAttributedString *buildingName = [[NSMutableAttributedString alloc] initWithString:firstName];
    [buildingName addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"HelveticaNeue-UltraLight"
                                               size:45.0]
                         range:NSMakeRange(0, firstName.length)];
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    [buildingName appendAttributedString:space];
    [buildingName appendAttributedString:suffixName];
    
    return buildingName;
}

- (NSAttributedString *)address {
    NSMutableAttributedString *adr = [self placeName];
    
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
    [adr appendAttributedString:newLine];
    
    [adr appendAttributedString:[self streetAdress]];

    [adr addAttribute:NSForegroundColorAttributeName
                value:[UIColor whiteColor]
                range:NSMakeRange(0, adr.length)];


    return adr;
}


    
@end
