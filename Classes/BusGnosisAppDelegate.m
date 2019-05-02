/*

File: BusGnosisAppDelegate.m
Abstract: App delegate. Creates window and root view.

*/

#import "BusGnosisAppDelegate.h"

@implementation BusGnosisAppDelegate

@synthesize window, mainViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[window addSubview:[mainViewController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[mainViewController release];
	[window release];
	[super dealloc];
}

@end
