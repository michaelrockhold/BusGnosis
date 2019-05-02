//
//  BusInfo.m
//
//  Created by Michael Rockhold on 6/23/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "BusInfo.h"

@implementation BusInfo

@synthesize name, description = desc, location;

- (id)initFromName:(NSString*)n Description:(NSString*)d Location:(CLLocation*)l
{
	id this = [super init];
	if (this != nil)
	{
		[(name = n) retain];
		[(desc = d) retain];
		[(location = l) retain];
	}
	return this;
}

- (void)dealloc
{
	[name release];
	[desc release];
	[location release];
	
	[super dealloc];
}

- (NSString*)title
{
	return self.name;
}

- (CLLocationCoordinate2D)coordinate
{
	return location.coordinate;
}

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation
{
	return [self.location getDistanceFrom:otherLocation];
}

@end
