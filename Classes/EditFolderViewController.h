//
//  EditFolderViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 08.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderFirstLevelController.h"


@interface EditFolderViewController : UIViewController {
	UITextField *_nameTextField;
	Folder *_folder;   
	FolderFirstLevelController *_parent;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) FolderFirstLevelController *parent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(FolderFirstLevelController *)aParent folder:(Folder *)aFolder;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(FolderFirstLevelController *)aParent;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end
