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

#import <MobileCoreServices/MobileCoreServices.h>

@interface EntryViewController ()

@end

@implementation EntryViewController

NSMutableArray *entryListItems;
NSMutableArray *entryListItemsSwitch;
NSString * selectedImage;
MapHelper *myMapHelper;

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
    
    entryListItems = [[NSMutableArray alloc] init];
    entryListItemsSwitch = [[NSMutableArray alloc] init];
    [self newEntryListItemRecord];

    [self.note.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [[self.note layer] setBorderWidth:2.3];
    [[self.note layer] setCornerRadius:10];
    [self.note setClipsToBounds: YES];
    
    //method to dismiss virtual keyboard on textview
    [self dismissKeyBoardRecognizer];

    //set listTbl for editing from start
    [super setEditing:YES animated:YES];
    [self.listTbl setEditing:YES animated:NO];
    
    self.entryDate.text = [self currentDateTime];
    
    [self validateCamera];
    
    myMapHelper = [[MapHelper alloc] init];
    [myMapHelper setLocationInfo];
    [myMapHelper placeAnnotationforMap:self.mapView];
    self.mapView.delegate = self;
    /*
     self.address1.enabled = false;
     self.address2.enabled = false;
     */
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


-(NSString *)currentDateTime
{
    NSDate *date = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy hh:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
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
    
    /*
    else if([self.address1 isFirstResponder])
        [self.address1 resignFirstResponder];
    else if([self.address2 isFirstResponder])
        [self.address2 resignFirstResponder];
     */
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
    int rows = (int)[entryListItems count];
    
    NSLog(@"..numberOfRowsInSection:%d", rows);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = (int)indexPath.row;
    //NSLog(@"..cellForRowAtIndexPath:%d", rowNum);
    
    static NSString *CellIdentifier = @"ListCell";
    EntryViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //may not need to check for nil since setting Identifier in IB
    if (cell == nil) {
        cell = [[EntryViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    
    cell.listItem.text = entryListItems[rowNum];
    
    NSNumber *switchOnOff = entryListItemsSwitch[rowNum];
    if([switchOnOff isEqualToNumber:[NSNumber numberWithBool:false]])
        cell.listItem.backgroundColor = [UIColor lightGrayColor]; //default is whitecolore
    
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
    
    NSLog(@"...textFieldChangedCell:row:%@:%d", txtValue, row);
    
    entryListItems[row] = txtValue;
    entryListItemsSwitch[row] = [NSNumber numberWithBool:selectedCell.listItemSwitch.on];
}

//protocol delegate in custom tablecell to move up view so keyboard doesn't block last list entry item
//check if textField is last one in listTbl, if so - scroll view up by ~ 20 (do in DidBegin...) do opp when done
- (void)textFieldEditingBeginCell:(id)sender
{
    //calculate where cursor is (y height) and size of keyboard, and adjust view frame accordingly...
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    if(row > 2)
    {
        CGRect frame = self.view.frame;
        int origY = frame.origin.y;
        frame.origin.y = origY-65;
        
        [self.view setFrame:frame];
        //NSLog(@"...textFIeldEditingBeginCell:origY:y - %d:%f", origY, frame.origin.y);
    }
}

//protocol delegate in custom tablecell to move up view so keyboard doesn't block last list entry item
//check if textField is last one in listTbl, if so - scroll view up by ~ 20 (do in DidBegin...) do opp when done
- (void)textFieldEditingEndCell:(id)sender
{
    NSIndexPath *indexpath = [self.listTbl indexPathForCell:sender];
    int row = (int)indexpath.row;
    if(row > 2)
    {
        CGRect frame = self.view.frame;
        int origY = frame.origin.y;
        frame.origin.y = origY+65;
        
        [self.view setFrame:frame];
        //NSLog(@"...textFIeldEditingEndCell:origY:y - %d:%f", origY, frame.origin.y);
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

/*
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"..editingStyleForRowAtIndexPath:%ld", (long)indexPath.row);
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
        //
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Add the row from the data source
        [self newEntryListItemRecord];

        NSLog(@"...commitEditingStyle-Insert:#entryListItems: %d", entryListItems.count);
              
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
/*
- (IBAction)locSwitchToggle:(id)sender {
    if(self.locSwitch.on) {
        self.address1.enabled = FALSE;
        self.address1.text = @"Address";
        
        self.address2.enabled = FALSE;
        self.address2.text = @"City, State or Zipcode";
    }
    
    else {
        self.address1.enabled = TRUE;
        self.address2.enabled = TRUE;

    }
}

- (IBAction)address1EditBegin:(id)sender {
    
    int yMove = 150;
    UITextField *textfield= (UITextField*)sender;
    if([textfield.text isEqualToString:@"Address"] || [textfield.text isEqualToString:@"City, State or Zipcode"])
        textfield.text = @"";
    
    if(textfield == self.address2)
        yMove = 170;
    
    CGRect frame = self.view.frame;
    int origY = frame.origin.y;
    frame.origin.y = origY-yMove;
    
    [self.view setFrame:frame];
}


- (IBAction)address1EditEnd:(id)sender {
    
    int yMove = 150;
    UITextField *textfield= (UITextField*)sender;
    if(textfield == self.address2)
        yMove = 170;
    
    CGRect frame = self.view.frame;
    int origY = frame.origin.y;
    frame.origin.y = origY+yMove;
    
    [self.view setFrame:frame];
    
}
*/

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self performSegueWithIdentifier:@"ToMapFromEntry" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ToMapFromEntry"]) {
        MapViewController *vc = [segue destinationViewController];
        
        TripEntry *entry = [[TripEntry alloc] init];
        self.selectedTrip = entry;
        
        self.selectedTrip.latitude = myMapHelper.latitude; //why null?
        self.selectedTrip.longitude = myMapHelper.longitude;

        //NSLog(@"..prepareForSegue:lat/long: %@/%@", self.selectedTrip.latitude, myMapHelper.latitude);
        
        self.selectedTrip.place = @"Current Loc";
        
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
/*
 - (IBAction)selectPhotoPicked:(id)sender {
 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
 picker.delegate = self;
 picker.allowsEditing = YES;
 picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 
 [self presentViewController:picker animated:YES completion:NULL];
 }
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.buttonPhoto.imageView.image = chosenImage;
    NSLog(@"..didFinishPickingMedia...:%@", chosenImage.description);
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];
        
        selectedImage = [imageUrl absoluteString];
        NSLog(@"..didFinishPickingMedia...:%@", selectedImage);
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
        //later save photo
        /*
         Boolean success = [dbHelper saveSelectedPhotoToDB:selectedImage tripId:self.selectedTrip.entryId];
         selectedPhoto = selectedImage;
         [tripPhotos addObject:selectedImage];
         */
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)saveButtonClick:(id)sender {
    TripEntry *trip = [[TripEntry alloc] init];
    trip.place = self.name.text;
    trip.note = self.note.text;
    trip.startDate = @"";
    trip.endDate = @"";
    trip.endDate = self.entryDate.text;
    trip.photoPath = selectedImage;
    
    NSLog(@"..saving entry:name, note, photoPath, list items count:%@:%@:%@,%d", trip.place, trip.note, trip.photoPath, entryListItems.count);
    
    //need new table for entry list item and if complete or not
}
@end
