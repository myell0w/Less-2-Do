//
//  FolderCell.h
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"


@interface FolderCell : CustomCell {
	// Outlet for ImageView to set the BackgroundColor
	UIImageView *_imageview;
	
	UILabel *_title;
	UILabel *_detail;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *detail;

@end
