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

-(NSMutableArray *)loadTripPhotos:(NSString *) entryId
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
                                      @"SELECT PhotoPath FROM EntryPhotos WHERE EntryId=\"%@\"",
                                      entryId];
                
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(tripDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        NSString *imagePath = [[NSString alloc]
                                               initWithUTF8String:
                                               (const char *) sqlite3_column_text(
                                                                                  statement, 0)];
                        
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

                const char *sql_stmt =
                "CREATE TABLE IF NOT EXISTS Entry (ID INTEGER PRIMARY KEY AUTOINCREMENT, Place TEXT, Note TEXT, StartDate TEXT, EndDate TEXT, Latitude TEXT, Longitude TEXT, Address TEXT, PhotoPath TEXT, EntryDate TEXT)";
                
                
                if (sqlite3_exec(tripDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                {
                    NSLog(@"...created table Entry");

                    sql_stmt =
                    "CREATE TABLE IF NOT EXISTS EntryPhotos (ID INTEGER PRIMARY KEY AUTOINCREMENT, EntryId Text, PhotoPath Text)";
                    
                    if (sqlite3_exec(tripDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                    {
                        NSLog(@"...created table EntryPhotos");
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

-(TripEntry *)saveData:(TripEntry *) entry
{
    const char *dbpath = [self dbPath];
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO Entry (Place, Note, StartDate, EndDate, Latitude, Longitude, Address, PhotoPath, EntryDate) VALUES (\"%@\", \"%@\", \"%@\",\"%@\", \"%@\",\"%@\", \"%@\", \"%@\",\"%@\")",
                                   entry.place, entry.note, entry.startDate, entry.endDate, entry.latitude, entry.longitude, entry.address, entry.photoPath, entry.entryDate];
            
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(tripDB, insert_stmt, -1, &statement, NULL);
            int resultCode = sqlite3_step(statement);
            NSLog(@"...resultCode for saveData:%d", resultCode);
            if (resultCode == SQLITE_DONE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added Entry" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            else
            {
                NSLog(@"...bad resultCode-SQLstmt:%s", insert_stmt);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unabled To Add" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            //tripEntry.tripId = [NSNumber numberWithLongLong:sqlite3_last_insert_rowid(tripDB)];
            entry.entryId = [NSString stringWithFormat:@"%lld", sqlite3_last_insert_rowid(tripDB)];
            
            //NSLog(@"... DBHelper:saveData-%@:%@:%@", tripEntry.place, tripEntry.latitude, tripEntry.longitude);
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: saveData:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return entry;
}

-(TripEntry *)editData:(TripEntry *) entry
{
    const char *dbpath = [self dbPath];
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            NSString *updateSQL = [NSString stringWithFormat:
                                   @"Update Entry Set Place = \"%@\", Note = \"%@\", StartDate = \"%@\", EndDate = \"%@\", Latitude = \"%@\", Longitude = \"%@\", Address = \"%@\" Where Id = %d", entry.place, entry.note, entry.startDate, entry.endDate, entry.latitude, entry.longitude, entry.address, [entry.entryId intValue]];
            
            const char *update_stmt = [updateSQL UTF8String];
            sqlite3_prepare_v2(tripDB, update_stmt, -1, &statement, NULL);
            int resultCode = sqlite3_step(statement);
            NSLog(@"...resultCode for edit entry:%d - stmt:%s", resultCode, update_stmt);
            if (resultCode == SQLITE_DONE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updated Entry" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Update Entry" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }

            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: editData:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return entry;
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
                NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM Entry"];
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(tripDB,
                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    TripEntry* entry;
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        entry = [[TripEntry alloc] init];
                        //trip.tripId = [NSString stringWithFormat:@"%f", sqlite3_column_double(statement, 0)];
                        NSNumber *EntryID = [[NSNumber alloc] initWithLongLong:sqlite3_column_double(statement, 0)];
                        entry.entryId = [EntryID stringValue];
                        
                        entry.place = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 1)];
                        entry.note = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 2)];
                        entry.startDate = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 3)];
                        entry.endDate = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 4)];
                        entry.latitude = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 5)];
                        entry.longitude
                        = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 6)];
                        
                        entry.address
                        = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 7)];
                        
                        entry.photoPath
                        = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 8)];
                        
                        entry.entryDate
                        = [NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, 9)];
                        
                        [tripsTable addObject:entry];
                        entry = nil;
                    } 
                    sqlite3_finalize(statement);
                }
            }
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: selectAllFromDB:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return tripsTable;
}

