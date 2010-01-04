//
//  TaskEditRecurrenceViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 04.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditRecurrenceViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	// the task to edit
	Task *task;
	// Data for the Picker
	NSArray *pickerData;
	// Outlets
	UISegmentedControl *repeatFrom;
	UIPickerView *repeatEvery;
}

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, retain) IBOutlet UISegmentedControl *repeatFrom;
@property (nonatomic, retain) IBOutlet UIPickerView *repeatEvery;

@end
