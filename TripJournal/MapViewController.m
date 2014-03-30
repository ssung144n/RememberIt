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
}

- (void)viewWillAppear:(BOOL)animated {

    //CLLocationCoordinate2D zoomLocation;
    
    entryLoc.latitude = [self.selectedTrip.latitude doubleValue];
    entryLoc.longitude = [self.selectedTrip.longitude doubleValue];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, 300*METERS_PER_MILE, 300*METERS_PER_MILE);
    
    //region.center.latitude = [self.selectedTrip.latitude doubleValue];
    //region.center.longitude = [self.selectedTrip.longitude doubleValue];
    
    //region.span = MKCoordinateSpanMake(spanX, spanY);
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
    NSLog(@"...getDirections");
    
    self.tripMap.showsUserLocation = YES;
    
    //To do - calc distance bw 2 places and set an appropriate span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(entryLoc, 20000, 20000);
    [self.tripMap setRegion:region animated:YES];
    
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
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.tripMap addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

@end
