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
/*
@protocol MapHelperDelegate
@optional
- (void)longPressEvent:(id)sender;
@end
*/
@interface MapHelper : NSObject <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

-(id)initWithMap:(MKMapView *) myMapView;

-(void)setCurrentLocationInfo;
-(void)placeAnnotationforMap:(MKMapView *)mapView;

-(BOOL)haveLocationServices;
//-(void)addLongPressGesture;

//@property (nonatomic, strong) id delegate;

@end
