//
//  LocationInfo.m
//  LocateMe
//
//  Created by Michael Rockhold on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationInfo.h"
#import "Timepoint.h"
#import "BusesNearTimepointCollector.h"
#import <MapKit/MKPlacemark.h>

NSInteger TimepointSortByDistanceFromHome(id tp1, id tp2, void* currentLocation)
{
	
	CLLocationDistance dist1 = [tp1 getDistanceFrom:currentLocation];
	CLLocationDistance dist2 = [tp2 getDistanceFrom:currentLocation];
	
	return (dist1 > dist2) ? 1 : (dist1 < dist2) ? -1 : 0;
}


@implementation LocationInfo

- (id)initWithController:(NSObject<LocationInfoDelegate>*)c
{
	id this = [super init];
	if (this != nil)
	{
		controller = [c retain];
		timepoints = [[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"timepoints" ofType:@"dat"]] retain];
		nearby_timepoints = nil;
		m_nearby_buses = [[NSMutableDictionary dictionaryWithCapacity:400] retain];
	}
	return this;
}

- (void)dealloc
{
	[timepoints release];
	[nearby_timepoints release];
	[m_nearby_buses release];
	[currentLocation release];
	[controller release];
	[super dealloc];
}

- (CLLocation*)currentLocation
{
	return currentLocation;
}

- (void)setCurrentLocation:(CLLocation*)location
{	
	[controller nearbyTimepointsAboutToChange];
	[currentLocation release];
	currentLocation = [location retain];

	// Ask the map service for address info for this new location
    MKReverseGeocoder* rg = [[[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate] retain];
    rg.delegate = self;
    
    [rg start];	
	
#if 0
	[nearby_timepoints release];

	NSRange theRange; theRange.location = 0; theRange.length = 5;
	nearby_timepoints = [[[timepoints sortedArrayUsingFunction:TimepointSortByDistanceFromHome context:currentLocation] subarrayWithRange:theRange] retain];
	[self tellControllerNearbyTimepointsChanged];
	
    [[[[BusesNearTimepointCollector alloc] initWithRadius:250 delegate:self] retain] collectAsync:nearby_timepoints]; 
#else
	
    [[[[BusesNearTimepointCollector alloc] initWithRadius:250 delegate:self] retain] collectAsync:timepoints]; 
#endif
	
}

-(void)tellControllerNearbyTimepointsChanged
{
	[controller performSelectorOnMainThread:@selector(nearbyTimepointsChanged) withObject:nil waitUntilDone:NO];
}

#pragma mark BusesNearTimepointCollectorDelegate methods
// NB these are all always called from a secondary thread; take care to do all UI access in the main thread

- (void)busesNearTimepointCollectorWillStartCollectingBuses:(BusesNearTimepointCollector*)collector
{
}

- (void)busesNearTimepointCollector:(BusesNearTimepointCollector*)bntc addBus:(BusInfo*)bus
{
	@synchronized(m_nearby_buses)
	{
		Boolean busMoved = NO;
		BusInfo* previousBi = [m_nearby_buses objectForKey:bus.vehicleID];
		if ( previousBi == nil )
		{
			busMoved = YES;
		}
		else
		{
			busMoved = ! [previousBi isEqualToBusInfo:bus];
			
			if ( busMoved )
				[controller performSelectorOnMainThread:@selector(busRemoved:) withObject:previousBi waitUntilDone:YES];
		}
		if ( busMoved )
		{
			[m_nearby_buses setObject:bus forKey:bus.vehicleID];
			[controller performSelectorOnMainThread:@selector(busAdded:) withObject:bus waitUntilDone:NO];
		}
	}
}

- (void)busesNearTimepointCollectorDidFinishCollectingBuses:(BusesNearTimepointCollector*)collector
{
	[collector release];
}

#pragma mark ---- reverseGeocoder methods ----

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
    [geocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark
{
    NSMutableString* address = [[[NSMutableString alloc] init] autorelease];
    
    [address appendFormat:@"%@, %@, %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality];
	//[self newLocationUpdate:address];
    [geocoder release];
}

@end
