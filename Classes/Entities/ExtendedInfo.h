//
//  ExtendedInfo.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class Task;

@interface ExtendedInfo :  BaseManagedObject  
{
}

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * extendedInfoId;
@property (nonatomic, retain) NSSet* task;

@end


@interface ExtendedInfo (CoreDataGeneratedAccessors)
- (void)addTaskObject:(Task *)value;
- (void)removeTaskObject:(Task *)value;
- (void)addTask:(NSSet *)value;
- (void)removeTask:(NSSet *)value;

@end

