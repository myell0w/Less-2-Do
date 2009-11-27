//
//  TaskEditDueDateViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 27.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditDueDateViewController : UIViewController {
	UIDatePicker *datePicker;
	UILabel *dateLabel;
	
	NSDate *dueDate;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) NSDate *dueDate;

-(IBAction)selectionChanged:(id)sender;

-(IBAction)setToday;
-(IBAction)setTomorrow;
-(IBAction)setNextWeek;
-(IBAction)setNone;

@end
