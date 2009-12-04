//
//  FolderDetailViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderFirstLevelController.h"

#define NAME_ROW_INDEX				0
#define COLOR_ROW_INDEX				1
#define NUMBER_OF_EDITABLE_ROWS		1
	
#define LABEL_TAG					4096
	
@interface FolderDetailViewController : UITableViewController <UITextFieldDelegate> {
	Folder *_folder;
	NSArray *_fieldLabels;
	NSMutableDictionary *_tempValues;
	UITextField *_textFieldBeingEdited;    
	FolderFirstLevelController *_parent;
}

@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) FolderFirstLevelController *parent;

- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(FolderFirstLevelController *)aParent andFolder:(Folder *)aFolder;
- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(FolderFirstLevelController *)aParent;
- (UITableViewCell *)createNameCell;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end