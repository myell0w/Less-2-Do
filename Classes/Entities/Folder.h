//
//  Folder.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface Folder :  BaseRemoteObject  
{
}

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


// general fetch-methods for tasks
+ (NSArray *) getFoldersWithFilterString:(NSString*)filterString error:(NSError **)error;
+ (NSArray *) getFoldersWithFilterPredicate:(NSPredicate*)filterPredicate error:(NSError **)error;

// specialized fetch-methods for tasks - each method encapsulates a call to a general fetch-method
+ (NSArray *)getAllFoldersInStore:(NSError **)error;
+ (NSArray *)getAllFolders:(NSError **)error; //Automatisch geordnet nach Order
//TODO folder with rgb
+ (NSArray *)getFolderWithRGB:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue error:(NSError *)error;
+ (NSArray *)getRemoteStoredFolders:(NSError **)error;
+ (NSArray *)getRemoteStoredFoldersLocallyDeleted:(NSError **)error;
+ (NSArray *)getLocalStoredFoldersLocallyDeleted:(NSError **)error;
+ (NSArray *)getAllFoldersLocallyDeleted:(NSError **)error;
+ (NSArray *)getUnsyncedFolders:(NSError **)error;
+ (NSArray *)getModifiedFolders:(NSError **)error;

- (UIColor *) color;

@end

