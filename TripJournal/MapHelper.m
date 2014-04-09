//
//  MapHelper.m
//  RememberIt
//
//  Created by Sora Sung on 4/8/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "MapHelper.h"

@implementation MapHelper

//Set CoreLocation info and set this class as the delegate to receive the updates
-(void)setLocationInfo
{
    //check for location service
    if(![self haveLocationServices])
        return;
    
    //init location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
    
    //get location
    self.location = self.locationManager.location;
    self.latitude = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    
    NSLog(@"...setlocation:lat:lat - %@:%@", self.latitude, self.longitude);
}

-(BOOL)haveLocationServices
{
    BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
    if (!locationAllowed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"Location Related Features Will Be Disabled On This App Unless Location Services Are Re-Enabled"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return locationAllowed;
}

-(void)placeAnnotationforMap:(MKMapView *)mapView
{
    
    CLLocationCoordinate2D entryLoc;
    //set saved location
    entryLoc.latitude = [self.latitude doubleValue];
    entryLoc.longitude = [self.longitude doubleValue];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, 5000, 5000);
    
    [mapView setRegion:region animated:YES];
    
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    annotationPoint.title = @"Current Loc";
    [mapView addAnnotation:annotationPoint];
}

@end
