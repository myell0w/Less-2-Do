//
//  TaskTitleCell.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom TableViewCell - Title Cell of Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface TaskTitleCell : CustomCell {
	UIImageView *imageCompleted;
	// the titel of the task
	UILabel *title;
	UIImageView *imageStarred;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageCompleted;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UIImageView *imageStarred;

@end
