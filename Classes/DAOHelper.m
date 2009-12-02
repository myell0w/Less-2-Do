//
//  DaoHelper.m
//  Less2Do
//
//  Created by Matthias Tretter on 01.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "DAOHelper.h"


@implementation DAOHelper

+ (NSManagedObject *)objectOfType:(NSString *)type {
	// Den delegate vom Less2DoAppDelegate
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	// Den ManagedObjectContext durch den delegate
	NSManagedObjectContext *context = [delegate managedObjectContext];
	// create a Task
	return [NSEntityDescription insertNewObjectForEntityForName:type 
								inManagedObjectContext:context]; 
}

@end
