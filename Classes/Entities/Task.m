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
	/*NSSortDescriptor *sortByDueDate = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
	 NSSortDescriptor *sortByDueTime = [[NSSortDescriptor alloc] initWithKey:@"dueTime" ascending:YES];
	 [request setSortDescriptors:[NSArray arrayWithObjects:sortByDueDate, sortByDueTime, nil]];
	 [sortByDueDate release];
	 [sortByDueTime release];*/
	
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
	
	[request release];
	
	return objects;
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
	/*NSSortDescriptor *sortByDueDate = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
	 NSSortDescriptor *sortByDueTime = [[NSSortDescriptor alloc] initWithKey:@"dueTime" ascending:YES];
	 [request setSortDescriptors:[NSArray arrayWithObjects:sortByDueDate, sortByDueTime, nil]];
	 [sortByDueDate release];
	 [sortByDueTime release];*/
	
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
	
	[request release];
	
	return objects;
}

+ (NSArray *) getAllTasks:(NSError **)error {
	NSArray* objects = [Task getTasksWithFilterString:nil error:error];	
	return objects;
}

+ (NSArray *) getStarredTasks:(NSError **)error {
	NSArray* objects = [Task getTasksWithFilterString:@"star == 1" error:error];	
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
	return objects;
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
	return objects;
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
	
	return objects;
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
  NSArray *objects = [Task getTasksWithFilterPredicate:[NSPredicate predicateWithFormat:@"tags.@count > 0"] error:error];
}

@end
