//
//  SGDemoAppDelegate.m
//  SGDemoAppDelegate
//
//  Created by Derek Smith on 8/6/09.
//  Copyright SimpleGeo 2009. All rights reserved.
//

#import "SGDemoAppDelegate.h"

#import "SGMainViewController.h"
#import "SGEntityDescriptions.h"


@implementation LocationDemoAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (void) applicationDidFinishLaunching:(UIApplication *)application
{    
    InitializeEntityDescriptions([self managedObjectContext]);
        
    SGMainViewController* mapViewController = [[SGMainViewController alloc] init];
    
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    nvc.toolbar.hidden = NO;
    [window addSubview:nvc.view];

	[window makeKeyAndVisible];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void) applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
    
    ReleaseEntityDescriptions();
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel*) managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
                        
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"SGDemoApp.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"SGDemoApp" ofType:@"sqlite"];
        if (defaultStorePath)
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];    
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStore* store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
    if(!store) {
        
        [fileManager removeItemAtPath:storePath error:nil];
        
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"SGDemoApp" ofType:@"sqlite"];
        if (defaultStorePath)
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        
        NSPersistentStore* store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
        if(!store) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[window release];
	[super dealloc];
}


@end

