//
//  TaskDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "Tag.h"
#import "Folder.h"
#import "CustomGHUnitAppDelegate.h";

@interface TaskTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation TaskTest

- (void)setUp {
	
	/* delete all tasks from the persistent store */
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

/* Tests receiving all tasks without adding tasks before */
- (void)testAllTasksEmpty {
	NSError *error = nil;
	NSArray *tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)0, @"Task count must be 0");
}

/* adds 3 tasks - count must be 3 */
- (void)testAddTask {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"c1";
	newTask2.name = @"c2";
	newTask3.name = @"c3";
	
	NSArray *tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)3, @"Add task not successful");
}

/* Tests deleting a task with nil as parameter */
- (void)testDeleteTaskWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [Task deleteObject:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Task must not be deleted without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a task and then deletes it - count then must be 0 */
- (void)testDeleteTask {
	NSError *error = nil;
	Task *newTask = (Task*)[Task objectOfType:@"Task"];
	
	NSArray *tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"Add task not successful");
	
	BOOL deleteSuccessful = [Task deleteObject:newTask error:&error];
	GHAssertTrue(deleteSuccessful, @"Delete task not successful");
	
	tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)0, @"Delete task not successful");
}

- (void)testAllTasksOrdered {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"C";
	newTask1.dueDate = [NSDate dateWithTimeIntervalSince1970:20];
	newTask2.name = @"A";
	newTask2.dueDate = [NSDate dateWithTimeIntervalSince1970:10];
	newTask3.name = @"B";
	newTask3.dueDate = [NSDate dateWithTimeIntervalSince1970:15];
	
	NSArray *tasks = [Task getAllTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)3, @"Add tasknot successful");
	NSString *output = [NSString stringWithFormat:@"0: %@, 1: %@, 2: %@", [[tasks objectAtIndex:0] name], [[tasks objectAtIndex:1] name], [[tasks objectAtIndex:2] name]];
	GHAssertEqualStrings(output, @"0: A, 1: B, 2: C", @"Ordered Tasks not successful");
}

-(void) testGetRemoteStoredTasks
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.remoteId = [NSNumber numberWithInt:-1];
	newTask2.remoteId = [NSNumber numberWithInt:20000];
	newTask3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *tasks = [Task getRemoteStoredTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"");
}

-(void) testGetRemoteStoredTasksLocallyDeleted
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.remoteId = [NSNumber numberWithInt:-1];
	newTask2.remoteId = [NSNumber numberWithInt:20000];
	newTask3.remoteId = [NSNumber numberWithInt:23000];
	[Task deleteObject:newTask3 error:&error];
	
	NSArray *tasks = [Task getRemoteStoredTasksLocallyDeleted:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"");
}

-(void) testGetLocalStoredTasksLocallyDeleted
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.remoteId = [NSNumber numberWithInt:-1];
	newTask2.remoteId = [NSNumber numberWithInt:-1];
	newTask3.remoteId = [NSNumber numberWithInt:23000];
	[Task deleteObject:newTask2 error:&error];
	[Task commit];
	
	NSArray *tasks = [Task getLocalStoredTasksLocallyDeleted:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"");
}

-(void) testGetAllTasksLocallyDeleted
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.remoteId = [NSNumber numberWithInt:-1];
	newTask2.remoteId = [NSNumber numberWithInt:20000];
	newTask3.remoteId = [NSNumber numberWithInt:23000];
	[Task deleteObject:newTask2 error:&error];
	[Task deleteObject:newTask1 error:&error];
	
	NSArray *tasks = [Task getAllTasksLocallyDeleted:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"");
}

-(void) testGetUnsyncedTasks
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.remoteId = [NSNumber numberWithInt:-1];
	newTask2.remoteId = [NSNumber numberWithInt:20000];
	newTask3.remoteId = [NSNumber numberWithInt:23000];
	
	NSArray *tasks = [Task getUnsyncedTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)1, @"");
}

