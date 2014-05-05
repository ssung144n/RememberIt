//
//  EntryViewController.h
//  RememberIt
//
//  Created by Sora Sung on 4/1/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "MapHelper.h"

#import "TripEntry.h"

//Need a delegate to deal with the user interaction with the camera or the photo library.
//So need to conform to the UIImagePickerControllerDelegate protocol.
//Need to present the camera (or the photo library) modally, so need to implement the UINavigationControllerDelegate protocol

//MAY NOT NEED MKMAPVIEWDELEGATE - adding long gesture directly to mapview...won't want other gestures enabled
@interface EntryViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,MFMailComposeViewControllerDelegate, MapHelperDelegate, UITextFieldDelegate>
//<UITableViewDataSource, UITableViewDelegate, TableCellDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UITableView *listTbl;
@property (weak, nonatomic) IBOutlet UILabel *entryDate;
@property (weak, nonatomic) IBOutlet UITextField *name;

@property (strong, nonatomic) TripEntry *entry;

@property (weak, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (weak, nonatomic) IBOutlet UILabel *labelMorePhotos;

- (IBAction)removeKB:(id)sender;

- (IBAction)buttonPhotoPick:(id)sender;
- (IBAction)sendEmail:(id)sender;

- (IBAction)saveButtonClick:(id)sender;

@end
