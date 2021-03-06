//
//  CustomGHUnitAppDelegate.m
//  Less2Do
//
//  Created by Gerhard Schraml on 15.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomGHUnitAppDelegate.h"


@implementation CustomGHUnitAppDelegate

@synthesize timer;

- (void)commitDatabase:(NSTimer *) theTimer
{
	[BaseManagedObject commit];
}

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
	[super dealloc];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
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
}

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
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
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
/*- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Less2Do.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
/*		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}*/

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
    VVLog(@"creating NSPersistentStoreCoordinator");  
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"clearDatabase"]) {
		ALog(@"Clear Cache requested!");
		[[NSUserDefaults standardUserDefaults] setObject:NO forKey:@"clearDatabase"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self clearPersistentStore];
	}
	
#ifdef CLEAR_PERSISTENT_STORE
	[self clearPersistentStore];
#endif
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Less2Do.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], 
							 NSMigratePersistentStoresAutomaticallyOption, 
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil 
															URL:storeUrl options:options error:&error]) {
		// error! we delete the store and start over...
        DLog(@"error creating persistent store: %@", error);
		
		if([self clearPersistentStore]) {
			persistentStoreCoordinator = nil;
			return self.persistentStoreCoordinator; // potential loop. if this fails everything's not gonna work anyway...
		}else {
			return nil;
		}
	}  
	return persistentStoreCoordinator;
}

/**
 *  Simply deletes the sql file that is the persistent store.
 */
- (BOOL)clearPersistentStore {
	DLog(@"purging the persistent store...");
	
	NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Less2Do.sqlite"]];
	NSError *error = nil;
	if(![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error]) {
		ALog(@"Deleting the store at url %@ failed: %@", storeURL, error);
		return NO;
	}
	return YES;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    // add rootControllers-View as subview of main-window  
	[super applicationDidFinishLaunching:application];
	
	// start timer for committing to database
	/*self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0
												  target:self
												selector:@selector(commitDatabase:)
												userInfo:nil
												 repeats:YES];*/
}



-(void)startTimer
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0
												  target:self
												selector:@selector(commitDatabase:)
												userInfo:nil
												 repeats:YES];	
}

-(void)stopTimer
{
	[self.timer invalidate];	
}

@end
