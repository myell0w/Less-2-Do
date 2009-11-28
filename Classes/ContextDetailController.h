/*
 *  ContextDetailController.h
 *  Less2Do
 *
 *  Created by Philip Messlehner on 27.11.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define NAME_ROW_INDEX				0
#define NUMBER_OF_EDITABLE_ROWS		1

#define LABEL_TAG					4096

@interface ContextDetailController : UITableViewController <UITextFieldDelegate> {
    Context *context;
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;    
}

@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end