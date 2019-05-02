/*

File: MainViewController.m
Abstract: Controller class for the "main" view (visible at app start).

*/

// Shorthand for getting localized strings, used in formats below for readability
#define LocStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#import <Foundation/Foundation.h>

#import "MainViewController.h"
#import "Timepoint.h"
#import "BGAnnotationView.h"

#pragma mark Controller

@implementation MainViewController

@synthesize locationManager, locationInfo;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc
{
    [locationManager release];
    [locationInfo release];
	[super dealloc];
}

- (void)locationUpdaterHelper
{
    CLLocationCoordinate2D coordinate = locationInfo.currentLocation.coordinate;
    
    locationInfo.currentLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

- (NSInvocation*)makeLocationUpdatingTimerHelper
{
    SEL theSelector;
    NSMethodSignature *aSignature;
    NSInvocation *anInvocation;
    
    theSelector = @selector(locationUpdaterHelper);
    aSignature = [MainViewController instanceMethodSignatureForSelector:theSelector];
    anInvocation = [NSInvocation invocationWithMethodSignature:aSignature];
    [anInvocation setSelector:theSelector];
    return anInvocation;
}

// Called when the view is loading for the first time only
// If you want to do something every time the view appears, use viewWillAppear or viewDidAppear
- (void)viewDidLoad
{
    locationManager = [[[CLLocationManager alloc] init] retain];
    locationManager.delegate = self; // Tells the location manager to send updates to this object
    
    locationInfo = [[[LocationInfo alloc] initWithController:self] retain];

    if ( ! locationManager.locationServicesEnabled )
    {
        //[self addTextToLog:NSLocalizedString(@"NoLocationServices", @"User disabled location services")];
    }
    else
    {
        [locationManager startUpdatingLocation];
        
        //NSTimer* aTimer = [NSTimer scheduledTimerWithTimeInterval:15 invocation:[self makeLocationUpdatingTimerHelper] repeats:YES];
        NSTimer* aTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationUpdaterHelper) userInfo:nil repeats:YES];
        [aTimer retain];

        [self mapView].delegate = self;
    }
}

-(MKMapView*)mapView
{
    return (MKMapView*)[self view];
}
-(void)setMapView:(MKMapView*)mv
{
    [self setView:mv];
}

-(void)newError:(NSString *)text
{
}

#pragma mark ---- LocationInfoDelegate methods

- (void)nearbyTimepointsAboutToChange
{
    //[self.mapView removeAnnotations:locationInfo.nearby_buses];
}

- (void)nearbyTimepointsChanged
{
    //[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(locationInfo.currentLocation.coordinate, 300.0, 300.0) animated:TRUE];
}

- (void)busAdded:(BusInfo*)bus
{
    [self.mapView addAnnotation:bus];
}

- (void)busRemoved:(BusInfo*)bus
{
    [self.mapView removeAnnotation:bus];
}

- (void)busReplaced:(BusInfo*)oldBus by:(BusInfo*)newBus
{
    [self busRemoved:oldBus];
    [self busAdded:newBus];
}

#pragma mark ---- CLLocationManager methods

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];

    //locationInfo.currentLocation = newLocation;
    locationInfo.currentLocation = [[CLLocation alloc] initWithLatitude:47.606056 longitude:-122.332695];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(locationInfo.currentLocation.coordinate, 300.0, 300.0) animated:TRUE];
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];
    
	if ([error domain] == kCLErrorDomain)
    {
		// We handle CoreLocation-related errors here
        
		switch ([error code])
        {
                // This error code is usually returned whenever user taps "Don't Allow" in response to
                // being told your app wants to access the current location. Once this happens, you cannot
                // attempt to get the location again until the app has quit and relaunched.
                //
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
                //
			case kCLErrorDenied:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
                
                // This error code is usually returned whenever the device has no data or WiFi connectivity,
                // or when the location cannot be determined for some other reason.
                //
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
                //
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
                
                // We shouldn't ever get an unknown error code, but just in case...
                //
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	}
    else
    {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
    
	// Display the update
	[self newError:errorString];
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)ann
{
    return [BGAnnotationView newOrUsed:mv Annotation:ann];
}

@end
