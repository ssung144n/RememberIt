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
    tripPhotos = [dbHelper loadTripPhotos:self.selectedTrip.tripId];
    
    self.tripName.text = self.selectedTrip.place;
    self.tripNote.text = self.selectedTrip.note;

    photosToDelete = [NSMutableArray array];
    
    self.photoCollectionView.allowsMultipleSelection = TRUE;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(longPressHandler:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.photoCollectionView addGestureRecognizer:lpgr];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(-55, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.tripSegControls.selectedSegmentIndex =  UISegmentedControlNoSegment;
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

- (void)longPressHandler:(UILongPressGestureRecognizer *)gr {

    if (gr.state == UIGestureRecognizerStateBegan) {
        //UIGestureRecognizerStateBegan, UIGestureRecognizerStateEnded
        
        CGPoint p = [gr locationInView:self.photoCollectionView];
        
        NSIndexPath *indexPath = [self.photoCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            selectedPhoto = [tripPhotos objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
        }
    }
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
    bgColorView.layer.cornerRadius = 5;
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
    else if([segue.identifier isEqualToString:@"BackToMyTrips"]) {
        TripsTableViewController *vc = [segue destinationViewController];
        [vc setTripId: self.selectedTrip.tripId];
    }
    else if([segue.identifier isEqualToString:@"ShowPhoto"]) {
        ShowPhotoViewController *vc = [segue destinationViewController];
        [vc setPhotoName:selectedPhoto];
        //NSLog(@"...prepareForSegue-ShowPhoto:%@", selectedPhoto);
    }
}


//when user confirms delete on trip, then delete and remove current controller
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        Boolean success = [dbHelper deleteTrip:self.selectedTrip.tripId];
        if(success)
            [self.navigationController popViewControllerAnimated:YES];
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
        
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}

- (IBAction)deleteEntry:(id)sender {
    NSString * msg = [NSString stringWithFormat:@"Confirm delete: %@", self.selectedTrip.place];
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:msg message:@"" delegate: self cancelButtonTitle: @"YES"  otherButtonTitles:@"NO",nil];
    
    [updateAlert show];
}

- (IBAction)showMap:(id)sender {
    [self performSegueWithIdentifier:@"ToMap" sender:self];
}

- (IBAction)deletePhotos:(id)sender {
    tripPhotos = [dbHelper deletePhotos:photosToDelete tripId:self.selectedTrip.tripId tripPhotos:tripPhotos];
    [self.photoCollectionView reloadData];
    self.tripSegControls.selectedSegmentIndex =  UISegmentedControlNoSegment;
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];

        NSString *selectedImage = [imageUrl absoluteString];
        //NSLog(@"...selectedImage: %@", selectedImage);
        
        Boolean success = [dbHelper saveSelectedPhotoToDB:selectedImage tripId:self.selectedTrip.tripId];
        if(success)
        {
            [tripPhotos addObject:selectedImage];
            [self. photoCollectionView reloadData];
        }
    }
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

