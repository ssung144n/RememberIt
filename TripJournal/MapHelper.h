//
//  MapHelper.h
//  RememberIt
//
//  Created by Sora Sung on 4/8/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapHelper : NSObject <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@property (strong, nonatomic) MKMapItem *destination;

-(void) setLocationInfo;
-(void)placeAnnotationforMap:(MKMapView *)mapView;

@end
