//
//  TripViewController.m
//  TripJournal
//
//  Created by Sora Sung on 1/21/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "TripViewController.h"
#import "TripsTableViewController.h"
#import "DBHelper.h"
#import "TripEntry.h"

//#import <AddressBookUI/AddressBookUI.h>

@interface TripViewController ()
{
    NSNumber *tripId;
    DBHelper *dbHelper;
    BOOL haveLocationSrv;
}
@end

@implementation TripViewController

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
    
    dbHelper = [[DBHelper alloc] init];
    [dbHelper createDB];
    
    [self loadDatePicker];
    
    haveLocationSrv = [self haveLocationServices];
    self.navigationItem.hidesBackButton = YES;
    
    //Set CoreLocation info and set this view controller as the delegate to receive the updates
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
}
/*
 //Instead of calling delegate methods to be called automatically,calling when adding new trip with setLocation
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = locations.lastObject;
    self.latitude = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    NSLog(@"...location:lat:lat - %@:%@", self.latitude, self.longitude);
}
*/
-(void)setLocation
{
    self.location = self.locationManager.location;
    self.latitude = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    //NSLog(@"...setlocation:lat:lat - %@:%@", self.latitude, self.longitude);
}

-(void)loadDatePicker
{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [datePicker setDate:[NSDate date]];
    
    [datePicker addTarget:self action:@selector(enterEndDate:) forControlEvents:UIControlEventValueChanged];
    [_endDate setInputView:datePicker];
    
    [datePicker addTarget:self action:@selector(enterStartDate:) forControlEvents:UIControlEventValueChanged];
    [_startDate setInputView:datePicker];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)locSwitchToggle:(id)sender {
    if(_locSwitch.on) {
        [_locLabel setText:@"On"];
        _locLabel.textColor = [UIColor blackColor];
        _address.enabled = FALSE;
        _address.backgroundColor = [UIColor lightGrayColor];
        _address.text = @"";
    }
    
    else {
        [_locLabel setText:@"Off"];
        _locLabel.textColor = [UIColor redColor];
        _address.enabled = TRUE;
        _address.backgroundColor = [UIColor whiteColor];
    }

}

-(BOOL)validateEntry
{
    BOOL success = [self isNotEmpty:self.place.text];
    
    if(!success)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Place is required" message:@""
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        //check end date is after start date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateStyle = NSDateFormatterMediumStyle;
        
        NSDate *sDate = [dateFormat dateFromString:self.startDate.text];
        NSDate *eDate = [dateFormat dateFromString:self.endDate.text];
        
        NSComparisonResult result;
        //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
        result = [sDate compare:eDate]; // comparing two dates
        
        if(result==NSOrderedDescending)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"End date can't be less than start date" message:@""
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            success = FALSE;
        }
    }

    return success;
}

-(BOOL)isNotEmpty:(NSString *) value
{
    BOOL success = FALSE;
    NSString *trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(trimmedValue.length > 0)
        success = TRUE;
    return success;
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

- (IBAction)saveData:(id)sender {
    
    if(![self validateEntry])
        return;
    
    __block BOOL success=TRUE;
    __block TripEntry *newTrip = [[TripEntry alloc] init]; //need write access to var
    
    newTrip.place =self.place.text;
    newTrip.note = self.note.text;
    newTrip.startDate = self.startDate.text;
    newTrip.endDate = self.endDate.text;
    
    //Use Forward-Geocoding to get Location if enter address
    if(self.address.text.length > 0 && haveLocationSrv)
    {
        /*
         check error code: https://developer.apple.com/library/mac/documentation/Networking/Reference/CFNetworkErrors/Reference/reference.html
        */
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_address.text completionHandler:^(NSArray *placemarks, NSError *error) {
            
            //NSLog(@"..saving location:%@ - %ld", error, (long)error.code);
            if (error && error.code == 8) {
                NSLog(@"Invalid address: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to save: Invalid address" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                success = FALSE;
            }
            else if (error && (error.code == -1009 || error.code == 2)) {
                NSLog(@"Invalid address: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to save: Please check WiFi permissions" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                success = FALSE;
            }
            else {
                CLPlacemark *placemark = [placemarks lastObject];

                newTrip.latitude = [NSString stringWithFormat: @"%f", placemark.location.coordinate.latitude];
                newTrip.longitude = [NSString stringWithFormat: @"%f", placemark.location.coordinate.longitude];
                //NSLog(@"...saveData - Address:%@ - %@:%@", _address.text, newTrip.latitude, newTrip.longitude);
                newTrip = [dbHelper saveData:newTrip];
            }
        }];
    }
    else //get current user location
    {
        [self setLocation];
        newTrip.latitude = self.latitude;
        newTrip.longitude = self.longitude;
        
        //NSLog(@"...saveData - Current - %@:%@", self.latitude, self.longitude);
        newTrip = [dbHelper saveData:newTrip];
    }
    
    if(success)
    {
        self.place.text = @"";
        self.note.text = @"";
        self.startDate.text = @"";
        self.endDate.text = @"";
        self.address.text = @"";
    }
}

- (IBAction)returnedRemoveKB:(id)sender {
    [sender resignFirstResponder];
}


- (IBAction)enterStartDate:(id)sender {
    if([_startDate isFirstResponder]){
        UIDatePicker *picker = (UIDatePicker*)_startDate.inputView;

        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterMediumStyle;
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]]);
        self.startDate.text = [NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]];
        picker = nil;
    }
}

- (IBAction)enterEndDate:(id)sender {
    if([_endDate isFirstResponder]){
        UIDatePicker *picker = (UIDatePicker*)_endDate.inputView;
        //_endDate.text = [NSString stringWithFormat:@"%@",picker.date];
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterMediumStyle;
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]]);
        self.endDate.text = [NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]];
        picker = nil;
    }
}


@end
