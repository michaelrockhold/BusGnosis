//
//  BusInfo.h
//  SOAP_AuthExample
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MKAnnotation.h>

@interface BusInfo : NSObject<MKAnnotation>
{
	NSDictionary* m_info;
	CLLocation* m_location;
}

- (id)initWithDictionary:(NSDictionary*)d;

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation;

- (Boolean)isEqualToBusInfo:(BusInfo*)bus;

@property (readonly, retain) NSNumber* route;
@property (readonly, retain) NSNumber* vehicleID;
@property (readonly, retain) NSNumber* heading;
@property (readonly, retain) NSString* title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain, readonly) CLLocation* location;
@end
