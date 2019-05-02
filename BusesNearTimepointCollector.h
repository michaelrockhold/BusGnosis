#import <Foundation/Foundation.h>
#import <SoapFunction.h>
#import "BusInfo.h"

@class BusesNearTimepointCollector;

@protocol BusCollectorDelegate <NSObject>
@optional

- (void)busesNearTimepointCollectorWillStartCollectingBuses:(BusesNearTimepointCollector*)collector;
- (void)busesNearTimepointCollector:(BusesNearTimepointCollector*)bntc addBus:(BusInfo*)bus;
- (void)busesNearTimepointCollectorDidFinishCollectingBuses:(BusesNearTimepointCollector*)collector;
@end

@interface BusesNearTimepointCollector : NSObject
{
@private
	NSObject<BusCollectorDelegate>* m_delegate;
	float m_withinMeters;
	SoapFunction* m_getTimepointsEventsFn;
	SoapFunction* m_latestByRouteRemoteFn;
}

- (id)initWithRadius:(float)m delegate:(NSObject<BusCollectorDelegate>*)bcd;
- (void)collect:(NSObject*)timepointsArrayObject;
- (void)collectAsync:(NSArray*)timepoints;
- (void)latestByRoute:(NSString*)route;
@end
