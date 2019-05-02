//
//  Timepoint.h
//
//  Created by Michael Rockhold on 5/30/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timepoint : NSObject<NSCoding>
{
	@private
	NSString*	name;
	NSString*	pointID;
	CLLocation* location;
}

- (id)initFromName:(NSString*)n 
		   PointID:(NSString*)p 
		  Location:(CLLocation*)l;

- (NSString*)title;

- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation;

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, retain, readonly) NSString* pointID;
@property (nonatomic, retain, readonly) CLLocation* location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
