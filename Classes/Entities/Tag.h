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

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Tag (CoreDataGeneratedAccessors)
- (void)addTasksObject:(NSManagedObject *)value;
- (void)removeTasksObject:(NSManagedObject *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

// general fetch-methods for tasks
+ (NSArray *) getTasgsWithFilterString:(NSString*)filterString error:(NSError **)error;
+ (NSArray *) getTagsWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error;

// specialized fetch-methods for tasks - each method encapsulates a call to a general fetch-method
+ (NSArray *)getAllTagsInStore:(NSError **)error;
+ (NSArray *) getAllTags:(NSError **)error;

@end

