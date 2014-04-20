//
//  MapHelper.m
//  RememberIt
//
//  Created by Sora Sung on 4/8/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "MapHelper.h"

@implementation MapHelper

#define RANGE 5000
CLLocationCoordinate2D entryLoc;
MKMapView *mapView;
NSTimer *myTimer;

-(id)initWithMap:(MKMapView *) myMapView
{
    if (self = [super init])
    {
		mapView = myMapView;
    }
    return self;
}


/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
    self.location = [locations lastObject];
    NSDate* eventDate = self.location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        self.latitude  = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
        self.longitude  = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
        
        if([self.latitude intValue] != 0)
        {
            NSLog(@"..didUpdateLocation: lat %+.2f, lon %+.2f",
                  self.location.coordinate.latitude, self.location.coordinate.longitude);
        }
    };
}
*/
-(void)currentLocation
{
    //get current location
    self.location = self.locationManager.location;
    self.latitude = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
}

//Initial set up of mapHelper - Set current location, set as delegate for location
-(void)setCurrentLocationInfo
{
    //check for location service
    if(![self haveLocationServices])
    {
        NSLog(@"..MapHelper:setCurrentLocation - NO location service");
        return;
    }
    //init location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    //[self.locationManager startMonitoringSignificantLocationChanges]; //only with cell tower change..not wifi
    
    self.location = [[CLLocation alloc] init];
    
    //get current location
    [self currentLocation];
    
    NSLog(@"..MapHelper:setCurrentLocation - %@", self.latitude);
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                             selector:@selector(processComplete) userInfo:nil repeats:YES];
}

-(BOOL)haveLocationServices
{
    BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
    UIAlertView *alert;
    
    if (!locationAllowed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                           message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    return locationAllowed;
}

-(void)placeAnnotationforMap:(MKMapView *)mapView setRegion:(BOOL)setRegion
{
    NSLog(@"..MapHelper:placeAnnotation - %@", self.latitude);
    
    entryLoc.latitude = [self.latitude doubleValue];
    entryLoc.longitude = [self.longitude doubleValue];
    
    if([self.latitude intValue] == 0)
        return;
    if(setRegion)
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, RANGE, RANGE);
        [mapView setRegion:region animated:YES];
    }
    
    //remove any previous map annotation except current location before placing new pin
    NSMutableArray * annotationsToRemove = [ mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:mapView.userLocation ] ;
    [ mapView removeAnnotations:annotationsToRemove ] ;
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    [mapView addAnnotation:annotationPoint];
}

- (void)processComplete
{
    [self currentLocation];
    NSLog(@"..MapHelper.processComplete..checking if have current location: latitude: %@", self.latitude);
    if([self.latitude intValue] != 0)
    {
        [[self delegate] updateMap];
        [myTimer invalidate];
    }
}

-(void)setTouchLocation:(MKMapView *)mapView touchPoint:(CGPoint)touchPoint
{
    entryLoc = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    self.latitude = [NSString stringWithFormat:@"%f", entryLoc.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", entryLoc.longitude];
}

@end
