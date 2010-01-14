// 
//  Task.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

#import "Folder.h"
#import "Tag.h"

#define MAX_TAGS_COUNT 20


@implementation Task 

@dynamic frequencyAnnoy;
@dynamic isCompleted;
@dynamic duration;
@dynamic startTimeAnnoy;
@dynamic dueDate;
@dynamic dueTime;
@dynamic repeat;
@dynamic name;
@dynamic priority;
@dynamic modificationDate;
@dynamic reminder;
@dynamic timerValue;
@dynamic completionDate;
@dynamic star;
@dynamic note;
@dynamic startDateAnnoy;
@dynamic creationDate;
@dynamic endTimeAnnoy;
@dynamic folder;
@dynamic context;
@dynamic tags;
@dynamic abContact;
@dynamic extendedInfo;


- (NSString *)repeatString {
	NSArray *array = [NSArray arrayWithObjects:@"No Repeat", @"Weekly", @"Monthly", @"Yearly", @"Daily", @"Biweekly", 
			  				   					      @"Bimonthly", @"Semiannually", @"Quarterly", nil];
	
	if (self.repeat != nil) {
		return [array objectAtIndex:[self.repeat intValue]%100];
	} else {
		return @"No Repeat";
	}
}

- (NSString *)description {
	return self.name;
}

- (NSString *)tagsDescription {
	if ([self.tags count] > 0) {
		NSMutableString *s = [[NSMutableString alloc] init];
		
		for (id t in self.tags) {
			Tag *tag = (Tag *)t;
			[s appendFormat:@"%@, ", [tag description]];
		}
		
		NSString *desc = [s substringToIndex: (s.length - 2)];
		[s release];
		
		if (desc.length < MAX_TAGS_COUNT) {
			return desc;
		} else {
			if ([self.tags count] == 1)
				return @"1 Tag";
			else {
				return [NSString stringWithFormat:@"%d Tags", [self.tags count]];
			}
		}
	} else {
		return @"0 Tags";
	}
}

- (BOOL)isRepeating {
	return self.repeat != nil && ([self.repeat intValue]%100 != 0);
}

- (NSDate *)nextDueDate {
	if (![self isRepeating]) {
		return self.dueDate;
	} else {
		NSDate *d = self.dueDate;
		NSDate *now = [[NSDate alloc] init];
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *comp = [[NSDateComponents alloc] init];
		//TODO: support dueDate from completion-date
		
		switch ([self.repeat intValue]) {
			// repeat weekly
			case 1:
				[comp setDay:7];
				break;
			// repeat monthly
			case 2:
				[comp setMonth:1];
				break;
			// repeat yearly
			case 3:
				[comp setYear:1];
				break;
			// repeat daily
			case 4:
				[comp setDay:1];
				break;
			// repeat biweekly
			case 5:
				[comp setDay:14];
				break;
			// repeat bimonthly
			case 6:
				[comp setMonth:2];
				break;
			// repeat semiannually
			case 7:
				[comp setMonth:6];
				break;
			// repeat quarterly
			case 8:
				[comp setMonth:3];
				break;
			// repeat with parent
			case 9:
			default:
				[comp release];
				[now release];
				return self.dueDate;
				break;
		}
		
		for (int i=0; YES ; i++) {
			d = [cal dateByAddingComponents:comp toDate:d options:0];
			
			// return first dueDate, that is in the future
			if ([d compare:now] == NSOrderedDescending) {
				[comp release];
				[now release];
				
				return d;
			}
		}
	}
}

+ (NSArray *) getTasksWithFilterString:(NSString*)filterString error:(NSError **)error {
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Task"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* apply sort order */
	NSSortDescriptor *sortByDueDate = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
	NSSortDescriptor *sortByDueTime = [[NSSortDescriptor alloc] initWithKey:@"dueTime" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByDueDate, sortByDueTime, nil]];
	[sortByDueDate release];
	[sortByDueTime release];
	
	/* apply filter string */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
	[request setPredicate:predicate];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		[request release];
		
		return nil;
	}
	
	/* rearrange array */
	NSMutableArray *mutableObjects = [NSMutableArray arrayWithArray:objects];
	NSMutableArray *tasksWithNilDueDate = [NSMutableArray array];
	for(int i=0;i<[mutableObjects count];i++)
	{
		Task* task = [mutableObjects objectAtIndex:i];
		if(task.dueDate == nil)
			[tasksWithNilDueDate addObject:task];
	}
	
	for(int i=0;i<[tasksWithNilDueDate count];i++)
	{
		Task *task = [tasksWithNilDueDate objectAtIndex:i];
		[mutableObjects removeObject:task];
		[mutableObjects addObject:task];
	}
	
	NSArray *returnValue = [NSArray arrayWithArray:mutableObjects];
	
	ALog(@"SORTED DATES OF TASKS:");
	for(int i=0;i<[returnValue count];i++)
	{
		Task *task = [returnValue objectAtIndex:i];
		ALog(@"%d - %@ dueDate: %@ dueTime:%@", i, task.name, task.dueDate, task.dueTime);
	}
	
	[request release];
	
	return returnValue;
}

