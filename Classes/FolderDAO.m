//
//  FolderDAO.m
//  Less2Do
//
//  Created by BlackandCold on 27.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "FolderDAO.h"


@implementation FolderDAO

+(NSArray *)allFolders:(NSError**)error
{	
	NSError *fetchError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+(Folder*)addFolderWithName:(NSString*)theName error:(NSError**)error
{
	NSError *saveError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Folder *newFolder = [[Folder alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newFolder retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte context müsste dann wohl vom aufrufer released werden
	newFolder.name = theName;
	newFolder.order = 0;
	newFolder.tasks = nil;
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newFolder;
}

+(BOOL)deleteFolder:(Folder *)folder error:(NSError**)error
{
	NSError *deleteError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:folder];
	
	/* commit deleting and check for errors */
	BOOL deleteSuccessful = [managedObjectContext save:&deleteError];
	if (deleteSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotDeletedError userInfo:nil];
		return NO;
	}
	
	return YES;
}

+(BOOL)updateFolder:(Folder*)folder error:(NSError**)error
{
	NSError *updateError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* commit deleting and check for errors */
	BOOL updateSuccessful = [managedObjectContext save:&updateError];
	if (updateSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotEditedError userInfo:nil];
		return NO;
	}
	
	return YES;
}


+(Folder*)addFolderWithName:(NSString*)theName theTasks:(NSSet *)theTasks error:(NSError**)error
{
	NSError *saveError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Folder *newFolder = [[Folder alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newFolder retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte context müsste dann wohl vom aufrufer released werden
	newFolder.name = theName;
	newFolder.order = 0;
	newFolder.tasks = theTasks;
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newFolder;
}

+(Folder*)addFolderWithName:(NSString*)theName red:(NSNumber*)red green:(NSNumber*)green blue:(NSNumber*)blue error:(NSError**)error
{
	NSError *saveError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Folder *newFolder = [[Folder alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newFolder retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte context müsste dann wohl vom aufrufer released werden
	newFolder.name = theName;
	newFolder.order = 0;
	newFolder.tasks = nil;
	newFolder.r = red;
	newFolder.g = green;
	newFolder.b = blue;
	
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newFolder;
}

+(Folder*)addFolderWithName:(NSString*)theName theTasks:(NSSet *)theTasks theOrder:(NSNumber *)theOrder error:(NSError**)error
{
	NSError *saveError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Folder *newFolder = [[Folder alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newFolder retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte context müsste dann wohl vom aufrufer released werden
	newFolder.name = theName;
    newFolder.order = theOrder;
	newFolder.tasks = theTasks;
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newFolder;
}

@end
