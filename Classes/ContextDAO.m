//
// ContextDAO.m
// Less2Do
//
// Created by Gerhard Schraml on 24.11.09.
// Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDAO.h"

//NSString *const DAOErrorDomain = @"com.ASE_06.Less2Do.DAOErrorDomain";

@implementation ContextDAO

/*
 parameters:
 - (NSError**) error: reference to NSError object
 return value:
 successful: (Context*) the created context object
 error: nil
 possible values for (NSError**)error:
 - DAONotFetchedError: when the object list could not be fetched from the persistent store
 */
+(NSArray *)allContexts:(NSError**)error
{
	NSError *fetchError;
	
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	 */
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

/*
 parameters:
 - (NSString*) theName: the name of the new context
 - (NSError**) error: reference to NSError object
 return value:
 successful: (Context*) the created context object
 error: nil
 possible values for (NSError**)error:
 - DAOMissingParametersError: when parameter theName is nil or empty
 - DAONotAddedError: when the new object could not be save to the persistend store
 */
+(Context*)addContextWithName:(NSString*)theName error:(NSError**)error
{
	NSError *saveError;
	
	/* show if parameter is set */
	if(theName == nil || [theName length] == 0) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return nil;
	}
	
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	 */
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

/*
 parameters:
 - (NSString*) context: the context object to delete
 - (NSError**) error: reference to NSError object
 return value: BOOL
 successful: YES
 error: NO
 possible values for (NSError**)error:
 - DAOMissingParametersError: when parameter context is nil
 - DAONotDeletedError: when the new object could not be deleted from the persistend store
 */
+(BOOL)deleteContext:(Context *)context error:(NSError**)error
{
	NSError *deleteError;
	
	/* show if parameter is set */
	if(context == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	 */
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
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:context];
	
	/* commit deleting and check for errors */
	BOOL deleteSuccessful = [managedObjectContext save:&deleteError];
	if (deleteSuccessful == NO) {
		//*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotDeletedError userInfo:nil];
		*error = deleteError;
		return NO;
	}
	
	return YES;
}

/*
 parameters:
 - (NSString*) context: the context object to update (commit)
 - (NSError**) error: reference to NSError object
 return value: BOOL
 successful: YES
 error: NO
 possible values for (NSError**)error:
 - DAOMissingParametersError: when context is nil
 - DAONotEditError: when the new object could not be updated in the persistend store
 */
+(BOOL)updateContext:(Context*)context error:(NSError**)error
{
	NSError *updateError;
	
	/* show if parameters are set */
	if(context == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	
	/* get managed object context */
	/*Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	 */
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
	
	/* commit deleting and check for errors */
	BOOL updateSuccessful = [managedObjectContext save:&updateError];
	if (updateSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotEditedError userInfo:nil];
		return NO;
	}
	
	return YES;
}

@end