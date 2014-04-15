//
//  TripEntry.m
//  TripJournal
//
//  Created by Sora Sung on 1/27/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "TripEntry.h"

@implementation TripEntry

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
