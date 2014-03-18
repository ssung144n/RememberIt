//
//  MapViewController.m
//  TripJournal
//
//  Created by Sora Sung on 2/24/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

#define METERS_PER_MILE 1609.344

@end

@implementation MapViewController

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
    //self.tripMap.showsUserLocation = YES;
    //NSLog(@"... MapViewController:viewDidLoad-%@:%@:%@", self.selectedTrip.place, self.selectedTrip.latitude, self.selectedTrip.latitude);
}

- (void)viewWillAppear:(BOOL)animated {

    CLLocationCoordinate2D zoomLocation;
    
    zoomLocation.latitude = [self.selectedTrip.latitude doubleValue];
    zoomLocation.longitude = [self.selectedTrip.longitude doubleValue];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(zoomLocation, 300*METERS_PER_MILE, 300*METERS_PER_MILE);
    
    //region.center.latitude = [self.selectedTrip.latitude doubleValue];
    //region.center.longitude = [self.selectedTrip.longitude doubleValue];
    
    //region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.tripMap setRegion:region animated:YES];
    
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = zoomLocation;
    annotationPoint.title = self.selectedTrip.place;
    [self.tripMap addAnnotation:annotationPoint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
