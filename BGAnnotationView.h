//
//  BGAnnotationView.h
//  BusGnosis
//
//  Created by Michael Rockhold on 7/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotationView.h>

@interface BGAnnotationView : MKAnnotationView
{
}

+(void)initialize;

+ (BGAnnotationView*)reuseExistingView:(MKMapView*)mv Annotation:(id <MKAnnotation>)ann;

- (id)initWithMapView:(MKMapView*)mv Annotation:(id <MKAnnotation>)ann;

+ (BGAnnotationView*)newOrUsed:(MKMapView*)mv Annotation:(id <MKAnnotation>)ann;

- (void)drawRect:(CGRect)rect;

@end
