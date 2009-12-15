//
//  BaseManagedObject.h
//  Less2Do
//
//  Created by Gerhard Schraml on 15.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface BaseManagedObject : NSManagedObject {
}

+ (NSManagedObjectContext*) managedObjectContext;

+ (NSManagedObject *)objectOfType:(NSString *)type;
+ (BOOL)deleteObject:(BaseManagedObject *)theObject error:(NSError **)error;

@end
