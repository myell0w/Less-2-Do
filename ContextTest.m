//
//  ContextDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"
#import "CustomGHUnitAppDelegate.h";

@interface ContextTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation ContextTest

- (void)setUp {
	
	/* delete all contexts from the persistent store */
	CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
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
		GHFail(@"Error at setUp");
}

- (void)tearDown {
	/* do nothing */
}

/* Tests receiving all contexts without adding contexts before */
- (void)testAllContextsEmpty {
	NSError *error = nil;
	NSArray *contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)0, @"Context count must be 0");
}

/* adds 3 contexts - count must be 3 */
- (void)testAddContext {
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.name = @"c1";
	newContext2.name = @"c2";
	newContext3.name = @"c3";
	
	NSArray *contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)3, @"Add context not successful");
}

/* Tests deleting a context with nil as parameter */
- (void)testDeleteContextWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [Context deleteObject:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Context must not be deleted without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a context and then deletes it - count then must be 0 */
- (void)testDeleteContext {
	NSError *error = nil;
	Context *newContext = (Context*)[Context objectOfType:@"Context"];
	
	NSArray *contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"Add context not successful");
	
	BOOL deleteSuccessful = [Context deleteObject:newContext error:&error];
	GHAssertTrue(deleteSuccessful, @"Delete context not successful");
	
	contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)0, @"Delete context not successful");
}

- (void)testAllContextsOrdered {
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.name = @"C";
	newContext2.name = @"A";
	newContext3.name = @"B";
	 
	NSArray *contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)3, @"Add contextnot successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [contexts objectAtIndex:0], [contexts objectAtIndex:1], [contexts objectAtIndex:2]];
	GHAssertEqualStrings(output, @"0: A, 1: B, 2: C", @"Ordered Contexts not successful");
}

-(void) testGetRemoteStoredContexts
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.remoteId = [NSNumber numberWithInt:-1];
	newContext2.remoteId = [NSNumber numberWithInt:20000];
	newContext3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *contexts = [Context getRemoteStoredContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)2, @"");
}

-(void) testGetRemoteStoredContextsLocallyDeleted
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.remoteId = [NSNumber numberWithInt:-1];
	newContext2.remoteId = [NSNumber numberWithInt:20000];
	newContext3.remoteId = [NSNumber numberWithInt:23000];
	[Context deleteObject:newContext3 error:&error];
	
	NSArray *contexts = [Context getRemoteStoredContextsLocallyDeleted:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"");
}

-(void) testGetLocalStoredContextsLocallyDeleted
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.remoteId = [NSNumber numberWithInt:-1];
	newContext2.remoteId = [NSNumber numberWithInt:-1];
	newContext3.remoteId = [NSNumber numberWithInt:23000];
	[Context deleteObject:newContext2 error:&error];
	[Context commit];
	
	NSArray *contexts = [Context getLocalStoredContextsLocallyDeleted:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"");
}

-(void) testGetAllContextsLocallyDeleted
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.remoteId = [NSNumber numberWithInt:-1];
	newContext2.remoteId = [NSNumber numberWithInt:20000];
	newContext3.remoteId = [NSNumber numberWithInt:23000];
	[Context deleteObject:newContext2 error:&error];
	[Context deleteObject:newContext1 error:&error];
	
	NSArray *contexts = [Context getAllContextsLocallyDeleted:&error];
	GHAssertEquals([contexts count], (NSUInteger)2, @"");
}

-(void) testGetUnsyncedContexts
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.remoteId = [NSNumber numberWithInt:-1];
	newContext2.remoteId = [NSNumber numberWithInt:20000];
	newContext3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *contexts = [Context getUnsyncedContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"");
}

-(void) testGetModifiedContexts
{
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:0];
	newContext1.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newContext2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:15];
	newContext2.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newContext3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:20];
	newContext3.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];

	
	NSArray *contexts = [Context getModifiedContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)2, @"");
}

-(void) testGetContextWithRemoteId
{
	NSError *error = nil;
	
	Context *newContext = (Context*)[Context objectOfType:@"Context"];
	newContext.remoteId = [NSNumber numberWithInt:20000];
	
	Context *theResult = [Context getContextWithRemoteId:[NSNumber numberWithInt:20000] error:&error];
	GHAssertNotNil(theResult, @"");
}


/* adds 3 contexts - count must be 3 */
/*- (void)testOldestModificationDate {
	NSError *error = nil;
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyy:mm:dd hh:mm "];
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	
	newContext1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:2];
	newContext2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:3];
	newContext3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:4];
	ALog(@"date1: %@", newContext1.lastLocalModification);
	
	[BaseRemoteObject commit];

	NSDate *oldestDate = [Context oldestModificationDateOfType:@"Context" error:&error];
	if (![oldestDate isEqualToDate:newContext1.lastLocalModification]) {
		GHFail(@"Oldest Mod Date not successful");
	}
}*/

@end