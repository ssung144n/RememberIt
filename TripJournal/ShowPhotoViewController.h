//
//  ShowPhotoViewController.h
//  TripJournal
//
//  Created by Sora Sung on 3/15/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TripEntry.h"

@interface ShowPhotoViewController : UIViewController

@property (weak, nonatomic) NSString *photoPath;
//@property (weak, nonatomic) NSString *entryId;
@property (strong, nonatomic) TripEntry *selectedTrip;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (IBAction)done:(id)sender;
- (IBAction)setAsCoverPhoto:(id)sender;

@end
