//
//  BusInfo.m
//  BusGnosis
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "BusInfo.h"
@implementation BusInfo

- (id)initWithDictionary:(NSDictionary*)d
{
	id this = [super init];
	if (this != nil)
	{
		m_info = [d retain];
		m_location = [[[CLLocation alloc] initWithLatitude:[[d valueForKey:@"latitude"] doubleValue] longitude:[[d valueForKey:@"longitude"] doubleValue]] retain];
	}
	return this;
}

- (void)dealloc
{
	[m_info release];
	[m_location release];
	[super dealloc];
}

- (NSNumber*)route
{
	return [m_info valueForKey:@"routeID"];
}

- (NSNumber*)vehicleID
{
	return [m_info valueForKey:@"vehicleID"];
}

- (NSNumber*)heading
{
	return [m_info valueForKey:@"heading"];
}

- (NSString*)title
{
	return [NSString stringWithFormat:@"Route %@ (#%@)", [m_info valueForKey:@"routeID"], [m_info valueForKey:@"vehicleID"]];
}

- (CLLocationCoordinate2D)coordinate
{
	return m_location.coordinate;
}

- (CLLocation*)location
{
	return m_location;
}

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation
{
	return [self.location getDistanceFrom:otherLocation];
}

- (Boolean)isEqualToBusInfo:(BusInfo*)bus
{
	return ( [self.location isEqual:bus.location] 
			&& [self.route isEqual:bus.route]
			&& [self.vehicleID isEqual:bus.vehicleID]
			&& [self.heading isEqual:bus.heading]
			);
}

@end

