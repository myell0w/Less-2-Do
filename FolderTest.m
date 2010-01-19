//
//  FolderDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"
#import "CustomGHUnitAppDelegate.h";

@interface FolderTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation FolderTest

- (void)setUp {
	
	/* delete all folders from the persistent store */
	CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	managedObjectContext = [delegate managedObjectContext];
	
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
	/* do nothing */
}

/* Tests receiving all folders without adding folders before */
- (void)testAllFoldersEmpty {
	NSError *error = nil;
	NSArray *folders = [Folder getAllFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)0, @"Folder count must be 0");
}

/* adds 3 folders - count must be 3 */
- (void)testAddFolder {
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.name = @"c1";
	newFolder2.name = @"c2";
	newFolder3.name = @"c3";
	
	NSArray *folders = [Folder getAllFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)3, @"Add folder not successful");
}

/* Tests deleting a folder with nil as parameter */
- (void)testDeleteFolderWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [Folder deleteObject:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Folder must not be deleted without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a folder and then deletes it - count then must be 0 */
- (void)testDeleteFolder {
	NSError *error = nil;
	Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
	
	NSArray *folders = [Folder getAllFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)1, @"Add folder not successful");
	
	BOOL deleteSuccessful = [Folder deleteObject:newFolder error:&error];
	GHAssertTrue(deleteSuccessful, @"Delete folder not successful");
	
	folders = [Folder getAllFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)0, @"Delete folder not successful");
}

- (void)testAllFoldersOrdered {
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.name = @"C";
	newFolder1.order = [NSNumber numberWithInt:1];
	newFolder2.name = @"A";
	newFolder2.order = [NSNumber numberWithInt:3];
	newFolder3.name = @"B";
	newFolder3.order = [NSNumber numberWithInt:2];
	
	NSArray *folders = [Folder getAllFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)3, @"Add foldernot successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [[folders objectAtIndex:0] name], [[folders objectAtIndex:1] name], [[folders objectAtIndex:2] name]];
	GHAssertEqualStrings(output, @"0: C, 1: B, 2: A", @"Ordered Folders not successful");
}

-(void) testGetRemoteStoredFolders
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.remoteId = [NSNumber numberWithInt:-1];
	newFolder2.remoteId = [NSNumber numberWithInt:20000];
	newFolder3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *folders = [Folder getRemoteStoredFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)2, @"");
}

-(void) testGetRemoteStoredFoldersLocallyDeleted
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.remoteId = [NSNumber numberWithInt:-1];
	newFolder2.remoteId = [NSNumber numberWithInt:20000];
	newFolder3.remoteId = [NSNumber numberWithInt:23000];
	[Folder deleteObject:newFolder3 error:&error];
	
	NSArray *folders = [Folder getRemoteStoredFoldersLocallyDeleted:&error];
	GHAssertEquals([folders count], (NSUInteger)1, @"");
}

-(void) testGetLocalStoredFoldersLocallyDeleted
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.remoteId = [NSNumber numberWithInt:-1];
	newFolder2.remoteId = [NSNumber numberWithInt:-1];
	newFolder3.remoteId = [NSNumber numberWithInt:23000];
	[Folder deleteObject:newFolder2 error:&error];
	[Folder commit];
	
	NSArray *folders = [Folder getLocalStoredFoldersLocallyDeleted:&error];
	GHAssertEquals([folders count], (NSUInteger)1, @"");
}

-(void) testGetAllFoldersLocallyDeleted
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.remoteId = [NSNumber numberWithInt:-1];
	newFolder2.remoteId = [NSNumber numberWithInt:20000];
	newFolder3.remoteId = [NSNumber numberWithInt:23000];
	[Folder deleteObject:newFolder2 error:&error];
	[Folder deleteObject:newFolder1 error:&error];
	
	NSArray *folders = [Folder getAllFoldersLocallyDeleted:&error];
	GHAssertEquals([folders count], (NSUInteger)2, @"");
}

-(void) testGetUnsyncedFolders
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.remoteId = [NSNumber numberWithInt:-1];
	newFolder2.remoteId = [NSNumber numberWithInt:20000];
	newFolder3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *folders = [Folder getUnsyncedFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)1, @"");
}

-(void) testGetModifiedFolders
{
	NSError *error = nil;
	
	Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
	Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:0];
	newFolder1.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newFolder2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:15];
	newFolder2.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newFolder3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:20];
	newFolder3.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	
	
	NSArray *folders = [Folder getModifiedFolders:&error];
	GHAssertEquals([folders count], (NSUInteger)2, @"");
}

-(void) testGetFolderWithRemoteId
{
	NSError *error = nil;
	
	Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder.remoteId = [NSNumber numberWithInt:20000];
	
	Folder *theResult = [Folder getFolderWithRemoteId:[NSNumber numberWithInt:20000] error:&error];
	GHAssertNotNil(theResult, @"");
}


/* adds 3 folders - count must be 3 */
/*- (void)testOldestModificationDate {
 NSError *error = nil;
 
 NSDateFormatter *format = [[NSDateFormatter alloc] init];
 [format setDateFormat:@"yyyy:mm:dd hh:mm "];
 
 Folder *newFolder1 = (Folder*)[Folder objectOfType:@"Folder"];
 Folder *newFolder2 = (Folder*)[Folder objectOfType:@"Folder"];
 Folder *newFolder3 = (Folder*)[Folder objectOfType:@"Folder"];
 
 newFolder1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:2];
 newFolder2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:3];
 newFolder3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:4];
 ALog(@"date1: %@", newFolder1.lastLocalModification);
 
 [BaseRemoteObject commit];
 
 NSDate *oldestDate = [Folder oldestModificationDateOfType:@"Folder" error:&error];
 if (![oldestDate isEqualToDate:newFolder1.lastLocalModification]) {
 GHFail(@"Oldest Mod Date not successful");
 }
 }*/

@end