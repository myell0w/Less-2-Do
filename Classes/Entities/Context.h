//
//  Context.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Task;

@interface Context :  BaseRemoteObject  
{
}

@property (nonatomic, retain) NSNumber * gpsY;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * gpsX;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Context (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

- (BOOL)hasGps;
- (double)distanceTo:(CLLocationCoordinate2D)pos;

// general fetch-methods for contexts
+ (NSArray *) getContextsWithFilterString:(NSString*)filterString error:(NSError **)error;
+ (NSArray *) getContextsWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error;

// specialized fetch-methods for contexts - each method encapsulates a call to a general fetch-method
+ (NSArray *)getAllContextsInStore:(NSError **)error;
+ (NSArray *) getAllContexts:(NSError **)error;
+ (NSArray *)getRemoteStoredContexts:(NSError **)error;
+ (NSArray *)getRemoteStoredContextsLocallyDeleted:(NSError **)error;
+ (NSArray *)getLocalStoredContextsLocallyDeleted:(NSError **)error;
+ (NSArray *)getAllContextsLocallyDeleted:(NSError **)error;
+ (NSArray *)getUnsyncedContexts:(NSError **)error;
+ (NSArray *)getModifiedContexts:(NSError **)error;
+ (Context*)getContextWithRemoteId:(NSNumber*)remoteId error:(NSError **)error;

@end

