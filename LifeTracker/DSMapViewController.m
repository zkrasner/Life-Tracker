//
//  DSMapViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/14/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DSAppDelegate.h"
#import <MapKit/MapKit.h>
#import "DSActivity.h"
#import "DSSelectedActitvityViewController.h"

@interface DSMapViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) DSAppDelegate *appDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *selectedPin;

@end

@implementation DSMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (DSAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (DSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.locationManager startUpdatingLocation];
    self.mapView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    for(int i = 0; i < self.appDelegate.allActivities.count; i++){
        DSActivity *activity = self.appDelegate.allActivities[i];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake([activity.latitude doubleValue],[activity.longitude doubleValue])];
        annotation.title = activity.name;
        [self.mapView addAnnotation:annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"accessory button tapped for annotation");
    static NSString *reuseId = @"StandardPin";
    
    MKPinAnnotationView *aView = (MKPinAnnotationView *)[sender
                                                         dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (aView == nil)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:reuseId];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.canShowCallout = YES;
    }

    
    aView.annotation = annotation;
    
    return aView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    self.selectedPin = [annotation title];
    
    [self performSegueWithIdentifier:@"ViewActivityFromMap" sender:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewActivityFromMap"]) {
    
    // Get destination view
    DSSelectedActitvityViewController *vc = [segue destinationViewController];
    vc.activityTitle = self.selectedPin;
        
    }
}


@end
