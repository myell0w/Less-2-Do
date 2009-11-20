//
//  Less2DoAppDelegate.h
//  Less2Do
//
//  Created by Matthias Tretter on 17.11.09.
//  Copyright BIAC 2009. All rights reserved.
//

@class HomeNavigationController;

@interface Less2DoAppDelegate : NSObject <UIApplicationDelegate> {

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
	// Controller for the Black Tab Bar
	UITabBarController *rootController;
	// Navigation Controller for Section "Home"
	HomeNavigationController *homeController;
	// Navigation Controller for Section "Folders"
	UINavigationController *foldersController;
	// Navigation Controller for Section "Contexts"
	UINavigationController *contextsController;
	// Navigation Controller for Section "Tags"
	UINavigationController *tagsController;
	// Navigation Controller for Section "Settings"
	UINavigationController *settingsController;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet HomeNavigationController *homeController;
@property (nonatomic, retain) IBOutlet UINavigationController *foldersController;
@property (nonatomic, retain) IBOutlet UINavigationController *contextsController;
@property (nonatomic, retain) IBOutlet UINavigationController *tagsController;
@property (nonatomic, retain) IBOutlet UINavigationController *settingsController;

- (NSString *)applicationDocumentsDirectory;

@end

