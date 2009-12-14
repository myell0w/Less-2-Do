// 
//  Folder.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"


@implementation Folder 

@dynamic folderId;
@dynamic order;
@dynamic name;
@dynamic tasks;
@dynamic r;
@dynamic g;
@dynamic b;

- (NSString *)description {
	return self.name;
}

+ (NSArray *)getAllFolders:(NSError *)error //Automatisch geordnet nach Order
{
	NSError *fetchError;
	
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];*/
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
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription]; // TODO: Request um order erweitern!
	
	NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByOrder, sortByName, nil]];
	[sortByOrder release];
	[sortByName release];
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (BOOL)deleteFolder:(Folder *)theFolder:(NSError *)error
{
	for(Task *t in theFolder.tasks)
	{
		[t removeFolder];
	}
	
	NSError *deleteError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:theFolder];
	
	/* commit deleting and check for errors */
	
	// TODO: Update entfernen? 
	BOOL deleteSuccessful = [managedObjectContext save:&deleteError];
	if (deleteSuccessful == NO) 
	{
		error = [NSError errorWithDomain:DAOErrorDomain code:DAONotDeletedError userInfo:nil];
		return NO;
	}
	return YES;
	
	
	
}

+ (NSArray *)getFolderbyRGB:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue error:(NSError *)error
{
	// TODO: Selektion für RGB
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
	[request setEntity:entityDescription]; // TODO: Request um order erweitern!
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (NSArray *)getFolderbyTask:(Task *)theTask error:(NSError *)error
{
	// TODO: Selektion für Task
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
	[request setEntity:entityDescription]; // TODO: Request um order erweitern!
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

- (NSManagedObjectContext *)managedObjectContext
{
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];*/
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
	return managedObjectContext;
}

@end
