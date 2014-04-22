//
//  EntryViewController.m
//  RememberIt
//
//  Created by Sora Sung on 4/1/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "EntryViewController.h"
#import "EntryViewTableCell.h"
#import "TripEntry.h"
#import "MapHelper.h"
#import "MapViewController.h"
#import "DBHelper.h"
#import "TripsTableViewController.h"
#import "PhotosTripViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAsset.h>

@interface EntryViewController ()

#define SCROLLUP 65
#define ROWTOSCROLL 2

@end

@implementation EntryViewController

NSMutableArray *entryListItems;
NSMutableArray *entryListItemsSwitch;
//NSString * selectedImage = @"";
MapHelper *mapHelper;
DBHelper *dbHelper;
BOOL isEdit = NO;
NSString *listTitle;

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
    
    dbHelper = [[DBHelper alloc] init];
    [dbHelper createDB];
    
    entryListItems = [[NSMutableArray alloc] init];
    entryListItemsSwitch = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:gesture];
    
    mapHelper = [[MapHelper alloc] init];
    
    if(![mapHelper haveLocationServices])
        self.mapView.hidden = true;
    [mapHelper setDelegate:self];
    
     //self.navigationItem.hidesBackButton = YES;
    [self validateCamera];
    if(self.entry.entryId)
    {
        [self setEditEntry];
    }
    else
    {
        self.entry = [[TripEntry alloc] init];
        [mapHelper setCurrentLocationInfo]; //if first time loading app, init loc manager, loc, current loc, etc
        
        isEdit = false;
        [self newEntryListItemRecord]; //insert first list item row
        self.emailButton.hidden = TRUE;
        //selectedImage = @"";
        self.labelMorePhotos.hidden = YES;
    }
    
    [self.note.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [[self.note layer] setBorderWidth:2.3];
    [[self.note layer] setCornerRadius:10];
    [self.note setClipsToBounds: YES];
    
    [self.buttonPhoto.layer setBorderColor: [[UIColor greenColor] CGColor]];
    [[self.buttonPhoto layer] setBorderWidth:2.3];
    [[self.buttonPhoto layer] setCornerRadius:10];
    [self.buttonPhoto setClipsToBounds: YES];
    
    //dismiss virtual keyboard on textview
    [self dismissKeyBoardRecognizer];

    //set listTbl for editing from start
    [super setEditing:YES animated:YES];
    [self.listTbl setEditing:YES animated:NO];
    
    self.entryDate.text = [TripEntry checkDateForToday:[TripEntry currentDate]];
    
    self.name.layer.borderWidth = 2.0f;
    [[self.name layer] setCornerRadius:10];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"..viewWillAppear: will callsetLocationMapInfo - lat:%@, lon:%@", mapHelper.latitude, mapHelper.longitude);

    [self setMapAndPhoto];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self performSegueWithIdentifier:@"ToMapFromEntry" sender:self];
}

-(void)setEditEntry
{
    isEdit = true;
    self.navigationItem.title = self.entry.place;
    self.name.text = self.entry.place;
    self.note.text = self.entry.note;
    
    self.emailButton.hidden = NO;
    [self setEntryCoverPhoto];
    
    //get list items
    NSMutableArray *returnList = [dbHelper selectFromTbl:@"EntryListItems" colNames:@[@"ListItem", @"ListItemSwitch"] whereCols:@[@"EntryId"] whereColValues:@[self.entry.entryId] orderByDesc:false];
    
    if(returnList && returnList.count > 0)
    {
        for(int i=0;i<returnList.count;i++)
        {
            NSArray *listItemRow = returnList[i];
            [entryListItems addObject:listItemRow[0]];
            [entryListItemsSwitch addObject:listItemRow[1]];
        }
    }
    else
    {
        [self newEntryListItemRecord];
    }
}

