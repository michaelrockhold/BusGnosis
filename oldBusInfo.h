//
//  BusInfo.h
//  LocateMe
//
//  Created by Michael Rockhold on 6/23/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <MapKit/MKAnnotation.h>

@interface BusInfo : NSObject<MKAnnotation>
{
@private
	NSString*	name;
	NSString*	desc;
	CLLocation* location;
}

- (id)initFromName:(NSString*)n 
	   Description:(NSString*)d 
		  Location:(CLLocation*)l;

- (NSString*)title;

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation;

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, retain, readonly) NSString* description;
@property (nonatomic, retain, readonly) CLLocation* location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
