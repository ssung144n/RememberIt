//
//  sssAppDelegate.h
//  TripJournal
//
//  Created by Sora Sung on 1/21/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sssAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
