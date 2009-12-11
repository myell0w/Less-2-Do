//
//  EditContextViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContextsFirstLevelViewController.h"

@interface EditContextViewController : UIViewController {
	UITextField *_nameTextField;
	Context *_context;   
	ContextsFirstLevelViewController *_parent;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) ContextsFirstLevelViewController *parent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent context:(Context *)aContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end
