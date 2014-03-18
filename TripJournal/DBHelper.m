//
//  DBHelper.m
//  TripJournal
//
//  Created by Sora Sung on 3/1/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

sqlite3 *tripDB;
NSString *DBFILE = @"trips.db";
NSString *stmtSQL;
const char *stmt;
sqlite3_stmt *statement;

-(NSMutableArray *)loadTripPhotos:(NSString *) tripId
{
    //select photos from tripId
    NSMutableArray *tripPhotos = [[NSMutableArray alloc] init];
    const char *dbpath = [self dbPath];
    NSString *databasePath = [self databasePath];
    
    @try{
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath:databasePath])
        {
            if (sqlite3_open(dbpath, & tripDB) == SQLITE_OK)
            {
                NSString *querySQL = [NSString stringWithFormat:
                                      @"SELECT imagePath FROM TripPhotos WHERE TripId=\"%@\"",
                                      tripId];
                
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(tripDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        NSString *imagePath = [[NSString alloc]
                                               initWithUTF8String:
                                               (const char *) sqlite3_column_text(
                                                                                  statement, 0)];
                        
                        //NSLog(@"..db loadTriphotos - photoPath:%@", imagePath);
                        [tripPhotos addObject:imagePath];
                        
                    }
                    //NSLog(@"..db loadTriphotos - tripPhotos.count:%lu", (unsigned long)tripPhotos.count);
                    sqlite3_finalize(statement);
                }
            }
        }//db exists
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: Select from TripPhotos");
    }
    @finally {
        sqlite3_close(tripDB);
    }
    
    return tripPhotos;
}

-(void)createDB
{
    const char *dbpath = [self dbPath];
    NSString *databasePath = [self databasePath];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    @try
    {
        if ([filemgr fileExistsAtPath: databasePath ] == NO) //first time to app - db doesn't exist
        {
            if (sqlite3_open(dbpath, & tripDB) == SQLITE_OK){
                
                char *errMsg;
                //create the TripJournal table
                const char *sql_stmt =
                "CREATE TABLE IF NOT EXISTS TripJournal (ID INTEGER PRIMARY KEY AUTOINCREMENT, Place TEXT, Note TEXT, StartDate TEXT, EndDate TEXT, Latitude TEXT, Longitude TEXT)";
                
                
                if (sqlite3_exec(tripDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                {
                    //NSLog(@"...created table TRIPJournal");
                    
                    //create the TripJournal table
                    sql_stmt =
                    "CREATE TABLE IF NOT EXISTS TripPhotos (ID INTEGER PRIMARY KEY AUTOINCREMENT, TripId Text, ImagePath Text)";
                    
                    if (sqlite3_exec(tripDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                    {
                        NSLog(@"...created table TripPhotos");
                    }
                }
            }
            else{
                NSLog(@"Failed - Error: DB");
            }
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: createDB:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
}

-(TripEntry *)saveData:(TripEntry *) tripEntry
{
    const char *dbpath = [self dbPath];
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO TripJournal (Place, Note, StartDate, EndDate, Latitude, Longitude) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                                   tripEntry.place, tripEntry.note, tripEntry.startDate, tripEntry.endDate, tripEntry.latitude,tripEntry.longitude];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(tripDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added trip" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unabled to add tripo" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            //tripEntry.tripId = [NSNumber numberWithLongLong:sqlite3_last_insert_rowid(tripDB)];
            tripEntry.tripId = [NSString stringWithFormat:@"%lld", sqlite3_last_insert_rowid(tripDB)];
            
            NSLog(@"... DBHelper:saveData-%@:%@:%@", tripEntry.place, tripEntry.latitude, tripEntry.longitude);
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: createDB:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return tripEntry;
}

-(NSMutableArray *)selectAllFromDB
{
    NSMutableArray *tripsTable = [[NSMutableArray alloc] initWithCapacity:10];
    
    const char *dbpath = [self dbPath];
    NSString *databasePath = [self databasePath];
    
    @try{
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath: databasePath])
        {
            if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
            {
                NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM TripJournal"];
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(tripDB,
                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    TripEntry* trip;
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        trip = [[TripEntry alloc] init];
                        //trip.tripId = [NSString stringWithFormat:@"%f", sqlite3_column_double(statement, 0)];
                        NSNumber *tripID = [[NSNumber alloc] initWithLongLong:sqlite3_column_double(statement, 0)];
                        trip.tripId = [tripID stringValue];
                        
                        trip.place = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 1)];
                        trip.note = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 2)];
                        trip.startDate = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 3)];
                        trip.endDate = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 4)];
                        trip.latitude = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 5)];
                        trip.longitude
                        = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 6)];
                        
                        [tripsTable addObject:trip];
                        trip = nil;
                    } 
                    sqlite3_finalize(statement);
                }
            }
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: selectAllFromDB");
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return tripsTable;
}

