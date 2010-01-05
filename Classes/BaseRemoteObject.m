//
//  BaseRemoteObject.m
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseRemoteObject.h"


@implementation BaseRemoteObject

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
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return [[objects objectAtIndex:0] objectForKey:@"minModDate"];
}

@end
