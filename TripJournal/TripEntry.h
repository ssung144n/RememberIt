//
//  TripEntry.h
//  TripJournal
//
//  Created by Sora Sung on 1/27/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripEntry : NSObject

@property (nonatomic,strong) NSString *place;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *photoPath;
@property (nonatomic,strong) NSString *entryDate;

@property (nonatomic,strong) NSString *entryId;

//construtor
-(id)initWithValues:(NSArray *) entryValues;

+(NSString *)checkDateForToday:(NSString *)entryDate;
+(NSString *)currentDate;

@end

