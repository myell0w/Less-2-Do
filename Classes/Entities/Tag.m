// 
//  Tag.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"


@implementation Tag 

@dynamic name;
@dynamic tasks;

-(NSString *)description {
	return self.name;
}

+ (NSArray *) getTagsWithFilterString:(NSString*)filterString error:(NSError **)error {
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Tag"
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

+ (NSArray *) getTagsWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Tag"
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

+ (NSArray *)getAllTagsInStore:(NSError **)error
{
	return [self getAllTags:error];
}

+ (NSArray *) getAllTags:(NSError **)error {
	NSArray* objects = [Tag getTagsWithFilterString:nil error:error];	
	return objects;
}

+ (BOOL)deleteObject:(BaseManagedObject *)theObject error:(NSError **)error
{
	[BaseManagedObject deleteObjectFromPersistentStore:theObject error:error];
	if (error == nil) {
		return YES;
	}
	return NO;
}

+ (Tag*) getTagWithName:(NSString*)theName error:(NSError **)error
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",theName];
	NSArray *result = [Tag getTagsWithFilterPredicate:predicate error:error];
	if([result count]!= 1)
	{
		return nil;
	}else {
		return [result objectAtIndex:0];
	}

	 
}

@end
