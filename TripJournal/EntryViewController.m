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

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAsset.h>

@interface EntryViewController ()

#define SCROLLUP 65
#define ROWTOSCROLL 2

@end

@implementation EntryViewController

NSMutableArray *entryListItems;
NSMutableArray *entryListItemsSwitch;
NSString * selectedImage = @"";
MapHelper *mapHelper;
DBHelper *dbHelper;
BOOL isEdit = false;

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
    entryListItems = [[NSMutableArray alloc] init];
    entryListItemsSwitch = [[NSMutableArray alloc] init];

    //NSLog(@"EntryViewController:viewDidLoad - alloc/init mapHelper, assign as delegate");
    mapHelper = [[MapHelper alloc] init];
    self.mapView.delegate = self; //for select annotation event
    
    //check if editing
    NSLog(@"..EntryViewController:viewDidLoad - selectedTrip:%@", self.selectedTrip);
    if(self.selectedTrip && self.selectedTrip.entryId)
    {
        isEdit = true;
        [self setEditEntry];

        NSMutableArray *returnList = [dbHelper selectFromTbl:@"EntryListItems" colNames:[[NSArray alloc] initWithObjects:@"ListItem", @"ListItemSwitch", nil] whereCols:[[NSArray alloc] initWithObjects:@"EntryId", nil] whereColValues:[[NSArray alloc] initWithObjects:self.selectedTrip.entryId, nil]];
        
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
            [self newEntryListItemRecord];
    }
    else
    {
        isEdit = false;
        [self newEntryListItemRecord]; //insert first list item row
        selectedImage = @"";
        self.emailButton.hidden = true;
    }
    
    [self.note.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [[self.note layer] setBorderWidth:2.3];
    [[self.note layer] setCornerRadius:10];
    [self.note setClipsToBounds: YES];
    
    //coverPhoto button border
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
    
    [self validateCamera];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"..viewWillAppear: will callsetLocationMapInfo - lat:%@, lon:%@", mapHelper.latitude, mapHelper.longitude);
    [self setLocationMapInfo];
}

-(void)setEditEntry
{
    self.navigationItem.title = @"Edit";
    self.name.text = self.selectedTrip.place;
    self.note.text = self.selectedTrip.note;
    
    [self setEntryCoverPhoto];
}

-(void)setEntryCoverPhoto
{
    if(self.selectedTrip.photoPath.length > 0)
    {
        __block UIImage *photo = nil;
        NSURL* aURL = [NSURL URLWithString:self.selectedTrip.photoPath];
        selectedImage = self.selectedTrip.photoPath;
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
}

-(void)newEntryListItemRecord
{
    [entryListItems addObject:@""];
    [entryListItemsSwitch addObject:[NSNumber numberWithBool:true]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLocationMapInfo
{
    if([mapHelper haveLocationServices])
    {
        if(self.selectedTrip.latitude && self.selectedTrip.longitude)
        {
            mapHelper.latitude = self.selectedTrip.latitude;
            mapHelper.longitude = self.selectedTrip.longitude;
        }
        else
            [mapHelper setCurrentLocationInfo];
        
        if(mapHelper.latitude && [mapHelper.latitude intValue] != 0)
            NSLog(@"...EntryViewController:setLocationMapInfo - mapHelper.latitude and intvalue:%@, %d", mapHelper.latitude, [mapHelper.latitude intValue]);
            
        [mapHelper placeAnnotationforMap:self.mapView];
    }
}

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
    return @"List";
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
    if([switchOnOff isEqualToNumber:[NSNumber numberWithBool:false]])
    {
        cell.listItem.backgroundColor = [UIColor lightGrayColor]; //default is whitecolore
        cell.listItemSwitch.on = false;
    }
    
    //[cell.listItem addTarget:self action:@selector(listItemChanged:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    cell.delegate = self;

    return cell;
}

//http://www.codigator.com/tutorials/ios-uitableview-tutorial-custom-cell-and-delegates/
//protocol delegate in custom tablecell for controlEvent for textField

- (void)textFieldChangedCell:(id)sender {
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    
    EntryViewTableCell *selectedCell = (EntryViewTableCell *)sender;
    NSString *txtValue = selectedCell.listItem.text;
    
    entryListItems[row] = [self checkForQuotes:txtValue];
}

//protocol delegate in custom tablecell to move up view so keyboard doesn't block last list entry item
//check if textField is last one in listTbl, if so - scroll view up by ~ 20 (do in DidBegin...) do opp when done
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

//protocol delegate in custom tablecell to move up view so keyboard doesn't block last list entry item
//check if textField is last one in listTbl, if so - scroll view up by ~ 20 (do in DidBegin...) do opp when done
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
//protocol delegate
- (void)switchToggleCell:(id)sender
{
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    
    EntryViewTableCell *selectedCell = (EntryViewTableCell *)sender;

    BOOL switchOn = selectedCell.listItemSwitch.on;
    entryListItemsSwitch[row] = [NSNumber numberWithBool:switchOn];
    
    if(!switchOn)
        selectedCell.listItem.backgroundColor = [UIColor lightGrayColor];
    else
        selectedCell.listItem.backgroundColor = [UIColor whiteColor];

}

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
    //NSLog(@"..editingStyleForRowAtIndexPath:%ld", (long)indexPath.row);
    if (indexPath.row+1 == ([entryListItems count])) //if last row, insert style
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
    
    //return UITableViewCellEditingStyleNone;
}

//delete or insert in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [entryListItems removeObjectAtIndex:indexPath.row];

        //[self.listTbl reloadData];
        [self.listTbl deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Add the row from the data source
        [self newEntryListItemRecord];
              
        [self.listTbl reloadData];
        
        //scroll down to last entry
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: entryListItems.count-1 inSection: 0];
        [self.listTbl scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
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

//------------- location ------------------------

//MKMapView delegate - when selecting annotation-----------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self performSegueWithIdentifier:@"ToMapFromEntry" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ToMapFromEntry"]) {
        MapViewController *vc = [segue destinationViewController];
        
        if(!(self.selectedTrip && self.selectedTrip.entryId))
        {
            self.selectedTrip = [[TripEntry alloc] init];
        }
        
        self.selectedTrip.latitude = mapHelper.latitude;
        self.selectedTrip.longitude = mapHelper.longitude;
        
        [vc setSelectedTrip: self.selectedTrip];
    }

}

