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
	return self.name;
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
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (NSArray *) getAllFolders:(NSError **)error
{
	NSArray* objects = [Folder getFoldersWithFilterString:nil error:error];	
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

- (UIColor *) color {
	return [UIColor colorWithRed:[self.r floatValue] green:[self.g floatValue] blue:[self.b floatValue] alpha:1.f];
}

@end
