//
//  PhotosTripViewController.m
//  TripJournal
//
//  Created by Sora Sung on 2/16/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "PhotosTripViewController.h"
#import "TripsTableViewController.h"
#import "MapViewController.h"
#import "ShowPhotoViewController.h"
#import "EntryViewController.h"

#import "DBHelper.h"

@interface PhotosTripViewController ()
{
    NSMutableArray *tripPhotos;
    NSMutableArray *photosToDelete;
    NSString *selectedPhoto;
    
    DBHelper *dbHelper;
}
@end

@implementation PhotosTripViewController

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
	// Do any additionl setup after loading the view.
    
    dbHelper = [[DBHelper alloc] init];
    //tripPhotos = [dbHelper loadTripPhotos:self.selectedTrip.entryId];
    
    NSArray *returnList = [dbHelper selectFromTbl:@"EntryPhotos" colNames:[[NSArray alloc] initWithObjects:@"PhotoPath", nil]  whereCols:[[NSArray alloc] initWithObjects:@"EntryId", nil] whereColValues:[[NSArray alloc] initWithObjects:self.selectedTrip.entryId, nil] ];
    
    if(returnList)
    {
       // NSLog(@"...returnList from selectFromTbl: %lu", (unsigned long)returnList.count);
        tripPhotos = [[NSMutableArray alloc] init];
        
        for(int i=0;i<returnList.count;i++)
        {
            NSArray *returnRow = returnList[i];
            //NSLog(@"..photo:%@ - rowCount:%lu", returnRow[0], (unsigned long)returnRow.count);
            [tripPhotos addObject:returnRow [0]];
        }
    }
    
    self.title = self.selectedTrip.place;

    photosToDelete = [NSMutableArray array];
    
    self.photoCollectionView.allowsMultipleSelection = TRUE;
    //self.photoCollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    //self.photoCollectionView.layer.borderWidth = 3.0f;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(longPressHandler:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.photoCollectionView addGestureRecognizer:lpgr];
}

 - (void)longPressHandler:(UILongPressGestureRecognizer *)lpgr {
     
     if (lpgr.state == UIGestureRecognizerStateBegan) {
         //UIGestureRecognizerStateBegan, UIGestureRecognizerStateEnded
         
         CGPoint p = [lpgr locationInView:self.photoCollectionView];
         
         NSIndexPath *indexPath = [self.photoCollectionView indexPathForItemAtPoint:p];
         if (indexPath != nil) {
             selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
             [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
         }
     }
 }

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(-55, 0, 0, 0); // top, left, bottom, right
    //return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tripPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //referencing the attributes of our cell
    static NSString *identifier = @"Cell";
    //start our virtual loop through the cell
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //Highlight the cell selected to red
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor redColor];
    bgColorView.layer.cornerRadius = 8;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    //instantiate the imageview in each cell
    UIImageView *photoView = (UIImageView *)[cell viewWithTag:99];

    NSURL* aURL = [NSURL URLWithString:[tripPhotos objectAtIndex:indexPath.row]];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         //UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.3 orientation:UIImageOrientationUp];
         UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[asset thumbnail] scale:1.0 orientation:UIImageOrientationUp];
         
         
         photoView.image = copyOfOriginalImage;
     }
        failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"...Error: Photo doesn't exist. Removing from tripPhotos list");
         [tripPhotos removeObjectAtIndex:indexPath.row];
     }];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
    [photosToDelete addObject:selectedPhoto];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
    [photosToDelete removeObject:selectedPhoto];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"ToMap"]) {
        MapViewController *vc = [segue destinationViewController];
        [vc setSelectedTrip: self.selectedTrip];
    }
    else if([segue.identifier isEqualToString:@"ShowPhoto"]) {
        ShowPhotoViewController *vc = [segue destinationViewController];
        
        [vc setSelectedTrip: self.selectedTrip];
        [vc setPhotoPath:selectedPhoto];
    }
    else if([segue.identifier isEqualToString:@"ToEdit"]) {
        EntryViewController *vc = [segue destinationViewController];
        //NSLog(@"..ToEditEntry segue-tripId:%@", self.selectedTrip.place);
        [vc setSelectedTrip:self.selectedTrip];
    }
}


