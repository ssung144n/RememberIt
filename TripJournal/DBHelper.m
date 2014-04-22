//
//  DBHelper.m
//  TripJournal
//
//  Created by Sora Sung on 3/1/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

sqlite3 *rememberItDB;
NSString *DBFILE = @"rememberIt.db";
NSString *stmtSQL;
const char *stmt;
sqlite3_stmt *statement;


-(void)createDB
{
    const char *dbpath = [self dbPath];
    NSString *databasePath = [self databasePath];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    @try
    {
        if ([filemgr fileExistsAtPath: databasePath ] == NO) //first time to app - db doesn't exist
        {
            if (sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK){
                char *errMsg;

                const char *sql_stmt =
                "CREATE TABLE IF NOT EXISTS Entry (ID INTEGER PRIMARY KEY AUTOINCREMENT, Place TEXT, Note TEXT, StartDate TEXT, EndDate TEXT, Latitude TEXT, Longitude TEXT, Address TEXT, PhotoPath TEXT, EntryDate TEXT)";
                
                
                if (sqlite3_exec(rememberItDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                {
                    NSLog(@"...created table Entry");

                    sql_stmt =
                    "CREATE TABLE IF NOT EXISTS EntryPhotos (ID INTEGER PRIMARY KEY AUTOINCREMENT, EntryId Text, PhotoPath Text)";
                    
                    if (sqlite3_exec(rememberItDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                    {
                        NSLog(@"...created table EntryPhotos");
                    }
                    
                    sql_stmt =
                    "CREATE TABLE IF NOT EXISTS EntryListItems (ID INTEGER PRIMARY KEY AUTOINCREMENT, EntryId Text, ListItem Text, ListItemSwitch Integer)";
                    
                    if (sqlite3_exec(rememberItDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                    {
                        NSLog(@"...created table EntryListItems");
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
        sqlite3_close(rememberItDB);
    }
}


-(TripEntry *)saveEntry:(TripEntry *) entry
{
    const char *dbpath = [self dbPath];
    
    if(entry.entryId && entry.entryId.length)
    {
        stmtSQL = [NSString stringWithFormat:
                               @"Update Entry Set Place = \"%@\", Note = \"%@\", StartDate = \"%@\", EndDate = \"%@\", Latitude = \"%@\", Longitude = \"%@\", Address = \"%@\", PhotoPath = \"%@\" Where Id = %d", entry.place, entry.note, entry.startDate, entry.endDate, entry.latitude, entry.longitude, entry.address, entry.photoPath, [entry.entryId intValue]];
    
    
    }
    else
    {
        stmtSQL = [NSString stringWithFormat:
                   @"INSERT INTO Entry (Place, Note, StartDate, EndDate, Latitude, Longitude, Address, PhotoPath, EntryDate) VALUES (\"%@\", \"%@\", \"%@\",\"%@\", \"%@\",\"%@\", \"%@\", \"%@\",\"%@\")",
                   entry.place, entry.note, entry.startDate, entry.endDate, entry.latitude, entry.longitude, entry.address, entry.photoPath, entry.entryDate];
    }
    
    @try
    {
        if (sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK)
        {
            //NSLog(@"..saveData:%@", stmtSQL);

            const char *sql_stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(rememberItDB, sql_stmt, -1, &statement, NULL);
            int resultCode = sqlite3_step(statement);
            NSLog(@"...resultCode for saveData:%d", resultCode);
            if (resultCode == SQLITE_DONE)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved Entry" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            else
            {
                NSLog(@"...bad resultCode-SQLstmt:%s", sql_stmt);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unabled To Save" message:@""
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            //tripEntry.tripId = [NSNumber numberWithLongLong:sqlite3_last_insert_rowid(tripDB)];
            if(!(entry.entryId && entry.entryId.length))
                entry.entryId = [NSString stringWithFormat:@"%lld", sqlite3_last_insert_rowid(rememberItDB)];
            
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: saveEntry:%@", ex.description);
    }
    @finally {
        sqlite3_close(rememberItDB);
    }
    return entry;
}


//generic select from table
-(NSMutableArray *) selectFromTbl:(NSString *)tblName colNames:(NSArray *)colNames whereCols:(NSArray *)whereCols whereColValues:(NSArray *)whereColValues orderByDesc:(BOOL)orderByDesc
{
    NSMutableArray *returnRow, *returnList;
    const char *dbpath = [self dbPath];
    
    NSMutableString *myStmt = [NSMutableString stringWithFormat:@"Select "];
    
    for(int i=0;i<colNames.count;i++)
    {
        if(i+1 == colNames.count)
            [myStmt appendString: [NSString stringWithFormat:@"%@", colNames[i]] ];
        else
            [myStmt appendString: [NSString stringWithFormat:@"%@ ,", colNames[i]] ];
    }
    
    [myStmt appendString: [NSString stringWithFormat:@" From %@", tblName] ];
    
    if(whereCols)
    {
        [myStmt appendString: [NSString stringWithFormat:@" Where "] ];
        for(int i=0;i<whereCols.count;i++)
        {
            if(i+1 == whereCols.count)
                [myStmt appendString: [NSString stringWithFormat:@"%@ = \"%@\"" , whereCols[i], whereColValues[i] ]];
            else
                [myStmt appendString: [NSString stringWithFormat:@"%@ = \"%@\" And ", whereCols[i], whereColValues[i] ]];
        }
    }
    if(orderByDesc)
        [myStmt appendString: [NSString stringWithFormat:@" ORDER BY ID DESC"]];
    
    stmtSQL = [NSMutableString stringWithString:myStmt];
    
    //NSLog(@"...selectFromTbl:%@", stmtSQL);
    
    @try
    {
        returnList = [[NSMutableArray alloc] init];
        
        if(sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK)
        {
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(rememberItDB, stmt, -1, &statement, NULL);
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                returnRow = [[NSMutableArray alloc] init];
                
                for(int i=0;i<colNames.count;i++)
                    [returnRow addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text (statement, i)]];
                
                [returnList addObject:returnRow];
                returnRow = nil;
            }
            sqlite3_finalize(statement);
        }
    }
    @catch(NSException *ex)
    {
        NSLog(@"Exception: Select From tbl:%@, error:%@", tblName, ex.description);
    }
    @finally
    {
        sqlite3_close(rememberItDB);
    }
    
    return returnList;
}

//generic delete
-(BOOL) deleteFromTbl:(NSString *)tblName whereCol:(NSString *)whereCol whereValues:(NSArray *)whereValues andCol:(NSString *)andCol andValue:(NSString *)andValue
{
    BOOL success = false;
    const char *dbpath = [self dbPath];
    
    NSMutableString *myStmt = [NSMutableString stringWithFormat:@"Delete From %@ Where %@ In (",tblName, whereCol];
    
    for(int i=0;i<whereValues.count;i++)
    {
        if(i+1 == whereValues.count)
            [myStmt appendString: [NSString stringWithFormat:@"\"%@\")", whereValues[i]] ];
        else
            [myStmt appendString: [NSString stringWithFormat:@"\"%@\" ,", whereValues[i]] ];
        
            //[myStmt appendString: [NSString stringWithFormat:@"%@ ,", (long)[colValues[i]] integerValue] ];
    }
    if(andCol)
        [myStmt appendString: [NSString stringWithFormat:@" And %@ = %@", andCol, andValue] ];
    
    stmtSQL = [NSMutableString stringWithString:myStmt];
    //NSLog(@"..deleteFromTbl:%@", stmtSQL);
    
    @try
    {
        if(sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK)
        {
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(rememberItDB, stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                success = true;
            }
            
            sqlite3_finalize(statement);
        }
    }
    @catch(NSException *ex)
    {
        NSLog(@"Exception: Delete From tbl:%@, error:%@", tblName, ex.description);
    }
    @finally
    {
        sqlite3_close(rememberItDB);
    }
    
    return success;
}

//generic insert, allows for multiple row inserts
-(NSString *)insertInToTbl:(NSString *)tblName colNames:(NSArray *)colNames colValues:(NSArray *)colValues multiple:(BOOL)multiple
{
    const char *dbpath = [self dbPath];
    BOOL success = FALSE;
    NSString *insertRowId;
    
    NSMutableString *myStmt = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", tblName];
    
    for(int i=0;i<colNames.count;i++)
    {
        if(i+1 == colNames.count)
            [myStmt appendString:[NSString stringWithFormat:@"%@) VALUES " , colNames[i]] ];
        else
            [myStmt appendString:[NSString stringWithFormat:@"%@, ", colNames[i]] ];
    }
    
    if(multiple)
    {
        for(int i=0;i<colValues.count;i++)
        {
            //NSLog(@"...colValues:%@", colValues[i]);
            if(i+1 == colValues.count)
                [myStmt appendString:[NSString stringWithFormat:@"(\"%@\")", colValues[i]] ];
            else
                [myStmt appendString:[NSString stringWithFormat:@"(\"%@\"), ", colValues[i]] ];
        }
    }
    else
    {
        if(colValues.count == 1)//if count is 1 - then don't want to insert"( or )" in value returned
            [myStmt appendString: [NSString stringWithFormat:@"(\"%@\")", colValues[0] ]];
        else
        {
            for(int i=0;i<colValues.count;i++)
            {
                if(i+1 == colValues.count)
                    [myStmt appendString: [NSString stringWithFormat:@"\"%@\")", colValues[i] ]];
                else if(i==0)
                    [myStmt appendString: [NSString stringWithFormat:@"(\"%@\", ", colValues[i] ]];
                else
                    [myStmt appendString: [NSString stringWithFormat:@"\"%@\", ", colValues[i] ]];
            }
        }
    }
    
    stmtSQL = [NSMutableString stringWithString:myStmt];
    //NSLog(@"...insertInToTable-multiple: %@", stmtSQL);
    
    @try
    {
        if (sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK)
        {
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(rememberItDB, stmt, -1, &statement, NULL);
            
            int result = sqlite3_step(statement);
            if (result == SQLITE_OK || result == SQLITE_DONE)
                success = TRUE;
            else
                NSLog(@"...result of insertInToTable - %d:%s", result, sqlite3_errmsg(rememberItDB));
            
            insertRowId = [NSString stringWithFormat:@"%lld", sqlite3_last_insert_rowid(rememberItDB)];
            NSLog(@"...insert return rowid:%@", insertRowId);
            
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: insertInToTable:%@", ex.description);
    }
    @finally {
        sqlite3_close(rememberItDB);
    }
    
    return insertRowId;
}

-(BOOL)updateTbl:(NSString *)tblName colNames:(NSArray *)colNames colValues:(NSArray *)colValues whereCol:(NSString *)whereCol whereValue:(NSString *)whereValue
{
    BOOL success = false;
    const char *dbpath = [self dbPath];
    
    NSMutableString *appendSql = [NSMutableString stringWithFormat: @"Update %@ Set ", tblName];
    
    for(int i=0;i<colNames.count;i++)
    {
        if(i+1 == colNames.count)
            [appendSql appendString: [NSString stringWithFormat:@"%@ = \"%@\" ", colNames[i], colValues[i] ]];
        else
            [appendSql appendString: [NSString stringWithFormat:@"%@ = \"%@\",", colNames[i], colValues[i] ]];
    }
    
    if([[whereCol uppercaseString] isEqualToString:@"ID"]) //if primary key, column is Integer type
        [appendSql appendString:[NSString stringWithFormat:@"Where %@ = %ld", whereCol, (long)[whereValue integerValue]] ];
    else
        [appendSql appendString:[NSString stringWithFormat:@"Where %@ = \"%@\"", whereCol, whereValue] ];
    
    stmtSQL = [NSMutableString stringWithString:appendSql];
    
    //NSLog(@"...updateTbl:%@", stmtSQL);
    
    @try
    {
        if (sqlite3_open(dbpath, &rememberItDB) == SQLITE_OK)
        {
            stmt = [stmtSQL UTF8String];
            sqlite3_prepare_v2(rememberItDB, stmt, -1, &statement, NULL);
            
            int result = sqlite3_step(statement);
            if (result == SQLITE_OK || result == SQLITE_DONE)
                success = TRUE;
            else
                NSLog(@"...result of updateTbl - %d:%s", result, sqlite3_errmsg(rememberItDB));
            
            sqlite3_finalize(statement);
        }
    }
    @catch (NSException * ex) {
        NSLog(@"Exception: updateTbl:%@", ex.description);
    }
    @finally {
        sqlite3_close(rememberItDB);
    }
    
    return true;
}

-(const char *)dbPath
{
    NSString *databasePath = [self databasePath];
    const char *dbpath = [databasePath UTF8String];
    return dbpath;
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
