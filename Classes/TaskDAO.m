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
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Task"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Task *newTask = [[Task alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];

	[newTask retain];	
	
	newTask.name = theTask.name;
	
	//TODO: Default values if -1 or simmilar
	
	// edited by Matthias, 30.11.09 23:46: no nil for boolean-values, made NO instead
	newTask.frequencyAnnoy = theTask.frequencyAnnoy; 
	newTask.isCompleted = theTask.isCompleted != nil ? theTask.isCompleted : [[NSNumber alloc] initWithBool:NO];
	newTask.duration = theTask.duration;
	newTask.startTimeAnnoy = theTask.startTimeAnnoy;
	newTask.dueDate = theTask.dueDate;
	newTask.dueTime = theTask.dueDate;
	newTask.repeat = theTask.repeat;
	newTask.priority = theTask.priority != nil ? theTask.priority : [[NSNumber alloc] initWithInt:-1];
	newTask.modificationDate = theTask.modificationDate;
	newTask.reminder = theTask.reminder;
	newTask.timerValue = theTask.timerValue;
	newTask.completionDate = theTask.completionDate;
	newTask.star = theTask.star != nil ? theTask.star : [[NSNumber alloc] initWithBool:NO];
	newTask.note = theTask.note; //TODO: Strings erzeugen?
	newTask.startDateAnnoy = theTask.startDateAnnoy;
	newTask.creationDate = theTask.creationDate;
	newTask.endTimeAnnoy = theTask.endTimeAnnoy;
	newTask.folder = theTask.folder;
	newTask.tags = theTask.tags;
	newTask.extendedInfo = theTask.extendedInfo;

	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	
	if (saveSuccessful == NO) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newTask;
}

/* TODO: Implement

+(BOOL)deleteTask:(Task*)theTask error:(NSError**)error
{
}

+(BOOL)updateTask:(Task*)oldTask newTask:(Folder*)newTast error:(NSError**)error
{
}
*/

@end
