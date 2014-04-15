//
//  PhotosTripViewController.h
//  TripJournal
//
//  Created by Sora Sung on 2/16/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripEntry.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAsset.h>

@interface PhotosTripViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

//@interface PhotosTripViewController : UIViewController
@property (strong, nonatomic) TripEntry *selectedTrip;

@property (strong, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;

//@property (strong, nonatomic) IBOutlet UILabel *tripName;

- (IBAction)selectPhotos:(id)sender;

//- (IBAction)deleteEntry:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)deletePhotos:(id)sender;
- (IBAction)editEntry:(id)sender;

@end
