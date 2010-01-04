// 
//  Context.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

#import "Task.h"

@implementation Context 

@dynamic gpsY;
@dynamic contextId;
@dynamic name;
@dynamic gpsX;
@dynamic tasks;

- (NSString *)description {
	return self.name;
}

- (BOOL)hasGps {
	ALog("gpsx: %@, gpsy:%@", self.gpsX, self.gpsY);
	return self.gpsX != nil && self.gpsY != nil && [self.gpsX doubleValue] != 0 && [self.gpsY doubleValue] != 0;
}

- (double)distanceTo:(CLLocationCoordinate2D)pos {
	//TODO:implement
	return 0.;
}

+ (NSArray *) getContextsWithFilterString:(NSString*)filterString error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* apply sort order */
	NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortByName]];
	[sortByName release];
	
	/* apply filter string */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
	[request setPredicate:predicate];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (NSArray *) getContextsWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* apply sort order */
	NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortByName]];
	[sortByName release];
	
	/* apply filter string */
	[request setPredicate:filterPredicate];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (NSArray *) getAllContexts:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:nil error:error];	
	return objects;
}

@end
