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

NSString *addPhotoImage = @"camerared1.png";

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
    tripPhotos = [[NSMutableArray alloc] init];
    
    if([self.selectedTrip.latitude intValue] == 0)
        self.mapBarButton.enabled = false;
    
    NSArray *returnList = [dbHelper selectFromTbl:@"EntryPhotos" colNames:@[@"PhotoPath"] whereCols:@[@"EntryId"] whereColValues:@[self.selectedTrip.entryId] orderByDesc:false ];
    
    if(returnList)
    {
        for(int i=0;i<returnList.count;i++)
        {
            NSArray *returnRow = returnList[i];
            [tripPhotos addObject:returnRow [0]];
        }
    }
    
    self.title = self.selectedTrip.place;
    photosToDelete = [NSMutableArray array];
    
    self.photoCollectionView.allowsMultipleSelection = TRUE;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(longPressHandler:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.photoCollectionView addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"...PhotosViewController:viewWillAppear");
    [self.photoCollectionView reloadData];
}

 - (void)longPressHandler:(UILongPressGestureRecognizer *)lpgr {
     
     if (lpgr.state == UIGestureRecognizerStateBegan) {
         //UIGestureRecognizerStateBegan, UIGestureRecognizerStateEnded
         
         CGPoint p = [lpgr locationInView:self.photoCollectionView];
         
         NSIndexPath *indexPath = [self.photoCollectionView indexPathForItemAtPoint:p];
         if (indexPath != nil) {
             selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
             
             //if image is addPhotoImage - go to select photos action
             if([selectedPhoto isEqualToString:addPhotoImage])
                 [self selectPhotos:self];
             else
                 [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
         }
     }
 }

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(-60, 0, 0, 0); // top, left, bottom, right
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
    if(tripPhotos.count == 0)
    {
        [tripPhotos addObject:addPhotoImage];
        //NSLog(@"..Photos...nuberOfItemsInSection - %@", addPhotoImage);
    }
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
    bgColorView.layer.cornerRadius = 12;
    //bgColorView.layer.borderWidth = 3.0f;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    //instantiate the imageview in each cell
    UIImageView *photoView = (UIImageView *)[cell viewWithTag:99];
    
    NSString *photo = tripPhotos[indexPath.row];
    //check if photo exists-------
    if([photo isEqualToString:self.selectedTrip.photoPath])
    {
        UIView *bgColorViewCP = [[UIView alloc] init];
        bgColorViewCP.backgroundColor = [UIColor greenColor];
        bgColorViewCP.layer.cornerRadius = 12;
        bgColorViewCP.layer.masksToBounds = YES;
        [cell setBackgroundView:bgColorViewCP];
    }
    else
        cell.backgroundView = nil;

    if([photo isEqualToString:addPhotoImage])
    {
        photoView.image = [UIImage imageNamed:photo];
        //NSLog(@"..Photos...CelllforItemIndex:photo - %@", photoView.image);
    }
    else
    {
    NSURL* aURL = [NSURL URLWithString:photo];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         if(asset)
         {
             UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[asset thumbnail] scale:1.0 orientation:UIImageOrientationUp];
             
             photoView.image = copyOfOriginalImage;
         }
         else
             [self nonExistingPhoto:photo];
     }
     
        failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"...PhotosTripView:cellForItemAtIndexPath: error - %@", error.description);
     }];
    }
    return cell;
}
     
-(void)nonExistingPhoto:(NSString *)photo
{
    //NSLog(@"...PhotosTripView:nonExistingPhoto: %@", photo);
    [tripPhotos removeObject:photo];

    [dbHelper deleteFromTbl:@"EntryPhotos" whereCol:@"EntryId" whereValues:@[self.selectedTrip.entryId] andCol:@"PhotoPath" andValue:photo];
    
    if([photo isEqualToString:self.selectedTrip.photoPath])
    {
        NSLog(@"...PhotosTripView:nonExistingPhoto: - is cover photo - so update:%@", photo);
        [dbHelper updateTbl:@"Entry" colNames:@[@"PhotoPath"] colValues:@[@""] whereCol:@"Id" whereValue:self.selectedTrip.entryId];
        
        self.selectedTrip.photoPath = @"";
    }
    [self.photoCollectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
    [photosToDelete addObject:selectedPhoto];
    //NSLog(@"..did SELECT Item:%@", selectedPhoto);
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
    [photosToDelete removeObject:selectedPhoto];
    //NSLog(@"..did REMOVE SelectItem:%@", selectedPhoto);
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

}


//when user confirms on cover photo
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) //confirm yes on alertView
    {
        [dbHelper updateTbl:@"Entry" colNames:@[@"PhotoPath"]  colValues:@[selectedPhoto]  whereCol:@"Id" whereValue:self.selectedTrip.entryId];
        self.selectedTrip.photoPath = selectedPhoto;
        NSLog(@"...cover photo:%@", selectedPhoto);
        [self.photoCollectionView reloadData];
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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//since added segues from IB, is button action event even necessary?
- (IBAction)showMap:(id)sender {
    [self performSegueWithIdentifier:@"ToMap" sender:self];
}

- (IBAction)deletePhotos:(id)sender
{
    //NSLog(@"..deletePhotos:num - %lu", (unsigned long)photosToDelete.count);
    BOOL success = [dbHelper deleteFromTbl:@"EntryPhotos" whereCol:@"PhotoPath" whereValues:photosToDelete andCol:@"EntryId" andValue:self.selectedTrip.entryId];
    
    if(success)
    {
        if([photosToDelete containsObject:self.selectedTrip.photoPath])
        {
            //NSLog(@"..deletePhotos:cover photo in deleted photos:%@", self.selectedTrip.photoPath);
            [dbHelper updateTbl:@"Entry" colNames:@[@"PhotoPath"] colValues:@[@""] whereCol:@"Id" whereValue:self.selectedTrip.entryId];
            self.selectedTrip.photoPath = @"";
        }
        for (int i = 0; i<photosToDelete.count; i++)
        {
            [tripPhotos removeObject:photosToDelete[i]];
        }
        
        [self.photoCollectionView reloadData];
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];

        selectedPhoto = [imageUrl absoluteString];
        
        NSString *insertRowId = [dbHelper insertInToTbl:@"EntryPhotos" colNames:@[@"EntryId, PhotoPath"] colValues:@[self.selectedTrip.entryId, selectedPhoto] multiple:false];
        
        if(insertRowId)
        {
            if([tripPhotos[0] isEqualToString:addPhotoImage])
                [tripPhotos removeObject:addPhotoImage];
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

