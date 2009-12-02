//
//  Folder.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface Folder :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * folderId;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* tasks;
@property (nonatomic, retain) NSNumber * r;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * b;

@end


@interface Folder (CoreDataGeneratedAccessors)
- (void)addTasksObject:(NSManagedObject *)value;
- (void)removeTasksObject:(NSManagedObject *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

