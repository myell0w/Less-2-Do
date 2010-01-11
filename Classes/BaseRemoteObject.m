//
//  BaseRemoteObject.m
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseRemoteObject.h"


@implementation BaseRemoteObject

@dynamic remoteId;
@dynamic lastSyncDate;
@dynamic lastLocalModification;

+ (NSDate *) oldestModificationDateOfType:(NSString *)type error:(NSError **)error
{
	
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"lastLocalModification"];
	NSExpression *minModDateExpression = [NSExpression expressionForFunction:@"min:"
																   arguments:[NSArray arrayWithObject:keyPathExpression]];
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"minModDate"];
	[expressionDescription setExpression:minModDateExpression];
	[expressionDescription setExpressionResultType:NSDateAttributeType];
	
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:type
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	[request setResultType:NSDictionaryResultType];
	
	/* apply filter string */
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	[expressionDescription release];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		[request release];
		
		return nil;
	}
	
	[request release];
	
	return [[objects objectAtIndex:0] objectForKey:@"minModDate"];
}

+ (NSDate *) oldestSyncDateOfType:(NSString *)type error:(NSError **)error
{
	
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"lastSyncDate"];
	NSExpression *minSyncDateExpression = [NSExpression expressionForFunction:@"min:"
																   arguments:[NSArray arrayWithObject:keyPathExpression]];
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"minSyncDate"];
	[expressionDescription setExpression:minSyncDateExpression];
	[expressionDescription setExpressionResultType:NSDateAttributeType];
	
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:type
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	[request setResultType:NSDictionaryResultType];
	
	/* apply filter string */
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return [[objects objectAtIndex:0] objectForKey:@"minSyncDate"];
}

/*+ (BaseManagedObject *)objectOfType:(NSString *)type
{

	BaseRemoteObject *castValue = [NSEntityDescription insertNewObjectForEntityForName:type 
										 inManagedObjectContext:[BaseManagedObject managedObjectContext]]; 
	ALog(@"remoteId vor dem -1 setzten: %d", [castValue.remoteId integerValue]);
	castValue.remoteId = [NSNumber numberWithInteger:-1];
	ALog(@"remoteId NACH dem -1 setzten: %d", [castValue.remoteId integerValue]);
	return castValue;
}*/


@end
