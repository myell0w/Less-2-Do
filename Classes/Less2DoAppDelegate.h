//
//  Less2DoAppDelegate.h
//  Less2Do
//
//  Created by Matthias Tretter on 17.11.09.
//  Copyright BIAC 2009. All rights reserved.
//

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark The Application Delegate 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@class HomeNavigationController;
@class FolderNavigationController;
@class ContextsNavigationController;
@class TagsNavigationController;
@class SettingsNavigationController;


@interface Less2DoAppDelegate : NSObject <UIApplicationDelegate> {

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	NSTimer *syncTimer;
	NSTimer *reminderTimer;
	NSMutableDictionary *alreadyReminded;

	// the main window
    UIWindow *window;
	// Controller for the Black Tab Bar = root Controller
	UITabBarController *rootController;
	
	// Navigation Controller for Section "Home"
	HomeNavigationController *homeController;
	// Navigation Controller for Section "Folders"
	FolderNavigationController *foldersController;
	// Navigation Controller for Section "Contexts"
	ContextsNavigationController *contextsController;
	// Navigation Controller for Section "Tags"
	TagsNavigationController *tagsController;
	// Navigation Controller for Section "Settings"
	SettingsNavigationController *settingsController;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSTimer * syncTimer;
@property (nonatomic, retain) NSTimer * reminderTimer;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet HomeNavigationController *homeController;
@property (nonatomic, retain) IBOutlet FolderNavigationController *foldersController;
@property (nonatomic, retain) IBOutlet ContextsNavigationController *contextsController;
@property (nonatomic, retain) IBOutlet TagsNavigationController *tagsController;
@property (nonatomic, retain) IBOutlet SettingsNavigationController *settingsController;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)applicationDocumentsDirectory;

- (void)commitDatabase:(NSTimer *)timer;
- (void)checkDueTasks:(NSTimer *)timer;

-(void)startTimer;
-(void)stopTimer;

@end

