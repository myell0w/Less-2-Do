//
//  ContextDAO.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDAO.h"

NSString *const DAOErrorDomain = @"com.ASE_06.Less2Do.DAOErrorDomain";

@implementation ContextDAO

+(NSArray *)allContexts:(NSError**)error
{	
	NSError *fetchError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
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

+(Context*)addContextWithName:(NSString*)theName error:(NSError**)error
{
	NSError *saveError;
	
	ALog(@"THERE");
	if(theName == nil || [theName length] == 0) {
		ALog(@"here");
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return nil;
	}
		
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Context *newContext = [[Context alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newContext retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte context müsste dann wohl vom aufrufer released werden
	newContext.name = theName;
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newContext;
}

+(BOOL)deleteContext:(Context *)context error:(NSError**)error
{
	NSError *deleteError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:context];
	
	/* commit deleting and check for errors */
	BOOL deleteSuccessful = [managedObjectContext save:&deleteError];
	if (deleteSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotDeletedError userInfo:nil];
		return NO;
	}
	
	return YES;
}

+(BOOL)updateContext:(Context*)oldContext newContext:(Context*)newContext error:(NSError**)error
{
	NSError *updateError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	oldContext.name = newContext.name;
	oldContext.gpsX = newContext.gpsX;
	oldContext.gpsY = newContext.gpsY;
	oldContext.tasks = newContext.tasks;
	
	/* commit deleting and check for errors */
	BOOL updateSuccessful = [managedObjectContext save:&updateError];
	if (updateSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotEditedError userInfo:nil];
		return NO;
	}
	
	return YES;
}

@end