-(BOOL) deleteTrip:(NSString *) tripId
{
    BOOL success = FALSE;
    const char *dbpath = [self dbPath];

    @try
    {
        if(sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            stmtSQL = [NSString stringWithFormat:
                       @"Delete From TripPhotos Where TripId = \"%@\"", tripId];
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"..deleted from TripPhotos where TripId:%@", tripId);
                success = TRUE;
            }
            sqlite3_finalize(statement);
            if(success)
            {
                //delete from TripJournal
                stmtSQL = [NSString stringWithFormat:
                           @"Delete From TripJournal Where Id = %ld", (long)[tripId integerValue]];
                stmt = [stmtSQL UTF8String];
                sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"..DELETED from TripJournal where Id:%@", tripId);
                }
                else
                {
                    NSLog(@"..FAILED to delete from TripJournal where Id:%@", tripId);
                    success = FALSE;
                }
                sqlite3_finalize(statement);
            }
        }
    }
    @catch(NSException *ex)
    {
        NSLog(@"Exception: Delete Trip:%@", ex.description);
    }
    @finally
    {
        sqlite3_close(tripDB);
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleted Trip"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleted Trip" message:@""
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
         */
    }
    return success;
}

- (NSMutableArray *)deletePhotos:(NSMutableArray *) photosToDelete tripId:(NSString *)tripId tripPhotos:(NSMutableArray *) tripPhotos
{
    const char *dbpath = [self dbPath];
    //NSString *docsDir = [self docsDirPath];
    
    @try
    {
        for (int i = 0; i<photosToDelete.count; i++)
        {
            if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
            {
                //stmtSQL = [NSString stringWithFormat:@"Delete From TripPhotos Where TripId = \"%@\"", tripId];
                stmtSQL = [NSString stringWithFormat:
                           @"Delete From TripPhotos Where TripId = \"%@\" and ImagePath = \"%@\"", tripId, photosToDelete[i]];
                
                stmt = [stmtSQL UTF8String];
                sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"..Deleted Photo: %@", photosToDelete[i]);
                }
                sqlite3_finalize(statement);
                [tripPhotos removeObject:photosToDelete[i]];
            }
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: deleteTripPhotos:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return tripPhotos;
}

-(BOOL)saveSelectedPhotoToDB:(NSString *)imagePath tripId:(NSString *)tripId
{
    const char *dbpath = [self dbPath];
    BOOL success = FALSE;
    
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            stmtSQL = [NSString stringWithFormat:
                         @"INSERT INTO TripPhotos (TripId, ImagePath) VALUES (\"%@\", \"%@\")",
                         tripId, imagePath];
            
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
            
            int result = sqlite3_step(statement);
            if (result == SQLITE_OK || result == SQLITE_DONE)
                success = TRUE;
            else
                NSLog(@"...result of saveSelectedPhotoToDB - %d:%s", result, sqlite3_errmsg(tripDB));

            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: saveSelectedPhotoToDB:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }

    return success;
}

-(const char *)dbPath
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc]
                              initWithString: [docsDir stringByAppendingPathComponent:DBFILE]];
    const char *dbpath = [databasePath UTF8String];
    return dbpath;
}

-(NSString *)docsDirPath
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    return docsDir;
}

-(NSString *)databasePath
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc]
                              initWithString: [docsDir stringByAppendingPathComponent:DBFILE]];
    return databasePath;
}
@end
