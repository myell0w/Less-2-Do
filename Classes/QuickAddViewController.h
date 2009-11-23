//
//  QuickAddViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 23.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuickAddViewController : UIViewController {
	UITextField *task;
}

@property (nonatomic, retain) IBOutlet UITextField *task;

-(IBAction)taskAdded:(id)sender;
-(IBAction)taskDetailsEdit:(id)sender;

@end