+ (NSArray *) getTasksWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error
{
	NSError *fetchError;
	
	/* get entity description - needed for fetching */
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Task"
											  inManagedObjectContext:[self managedObjectContext]];
	
	/* create new fetch request */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	/* apply sort order */
	NSSortDescriptor *sortByDueDate = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
	NSSortDescriptor *sortByDueTime = [[NSSortDescriptor alloc] initWithKey:@"dueTime" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortByDueDate, sortByDueTime, nil]];
	[sortByDueDate release];
	[sortByDueTime release];
	
	/* apply filter string */
	[request setPredicate:filterPredicate];
	
	/* fetch objects */
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
	if (objects == nil) 
	{
		*error = [NSError errorWithDomain:DAOErrorDomain code:DAONotFetchedError userInfo:nil];
		[request release];
		
		return nil;
	}
	
	/* rearrange array */
	NSMutableArray *mutableObjects = [NSMutableArray arrayWithArray:objects];
	NSMutableArray *tasksWithNilDueDate = [NSMutableArray array];
	for(int i=0;i<[mutableObjects count];i++)
	{
		Task* task = [mutableObjects objectAtIndex:i];
		if(task.dueDate == nil)
			[tasksWithNilDueDate addObject:task];
	}
	
	for(int i=0;i<[tasksWithNilDueDate count];i++)
	{
		Task *task = [tasksWithNilDueDate objectAtIndex:i];
		[mutableObjects removeObject:task];
		[mutableObjects addObject:task];
	}
	
	NSArray *returnValue = [NSArray arrayWithArray:mutableObjects];
	
	ALog(@"SORTED DATES OF TASKS:");
	for(int i=0;i<[returnValue count];i++)
	{
		Task *task = [returnValue objectAtIndex:i];
		ALog(@"%d - %@ dueDate: %@ dueTime:%@", i, task.name, task.dueDate, task.dueTime);
	}
	
	[request release];
	
	return returnValue;
}

+ (NSArray *) getAllTasks:(NSError **)error {
	NSArray* objects = [Task getTasksWithFilterPredicate:[NSPredicate predicateWithFormat:@"isCompleted == NO"] error:error];	
	return objects;
}

+ (NSArray *) getStarredTasks:(NSError **)error {
	NSArray* objects = [Task getTasksWithFilterString:@"star == 1 and isCompleted == NO" error:error];	
	return objects;
}

+ (NSArray *) getTasksInFolder:(Folder*)theFolder error:(NSError **)error {	
	NSExpression *leftSide = [NSExpression expressionForKeyPath:@"folder"];
	NSExpression *rightSide = [NSExpression expressionForConstantValue:theFolder];
	NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:leftSide
																rightExpression:rightSide
																	   modifier:NSDirectPredicateModifier
																		   type:NSEqualToPredicateOperatorType
																		options:0];
	NSArray* objects = [Task getTasksWithFilterPredicate:predicate error:error];
	return [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCompleted == NO"]];
}

+ (NSArray *) getTasksWithTag:(Tag*)theTag error:(NSError **)error {	
	NSExpression *leftSide = [NSExpression expressionForKeyPath:@"tags"];
	NSExpression *rightSide = [NSExpression expressionForConstantValue:theTag];
	NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:leftSide
																rightExpression:rightSide
																	   modifier:NSDirectPredicateModifier
																		   type:NSContainsPredicateOperatorType
																		options:0];
	NSArray* objects = [Task getTasksWithFilterPredicate:predicate error:error];
	return [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCompleted == NO"]];
}

+ (NSArray *) getTasksInContext:(Context*)theContext error:(NSError **)error {	
	NSExpression *leftSide = [NSExpression expressionForKeyPath:@"context"];
	NSExpression *rightSide = [NSExpression expressionForConstantValue:theContext];
	NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:leftSide
																rightExpression:rightSide
																	   modifier:NSDirectPredicateModifier
																		   type:NSEqualToPredicateOperatorType
																		options:0];
	NSArray* objects = [Task getTasksWithFilterPredicate:predicate error:error];
	
	return [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCompleted == NO"]];
}

+ (NSArray *) getCompletedTasks:(NSError **)error
{
	NSArray* objects = [Task getTasksWithFilterString:@"isCompleted == YES" error:error];	
	return objects;
}

+ (NSArray *) getTasksWithoutFolder:(NSError **)error
{ 
	// TODO: WARUM GEHT DAS NICHT - Folder default belegung?
	NSArray* objects = [Task getTasksInFolder:nil error:error];	
	return objects;
}

+ (NSArray *) getTasksWithoutContext:(NSError **)error
{
	NSArray* objects = [Task getTasksInContext:nil error:error];	
	return objects;
}

+ (NSArray *) getTasksWithoutTag:(NSError **)error
{
  return [Task getTasksWithFilterPredicate:[NSPredicate predicateWithFormat:@"tags.@count == 0 and isCompleted == NO"] error:error];
}

+ (NSArray *) getTasksWithContext:(NSError **)error
{
	return [Task getTasksWithFilterString:@"context != nil and context.gpsX != nil and context.gpsY != nil and isCompleted == NO" error:error];
}

@end
