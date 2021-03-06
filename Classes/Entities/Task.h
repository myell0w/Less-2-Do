//
//  Task.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

@class Folder;
@class Tag;

#define PRIORITY_NONE   -1
#define PRIORITY_LOW    0
#define PRIORITY_MEDIUM 1
#define PRIORITY_HIGH   2

@interface Task :  BaseRemoteObject  
{
}

@property (nonatomic, retain) NSNumber * frequencyAnnoy;
@property (nonatomic, retain) NSNumber * isCompleted;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * startTimeAnnoy;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSDate * dueTime;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSNumber * timerValue;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSNumber * star;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * startDateAnnoy;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * endTimeAnnoy;
@property (nonatomic, retain) Folder * folder;
@property (nonatomic, retain) Context * context;
@property (nonatomic, retain) NSSet* tags;
@property (nonatomic, retain) NSManagedObject * abContact;
@property (nonatomic, retain) NSSet* extendedInfo;


@end


@interface Task (CoreDataGeneratedAccessors)
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)value;
- (void)removeTags:(NSSet *)value;

- (void)addExtendedInfoObject:(NSManagedObject *)value;
- (void)removeExtendedInfoObject:(NSManagedObject *)value;
- (void)addExtendedInfo:(NSSet *)value;
- (void)removeExtendedInfo:(NSSet *)value;

- (void)setFolder:(Folder *)value;
- (void)removeFolder;
- (void)setContext:(Context *)value;
- (void)removeContext;

- (NSString *)tagsDescription;
- (NSDate *)nextDueDate;
- (BOOL)isRepeating;
- (BOOL)hasImage;
- (NSData *)imageData;

- (NSString *)repeatString;

// general fetch-methods for tasks
+ (NSArray *) getTasksWithFilterString:(NSString*)filterString error:(NSError **)error;
+ (NSArray *) getTasksWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error;

// specialized fetch-methods for tasks - each method encapsulates a call to a general fetch-method
+ (NSArray *) getAllTasksInStore:(NSError **)error;
+ (NSArray *) getAllTasks:(NSError **)error;
+ (NSArray *) getStarredTasks:(NSError **)error;
+ (NSArray *) getTasksInFolder:(Folder*)theFolder error:(NSError **)error;
+ (NSArray *) getTasksWithTag:(Tag*)theTag error:(NSError **)error;
+ (NSArray *) getTasksInContext:(Context*)theContext error:(NSError **)error;
+ (NSArray *) getTasksWithContext:(CLLocation *)theLocation error:(NSError **)error;

+ (NSArray *) getCompletedTasks:(NSError **)error;
+ (NSArray *) getTasksWithoutFolder:(NSError **)error;
+ (NSArray *) getTasksWithoutContext:(NSError **)error;
+ (NSArray *) getTasksWithoutTag:(NSError **)error;

+ (NSArray *) getTasksToday:(NSError **)error;
+ (NSArray *) getTasksThisWeek:(NSError **)error;
+ (NSArray *) getTasksOverdue:(NSError **)error;

//Tags conversion functions
- (NSString *) tagsAsString:(NSError **)error;
- (NSSet *) tagStringToTags:(NSString *)tagString error:(NSError **)error;

+ (NSArray *)getRemoteStoredTasks:(NSError **)error;
+ (NSArray *)getRemoteStoredTasksLocallyDeleted:(NSError **)error;
+ (NSArray *)getLocalStoredTasksLocallyDeleted:(NSError **)error;
+ (NSArray *)getAllTasksLocallyDeleted:(NSError **)error;
+ (NSArray *)getUnsyncedTasks:(NSError **)error;
+ (NSArray *)getModifiedTasks:(NSError **)error;
/*
alle Tasks, die completed sind (done)
alle Tasks die keinen Folder haben (done)
keinen Context (done)
kein Tag (done)
 
 TASK LOESCHEN
*/

@end

