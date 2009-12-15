//
//  BaseManagedObject.m
//  Less2Do
//
//  Created by Gerhard Schraml on 15.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseManagedObject.h"
#import "Less2DoAppDelegate.h"


@implementation BaseManagedObject

+ (NSManagedObjectContext*) managedObjectContext
{
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	return [delegate managedObjectContext];
}

+ (BaseManagedObject *)objectOfType:(NSString *)type
{
	return [NSEntityDescription insertNewObjectForEntityForName:type 
										 inManagedObjectContext:[self managedObjectContext]]; 
}

+ (BOOL)deleteObject:(BaseManagedObject *)theObject error:(NSError **)error
{
	NSError *deleteError;
	
	/* show if parameter is set */
	if(theObject == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAOMissingParametersError userInfo:nil];
		return NO;
	}
	
	/* mark object to be deleted */
	[[self managedObjectContext] deleteObject:theObject];
	
	/* commit deleting and check for errors */
	BOOL deleteSuccessful = [[self managedObjectContext] save:&deleteError];
	if (deleteSuccessful == NO) {
		*error = deleteError;
		return NO;
	}
	
	return YES;
}

+ (void)commit
{	
	NSError *saveError;
	/* check if there were changes */

	//ALog(@"Changed: %@", [[[self managedObjectContext] insertedObjects] count]);
	
	if([self managedObjectContext].hasChanges)
	{
		BOOL saveSuccessful = [[self managedObjectContext] save:&saveError];
		
		if (saveSuccessful == NO)
		{
			ALog(@"Error @ autocommit");
		}
		else
		{
			ALog(@"Successfully autocommitted");
		}
	}
	else
		ALog(@"No changes - no autocommit");
}

@end