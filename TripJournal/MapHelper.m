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

-(id)initWithMap:(MKMapView *) myMapView
{
    if (self = [super init])
    {
		mapView = myMapView;
    }
    return self;
}

/*
-(void)addLongPressGesture
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5;
    [mapView addGestureRecognizer:lpgr];
    
    //[self.delegate longPressEvent:self]; //To Be Implemented To Return Updated Lat/Long
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    entryLoc = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    self.latitude = [NSString stringWithFormat:@"%f", entryLoc.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", entryLoc.longitude];
    
    [self addAnnotationToMap];
}
*/

//Set Location info and set this class as the delegate to receive the updates
-(void)setCurrentLocationInfo
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
    
    //get current location
    self.location = self.locationManager.location;
    self.latitude = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
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

-(void)addAnnotationToMap
{
    NSMutableArray * annotationsToRemove = [ mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:mapView.userLocation ] ;
    [ mapView removeAnnotations:annotationsToRemove ] ;
    
    //NSLog(@"..MapHelper:addAnnotationToMap: lat:%f, long:%f", entryLoc.latitude, entryLoc.longitude);
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    [mapView addAnnotation:annotationPoint];
}

-(void)placeAnnotationforMap
{
    entryLoc.latitude = [self.latitude doubleValue];
    entryLoc.longitude = [self.longitude doubleValue];
    
    //NSLog(@"..MapHelper:placeAnnotationForMap: lat:%f, long:%f", entryLoc.latitude, entryLoc.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, RANGE, RANGE);
    [mapView setRegion:region animated:YES];
    
    //[self addAnnotationToMap];
    
    //remove any previous map annotation except current location before placing new pin
    NSMutableArray * annotationsToRemove = [ mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:mapView.userLocation ] ;
    [ mapView removeAnnotations:annotationsToRemove ] ;
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    [mapView addAnnotation:annotationPoint];
}

@end
