// 
//  Folder.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"


@implementation Folder 

@dynamic folderId;
@dynamic order;
@dynamic name;
@dynamic tasks;
@dynamic r;
@dynamic g;
@dynamic b;

- (NSString *)description {
	return self.name;
}

- (void)setRGB:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue
{
	r = red;
	g = green;
	b = blue;
}

- (void)setOrder:(NSNumber *)order
{
	self.order = order;
}

- (void)setOrderAndRGB:(NSNumber *)order red:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue
{
	r = red;
	g = green;
	b = blue;
	self.order = order;
}

+ (NSArray *)getAllFolders //Automatisch geordnet nach Order
{
	NSError *fetchError;
	
	/* get managed object context */
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder"
											  inManagedObjectContext:managedObjectContext];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription]; // TODO: Request um order erweitern!
	
	/* fetch objects */
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:&fetchError];
	if (objects == nil) {
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		return nil;
	}
	
	[request release];
	
	return objects;
}

+ (void)deleteFolder:(Folder *)theFolder
{
	for(theFolder.tasks as task)
	{
		task.deleteFolder;
	}
}

+ (NSArray *)getFolderbyRGB:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue
{
	
}

+ (NSArray *)getFolderbyTask:(Task *)theTask
{
	
}

@end
