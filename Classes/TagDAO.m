//
//  TagDAO.m
//  Less2Do
//
//  Created by Blackandcold on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagDAO.h"

@implementation TagDAO

/* 
 parameters:
 - (NSError**) error: reference to NSError object
 return value:
 successful: (Tag*) the created Tag object
 error: nil
 possible values for (NSError**)error:
 - DAONotFetchedError: when the object list could not be fetched from the persistent store
 */
+(NSArray *)allTags:(NSError**)error
{	
	NSError *fetchError;
	
	/* get managed object Tag */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Tag"
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
 - (NSString*) theName: the name of the new Tag
 - (NSError**) error: reference to NSError object
 return value:
 successful: (Tag*) the created Tag object
 error: nil
 possible values for (NSError**)error:
 - DAOMissingParametersError: when parameter theName is nil or empty
 - DAONotAddedError: when the new object could not be save to the persistend store
 */
+(Tag*)addTagWithName:(NSString*)theName error:(NSError**)error
{
	NSError *saveError;
	
	/* show if parameter is set */
	if(theName == nil || [theName length] == 0) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return nil;
	}
	
	/* get managed object Tag */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for creating */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Tag"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new object and set values */
	Tag *newTag = [[Tag alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	[newTag retain]; // TODO da bin ich mir nicht so sicher - der zurückgelieferte Tag müsste dann wohl vom aufrufer released werden
	newTag.name = theName;
	
	/* commit inserting and check for errors */
	BOOL saveSuccessful = [managedObjectContext save:&saveError];
	if (saveSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotAddedError userInfo:nil];
		return nil;
	}
	
	return newTag;
}

/*
 parameters:
 - (NSString*) Tag: the Tag object to delete
 - (NSError**) error: reference to NSError object
 return value: BOOL
 successful: YES
 error: NO
 possible values for (NSError**)error:
 - DAOMissingParametersError: when parameter Tag is nil
 - DAONotDeletedError: when the new object could not be deleted from the persistend store
 */
+(BOOL)deleteTag:(Tag *)Tag error:(NSError**)error
{
	NSError *deleteError;
	
	/* show if parameter is set */
	if(Tag == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	
	/* get managed object Tag */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* mark object to be deleted */
	[managedObjectContext deleteObject:Tag];
	
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
 - (NSString*) Tag: the Tag object to delete
 - (NSError**) error: reference to NSError object
 return value: BOOL
 successful: YES
 error: NO
 possible values for (NSError**)error:
 - DAOMissingParametersError: when at least one of the parameters (oldTag, newTag)  is nil
 - DAONotEditError: when the new object could not be updated in the persistend store
 */
+(BOOL)updateTag:(Tag*)oldTag newTag:(Tag*)newTag error:(NSError**)error
{
	NSError *updateError;
	
	/* show if parameters are set */
	if(oldTag == nil || newTag == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	
	/* get managed object Tag */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	oldTag.name = newTag.name;
	oldTag.tasks = newTag.tasks;
	
	/* commit deleting and check for errors */
	BOOL updateSuccessful = [managedObjectContext save:&updateError];
	if (updateSuccessful == NO) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotEditedError userInfo:nil];
		return NO;
	}
	
	return YES;
}

@end
