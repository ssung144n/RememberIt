//
//  TripsTableViewController.m
//  TripJournal
//
//  Created by Sora Sung on 1/27/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "TripsTableViewController.h"
#import "TripEntry.h"
#import "PhotosTripViewController.h"
#import "TripViewController.h"
#import "DBHelper.h"

#import <AssetsLibrary/ALAsset.h>

@interface TripsTableViewController ()
{
    NSMutableArray *tripsTable;
    TripEntry *selectedTrip;
    DBHelper *dbHelper;
}
@end

@implementation TripsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[super viewWillAppear:animated];
    
    tripsTable = dbHelper.selectAllFromDB;
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dbHelper = [[DBHelper alloc] init];
    tripsTable = dbHelper.selectAllFromDB;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tripsTable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    long rowCount = indexPath.row;
    TripEntry * trip = [tripsTable objectAtIndex:rowCount];
    cell.textLabel.text = trip.place;
    NSString *tripDates;
    
    tripDates = [NSString stringWithFormat:@"%@%@%@", trip.startDate, @"-", trip.endDate];
    cell.detailTextLabel.text = tripDates;
    if(trip.photoPath.length > 0)
    {
        //NSLog(@"..TripsTable..trip.photoPath:%@", trip.photoPath);
        
        __block UIImage *photo = nil;
        NSURL* aURL = [NSURL URLWithString:trip.photoPath];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             photo = [UIImage imageWithCGImage:[asset thumbnail] scale:1.0 orientation:UIImageOrientationUp];
             //NSLog(@"..TripsTable..photoLibAsset-photo:%@", photo.description);
             cell.imageView.image = photo;
         }
                failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"...Error: Photo doesn't exist");
         }];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedTrip = tripsTable[indexPath.row];
    
    //NSLog(@"...didSelectRowAtIndex -  %@:%@:%@:%@", selectedTrip.tripId, selectedTrip.place, selectedTrip.latitude, selectedTrip.longitude);
    
    [self performSegueWithIdentifier:@"tripsToPhotos" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //this tells us where we are going
    if ([segue.identifier isEqualToString:@"tripsToPhotos"]) {
        PhotosTripViewController *vc = [segue destinationViewController];
        
        //this will tell the information controller what trip we have selected
        [vc setSelectedTrip:selectedTrip];
        
        //NSLog(@"..tripsToPhotos:TripsTableViewController - tripId:place: %@:%@", selectedTrip.tripId, selectedTrip.place);
    }
    else if ([segue.identifier isEqualToString:@"ToAddTrip"])
    {
        //TripViewController *vc = [segue destinationViewController];
        //NSLog(@"..ToAddTrip:TripsTableViewController");
    }
}


//swipe to delete entry
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        selectedTrip = tripsTable[indexPath.row];
        BOOL success = [dbHelper deleteTrip:selectedTrip.entryId];
        if(success)
        {
            [tripsTable removeObjectAtIndex:indexPath.row];
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}


@end
