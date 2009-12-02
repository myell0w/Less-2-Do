//
//  FolderDetailController.h
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NAME_ROW_INDEX				0
#define COLOR_ROW_INDEX				1
#define NUMBER_OF_EDITABLE_ROWS		1
	
#define LABEL_TAG					4096
	
@interface FolderDetailController : UITableViewController <UITextFieldDelegate> {
	Folder *folder;
	NSArray *fieldLabels;
	NSMutableDictionary *tempValues;
	UITextField *textFieldBeingEdited;    
}

@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (id)initWithStyle:(UITableViewStyle)aStyle andFolder:(Folder *)aFolder;
- (UITableViewCell *)createNameCell;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end