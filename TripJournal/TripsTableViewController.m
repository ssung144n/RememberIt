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
#import "EntryViewController.h"

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
    
    NSArray *returnList= [dbHelper selectFromTbl:@"Entry" colNames:@[@"Id", @"Place", @"Note", @"StartDate", @"EndDate", @"Latitude", @"Longitude", @"Address", @"PhotoPath", @"EntryDate"] whereCols:nil whereColValues:nil orderByDesc:true];
    
    tripsTable = [[NSMutableArray alloc] initWithCapacity:returnList.count];
    for(int i=0;i<returnList.count;i++)
    {
        NSArray *returnRow = returnList[i];

        TripEntry *entry = [[TripEntry alloc] initWithValues:returnRow];
        if(entry)
        {
            [tripsTable addObject:entry];
        }
        else
            NSLog(@"..TTVC:viewDidLoad: no entries");
        
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
    NSString *tripDates = [TripEntry checkDateForToday:trip.entryDate];
    //tripDates = [NSString stringWithFormat:@"%@", trip.entryDate];
    cell.detailTextLabel.text = tripDates;
    if(trip.photoPath.length > 0)
    {
        __block UIImage *photo = nil;
        NSURL* aURL = [NSURL URLWithString:trip.photoPath];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             photo = [UIImage imageWithCGImage:[asset thumbnail] scale:1.0 orientation:UIImageOrientationUp];
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
    
    [self performSegueWithIdentifier:@"ToEditEntry" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    else if ([segue.identifier isEqualToString:@"ToNewEntry"]) {
     --Nothing..want to pass in an nil entry
    }
    */
    
    if ([segue.identifier isEqualToString:@"ToEditEntry"])
    {
        NSLog(@"..TTVC:prepareForSegue-ToEditEntry:entry selected: %@", selectedTrip.place);
        EntryViewController *vc = [segue destinationViewController];
        [vc setEntry: selectedTrip];
    }
}


//swipe to delete entry
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        selectedTrip = tripsTable[indexPath.row];
        BOOL success = [dbHelper deleteFromTbl:@"EntryPhotos" whereCol:@"EntryId" whereValues:@[selectedTrip.entryId] andCol:nil andValue:nil];

        if(success)
            success = [dbHelper deleteFromTbl:@"EntryListItems" whereCol:@"EntryId" whereValues:@[selectedTrip.entryId] andCol:nil andValue:nil];

        if(success)
            success = [dbHelper deleteFromTbl:@"Entry" whereCol:@"Id" whereValues:@[selectedTrip.entryId] andCol:nil andValue:nil];
        
        if(success)
        {
            [tripsTable removeObjectAtIndex:indexPath.row];
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
}


@end
