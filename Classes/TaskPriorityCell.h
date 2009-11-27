//
//  TaskPriorityCell.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Cell for Priority of a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface TaskPriorityCell : CustomCell {
	// SegmentedControl for storing the priority
	UISegmentedControl *priority;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) IBOutlet UISegmentedControl *priority;

@end
