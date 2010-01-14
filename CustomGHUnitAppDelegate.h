//
//  CustomGHUnitAppDelegate.h
//  Less2Do
//
//  Created by Gerhard Schraml on 15.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHUnitIPhoneAppDelegate.h"

@interface CustomGHUnitAppDelegate : GHUnitIPhoneAppDelegate {
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSTimer *timer;
}

@property (nonatomic, retain) NSTimer *timer;


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (BOOL)clearPersistentStore;
- (void)commitDatabase:(NSTimer *) theTimer;
- (void)startTimer;
- (void)stopTimer;

@end
