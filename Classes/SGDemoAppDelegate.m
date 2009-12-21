//
//  SGDemoAppDelegate.m
//  SGDemoAppDelegate
//
//  Created by Derek Smith on 8/6/09.
//  Copyright SimpleGeo 2009. All rights reserved.
//

#import "SGDemoAppDelegate.h"

#import "SGMainViewController.h"


@implementation LocationDemoAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{       
    SGMainViewController* mapViewController = [[SGMainViewController alloc] init];
    
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    nvc.toolbar.hidden = NO;
    [window addSubview:nvc.view];
	[window makeKeyAndVisible];
}

- (void) dealloc
{
	    
	[window release];
	[super dealloc];
}


@end

