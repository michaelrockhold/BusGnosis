/*
MainViewController.h
Controller class for the "main" view.
 
Copyright 2009, The Rockhold Company. All rights reserved.
*/

#import <MapKit/MKMapView.h>
#import "LocationInfo.h"

@interface MainViewController : UIViewController <CLLocationManagerDelegate, LocationInfoDelegate, MKMapViewDelegate>
{    
    // model
    LocationInfo*       locationInfo;

	CLLocationManager*  locationManager;
}

//LocationInfoDelegate methods
- (void)nearbyTimepointsAboutToChange;
- (void)nearbyTimepointsChanged;
- (void)busAdded:(BusInfo*)bus;
- (void)busRemoved:(BusInfo*)bus;
- (void)busReplaced:(BusInfo*)oldBus by:(BusInfo*)newBus;

//CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

//MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;

//misc
- (void)newError:(NSString *)text;

-(void)locationUpdaterHelper;
-(NSInvocation*)makeLocationUpdatingTimerHelper;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) LocationInfo *locationInfo;
@property (nonatomic, retain) MKMapView* mapView;

@end
