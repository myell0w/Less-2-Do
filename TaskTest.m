//
//  TaskTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 14.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "Less2DoAppDelegate.h";

@interface TaskTest : GHTestCase {
	Less2DoAppDelegate* appDelegate;
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation TaskTest

- (void)setUp {
	
	/* delete all folders from the persistent store */
	appDelegate = [[Less2DoAppDelegate alloc] init];
	managedObjectContext = [appDelegate managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext]];
	
	NSError *error;
	NSArray *allTasks = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	for (NSManagedObject* task in allTasks)
	{
		[managedObjectContext deleteObject:task];
	}
	if([managedObjectContext save:&error] == NO)
		GHFail(@"Error at setUp");
}

- (void)tearDown {
	[appDelegate release];
	appDelegate = nil;
}

/* test all tasks */
- (void)testAllTasks {
	NSError *error = nil;
	
	Task *newTask1 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask2 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask3 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	newTask1.name = @"Task 1";
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)3, @"Add tasks not successful");
	//NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [tasks objectAtIndex:0], [tasks objectAtIndex:1], [tasks objectAtIndex:2]];
	//GHAssertEqualStrings(output, @"0: Task 1, 1: Task 2, 2: Task 3", @"Ordered Folders not successful");
}

/* test starred tasks */
- (void)testStarredTasks {
	NSError *error = nil;
	
	Task *newTask1 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask2 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask3 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	newTask1.name = @"Task 1";
	newTask1.star = [NSNumber numberWithInt:0];
	newTask2.name = @"Task 2";
	newTask2.star = [NSNumber numberWithInt:1];
	newTask3.name = @"Task 3";
	newTask3.star = [NSNumber numberWithInt:0];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getStarredTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"0 starred tasks not successful");
	//NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [tasks objectAtIndex:0], [tasks objectAtIndex:1], [tasks objectAtIndex:2]];
	//GHAssertEqualStrings(output, @"0: Task 1, 1: Task 2, 2: Task 3", @"Ordered Folders not successful");
}

/* test ordering of tasks */
- (void)testOrderedTasks {
	NSError *error = nil;
	
	Task *newTask1 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask2 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	Task *newTask3 = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	newTask1.name = @"Task 1: 2009-12-05";
	newTask1.dueDate = [[NSDate alloc] initWithString:@"2009-12-05 00:00:00 +0100"];
	newTask2.name = @"Task 2: 2009-12-04";
	//newTask2.dueDate = [[NSDate alloc] initWithString:@"2009-12-04 00:00:00 +0100"];
	newTask2.dueDate = nil;
	newTask3.name = @"Task 3: 2009-12-03";
	newTask3.dueDate = [[NSDate alloc] initWithString:@"2009-12-03 00:00:00 +0100"];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasks:nil error:&error];
	GHAssertEquals([tasks count], (NSUInteger)3, @"0 starred tasks not successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [tasks objectAtIndex:0], [tasks objectAtIndex:1], [tasks objectAtIndex:2]];
	GHFail(output);
	//GHAssertEqualStrings(output, @"0: Task 1, 1: Task 2, 2: Task 3", @"Ordered Folders not successful");
}

@end