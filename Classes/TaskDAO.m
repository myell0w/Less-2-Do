//
//  TastDAO.m
//  Less2Do
//
//  Created by BlackandCold on 29.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "TaskDAO.h"


@implementation TaskDAO


+(NSArray*)allTasks:(NSError**)error
{
	NSError *fetchError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Task"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}
/*

@property (nonatomic, retain) NSNumber * taskId;
@property (nonatomic, retain) NSNumber * frequencyAnnoy;
@property (nonatomic, retain) NSNumber * isCompleted;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * startTimeAnnoy;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSNumber * timerValue;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSNumber * star;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * startDateAnnoy;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * endTimeAnnoy;
@property (nonatomic, retain) Folder * folder;
@property (nonatomic, retain) NSManagedObject * context;
@property (nonatomic, retain) NSSet* tags;
@property (nonatomic, retain) NSManagedObject * abContact;
@property (nonatomic, retain) NSSet* extendedInfo;
 */

+(Task *)addTask:(Task *)theTask error:(NSError**)error
{
	NSError *saveError;

	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* DEFAULT VALUES */
	
	
	
	
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	
	if (saveSuccessful == NO) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return theTask;
}

+(BOOL)updateTask:(Task *)theTask error:(NSError**)error
{
	NSError *saveError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* commit updateing and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	
	if (saveSuccessful == NO) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return NO;
	}
	
	return YES;
}



+(BOOL)deleteTask:(Task*)theTask error:(NSError**)error
{
	NSError *deleteError;
	
	/* show if parameter is set */
	if(theTask == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	

	Less2DoAppDelegate *delegate;
	NSManagedObjectContext *managedObjectContext;
	@try
	{
		delegate = [[UIApplication sharedApplication] delegate];
		managedObjectContext = [delegate managedObjectContext];
	}
	@catch (NSException *exception) 
	{
		// Test target, create new AppDelegate
		delegate = [[[Less2DoAppDelegate alloc] init] autorelease];
		managedObjectContext = [delegate managedObjectContext];
	}
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:theTask];
	
	/* commit deleting and check for errors */
	BOOL deleteSuccessful = [managedObjectContext save:&deleteError];
	if (deleteSuccessful == NO) {
		*error = deleteError;
		return NO;
	}
	
	return YES;
}

@end
