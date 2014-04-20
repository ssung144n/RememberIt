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


-(TripEntry *)saveEntry:(TripEntry *) entry;

-(void) createDB;

-(NSString *)insertInToTbl:(NSString *)tblName colNames:(NSArray *)colNames colValues:(NSArray *)colValues multiple:(BOOL)multiple;

-(BOOL) deleteFromTbl:(NSString *)tblName whereCol:(NSString *)whereCol whereValues:(NSArray *)whereValues andCol:(NSString *)andCol andValue:(NSString *)andValue;

-(NSMutableArray *) selectFromTbl:(NSString *)tblName colNames:(NSArray *)colNames whereCols:(NSArray *)whereCols whereColValues:(NSArray *)whereColValues orderByDesc:(BOOL)orderByDesc;

-(BOOL)updateTbl:(NSString *)tblName colNames:(NSArray *)colNames colValues:(NSArray *)colValues whereCol:(NSString *)whereCol whereValue:(NSString *)whereValue;

@end
