//
//  DBHelper.h
//  TripJournal
//
//  Created by Sora Sung on 3/1/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "TripEntry.h"

@interface DBHelper : NSObject

//properties for TripViewController - Add Trip
-(TripEntry *)saveData:(TripEntry *) entry;
-(TripEntry *)editData:(TripEntry *) entry;

-(void) createDB;

//properties for TripsTableViewController - My Trips
-(NSMutableArray *)selectAllFromDB;

//properties for PhotosTripViewController
-(NSMutableArray *)loadTripPhotos:(NSString *) tripId;
-(BOOL) deleteTrip:(NSString *) tripId;
- (NSMutableArray *)deletePhotos:(NSMutableArray *) photosToDelete tripId:(NSString *)tripId tripPhotos:(NSMutableArray *) tripPhotos;
-(BOOL)saveSelectedPhotoToDB:(NSString *)imagePath tripId:(NSString *)tripId;
-(BOOL)setPhotoCover:(NSString *)photoPath entryId:(NSString *)entryId;

@end
