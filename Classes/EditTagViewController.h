//
//  EditTagViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsFirstLevelController.h"

@interface EditTagViewController : UIViewController {
	UITextField *_nameTextField;
	Tag *_tag;   
	TagsFirstLevelController *_parent;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) TagsFirstLevelController *parent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(TagsFirstLevelController *)aParent tag:(Tag *)aTag;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(TagsFirstLevelController *)aParent;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
@end
