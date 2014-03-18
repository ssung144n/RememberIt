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

@interface ShowPhotoViewController : UIViewController

@property (weak, nonatomic) NSString *photoName;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (IBAction)done:(id)sender;

@end