//---------------- camera -----------------------
// TO DO - popup selection of take photo or select existing photo

- (IBAction)buttonPhotoPick:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.buttonPhoto.imageView.image = chosenImage;
    //NSLog(@"..didFinishPickingMedia...:%@", chosenImage.description);
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];
        
        selectedImage = [imageUrl absoluteString];
        //NSLog(@"..didFinishPickingMedia...:%@", selectedImage);
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
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
    
    TripEntry *entry = [[TripEntry alloc] init];
    entry.place = self.name.text;
    entry.note = self.note.text;

    entry.photoPath = selectedImage;
    entry.latitude = mapHelper.latitude;
    entry.longitude = mapHelper.longitude;
    entry.entryId = self.selectedTrip.entryId;
    
    entry = [dbHelper saveEntry:entry];
    
    if(entry.entryId && entry.entryId.length)
    {
        if(selectedImage.length > 0)
        {
            //check if photo path in entry
            NSArray *returnList = [dbHelper selectFromTbl:@"EntryPhotos"  colNames:[[NSArray alloc] initWithObjects:@"PhotoPath", nil]  whereCols:[[NSArray alloc] initWithObjects:@"EntryId", @"PhotoPath", nil] whereColValues:[[NSArray alloc] initWithObjects:entry.entryId, selectedImage, nil] ];
            //if not, add it
            if(returnList.count == 0)
                [dbHelper insertInToTbl:@"EntryPhotos" colNames:[[NSArray alloc] initWithObjects:@"EntryId, PhotoPath", nil] colValues:[[NSArray alloc] initWithObjects:entry.entryId, selectedImage, nil] multiple:false];
        }
        
        if(isEdit)
        {
            //delete existing entrylist first
            [dbHelper deleteFromTbl:@"EntryListItems" whereCol:@"EntryId" whereValues:[[NSArray alloc] initWithObjects:entry.entryId, nil] andCol:nil andValue:nil];
        }
        
        //[dbHelper saveEntryListItems:entry.entryId listItems:entryListItems listItemsSwitch:entryListItemsSwitch];
        NSMutableArray *entryItemsToAdd = [[NSMutableArray alloc]initWithCapacity:entryListItems.count];
        for(int i=0;i<entryListItems.count;i++)
            [entryItemsToAdd addObject:[NSString stringWithFormat:@"%@\",\"%@\",\"%@", entry.entryId, entryListItems[i], entryListItemsSwitch[i] ]];
        NSString *lastRowId = [dbHelper insertInToTbl:@"EntryListItems" colNames:[[NSArray alloc] initWithObjects:@"EntryId, ListItem, ListItemSwitch", nil] colValues:entryItemsToAdd multiple:true];
        if(!lastRowId)//error with insert entryListItems
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Save Entry List Items" message:@""
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
        NSLog(@"..saveEntry returned with empty entryId");
}

- (IBAction)sendEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"RememberIt - %@", self.selectedTrip.place];
    NSMutableString *msgBody = [NSMutableString stringWithFormat:@"Note: %@\r\n", self.selectedTrip.note];
    if(entryListItems && entryListItems.count > 0)
    {
        [msgBody appendFormat:@"List Items:\r\n"];
        if(entryListItems.count == 1 && [entryListItems[0] isEqualToString:@""])
            [msgBody appendFormat:@"...None"];
        else
        {
            for(int i=0;i<entryListItems.count;i++)
            {   if([entryListItemsSwitch[i] intValue] == 1)
                    [msgBody appendFormat:@"  *%@\r\n", entryListItems[i]];
                else
                    [msgBody appendFormat:@"  *<done> %@\r\n", entryListItems[i]];
            }
        }
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    [mc setSubject:emailTitle];
    [mc setMessageBody:[NSMutableString stringWithString:msgBody] isHTML:NO];
    if(![self.selectedTrip.photoPath isEqualToString:@""])
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

@end
