//
//  TagDetailViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsFirstLevelController.h"

#define NAME_ROW_INDEX				0
#define NUMBER_OF_EDITABLE_ROWS		1
	
#define LABEL_TAG					4096
	
@interface TagDetailViewController : UITableViewController <UITextFieldDelegate> {
	Tag *_tag;
	NSArray *_fieldLabels;
	NSMutableDictionary *_tempValues;
	UITextField *_textFieldBeingEdited;
	TagsFirstLevelController *_parent;
}

@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) TagsFirstLevelController *parent;

- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(TagsFirstLevelController *)aParent andTag:(Tag *)aTag;
- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(TagsFirstLevelController *)aParent;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@end