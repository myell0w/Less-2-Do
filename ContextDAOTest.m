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

- (void)testAddContextWithNameWithoutTitle;

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

/* Tests adding a context without a context parameter */
- (void)testAddContextWithNameWithoutTitle {
	NSError *error = nil;
	Context *returnValue = [ContextDAO addContextWithName:nil error:&error];
	GHAssertTrue([error code] == DAOMissingParametersError, @"Context must not be added without name");
	GHAssertTrue(returnValue == nil, @"Return value must be nil.");
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

@end