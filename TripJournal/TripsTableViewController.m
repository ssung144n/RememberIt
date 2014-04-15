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
#import "EntryViewController.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dbHelper = [[DBHelper alloc] init];
    
    NSArray *returnList= [dbHelper selectFromTbl:@"Entry" colNames:[[NSArray alloc] initWithObjects:@"Id", @"Place", @"Note", @"StartDate", @"EndDate", @"Latitude", @"Longitude", @"Address", @"PhotoPath", @"EntryDate", nil] whereCols:nil whereColValues:nil];
    
    tripsTable = [[NSMutableArray alloc] initWithCapacity:returnList.count];
    for(int i=0;i<returnList.count;i++)
    {
        NSArray *returnRow = returnList[i];
        //NSLog(@"..entryRow id:%@, place:%@", returnRow[0], returnRow[1] );
        //TripEntry *entry = [TripEntry returnEntry:returnRow];
        TripEntry *entry = [[TripEntry alloc] initWithValues:returnRow];
        if(entry)
        {
            [tripsTable addObject:entry];
            //NSLog(@"..entry id:%@, place:%@", entry.entryId, entry.place);
        }
        else
            NSLog(@"..entry is nil");
        
        entry = nil;

    }
    
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
    tripDates = [NSString stringWithFormat:@"%@", trip.entryDate];
    cell.detailTextLabel.text = tripDates;
    if(trip.photoPath.length > 0)
    {
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
    
    [self performSegueWithIdentifier:@"tripsToPhotos" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //this tells us where we are going
    if ([segue.identifier isEqualToString:@"tripsToPhotos"]) {
        PhotosTripViewController *vc = [segue destinationViewController];
        [vc setSelectedTrip:selectedTrip];
    }
    //net setting selected trip = so will be nil
    /*
    else if ([segue.identifier isEqualToString:@"ToEntry"]) {
        EntryViewController *vc = [segue destinationViewController];
        [vc setSelectedTrip:nil];
    }
     */
}


//swipe to delete entry
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        selectedTrip = tripsTable[indexPath.row];
        BOOL success = [dbHelper deleteFromTbl:@"EntryPhotos" whereCol:@"EntryId" whereValues:[[NSArray alloc] initWithObjects:selectedTrip.entryId, nil] andCol:nil andValue:nil];
        
        //BOOL success = [dbHelper deleteFromTbl:selectedTrip.entryId colName:@"EntryId" tblName:@"EntryPhotos"];
        if(success)
            success = [dbHelper deleteFromTbl:@"EntryListItems" whereCol:@"EntryId" whereValues:[[NSArray alloc] initWithObjects:selectedTrip.entryId, nil] andCol:nil andValue:nil];
            //success = [dbHelper deleteFromTbl:selectedTrip.entryId colName:@"EntryId" tblName:@"EntryListItems"];
        if(success)
            success = [dbHelper deleteFromTbl:@"Entry" whereCol:@"Id" whereValues:[[NSArray alloc] initWithObjects:selectedTrip.entryId, nil] andCol:nil andValue:nil];
            //success = [dbHelper deleteFromTbl:selectedTrip.entryId colName:@"Id" tblName:@"Entry"];
        
        if(success)
        {
            [tripsTable removeObjectAtIndex:indexPath.row];
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
}


@end
