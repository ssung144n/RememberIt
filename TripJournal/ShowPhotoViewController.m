//
//  ShowPhotoViewController.m
//  TripJournal
//
//  Created by Sora Sung on 3/15/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "ShowPhotoViewController.h"
#import "DBHelper.h"
#import "PhotosTripViewController.h"

@interface ShowPhotoViewController ()

@end

@implementation ShowPhotoViewController

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

    NSURL* aURL = [NSURL URLWithString:self.photoPath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:1.0 orientation:UIImageOrientationUp];
         
         self.photoImageView.image = copyOfOriginalImage;
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"...Error: Photo doesn't exist");
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
 */

- (IBAction)setAsCoverPhoto:(id)sender {
    
    DBHelper *dbHelper = [[DBHelper alloc] init];
    [dbHelper updateTbl:@"Entry" colNames:@[@"PhotoPath"] colValues:@[self.photoPath]  whereCol:@"Id" whereValue:self.selectedTrip.entryId];
    NSLog(@"..SPC:setAsCoverPhoto-entry photo:%@",self.selectedTrip.photoPath);
    //self.selectedTrip.photoPath = self.photoPath;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
