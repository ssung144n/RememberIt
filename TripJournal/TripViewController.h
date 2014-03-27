//
//  TripViewController.h
//  TripJournal
//
//  Created by Sora Sung on 1/21/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "TripEntry.h"

@interface TripViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) TripEntry *selectedTrip;
//Location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;


@property (strong, nonatomic) IBOutlet UITextField *place;
@property (weak, nonatomic) IBOutlet UITextView *note;

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UITextField *startDate;
@property (strong, nonatomic) IBOutlet UITextField *endDate;
@property (strong, nonatomic) IBOutlet UITextField *address;

@property (strong, nonatomic) IBOutlet UISwitch *locSwitch;

@property (strong, nonatomic) IBOutlet UILabel *locLabel;
- (IBAction)locSwitchToggle:(id)sender;

- (IBAction)saveData:(id)sender;
- (IBAction)returnedRemoveKB:(id)sender;

//editing did begin
- (IBAction)enterStartDate:(id)sender;
- (IBAction)enterEndDate:(id)sender;

@end
