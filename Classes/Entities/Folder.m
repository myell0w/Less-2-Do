// 
//  Folder.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"


@implementation Folder 

@dynamic order;
@dynamic name;
@dynamic tasks;
@dynamic r; 
@dynamic g;
@dynamic b;

- (NSString *)description {
	return [NSString stringWithFormat:@"<Folder remoteId='%d' name='%@' deleted='%d' order='%d' lastLocalMod='%@' lastSync='%@'>", [self.remoteId intValue], self.name, [self.deleted intValue], [self.order intValue], self.lastLocalModification, self.lastSyncDate];
}

+ (NSArray *) getFoldersWithFilterString:(NSString*)filterString error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	[request setIncludesPendingChanges:YES];
	
	/* apply sort order */
	NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByOrder, sortByName, nil]];
	[sortByOrder release];
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

+ (NSArray *) getFoldersWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	[request setIncludesPendingChanges:YES];
	
	/* apply sort order */
	NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByOrder, sortByName, nil]];
	[sortByOrder release];
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

+ (NSArray *)getAllFoldersInStore:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:nil error:error];	
	return objects;
}

+ (NSArray *) getAllFolders:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:@"deleted == NO" error:error];	
	return objects;
}

+ (NSArray *)getFolderWithRGB:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue error:(NSError *)error
{
	// TODO: Selektion für RGB
	/*NSError *fetchError;
	
	// get entity description - needed for fetching 
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	/*NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription]; // TODO: Request um order erweitern!
	
	/* fetch objects */
	/*NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;*/
	return nil;
}

+ (NSArray *)getRemoteStoredFolders:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:@"remoteId != -1" error:error];	
	return objects;
}

+ (NSArray *)getRemoteStoredFoldersLocallyDeleted:(NSError **)error
{
	/*NSArray* objects = [Folder getFoldersWithFilterString:@"remoteId != -1 AND deleted == YES" error:error];	
	return objects;*/
	
	/* HACK DES JAHRES - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	NSArray *objects = [Folder getFoldersWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(Folder *folder in objects)
	{
		if(!(folder.remoteId != [NSNumber numberWithInt:-1] && [folder.deleted intValue] == 1))
			[mutable removeObject:folder];
	}
	/*for(int i=0;i<[mutable count];i++)
	{
		Folder *folder = [mutable objectAtIndex:i];
		if(!(folder.remoteId != [NSNumber numberWithInt:-1] && folder.deleted == [NSNumber numberWithInt:1]))
			[mutable removeObjectAtIndex:i];
	}*/
	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;
}

+ (NSArray *)getLocalStoredFoldersLocallyDeleted:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:@"remoteId == -1 AND deleted == YES" error:error];	
	return objects;
	
	/* HACK DES JAHRES #2 - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	/*NSArray *objects = [Folder getFoldersWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(int i=0;i<[mutable count];i++)
	{
		Folder *folder = [mutable objectAtIndex:i];
		if(!(folder.remoteId == [NSNumber numberWithInt:-1] && folder.deleted == [NSNumber numberWithInt:1]))
			[mutable removeObjectAtIndex:i];
	}
	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;*/
}

+ (NSArray *)getAllFoldersLocallyDeleted:(NSError **)error
{
	/*NSArray* objects = [Folder getFoldersWithFilterString:@"deleted == YES" error:error];	
	return objects;*/
	
	/* HACK DES JAHRES #3 - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	NSArray *objects = [Folder getFoldersWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(Folder *folder in objects)
	{
		if(!([folder.deleted intValue] == 1))
			[mutable removeObject:folder];
	}
	/*for(int i=0;i<[mutable count];i++)
	 {
	 Folder *folder = [mutable objectAtIndex:i];
	 if(!(folder.remoteId != [NSNumber numberWithInt:-1] && folder.deleted == [NSNumber numberWithInt:1]))
	 [mutable removeObjectAtIndex:i];
	 }*/
	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;
}

+ (NSArray *)getUnsyncedFolders:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:@"remoteId == -1 AND deleted == NO" error:error];	
	return objects;
	
	/* HACK DES JAHRES #4 - inperformant bis zum geht nicht mehr, aber wenigstens korrekt */
	/*NSArray *objects = [Folder getFoldersWithFilterString:nil error:error];
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable setArray:objects];
	for(int i=0;i<[mutable count];i++)
	{
		Folder *folder = [mutable objectAtIndex:i];
		if(!(folder.remoteId == [NSNumber numberWithInt:-1] && folder.deleted == [NSNumber numberWithInt:0]))
			[mutable removeObjectAtIndex:i];
	}
	NSArray *returnValue = [NSArray arrayWithArray:mutable];
	return returnValue;*/
}

+ (NSArray *)getModifiedFolders:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:@"lastLocalModification > lastSyncDate" error:error];	
	return objects;
}

+ (Folder *)getFolderWithRemoteId:(NSNumber*)remoteId error:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterPredicate:[NSPredicate predicateWithFormat:@"remoteId == %d", [remoteId integerValue]] error:error];
	if([objects count] != 1)
		return nil;
	return [objects objectAtIndex:0];
}

- (UIColor *) color {
	return [UIColor colorWithRed:[self.r floatValue] green:[self.g floatValue] blue:[self.b floatValue] alpha:1.f];
}

@end
