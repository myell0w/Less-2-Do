//
//  FolderTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 14.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"
#import "Less2DoAppDelegate.h";

@interface FolderTest : GHTestCase {
	Less2DoAppDelegate* appDelegate;
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation FolderTest

- (void)setUp {
	
	/* delete all folders from the persistent store */
	appDelegate = [[Less2DoAppDelegate alloc] init];
	managedObjectContext = [appDelegate managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Folder" inManagedObjectContext:managedObjectContext]];
	
	NSError *error;
	NSArray *allFolders = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	for (NSManagedObject* folder in allFolders)
	{
		[managedObjectContext deleteObject:folder];
	}
	if([managedObjectContext save:&error] == NO)
		GHFail(@"Error at setUp");
}

- (void)tearDown {
	[appDelegate release];
	appDelegate = nil;
}

- (void)testAllFoldersOrdered {
	NSError *error = nil;
	
	Folder *newFolder1 = [[Folder alloc] init];
	newFolder1.name = @"Holder";
	newFolder1.order = [NSNumber numberWithInt:1];
	Folder *newFolder2 = [[Folder alloc] init];
	newFolder2.name = @"Golder";
	newFolder2.order = [NSNumber numberWithInt:1];
	Folder *newFolder3 = [[Folder alloc] init];
	newFolder3.name = @"Folder";
	newFolder3.order = [NSNumber numberWithInt:1];
	
	
	NSArray *folders = [Folder getAllFolders:error];
	GHAssertEquals([folders count], (NSUInteger)3, @"Add context not successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [folders objectAtIndex:0], [folders objectAtIndex:1], [folders objectAtIndex:2]];
	GHAssertEqualStrings(output, @"0: Folder, 1: Golder, 2: Holder", @"Ordered Folders not successful");
}

@end