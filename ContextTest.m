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
- (void)testAddContextWithName {
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	
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

/* first adds a context and then updates it */
- (void)testUpdateContext {
	Context *newContext = (Context*)[Context objectOfType:@"Context"];
	
	newContext.name = @"UPDATE";
	
	GHAssertTrue([newContext isUpdated], @"Update context not successful");
	
	/*//[NSThread sleepForTimeInterval:2];
	
	NSArray *contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"Add context not successful");
	Context *context = [contexts objectAtIndex:0];
	GHAssertEqualStrings([context name], [newContext name], @"Update context not successful"); */
}

- (void)testAllContextsOrdered {
	NSError *error = nil;
	
	Context *newContext1 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext2 = (Context*)[Context objectOfType:@"Context"];
	Context *newContext3 = (Context*)[Context objectOfType:@"Context"];
	newContext1.name = @"Eontext";
	newContext2.name = @"Dontext";
	newContext3.name = @"Context";
	 
	NSArray *contexts = [Context getAllContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)3, @"Add contextnot successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [contexts objectAtIndex:0], [contexts objectAtIndex:1], [contexts objectAtIndex:2]];
	GHAssertEqualStrings(output, @"0: Context, 1: Dontext, 2: Eontext", @"Ordered Contexts not successful");
}

/* adds 3 contexts - count must be 3 */
- (void)testOldestModificationDate {
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
}

@end