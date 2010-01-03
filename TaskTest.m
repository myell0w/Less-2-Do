//
//  TaskTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 14.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "Folder.h"
#import "Tag.h"
#import "CustomGHUnitAppDelegate.h";

@interface TaskTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation TaskTest

- (void)setUp {
	
	/* delete all Tasks from the persistent store */
	CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	managedObjectContext = [delegate managedObjectContext];
	
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
	/* do nothing */
}

/* test all tasks */
- (void)testAllTasks {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
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
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
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
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"Task 1: 2009-12-05";
	newTask1.dueDate = [[NSDate alloc] initWithString:@"2009-12-05 00:00:00 +0100"];
	newTask2.name = @"Task 2: 2009-12-04";
	//newTask2.dueDate = [[NSDate alloc] initWithString:@"2009-12-04 00:00:00 +0100"];
	newTask2.dueDate = nil;
	newTask3.name = @"Task 3: 2009-12-03";
	newTask3.dueDate = [[NSDate alloc] initWithString:@"2009-12-03 00:00:00 +0100"];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksWithFilterString:nil error:&error];
	GHAssertEquals([tasks count], (NSUInteger)3, @"0 starred tasks not successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [tasks objectAtIndex:0], [tasks objectAtIndex:1], [tasks objectAtIndex:2]];
	GHFail(output);
	//GHAssertEqualStrings(output, @"0: Task 1, 1: Task 2, 2: Task 3", @"Ordered Folders not successful");
}

- (void)testGetTasksInFolder {
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder.name = @"MyFolder";
	newTask1.name = @"Task 1";
	[newTask1 setFolder:newFolder];
	newTask2.name = @"Task 2";
	newTask2.folder = nil;
	newTask3.name = @"Task 3";
	newTask3.folder = newFolder;
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksInFolder:newFolder error:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Add tasks not successful");
}

- (void)testGetTasksWithTag {
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Tag *newTag = (Tag*)[Tag objectOfType:@"Tag"];
	newTag.name = @"MyTag";
	newTask1.name = @"Task 1";
	[newTask1 addTagsObject:newTag];
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[newTask3 addTagsObject:newTag];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksWithTag:newTag error:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Add tasks not successful");
}

- (void)testGetTasksInContext {
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Context *newContext = (Context*)[Context objectOfType:@"Context"];
	newContext.name = @"MyContext";
	newTask1.name = @"Task 1";
	newTask1.context = newContext;
	newTask2.name = @"Task 2";
	newTask2.context = nil;
	newTask3.name = @"Task 3";
	newTask3.context = newContext;
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksInContext:newContext error:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Add tasks not successful");
}

- (void)testGetTasksWithoutTag
{
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Tag *newTag = (Tag*)[Tag objectOfType:@"Tag"];
	newTag.name = @"MyTag";
	newTask1.name = @"Task 1";
	[newTask1 addTagsObject:newTag];
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[managedObjectContext save:&error];

	NSArray *tasks = [Task getTasksWithoutTag:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Getting tasks without a tag failed!");
}
- (void)testGetTasksWithoutContext
{
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Context *newContext = (Context*)[Context objectOfType:@"Context"];
	newContext.name = @"MyContext";
	newTask1.name = @"Task 1";
	[newTask1 setContext:newContext];
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksWithoutContext:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Getting tasks without a Context failed!");
}
- (void)testGetTasksWithoutFolder
{
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
	newFolder.name = @"MyFolder";
	newTask1.name = @"Task 1";
	[newTask1 setFolder:newFolder];
	//[newFolder.tasks setByAddingObject:self];
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksWithoutFolder:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"Getting tasks without a Folder failed!");
}

- (void)testGetCompletedTasks
{
	NSError *error = nil;
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];

	newTask1.name = @"Task 1";
    newTask1.isCompleted = [[NSNumber alloc] initWithInt:(int)1];
	newTask2.name = @"Task 2";
	newTask3.name = @"Task 3";
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getCompletedTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"Getting tasks that are completed failed!");
}

@end