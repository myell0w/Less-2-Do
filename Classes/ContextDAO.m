//
//  ContextDAO.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDAO.h"


@implementation ContextDAO

+(NSArray *)allContexts
{	
	NSError *error;
	Less2DoAppDelegate *del = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *moc = [del managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
											  inManagedObjectContext:moc];
	[request setEntity:entityDescription];
	
	
	/* zuerst eines anlegen */
	/*NSError *saveError;
	 Context *newContext = [[Context alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
	 newContext.name = @"bussi";
	 [moc save:&saveError];
	 /* ende anlegen */
	
	NSArray *objects = [moc executeFetchRequest:request
										  error:&error];
	if (objects == nil) {
		NSLog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	/*if ([objects count] > 0)
	 {
	 // for schleife objekte erzeugen und array addObject:currentContext
	 for (int i=0; i<[objects count]; i++) {
	 Context *context = [objects objectAtIndex:i];
	 //befülle Return-Array
	 [returnArray addObject:conte
	 }
	 }*/
	[request release];
	
	return objects;
}

+(int)addContextWithName:(NSString*)theName
{
	NSError *saveError;
	Less2DoAppDelegate *del = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *moc = [del managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Context"
											  inManagedObjectContext:moc];
	[request setEntity:entityDescription];
	
	
	/* zuerst eines anlegen */
	Context *newContext = [[Context alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
	newContext.name = theName;
	[moc save:&saveError];
	/* ende anlegen */
	
	[request release];
	
	return 0;
};

@end
