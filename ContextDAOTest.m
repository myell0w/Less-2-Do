//
//  ContextDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDAO.h"
#import "Context.h"
#import "Less2DoAppDelegate.h";

@interface ContextDAOTest : GHTestCase {
	Less2DoAppDelegate* appDelegate;
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation ContextDAOTest

- (void)setUp {
	
	/* delete all contexts from the persistent store */
	appDelegate = [[Less2DoAppDelegate alloc] init];
	managedObjectContext = [appDelegate managedObjectContext];
	
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
	[appDelegate release];
	appDelegate = nil;
}

/* Tests receiving all contexts without adding contexts before */
- (void)testAllContextsEmpty {
	NSError *error = nil;
	NSArray *contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)0, @"Context count must be 0");
}

/* Tests adding a context with nil as name */
- (void)testAddContextWithNameWithNilTitle {
	NSError *error = nil;
	Context *returnValue = [ContextDAO addContextWithName:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Context must not be added without name");
	GHAssertNil(returnValue, @"Return value must be nil.");
}

/* Tests adding a context with empty string as name */
- (void)testAddContextWithNameWithEmptyTitle {
	NSError *error = nil;
	Context *returnValue = [ContextDAO addContextWithName:@"" error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Context must not be added without name");
	GHAssertNil(returnValue, @"Return value must be nil.");
}

/* adds 3 contexts - count must be 3 */
- (void)testAddContextWithName {
	NSError *error = nil;
	
	Context *newContext1 = [ContextDAO addContextWithName:@"Test generated 1" error:&error];
	GHAssertNotNil(newContext1, @"Add context1 not successful");
	Context *newContext2 = [ContextDAO addContextWithName:@"Test generated 2" error:&error];
	GHAssertNotNil(newContext2, @"Add context2 not successful");
	Context *newContext3 = [ContextDAO addContextWithName:@"Test generated 3" error:&error];
	GHAssertNotNil(newContext3, @"Add context3 not successful");
	
	NSArray *contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)3, @"Add context not successful");
}

/* Tests deleting a context with nil as parameter */
- (void)testDeleteContextWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [ContextDAO deleteContext:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Context must not be deleted without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a context and then deletes it - count then must be 0 */
- (void)testDeleteContext {
	NSError *error = nil;
	Context *newContext = [ContextDAO addContextWithName:@"Test generated" error:&error];
	GHAssertNotNil(newContext, @"Add context not successful");
	
	NSArray *contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"Add context not successful");
	
	BOOL deleteSuccessful = [ContextDAO deleteContext:newContext error:&error];
	GHAssertTrue(deleteSuccessful, @"Delete context not successful");
	
	contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)0, @"Delete context not successful");
}

/* Tests updating a context with nil as parameter */
- (void)testUpdateContextWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [ContextDAO updateContext:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Context must not be updated without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a context and then updates it */
- (void)testUpdateContext {
	NSError *error = nil;
	Context *newContext = [ContextDAO addContextWithName:@"Test generated" error:&error];
	GHAssertNotNil(newContext, @"Add context not successful");
	
	newContext.name = @"UPDATE";
	BOOL updateSuccessful = [ContextDAO updateContext:newContext error:&error];
	GHAssertTrue(updateSuccessful, @"Update context not successful");
	
	GHAssertTrue([newContext isUpdated], @"Update context not successful");
	
	/*//[NSThread sleepForTimeInterval:2];
	
	NSArray *contexts = [ContextDAO allContexts:&error];
	GHAssertEquals([contexts count], (NSUInteger)1, @"Add context not successful");
	Context *context = [contexts objectAtIndex:0];
	GHAssertEqualStrings([context name], [newContext name], @"Update context not successful"); */
}

@end