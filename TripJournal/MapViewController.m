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

CLLocationCoordinate2D entryLoc;
MKRoute *route;

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
    self.tripMap.delegate = self;
    self.directionsStep.editable = false;
}

- (void)viewWillAppear:(BOOL)animated {
    
    entryLoc.latitude = [self.selectedTrip.latitude doubleValue];
    entryLoc.longitude = [self.selectedTrip.longitude doubleValue];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, 300*METERS_PER_MILE, 300*METERS_PER_MILE);
    
    [self.tripMap setRegion:region animated:YES];
    
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = entryLoc;
    annotationPoint.title = self.selectedTrip.place;
    [self.tripMap addAnnotation:annotationPoint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getDirections:(id)sender {
    self.tripMap.showsUserLocation = YES;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:entryLoc addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    
    request.destination = mapItem;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle error
         } else {
             route = response.routes.lastObject;
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    NSMutableString *steps = [[NSMutableString alloc] init];
    
    //To do - calc distance and set an appropriate span
    int regionSpan = route.distance * 1.2;
    NSLog(@"...showRoute-regionSpan:distance:regionSpan::%f,%d",route.distance, regionSpan);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, regionSpan, regionSpan);
    [self.tripMap setRegion:region animated:YES];
    
    for (MKRoute *route in response.routes)
    {
        [self.tripMap addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
            [steps appendString:@"->"];
            [steps appendString:step.instructions];
            [steps appendString:@"\n"];
        }
    }
    self.directionsStep.text = steps;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

@end