-(void)setEntryCoverPhoto
{
    if(self.entry.photoPath.length)
    {
        (NSLog(@"..EVC:setEntryPhoto-entryId:%@, photoPath:%@", self.entry.entryId, self.entry.photoPath));
        if(self.entry.entryId)
            self.labelMorePhotos.hidden = NO;
        else
            self.labelMorePhotos.hidden = YES;
        __block UIImage *photo = nil;
        
        NSURL* aURL = [NSURL URLWithString:self.entry.photoPath];
        //selectedImage = self.entry.photoPath;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             photo = [UIImage imageWithCGImage:[asset thumbnail] scale:1.0 orientation:UIImageOrientationUp];
             self.buttonPhoto.imageView.image = photo;
         }
         failureBlock:^(NSError *error)
         {
             NSLog(@"...Error:setEntryCoverPhoto - %@", error.description);
         }];
    }
    else
    {
        self.labelMorePhotos.hidden = YES;
        self.buttonPhoto.imageView.image = [UIImage imageNamed:@"camerared1.png"];
    }
}

-(void)newEntryListItemRecord
{
    [entryListItems addObject:@""];
    [entryListItemsSwitch addObject:[NSNumber numberWithBool:NO]]; //not checked..aka not selected when first added
}


//called with viewWillAppear - all views with Nav Back - capture updated changes for Map and Photo
-(void)setMapAndPhoto
{
    if(self.entry.entryId)
    {
        //NSLog(@"..EVC:setMapAndPhoto:entryId:%@, coverPhoto:%@", self.entry.entryId, self.entry.photoPath);
        NSMutableArray *returnList = [dbHelper selectFromTbl:@"Entry" colNames:@[@"PhotoPath"] whereCols:@[@"ID"]  whereColValues:@[self.entry.entryId]  orderByDesc:NO];
        if(returnList.count > 0)
        {
            NSLog(@"..EVC:setMapAndPhoto: returnList:%@", returnList[0]);
            NSArray *returnRow = returnList[0];
            NSLog(@"..EVC:setMapAndPhoto: returnList:%@", returnRow[0]);
            if(![returnRow[0] isEqualToString:@""])
            {
                self.entry.photoPath = returnRow[0];
                [self setEntryCoverPhoto];
            }
        }
        
        NSLog(@"..EVC:setMapAndPhoto:entryId:%@, coverPhoto:%@", self.entry.entryId, self.entry.photoPath);
    }
    
    if(self.entry.latitude && self.entry.longitude)
    {
        mapHelper.latitude = self.entry.latitude;
        mapHelper.longitude = self.entry.longitude;
    }
    
    if(mapHelper.latitude && [mapHelper.latitude intValue] != 0)
    {
        [mapHelper placeAnnotationforMap:self.mapView setRegion:TRUE];
    }
}

//MAKE ALERT CLASS to handle alert creation
-(void) validateCamera
{
    //validate if user using physical device with camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        self.buttonPhoto.enabled = false;
    }
}

//dismiss the keyboard
-(void)dismissKeyBoardRecognizer
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //view to catch  tap
    UIView *view = [[UIView alloc] init];
    
    //leave the navigation bar alone
    view.frame = CGRectMake(0, 60, screenWidth, screenHeight-60);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
}

