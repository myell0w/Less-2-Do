//
//  TaskPriorityCell.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"


@interface TaskPriorityCell : CustomCell {
	UISegmentedControl *priority;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *priority;

@end
