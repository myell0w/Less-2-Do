//
//  Less2DoAppDelegate.m
//  Less2Do
//
//  Created by Matthias Tretter on 17.11.09.
//  Copyright BIAC 2009. All rights reserved.
//

#import "Less2DoAppDelegate.h"
#import "HomeNavigationController.h"
#import "SyncManager.h"
#import "Setting.h"


#define SYNC_TIMER_INTERVAL 20.0
#define REMINDER_TIMER_INTERVAL 120.0
#define REMINDER_SECONDS_RANGE 3600

@implementation Less2DoAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize homeController;
@synthesize foldersController;
@synthesize contextsController;
@synthesize tagsController;
@synthesize settingsController;

@synthesize syncTimer;
@synthesize reminderTimer;

@synthesize currentEditedTask;


@synthesize activityViewContainer;
@synthesize activityView;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory management
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[rootController release];
	[homeController release];
	[foldersController release];
	[contextsController release];
	[tagsController release];
	[settingsController release];
	[alreadyReminded release];
	
	
	[activityView release];
	[activityViewContainer release];
	[window release];
	
	[super dealloc];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commitDatabase:(NSTimer *)timer {
	[BaseManagedObject commit];
}

- (void)checkDueTasks:(NSTimer *)timer {
	NSError *error = nil;
	NSArray *tasks = [Task getAllTasks:&error];
	NSDate *now = [[NSDate alloc] init];
	NSNumber *reminded = nil;
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = nil;
	NSDate *dueDate = nil;
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	
	[format setDateFormat:@"h:mm a"];
	
	ALog(@"Check Due Dates for Reminder!");
	
	for (Task *t in tasks) {
		if ([t.isCompleted boolValue] == NO && t.dueDate != nil && t.dueTime != nil) {
			reminded = [alreadyReminded objectForKey:t.name];
			
			// task not in list -> insert it
			if (reminded == nil) {
				[alreadyReminded setObject:[NSNumber numberWithBool:NO] forKey:t.name];
			} 
			
			BOOL r = [reminded boolValue];
			
			if (!r) {
				NSDateComponents *dueDateComp = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:t.dueDate];
				NSDateComponents *dueTimeComp = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:t.dueTime];
				
				components = [[NSDateComponents alloc] init];
				[components setYear:[dueDateComp year]];
				[components setMonth:[dueDateComp month]];
				[components setDay:[dueDateComp day]];
				[components setHour:[dueTimeComp hour]];
				[components setMinute:[dueTimeComp minute]];
				[components setSecond:[dueTimeComp second]];
				
				dueDate = [cal dateFromComponents:components];
				
				// remind 1 hour before
				if ([dueDate timeIntervalSinceDate:now] < REMINDER_SECONDS_RANGE) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder!" 
																	message:[NSString stringWithFormat:@"\"%@\" is due today at %@", t, [format stringFromDate:dueDate]]
																   delegate:nil 
														  cancelButtonTitle:@"Ok" 
														  otherButtonTitles:nil];
					
					[alert show];
					[alert release];
					
					[alreadyReminded setObject:[NSNumber numberWithBool:YES] forKey:t.name];
					ALog("Reminder!");
				}
				
				[components release];
			}
			
			
		}
	}
	
	[format release];
	[now release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// add rootControllers-View as subview of main-window  
	[window addSubview:rootController.view];
	
	activityViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	activityViewContainer.backgroundColor = [UIColor blackColor];
	activityViewContainer.alpha = 0.80;
	//activityViewContainer.hidden = YES;
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityView setCenter:CGPointMake(160.0f, 208.0f)];
	[activityViewContainer addSubview:activityView];
	//[window addSubview:activityViewContainer];
	[activityView release];
	
	[window makeKeyAndVisible];
	
	// start timer for committing to database
	self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:SYNC_TIMER_INTERVAL
													  target:self
													selector:@selector(commitDatabase:)
													userInfo:nil
													 repeats:YES];
	
	// start timer for displaying reminders
	alreadyReminded = [[NSMutableDictionary alloc] init];
	self.reminderTimer = [NSTimer scheduledTimerWithTimeInterval:REMINDER_TIMER_INTERVAL
														  target:self
														selector:@selector(checkDueTasks:)
														userInfo:nil
														 repeats:YES];
	
	//Check Settings
	NSError *error;
	Setting *settings = [Setting getSettings:&error];
	if(settings == nil) {
		ALog ("No Settings available");
		settings = (Setting*)[BaseManagedObject objectOfType:@"Setting"];
		settings.tdEmail = @"";
		settings.useTDSync = [NSNumber numberWithInt:0];
		settings.preferToodleDo = [NSNumber numberWithInt:0];
	} else {
		ALog ("Toodledo-User: %@", settings.tdEmail);
	}
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
	if (self.currentEditedTask != nil) {
		NSError *error;
		[BaseManagedObject deleteObject:self.currentEditedTask error:&error];
		ALog("Deleted Task because Adding was interrupted!");
	}
	
	ALog("Last commit");
	[BaseManagedObject commit];
	
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Core Data stack
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application's Documents directory
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application's Error Handling
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


NSString *const DAOErrorDomain = @"com.ASE_06.Less2Do.DAOErrorDomain";

-(void)startTimer {
	self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:20.0
													  target:self
													selector:@selector(commitDatabase:)
													userInfo:nil
													 repeats:YES];	
}

-(void)stopTimer {
	[self.syncTimer invalidate];	
	//timer = nil;
}

-(void)startAnimating {
	[NSThread detachNewThreadSelector:@selector(startAnimatingInThread) toTarget:self withObject:nil];
}

-(void)startAnimatingInThread {
	[window addSubview:activityViewContainer];
	[activityView startAnimating];
}

-(void)stopAnimating {
	[activityViewContainer removeFromSuperview];
	[self stopAnimatingWithTitle:nil andMessage:nil];
}

-(void)stopAnimatingWithTitle:(NSString *)title andMessage:(NSString *)message {
	[activityViewContainer removeFromSuperview];
	[activityView stopAnimating];
	
	if(title!=nil && message != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

@end

