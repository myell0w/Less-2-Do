// 
//  Task.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

#import "Folder.h"
#import "Tag.h"

@implementation Task 

@dynamic taskId;
@dynamic frequencyAnnoy;
@dynamic isCompleted;
@dynamic duration;
@dynamic startTimeAnnoy;
@dynamic dueDate;
@dynamic dueTime;
@dynamic repeat;
@dynamic name;
@dynamic priority;
@dynamic modificationDate;
@dynamic reminder;
@dynamic timerValue;
@dynamic completionDate;
@dynamic star;
@dynamic note;
@dynamic startDateAnnoy;
@dynamic creationDate;
@dynamic endTimeAnnoy;
@dynamic folder;
@dynamic context;
@dynamic tags;
@dynamic abContact;
@dynamic extendedInfo;

- (NSString *)description {
	return self.name;
}


- (void)setFolder:(Folder *)value {
	self.folder = value;
}

- (void)removeFolder {
	self.folder = nil;
	//[self.setFolder value:nil];
	//[setFolder:nil];
}

- (void)setContext:(Context *)value {
	self.context = value;
}

- (void)removeContext {
	self.context = nil;
}

+ (NSArray *) getTasks:(NSString*)filterString error:(NSError **)error {
	NSError *fetchError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate;
	NSManagedObjectContext *managedObjectContext;
	@try
	{
		delegate = [[UIApplication sharedApplication] delegate];
		managedObjectContext = [delegate managedObjectContext];
	}
	@catch (NSException *exception) {
		// Test target, create new AppDelegate
		delegate = [[[Less2DoAppDelegate alloc] init] autorelease];
		managedObjectContext = [delegate managedObjectContext];
	}
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Task"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* apply sort order */
	NSSortDescriptor *sortByDueDate = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
	//NSSortDescriptor *sortByDueTime = [[NSSortDescriptor alloc] initWithKey:@"dueTime" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByDueDate/*, sortByDueTime*/, nil]];
	[sortByDueDate release];
	//[sortByDueTime release];
	
	/* apply filter string */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
	[request setPredicate:predicate];
	
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

+ (NSArray *) getAllTasks:(NSError **)error {
	NSArray* objects = [Task getTasks:nil error:error];	
	return objects;
}

+ (NSArray *) getStarredTasks:(NSError **)error {
	NSArray* objects = [Task getTasks:@"star == 1" error:error];	
	return objects;
}

- (BOOL)saveTask:(NSError**)error {
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

@end
