//
//  Setting.m
//  Less2Do
//
//  Created by Gerhard Schraml on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Setting.h"
#import "SFHFKeychainUtils.h"

@implementation Setting

@dynamic tdEmail;
@dynamic useTDSync;
@dynamic preferToodleDo;

+(Setting*) getSettings:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Setting"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		[request release];
		
		return nil;
	}
	
	[request release];
	
	if([objects count] == 0)
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:SettingNotFound userInfo:nil];
		return nil;
	}
	if([objects count] > 1)
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:SettingMoreThanOne userInfo:nil];
		return nil;
	}
	
	ALog(@"settings count: %d", [objects count]);
	
	Setting *returnValue = [objects objectAtIndex:0];
	
	ALog(@"returnValue email: %@", returnValue.tdEmail);
	
	return returnValue;
}

@end
