//
//  Context.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class Task;

@interface Context :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * gpsY;
@property (nonatomic, retain) NSNumber * contextId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * gpsX;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Context (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

