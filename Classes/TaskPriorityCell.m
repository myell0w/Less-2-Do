//
//  TaskPriorityCell.m
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskPriorityCell.h"


@implementation TaskPriorityCell

@synthesize priority;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
