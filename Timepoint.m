//
//  Timepoint.m
//  MakeTimepointsDatabaseFromXML
//
//  Created by Michael Rockhold on 5/30/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Timepoint.h"


@implementation Timepoint

@synthesize name;
@synthesize pointID;
@synthesize location;

- (id)initFromName:(NSString*)_name PointID:(NSString*)_pointID Location:(CLLocation*)_location
{
	id this = [super init];
	if (this != nil)
	{
		[(name = _name) retain];
		[(pointID = _pointID) retain];
		[(location = _location) retain];
	}
	return this;
}

- (id)initWithCoder:(NSCoder*)coder
{
	name = [[coder decodeObjectForKey:@"name"] retain];
	pointID = [[coder decodeObjectForKey:@"pointID"] retain];
	location = [[[CLLocation alloc] initWithLatitude:[coder decodeFloatForKey:@"latitude"] longitude:[coder decodeFloatForKey:@"longitude"]] retain];
    return self;
}

- (void)dealloc
{
	[name release];
	[pointID release];
	[location release];
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:pointID forKey:@"pointID"];
    [coder encodeFloat:location.coordinate.longitude forKey:@"longitude"];
    [coder encodeFloat:location.coordinate.latitude forKey:@"latitude"];
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

