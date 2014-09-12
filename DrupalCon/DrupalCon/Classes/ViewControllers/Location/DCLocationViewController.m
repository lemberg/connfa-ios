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
@property (weak, nonatomic) IBOutlet UILabel *streetLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberLbl;
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
    self.addressHeader.attributedText = [self DC_headerAttrString];
    [self.streetLbl setText:[NSString stringWithFormat:@"%@,",self.location.streetName]];
    [self.numberLbl setText:self.location.number];
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


- (NSMutableAttributedString *)DC_headerAttrString
{
    // Select building name
    NSArray *buildingNames = [self.location.name componentsSeparatedByString:@" "];
    
    NSMutableAttributedString *suffixName = nil;
    // If place name has suffix
    if ([buildingNames count] > 1) {

        // Select building name suffix
        NSString *lastName = [buildingNames lastObject];
        suffixName = [[NSMutableAttributedString alloc] initWithString:lastName];
        [suffixName addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Thin"
                                              size:44.0]
                    range:NSMakeRange(0, lastName.length)];
    }

    NSString *firstName = [buildingNames firstObject];
    NSMutableAttributedString *buildingName = [[NSMutableAttributedString alloc] initWithString:(firstName?firstName:@" ")];
    [buildingName addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"HelveticaNeue-UltraLight"
                                               size:44.0]
                         range:NSMakeRange(0, firstName.length)];
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    [buildingName appendAttributedString:space];
    if (suffixName)
    {
        [buildingName appendAttributedString:suffixName];
    }
    
    return buildingName;
}


    
@end
