//
//  TripEntry.m
//  TripJournal
//
//  Created by Sora Sung on 1/27/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "TripEntry.h"

@implementation TripEntry


-(NSString *)place
{
    if(_place == nil)
        return @"";
    else
        return [_place stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];;
}

-(NSString *)note
{
    if(_note == nil)
        return @"";
    else
        return [_note stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];;
}


-(NSString *)photoPath
{
    if(_photoPath == nil)
        return @"";
    else
        return _photoPath;
}

-(NSString *)address
{
    if(_address == nil)
        return @"";
    else
        return _address;
}

-(NSString *)startDate
{
    if(_startDate == nil)
        return @"";
    else
        return _startDate;
}

-(NSString *)endDate
{
    if(_endDate == nil)
        return @"";
    else
        return _endDate;
}

-(NSString *)entryDate
{
    if(_entryDate == nil)
    {
        _entryDate = [TripEntry currentDate];
    }
    return _entryDate;
}

+(NSString *)currentDate
{
    NSDate *date = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy hh:mm"];
    return [dateFormatter stringFromDate:date];
}


+(NSString *)checkDateForToday:(NSString *)entryDate
{
    NSDate *today = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy"];
    
    NSString *todayStringCompare = [dateFormatter stringFromDate:today];
    NSArray *entryDateArray = [entryDate componentsSeparatedByString: @" "];
    NSString *entryDateStringCompare = entryDateArray[0];
    
    //NSLog(@"..checkDateForToday:entryDateCompare - %@, todayDateCompare - %@", entryDateStringCompare, todayStringCompare);
    if([todayStringCompare isEqualToString:entryDateStringCompare])
    {
        [dateFormatter setDateFormat:@"MMM-dd-yyyy hh:mm"];
        NSDate *entryDateOrig = [dateFormatter dateFromString:entryDate];
        
        [dateFormatter setDateFormat:@"hh:mm"];
        NSString *hoursMinutes = [dateFormatter stringFromDate:entryDateOrig];
        entryDate = [NSString stringWithFormat:@"Today %@", hoursMinutes];
    }

    return entryDate;
}

-(id)initWithValues:(NSArray *) entryValues
{
	if (self = [super init])
    {
		self.entryId = entryValues[0];
        self.place = entryValues[1];
        self.note = entryValues[2];
        
        self.startDate = entryValues[3];
        self.endDate = entryValues[4];
        self.latitude = entryValues[5];
        self.longitude = entryValues[6];
        
        self.address = entryValues[7];
        self.photoPath = entryValues[8];
        self.entryDate = entryValues[9];
	}
	return self;
}


@end
