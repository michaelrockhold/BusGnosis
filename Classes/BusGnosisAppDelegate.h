/*

File: BusGnosisAppDelegate.h
Abstract: App delegate. Creates window and root view.
 
*/

#import "MainViewController.h"

@interface BusGnosisAppDelegate : NSObject <UIApplicationDelegate>
{
	IBOutlet UIWindow *window;
    IBOutlet MainViewController* mainViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end

