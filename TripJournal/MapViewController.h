//
//  MapViewController.h
//  TripJournal
//
//  Created by Sora Sung on 2/24/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripEntry.h"

@interface MapViewController : UIViewController

@property (strong, nonatomic) TripEntry *selectedTrip;

@property (weak, nonatomic) IBOutlet MKMapView *tripMap;

@end