-(void)dismissKeyboard {
    if([self.note isFirstResponder])
        [self.note resignFirstResponder];
    else if([self.name isFirstResponder])
        [self.name resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([entryListItems[entryListItems.count - 1] isEqualToString:@""])
        listTitle = [NSString stringWithFormat:@"List: %u Items", (entryListItems.count-1)];
    else
        listTitle = [NSString stringWithFormat:@"List: %lu Items", (unsigned long)entryListItems.count];
    
    return listTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 25;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (int)[entryListItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = (int)indexPath.row;
    
    static NSString *CellIdentifier = @"ListCell";
    EntryViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //may not need to check for nil since setting Identifier in IB
    if (cell == nil) {
        cell = [[EntryViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    
    cell.listItem.text = entryListItems[rowNum];
    
    NSNumber *switchOnOff = [NSNumber numberWithInteger: [entryListItemsSwitch[rowNum] integerValue]];
    if([switchOnOff boolValue])
        cell.listItem.backgroundColor = [UIColor lightGrayColor];
    else
        cell.listItem.backgroundColor = [UIColor whiteColor];
    
    cell.listItemDoneButton.selected = [switchOnOff boolValue];
    
    //[cell.listItem addTarget:self action:@selector(listItemChanged:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    cell.delegate = self;

    return cell;
}

//http://www.codigator.com/tutorials/ios-uitableview-tutorial-custom-cell-and-delegates/
//protocol delegate in custom tablecell for controlEvent for textField
- (void)textFieldChangedCell:(id)sender
{
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    
    EntryViewTableCell *selectedCell = (EntryViewTableCell *)sender;
    NSString *txtValue = selectedCell.listItem.text;
    
    entryListItems[row] = [self checkForQuotes:txtValue];
    [self.listTbl reloadData]; //so section list title will update
}

//protocol delegate in custom tablecell to move up view so keyboard doesn't block list entry item
- (void)textFieldEditingBeginCell:(id)sender
{
    //calculate where cursor is (y height) and size of keyboard, and adjust view frame accordingly...
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    if(row > ROWTOSCROLL)
    {
        CGRect frame = self.view.frame;
        int origY = frame.origin.y;
        frame.origin.y = origY-SCROLLUP;
        
        [self.view setFrame:frame];
    }
}

//protocol delegate in custom tablecell to move up view so keyboard doesn't block list entry item
- (void)textFieldEditingEndCell:(id)sender
{
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    if(row > ROWTOSCROLL)
    {
        CGRect frame = self.view.frame;
        int origY = frame.origin.y;
        frame.origin.y = origY+SCROLLUP;
        
        [self.view setFrame:frame];
    }
}
//protocol delegate for buttonCheckBox
- (void)buttonListItemCell:(id)sender
{
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    
    EntryViewTableCell *selectedCell = (EntryViewTableCell *)sender;

    entryListItemsSwitch[row] = [NSNumber numberWithBool:selectedCell.listItemDoneButton.selected];
    if(selectedCell.listItemDoneButton.selected)
        selectedCell.listItem.backgroundColor = [UIColor lightGrayColor];
    else
        selectedCell.listItem.backgroundColor = [UIColor whiteColor];
}
//----------------------------------

/*
 //alternative solution-add target selection method
-(void)listItemChanged:(id)sender;
{
    UITextField *txtField = (UITextField *) sender;
    NSLog(@"..listItemChanged:superview*3%@", [[[sender superview] superview] superview]);
    
    EntryViewTableCell *selectedCell = (EntryViewTableCell *)[[[sender superview] superview] superview];
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:selectedCell];

    NSLog(@"Changed listitem:%@ - indexpath:%d", txtField.text, (int)indexpath.row);
}
*/


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == ([entryListItems count])) //if last row, insert style
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;

}

//delete or insert in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [entryListItems removeObjectAtIndex:indexPath.row];
        [entryListItemsSwitch removeObjectAtIndex:indexPath.row];
        
        [self.listTbl reloadData];//so section list title will update
        
        //[self.listTbl deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self tableView:tableView titleForHeaderInSection:indexPath.section];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Add a row if the current row has value
        NSString *temp = [entryListItems[indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if(![temp isEqualToString:@""])
        {
            [self newEntryListItemRecord];
            [self.listTbl reloadData];
            
            //scroll down to last entry
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: entryListItems.count-1 inSection: 0];
            [self.listTbl scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)removeKB:(id)sender {
    [sender resignFirstResponder];
}

//------------- map ------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ToMapFromEntry"]) {
        MapViewController *vc = [segue destinationViewController];
        
        self.entry.latitude = mapHelper.latitude;
        self.entry.longitude = mapHelper.longitude;
        
        [vc setSelectedTrip: self.entry];
    }
    else if([segue.identifier isEqualToString:@"ToPhotos"]) {
        PhotosTripViewController *vc = [segue destinationViewController];
        [vc setSelectedTrip:self.entry];
    }
}

//---------------- camera -----------------------
// TO DO - popup selection of take photo or select existing photo

- (IBAction)buttonPhotoPick:(id)sender {
    //NSLog(@"..EVC:buttonPhotoPick: %@", self.entry.photoPath);
    //if have cover photo - button pick goes to +Photos button
    if(self.entry.entryId && self.entry.photoPath.length)
        [self performSegueWithIdentifier:@"ToPhotos" sender:self];
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.buttonPhoto.imageView.image = chosenImage;
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];
        
        self.entry.photoPath = [imageUrl absoluteString];
        NSLog(@"..EVC:didFinishPickingMediaWithInfo: %@", self.entry.photoPath);
        [self setEntryCoverPhoto];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self setEntryCoverPhoto]; //if cancel on imagePicker, reset to previous cover photo
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//----check all text inputs for quotes and replace with something else ..single quote?
-(BOOL)validateForSave
{
    if(!self.name.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name is required" message:@""
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return false;
    }
    else
        return  true;
}

-(NSString *)checkForQuotes:(NSString *)txtValue
{
    NSString *noQuotes = [txtValue stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    return noQuotes;
}

- (IBAction)saveButtonClick:(id)sender {
    
    if(![self validateForSave])
        return;
    
    self.entry.place = self.name.text;
    self.entry.note = self.note.text;

    //self.entry.photoPath = selectedImage;
    self.entry.latitude = mapHelper.latitude;
    self.entry.longitude = mapHelper.longitude;
   
    self.entry = [dbHelper saveEntry:self.entry];
     NSLog(@"..EVC:saveButtonClick-Id:%@, entry photo:%@",self.entry.entryId, self.entry.photoPath);
    
    if(self.entry.entryId && self.entry.entryId.length)
    {
        self.emailButton.hidden = NO;
        if(self.entry.photoPath.length)
        {
            self.labelMorePhotos.hidden = NO;
            //check if photo path in entry
            NSArray *returnList = [dbHelper selectFromTbl:@"EntryPhotos"  colNames:@[@"PhotoPath"]  whereCols:@[@"EntryId", @"PhotoPath"] whereColValues:@[self.entry.entryId, self.entry.photoPath] orderByDesc:false];

            if(returnList.count == 0)
                [dbHelper insertInToTbl:@"EntryPhotos" colNames:@[@"EntryId, PhotoPath"] colValues:@[self.entry.entryId, self.entry.photoPath] multiple:false];
        }
        
        if(isEdit)
        {
            //delete existing entrylist first
            [dbHelper deleteFromTbl:@"EntryListItems" whereCol:@"EntryId" whereValues:@[self.entry.entryId] andCol:nil andValue:nil];
        }
        
        NSMutableArray *entryItemsToAdd = [[NSMutableArray alloc]initWithCapacity:entryListItems.count];
        for(int i=0;i<entryListItems.count;i++)
        {
            if(![entryListItems[i] isEqualToString:@""])
                [entryItemsToAdd addObject:[NSString stringWithFormat:@"%@\",\"%@\",\"%@", self.entry.entryId, entryListItems[i], entryListItemsSwitch[i] ]];
        }
        if(entryItemsToAdd.count > 0)
        {
            NSString *lastRowId = [dbHelper insertInToTbl:@"EntryListItems" colNames:@[@"EntryId, ListItem, ListItemSwitch"] colValues:entryItemsToAdd multiple:YES];
            NSLog(@"..EVC:saveButtonClick-adding entries:last row:%@", lastRowId);
        }
    }
    else
        NSLog(@"..saveEntry returned with empty entryId");
}

- (IBAction)sendEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"RememberIt - %@", self.entry.place];
    NSMutableString *msgBody = [NSMutableString stringWithFormat:@"Note: %@\r\n", self.entry.note];
    if(entryListItems && entryListItems.count > 0)
    {
        [msgBody appendFormat:@"%@\r\n", listTitle];
        if(!(entryListItems.count == 1 && [entryListItems[0] isEqualToString:@""]))
        {
            for(int i=0;i<entryListItems.count;i++)
            {
                if(![entryListItems[i] isEqualToString:@""])
                {
                    if([entryListItemsSwitch[i] intValue] == 1)
                        [msgBody appendFormat:@"  *<Done> %@\r\n", entryListItems[i]];
                    else
                        [msgBody appendFormat:@"  *%@\r\n", entryListItems[i]];
                }
                
            }
        }
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    [mc setSubject:emailTitle];
    [mc setMessageBody:[NSMutableString stringWithString:msgBody] isHTML:NO];
    
    if(!([self.entry.photoPath isEqualToString:@""]))
    {
        NSData* photoData = UIImageJPEGRepresentation(self.buttonPhoto.imageView.image, 1.0);
        [mc addAttachmentData:photoData mimeType:@"image/jpeg" fileName:@"Entry Photo"];
    }
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)updateMap
{
    //NSLog(@"..EntryViewController:updateMap - latitude: %@", mapHelper.latitude);
    [mapHelper placeAnnotationforMap:self.mapView setRegion:TRUE];
}

@end
