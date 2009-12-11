//
//  FolderCell.m
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderCell.h"


@implementation FolderCell
@synthesize imageView = _imageView;
@synthesize title = _title;
@synthesize detail = _detail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallWhiteBoarderedButton.png"]];
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
