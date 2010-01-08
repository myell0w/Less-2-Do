//
//  SyncTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TDApi.h"
#import "SyncManager.h"
#import "CustomGHUnitAppDelegate.h";

@interface SyncTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation SyncTest

- (void)setUp {
	
	/* delete all contexts from the persistent store */
	/*CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	managedObjectContext = [delegate managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Context" inManagedObjectContext:managedObjectContext]];
	
	NSError *error;
	NSArray *allContexts = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	for (NSManagedObject* context in allContexts)
	{
		[managedObjectContext deleteObject:context];
	}
	if([managedObjectContext save:&error] == NO)
		GHFail(@"Error at setUp");*/
}

- (void)tearDown {
	/* do nothing */
	ALog(@"got here");
}

/* Tests receiving all contexts without adding contexts before */
/*- (void)testDaFuckinConnection {
	//NSError *error = nil;
	//NSArray *contexts = [Context getAllContexts:&error];
	//GHAssertEquals([contexts count], (NSUInteger)0, @"Context count must be 0");
	
	NSError *error;
	
	TDApi *fuck2 = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&error];
	GHAssertNil(error, @"Do hots wos");
	GtdFolder *newFolder = [[GtdFolder alloc] init];
	newFolder.title = @"FuckYourself";
	//ALog(@"%@", newFolder.uid);
	NSInteger newId = [fuck2 addFolder:newFolder error:&error];
	//ALog(@"%@", newId);
	newFolder.uid = newId;
	
	GtdFolder *folder2 = [[GtdFolder alloc] init];
	folder2.uid = newId;
	
	
	[fuck2 deleteFolder:newFolder error:&error];
	//ALog(@"deleted: %@", deleted);
	//ALog(@"0: %@", fuck2.isAuthenticated);
	NSArray* folders = [fuck2 getFolders:&error];
	for (GtdFolder *gtdFolder in folders) {
		ALog(@"[Fuck] %@", gtdFolder);
	}
	//ALog(@"1: %@", error);
	//ALog(@"2: %@", fuck2);
}*/

-(void)testSync {
	NSError *error;
	[SyncManager sync:&error];
}
/*-(void)testGetLastModificationDates {
	NSError *error = nil;
	TDApi *tdApi = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&error];
	GHAssertNil(error, @"API not connected");
	NSMutableDictionary *datesDict = [tdApi getLastModificationsDates:&error];
	ALog(@"datesDict: %@", datesDict);
	ALog(@"error: %@", error);
	ALog(@"lastfolderedit: %@", [datesDict valueForKey:@"lastFolderEdit"]);
	//GHAssertNil(error, @"Retrieving dates not successful");
}*/

@end