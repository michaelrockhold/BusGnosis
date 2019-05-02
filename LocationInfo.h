//
//  LocationInfo.h
//  LocateMe
//
//  Created by Michael Rockhold on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BusesNearTimepointCollector.h"
#import <MapKit/MKReverseGeocoder.h>

@protocol LocationInfoDelegate<NSObject>

- (void)nearbyTimepointsAboutToChange;
- (void)nearbyTimepointsChanged;
- (void)busAdded:(BusInfo*)bus;
- (void)busRemoved:(BusInfo*)bus;
- (void)busReplaced:(BusInfo*)oldBus by:(BusInfo*)newBus;

@end

@interface LocationInfo : NSObject<BusCollectorDelegate, MKReverseGeocoderDelegate>
{
	id					controller;
	CLLocation*			currentLocation;
	NSArray*			timepoints;
	NSArray*			nearby_timepoints;

@private
   NSMutableDictionary*	m_nearby_buses;
}

- (id)initWithController:(NSObject<LocationInfoDelegate>*)c;

-(void)tellControllerNearbyTimepointsChanged;

- (void)busesNearTimepointCollectorWillStartCollectingBuses:(BusesNearTimepointCollector*)collector;
- (void)busesNearTimepointCollector:(BusesNearTimepointCollector*)bntc addBus:(BusInfo*)bus;
- (void)busesNearTimepointCollectorDidFinishCollectingBuses:(BusesNearTimepointCollector*)collector;

//MKReverseGeocoderDelegate methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder 
       didFindPlacemark:(MKPlacemark *)placemark;

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder 
       didFailWithError:(NSError *)error;

@property (nonatomic, retain) CLLocation* currentLocation;
@end
