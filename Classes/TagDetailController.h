//
//  TagDetailController.h
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define NAME_ROW_INDEX				0
#define NUMBER_OF_EDITABLE_ROWS		1
	
#define LABEL_TAG					4096
	
@interface TagDetailController : UITableViewController <UITextFieldDelegate> {
		Tag *tag;
		NSArray *fieldLabels;
		NSMutableDictionary *tempValues;
		UITextField *textFieldBeingEdited;    
}

@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (id)initWithStyle:(UITableViewStyle)aStyle andTag:(Tag *)aTag;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@end
