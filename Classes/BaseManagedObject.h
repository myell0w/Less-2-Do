//
//  BaseManagedObject.h
//  Less2Do
//
//  Created by Gerhard Schraml on 15.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface BaseManagedObject : NSManagedObject {
}

@property (nonatomic, retain) NSNumber * remoteId;

+ (NSManagedObjectContext*) managedObjectContext;

+ (BaseManagedObject *)objectOfType:(NSString *)type;
+ (BOOL)deleteObject:(BaseManagedObject *)theObject error:(NSError **)error;
+ (void)commit;

@end
