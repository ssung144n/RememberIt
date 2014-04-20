//
//  MapViewController.m
//  TripJournal
//
//  Created by Sora Sung on 2/24/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
{
    #define RANGE 15000
    MapHelper *mapHelper;
}
@end

@implementation MapViewController

//CLLocationCoordinate2D entryLoc;

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
    mapHelper = [[MapHelper alloc] init];
    self.tripMap.delegate = self; //MKMapViewDelegate
    
    //set saved location
    mapHelper.latitude = self.selectedTrip.latitude;
    mapHelper.longitude = self.selectedTrip.longitude;
    
    //entryLoc.latitude = [self.selectedTrip.latitude doubleValue];
    //entryLoc.longitude = [self.selectedTrip.longitude doubleValue];
    
    [mapHelper placeAnnotationforMap:self.tripMap setRegion:TRUE];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5;
    [self.tripMap addGestureRecognizer:lpgr];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tripMap];
    [mapHelper setTouchLocation:self.tripMap touchPoint:touchPoint];
    
    self.selectedTrip.latitude = mapHelper.latitude;
    self.selectedTrip.longitude = mapHelper.longitude;
    /*
    entryLoc = [self.tripMap convertPoint:touchPoint toCoordinateFromView:self.tripMap];
    
    self.selectedTrip.latitude = [NSString stringWithFormat:@"%f", entryLoc.latitude];
    self.selectedTrip.longitude = [NSString stringWithFormat:@"%f", entryLoc.longitude];
    mapHelper.latitude = self.selectedTrip.latitude;
    mapHelper.longitude = self.selectedTrip.longitude;
     */
    [mapHelper placeAnnotationforMap:self.tripMap setRegion:FALSE];
    /*
    NSMutableArray * annotationsToRemove = [ self.tripMap.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:self.tripMap.userLocation ] ;
    [ self.tripMap removeAnnotations:annotationsToRemove ] ;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    [self.tripMap addAnnotation:annotationPoint];
    */
    
    NSLog(@"..MapViewController:handleLongPress:lat:%@, lon:%@", self.selectedTrip.latitude, self.selectedTrip.longitude);
}

/*
- (void)viewWillAppear:(BOOL)animated {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, RANGE, RANGE);
    [self.tripMap setRegion:region animated:YES];
    
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    [self.tripMap addAnnotation:annotationPoint];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)useMapApp
{
    //CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(entryLoc.latitude, entryLoc.longitude);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([mapHelper.latitude doubleValue], [mapHelper.longitude doubleValue]);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.selectedTrip.place];
    
    // Set the directions mode to "Driving"
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];
}

- (IBAction)getDirections:(id)sender {
    self.tripMap.showsUserLocation = YES;
    //use default map app for iOS (moves away from RememberIt)
    [self useMapApp];
}


@end
