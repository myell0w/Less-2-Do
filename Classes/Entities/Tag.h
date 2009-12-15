//
//  Tag.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface Tag :  BaseManagedObject  
{
}

@property (nonatomic, retain) NSNumber * tagId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Tag (CoreDataGeneratedAccessors)
- (void)addTasksObject:(NSManagedObject *)value;
- (void)removeTasksObject:(NSManagedObject *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

// general fetch-methods for tasks
+ (NSArray *) getTasksWithFilterString:(NSString*)filterString error:(NSError **)error;
+ (NSArray *) getTasksWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error;

// specialized fetch-methods for tasks - each method encapsulates a call to a general fetch-method
+ (NSArray *) getAllTasks:(NSError **)error;

@end

