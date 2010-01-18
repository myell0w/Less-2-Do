// 
//  Context.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

#import "Task.h"
#import <MapKit/MapKit.h>

@implementation Context 

@dynamic gpsY;
@dynamic name;
@dynamic gpsX;
@dynamic tasks;
@dynamic span;

- (NSString *)description {
	return self.name;
}

- (BOOL)hasGps {
	ALog("gpsx: %@, gpsy:%@", self.gpsX, self.gpsY);
	return self.gpsX != nil && self.gpsY != nil && [self.gpsX doubleValue] != 0 && [self.gpsY doubleValue] != 0;
}

- (double)distanceTo:(CLLocationCoordinate2D)pos {
	CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[self.gpsX doubleValue] longitude:[self.gpsY doubleValue]];
	CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:pos.latitude longitude:pos.longitude];
	
	double distance = [loc1 getDistanceFrom:loc2];
	[loc1 release];
	[loc2 release];
	return distance;
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
		[request release];
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
		[request release];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (NSArray *)getAllContextsInStore:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:nil error:error];	
	return objects;
}

+ (NSArray *) getAllContexts:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:@"deleted == NO" error:error];	
	return objects;
}

+ (NSArray *)getRemoteStoredContexts:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:@"remoteId != -1" error:error];	
	return objects;
}

+ (NSArray *)getRemoteStoredContextsLocallyDeleted:(NSError **)error
{
	/* HACK DES JAHRES - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	NSArray *objects = [Context getContextsWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(Context *context in objects)
	{
		if(!(context.remoteId != [NSNumber numberWithInt:-1] && [context.deleted intValue] == 1))
			[mutable removeObject:context];
	}

	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;
}

+ (NSArray *)getLocalStoredContextsLocallyDeleted:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:@"remoteId == -1 AND deleted == YES" error:error];	
	return objects;
}

+ (NSArray *)getAllContextsLocallyDeleted:(NSError **)error
{
	/* HACK DES JAHRES #3 - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	NSArray *objects = [Context getContextsWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(Context *context in objects)
	{
		if(!([context.deleted intValue] == 1))
			[mutable removeObject:context];
	}

	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;
}

+ (NSArray *)getUnsyncedContexts:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:@"remoteId == -1 AND deleted == NO" error:error];	
	return objects;
}

+ (NSArray *)getModifiedContexts:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterString:@"lastLocalModification > lastSyncDate" error:error];	
	return objects;
}

+ (Context *)getContextWithRemoteId:(NSNumber*)remoteId error:(NSError **)error
{
	NSArray* objects = [Context getContextsWithFilterPredicate:[NSPredicate predicateWithFormat:@"remoteId == %d", [remoteId integerValue]] error:error];
	if([objects count] != 1)
		return nil;
	return [objects objectAtIndex:0];
}

@end
