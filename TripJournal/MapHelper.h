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

//@property (strong, nonatomic) MKMapItem *destination;
-(id)initWithMap:(MKMapView *) myMapView;

-(void)setCurrentLocationInfo;
-(void)placeAnnotationforMap;

-(BOOL)haveLocationServices;
//-(void)setCoordinateInfo:(NSString*)latitude longitude:(NSString*)longitude;
//-(void)addLongPressGesture;

//@property (nonatomic, strong) id delegate;

@end
