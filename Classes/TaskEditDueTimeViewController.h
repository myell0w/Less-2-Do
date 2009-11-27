//
//  TaskEditDueTimeViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 27.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditDueTimeViewController : UIViewController {
	UIDatePicker *datePicker;
	UILabel *dateLabel;
	
	NSDate *dueTime;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) NSDate *dueTime;

-(IBAction)selectionChanged:(id)sender;

-(IBAction)setNow;
-(IBAction)setOneHourFromNow;
-(IBAction)setTwoHoursFromNow;
-(IBAction)setNone;


@end
