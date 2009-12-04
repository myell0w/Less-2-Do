/*
 *  ContextDetailViewController.h
 *  Less2Do
 *
 *  Created by Philip Messlehner on 27.11.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "ContextsFirstLevelViewController.h"

#define NAME_ROW_INDEX				0
#define NUMBER_OF_EDITABLE_ROWS		1

#define LABEL_TAG					4096

@interface ContextDetailViewController : UITableViewController <UITextFieldDelegate> {
    Context *_context;
    NSArray *_fieldLabels;
    NSMutableDictionary *_tempValues;
    UITextField *_textFieldBeingEdited;
	ContextsFirstLevelViewController *_parent;
}

@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) ContextsFirstLevelViewController *parent;

- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(ContextsFirstLevelViewController *)parent andContext:(Context *)aContext;
- (id)initWithStyle:(UITableViewStyle)aStyle andParent:(ContextsFirstLevelViewController *)parent;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end