//when user confirms delete on trip, then delete and remove current controller
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if(buttonIndex == 0 && [alertView.title isEqualToString:alertSetCoverPhotoTitle])
    if(buttonIndex == 0) //confirm yes on alertView
    {
        [dbHelper updateTbl:@"Entry" colNames:[[NSArray alloc] initWithObjects:@"PhotoPath", nil]  colValues:[[NSArray alloc] initWithObjects:selectedPhoto, nil]  whereCol:@"Id" whereValue:self.selectedTrip.entryId];
        self.selectedTrip.photoPath = selectedPhoto;
    }
}


//selecting photo from photo gallery
- (IBAction)selectPhotos:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        //imagePicker.

        //UIColor * color = [UIColor colorWithRed:255/255.0f green:74/255.0f blue:5/255.0f alpha:1.0f];
        //imagePicker.navigationBar.barTintColor = color;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}
/*
- (IBAction)deleteEntry:(id)sender {
    alertConfirmDelete = [NSString stringWithFormat:@"Confirm delete: %@", self.selectedTrip.place];
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:alertConfirmDelete message:@"" delegate: self cancelButtonTitle: @"YES"  otherButtonTitles:@"NO",nil];
    
    [updateAlert show];
}
*/

//since added segues from IB, is button action event even necessary?
- (IBAction)showMap:(id)sender {
    [self performSegueWithIdentifier:@"ToMap" sender:self];
}

- (IBAction)deletePhotos:(id)sender {
    //tripPhotos = [dbHelper deletePhotos:photosToDelete tripId:self.selectedTrip.entryId tripPhotos:tripPhotos];
    BOOL success = [dbHelper deleteFromTbl:@"EntryPhotos" whereCol:@"PhotoPath" whereValues:photosToDelete andCol:@"EntryId" andValue:self.selectedTrip.entryId];
    
    if(success)
    {
        if([photosToDelete containsObject:selectedPhoto])
        {
            [dbHelper updateTbl:@"Entry" colNames:[[NSArray alloc] initWithObjects:@"PhotoPath", nil] colValues:[[NSArray alloc] initWithObjects:@"", nil] whereCol:@"Id" whereValue:self.selectedTrip.entryId];
            self.selectedTrip.photoPath = @"";
        }
        for (int i = 0; i<photosToDelete.count; i++)
        {
            [tripPhotos removeObject:photosToDelete[i]];
        }
        
        [self.photoCollectionView reloadData];
    }
}

- (IBAction)editEntry:(id)sender {
    [self performSegueWithIdentifier:@"ToEdit" sender:self];
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];

        selectedPhoto = [imageUrl absoluteString];
        
        //Boolean success = [dbHelper saveSelectedPhotoToDB:selectedImage tripId:self.selectedTrip.entryId];
        NSString *insertRowId = [dbHelper insertIntoTbl:@"EntryPhotos" colNames:[[NSArray alloc] initWithObjects:@"EntryId", @"PhotoPath", nil] colValues:[[NSArray alloc] initWithObjects:self.selectedTrip.entryId, selectedPhoto, nil]];
        
        NSLog(@"..didFinishPicking...insertRowId:%@", insertRowId);
        if(insertRowId)
        {
            [self confirmCoverPhoto];
            
            [tripPhotos addObject:selectedPhoto];
            [self. photoCollectionView reloadData];
        }
    }
}

-(void)confirmCoverPhoto
{
    NSString *alertSetCoverPhotoTitle = [NSString stringWithFormat:@"Set As Cover Photo?"];
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:alertSetCoverPhotoTitle message:@"" delegate: self cancelButtonTitle: @"YES"  otherButtonTitles:@"NO",nil];
    
    [updateAlert show];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to save photo" message:@""
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

