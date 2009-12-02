//
//  ColorChooserCell.m
//  Less2Do
//
//  Created by Philip Messlehner on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColorChooserCell.h"


@implementation ColorChooserCell
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize colorLabel;

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
	[colorLabel release];
    [super dealloc];
}


@end
