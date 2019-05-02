
#import "BusesNearTimepointCollector.h"
#import "BusInfo.h"
#import "Timepoint.h"

@implementation BusesNearTimepointCollector

- (id)initWithRadius:(float)m delegate:(NSObject<BusCollectorDelegate>*)bcd
{
	id this = [super init];
	if ( this != nil )
	{
		m_withinMeters = m;
		m_delegate = [bcd retain];
		m_getTimepointsEventsFn = [[[SoapFunction alloc] initWithUrl:@"http://ws.its.washington.edu/Mybus/Mybus.asmx"
															  Method:@"getEventEstimatesI"
														   Namespace:@"http://dotnet.ws.its.washington.edu"
														  SoapAction:@"http://dotnet.ws.its.washington.edu/getEventEstimatesI"
														  ParamOrder:[NSArray arrayWithObject:@"timepoint"]
													   ResponseQuery:@"//ns1:getEventEstimatesIResponse/ns1:getEventEstimatesIResult/ns1:EventEstimate/ns1:route"
													  ResponsePrefix:@"ns1"
												   ResponseNamespace:@"http://dotnet.ws.its.washington.edu"
								   ]
								   retain];
		
		m_latestByRouteRemoteFn = [[[SoapFunction alloc] initWithUrl:@"http://ws.its.washington.edu:9090/transit/avl/services/AvlService"
															  Method:@"getLatestByRoute"
														   Namespace:@"http://avl.transit.ws.its.washington.edu"
														  SoapAction:@"getLatestByRoute"
														  ParamOrder:[NSArray arrayWithObjects:@"in0", @"in1", nil]									
													   ResponseQuery:@"//multiRef"
													  ResponsePrefix:nil
												   ResponseNamespace:nil
								   ]
								   retain];		
	}
	
	return this;
}
- (void)dealloc
{
	[m_delegate release];
	[m_getTimepointsEventsFn release];
	[m_latestByRouteRemoteFn release];
	[super dealloc];
}

- (void)collectAsync:(NSArray*)timepoints
{
	[NSThread detachNewThreadSelector:@selector(collect:) toTarget:self withObject:timepoints];
}


- (void)collect:(NSObject*)timepointsObject
{
	NSArray* timepoints = (NSArray*)timepointsObject;
	NSAutoreleasePool* pool1 = [[NSAutoreleasePool alloc] init]; // autorelease pool for secondary thread
	
	[m_delegate busesNearTimepointCollectorWillStartCollectingBuses:self];

	NSMutableArray* uniqueRoutes = [NSMutableArray array];

	for (Timepoint* timepoint in timepoints)
	{
		NSError* error = nil;
		NSArray* routeNodes = [m_getTimepointsEventsFn Invoke:[NSDictionary dictionaryWithObject:timepoint.pointID forKey:@"timepoint"] error:&error];
		if ( error != nil )
		{
			// TODO: Do something reasonable with error. Throw?
			NSLog(@"error in BusesNearTimepointCollector collect::%@\n", error);
		}
		else
		{			
			for (NSDictionary* rn in routeNodes)
			{			
				NSString* route = [rn valueForKey:@"nodeContent"];
				if ( route != nil && ![uniqueRoutes containsObject:route] )
				{				
					[self latestByRoute:route];		
					[uniqueRoutes addObject:route];
				}
			}
		}
	}
		
	[m_delegate busesNearTimepointCollectorDidFinishCollectingBuses:self];
	[pool1 release];
}


- (void)latestByRoute:(NSString*)route
{
	NSError* error = nil;
	NSArray* rawBusArray = [m_latestByRouteRemoteFn Invoke:[NSDictionary dictionaryWithObjectsAndKeys:@"http://transit.metrokc.gov", @"in0", [NSNumber numberWithInt:[route intValue]], @"in1", nil] error:&error];
	if ( error != nil )
	{
		// TODO: do something reasonable with error. Throw exception?
		NSLog(@"error in BusesNearTimepointCollector collect::%@\n", error);
	}
	else
	{
		// each item is dictionary of the form { nodeAttributeArray, nodeChildArray }, where nodeChildArray is array 
		// of dictionaries of {nodeAttributeArray = <dont-care>, nodeContent = <int>, nodeName = routeID|longitude|vehicleID|etc,etc.}
		
		for (NSDictionary* bi in rawBusArray)
		{
			NSMutableDictionary* mdi = [NSMutableDictionary dictionaryWithCapacity:10];
			for (NSDictionary* attrib in [bi valueForKey:@"nodeChildArray"])
			{
				[mdi setValue:[attrib valueForKey:@"nodeContent"] forKey:[attrib valueForKey:@"nodeName"]];
			}
			if ( [[mdi valueForKey:@"latitude"] doubleValue] > 1.0 )
			{
				[m_delegate busesNearTimepointCollector:self addBus:[[BusInfo alloc] initWithDictionary:mdi]];
			}
		}
	}
}


@end