-(BOOL) deleteTrip:(NSString *) entryId
{
    BOOL success = FALSE;
    const char *dbpath = [self dbPath];

    @try
    {
        if(sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            stmtSQL = [NSString stringWithFormat:
                       @"Delete From EntryPhotos Where EntryId = \"%@\"", entryId];
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                //NSLog(@"..deleted from TripPhotos where TripId:%@", tripId);
                success = TRUE;
            }
            sqlite3_finalize(statement);
            if(success)
            {
                //delete from TripJournal
                stmtSQL = [NSString stringWithFormat:
                           @"Delete From Entry Where Id = %ld", (long)[entryId integerValue]];
                stmt = [stmtSQL UTF8String];
                sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"..DELETED from TripJournal where Id:%@", entryId);
                }
                else
                {
                    NSLog(@"..FAILED to delete from Entry where Id:%@", entryId);
                    success = FALSE;
                }
                sqlite3_finalize(statement);
            }
        }
    }
    @catch(NSException *ex)
    {
        NSLog(@"Exception: Delete Entry:%@", ex.description);
    }
    @finally
    {
        sqlite3_close(tripDB);
    }
    return success;
}

- (NSMutableArray *)deletePhotos:(NSMutableArray *) photosToDelete tripId:(NSString *)entryId tripPhotos:(NSMutableArray *) tripPhotos
{
    const char *dbpath = [self dbPath];
    //NSString *docsDir = [self docsDirPath];
    
    @try
    {
        for (int i = 0; i<photosToDelete.count; i++)
        {
            if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
            {
                stmtSQL = [NSString stringWithFormat:
                           @"Delete From EntryPhotos Where EntryId = \"%@\" and PhotoPath = \"%@\"", entryId, photosToDelete[i]];
                
                stmt = [stmtSQL UTF8String];
                sqlite3_prepare_v2(tripDB, stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"..Deleted Photo: %@", photosToDelete[i]);
                }
                sqlite3_finalize(statement);
                [tripPhotos removeObject:photosToDelete[i]];
            }
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: deletePhotos:%@", ex.description);
    }
    @finally {
        sqlite3_close(tripDB);
    }
    return tripPhotos;
}

-(BOOL)saveSelectedPhotoToDB:(NSString *)photoPath tripId:(NSString *)entryId
{
    const char *dbpath = [self dbPath];
    BOOL success = FALSE;
    
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            stmtSQL = [NSString stringWithFormat:
                         @"INSERT INTO EntryPhotos (EntryId, PhotoPath) VALUES (\"%@\", \"%@\")",
                         entryId, photoPath];
            
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

-(BOOL)setPhotoCover:(NSString *)photoPath entryId:(NSString *)entryId
{
    BOOL success = false;
    const char *dbpath = [self dbPath];
    
    @try
    {
        if (sqlite3_open(dbpath, &tripDB) == SQLITE_OK)
        {
            NSString *updateSQL = [NSString stringWithFormat:
                                   @"Update Entry Set PhotoPath = \"%@\" Where Id = %d", photoPath, [entryId intValue]];
            
            const char *update_stmt = [updateSQL UTF8String];
            sqlite3_prepare_v2(tripDB, update_stmt, -1, &statement, NULL);
            int resultCode = sqlite3_step(statement);
            NSLog(@"...resultCode for edit entry:%d - stmt:%s", resultCode, update_stmt);
            if (resultCode == SQLITE_DONE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updated PhotoCover" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Update PhotoCover" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: setPhotoCover:%@", ex.description);
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
