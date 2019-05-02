#import <Foundation/Foundation.h>
#import "AvlSvc.h"

NSArray* TimepointEstimatedEvents(NSString* timepointId)
{
	// SOAP request settings
	NSURL *url = [NSURL URLWithString:@"http://ws.its.washington.edu/Mybus/Mybus.asmx"];
	NSString *method = @"getEventEstimatesI";
	NSString *namespace = @"http://dotnet.ws.its.washington.edu";
	
	// SOAP request params
	NSDictionary *params = [NSDictionary dictionaryWithObject:timepointId forKey:@"timepoint"];
	
	NSArray *paramOrder = [NSArray arrayWithObject:@"timepoint"];
	
	// set SOAP request http headers -- some SOAP server impls require even empty SOAPAction headers
	NSDictionary *reqHeaders = [NSDictionary dictionaryWithObject:@"http://dotnet.ws.its.washington.edu/getEventEstimatesI" forKey:@"SOAPAction"];
	
	// create SOAP request
	WSMethodInvocationRef soapReq = WSMethodInvocationCreate((CFURLRef)url,
															 (CFStringRef)method,
															 kWSSOAP2001Protocol);
	
	// set SOAP params
	WSMethodInvocationSetParameters(soapReq, (CFDictionaryRef)params, (CFArrayRef)paramOrder);
	
	// set method namespace
	WSMethodInvocationSetProperty(soapReq, kWSSOAPMethodNamespaceURI, (CFStringRef)namespace);
	
	// Add HTTP headers (with SOAPAction header) -- some SOAP impls require even empty SOAPAction headers
	WSMethodInvocationSetProperty(soapReq, kWSHTTPExtraHeaders, (CFDictionaryRef)reqHeaders);
	
	// for good measure, make the request follow redirects.
	WSMethodInvocationSetProperty(soapReq,	kWSHTTPFollowsRedirects, kCFBooleanTrue);
	
#ifdef DEBUG
	// set debug props
	WSMethodInvocationSetProperty(soapReq, kWSDebugIncomingBody,	kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapReq, kWSDebugIncomingHeaders, kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapReq, kWSDebugOutgoingBody,	kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapReq, kWSDebugOutgoingHeaders, kCFBooleanTrue);
#endif
	
	// invoke SOAP request
	NSDictionary *result = (NSDictionary *)WSMethodInvocationInvoke(soapReq);
	
	// get HTTP response from SOAP request so we can see response HTTP status code
	CFHTTPMessageRef res = (CFHTTPMessageRef)[result objectForKey:(id)kWSHTTPResponseMessage];
	int resStatusCode = 0;
	if (res)
		resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
	
	if (soapReq) CFRelease(soapReq);
	
	return resStatusCode == 200 ? [[result valueForKey:@"getEventEstimatesIResult"] valueForKey:@"EventEstimate"] : nil;
}

@interface TooFarAway : NSObject
{
}

- (BOOL)evaluateWithObject:(id)object;

@end

@implementation TooFarAway

- (BOOL)evaluateWithObject:(id)object
{
	return NO;
}

@end


NSArray* AllBusesNearTimepoint(NSString* timepoint, int withinMeters)
{
	NSMutableArray* allbuses = [NSMutableArray array];

	NSArray* estimatedEvents = TimepointEstimatedEvents(timepoint);
	if ( nil != estimatedEvents )
	{	
		NSMutableArray* routes = [NSMutableArray array];
		for (NSDictionary* aBus in estimatedEvents)
		{
			NSString* route = [aBus valueForKey:@"route"];
			
			if ( ![routes containsObject:route] )
			{
				[routes addObject:route];
			}
		}
		
		// For each route, find all the buses
		for (NSString* r in routes)
		{
			[allbuses addObjectsFromArray:[AvlService getLatestByRoute:@"http://transit.metrokc.gov" in_in1:[r integerValue]]];		
		}
		// filter list by proximity
		TooFarAway* tooFarAway	= [[TooFarAway alloc] init];
		
		[allbuses filterUsingPredicate:tooFarAway];
	}
	return allbuses;
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	

	for (NSDictionary* busInfo in AllBusesNearTimepoint(@"5903", 250))
	{
		NSLog(@"%@ route %@ at %@, %@\n", [busInfo valueForKey:@"vehicleID"],  [busInfo valueForKey:@"routeID"],  [busInfo valueForKey:@"latitude"],  [busInfo valueForKey:@"longitude"]);
	}
	
	[pool release];
    return 0;
}