-(void) testGetModifiedTasks
{
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	newTask1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:0];
	newTask1.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newTask2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:15];
	newTask2.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	newTask3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:20];
	newTask3.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:5];
	
	
	NSArray *tasks = [Task getModifiedTasks:&error];
	GHAssertEquals([tasks count], (NSUInteger)2, @"");
}


/* adds 3 tasks - count must be 3 */
/*- (void)testOldestModificationDate {
 NSError *error = nil;
 
 NSDateFormatter *format = [[NSDateFormatter alloc] init];
 [format setDateFormat:@"yyyy:mm:dd hh:mm "];
 
 Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
 Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
 Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
 
 newTask1.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:2];
 newTask2.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:3];
 newTask3.lastLocalModification = [NSDate dateWithTimeIntervalSince1970:4];
 ALog(@"date1: %@", newTask1.lastLocalModification);
 
 [BaseRemoteObject commit];
 
 NSDate *oldestDate = [Task oldestModificationDateOfType:@"Task" error:&error];
 if (![oldestDate isEqualToDate:newTask1.lastLocalModification]) {
 GHFail(@"Oldest Mod Date not successful");
 }
 }*/

/* ===================================================================================================== */

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

- (void)testTasksToday {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask4 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"Task 1";
	newTask1.dueDate = [NSDate date];
	newTask2.name = @"Task 2";
	newTask2.dueDate = nil;
	newTask3.name = @"Task 3";
	newTask3.dueDate = [NSDate date];
	newTask4.name = @"Task 4";
	newTask4.dueDate = [[NSDate alloc] initWithString:@"2009-12-05 00:00:00 +0100"];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksToday:&error];
	ALog(@"TASKS TODAY");
	for(int i=0;i<[tasks count];i++)
	{
		Task *task = [tasks objectAtIndex:i];
		ALog(@"%d - %@ dueDate: %@ dueTime:%@", i, task.name, task.dueDate, task.dueTime);
	}
	GHAssertEquals([tasks count], (NSUInteger)2, @"tasks today not successful");
}

- (void)testTasksThisWeek {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask4 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"Task 1";
	newTask1.dueDate = [NSDate date];
	newTask2.name = @"Task 2";
	newTask2.dueDate = nil;
	newTask3.name = @"Task 3";
	newTask3.dueDate = [NSDate date];
	newTask4.name = @"Task 4";
	newTask4.dueDate = [[NSDate alloc] initWithString:@"2009-12-05 00:00:00 +0100"];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksThisWeek:&error];
	ALog(@"TASKS THIS WEEK");
	for(int i=0;i<[tasks count];i++)
	{
		Task *task = [tasks objectAtIndex:i];
		ALog(@"%d - %@ dueDate: %@ dueTime:%@", i, task.name, task.dueDate, task.dueTime);
	}
	GHAssertEquals([tasks count], (NSUInteger)2, @"tasks this week not successful");
}

- (void)testTasksOverdue {
	NSError *error = nil;
	
	Task *newTask1 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask2 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask3 = (Task*)[Task objectOfType:@"Task"];
	Task *newTask4 = (Task*)[Task objectOfType:@"Task"];
	newTask1.name = @"Task 1";
	newTask1.dueDate = [[NSDate date] addTimeInterval:-5];
	newTask2.name = @"Task 2";
	newTask2.dueDate = nil;
	newTask3.name = @"Task 3";
	newTask3.dueDate = [[NSDate date] addTimeInterval:-5];
	newTask4.name = @"Task 4";
	newTask4.dueDate = [[NSDate alloc] initWithString:@"2100-12-05 00:00:00 +0100"];
	[managedObjectContext save:&error];
	
	NSArray *tasks = [Task getTasksOverdue:&error];
	ALog(@"TASKS OVERDUE");
	for(int i=0;i<[tasks count];i++)
	{
		Task *task = [tasks objectAtIndex:i];
		ALog(@"%d - %@ dueDate: %@ dueTime:%@", i, task.name, task.dueDate, task.dueTime);
	}
	GHAssertEquals([tasks count], (NSUInteger)2, @"tasks this week not successful");
}

@end