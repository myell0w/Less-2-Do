//
//  ColorChooserCell.h
//  Less2Do
//
//  Created by Philip Messlehner on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomCell.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Cell for Color of a Folder
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ColorChooserCell : CustomCell {
	NSNumber *red;
	NSNumber *green;
	NSNumber *blue;
	UILabel *colorLabel;
}

@property (nonatomic, retain) NSNumber *red;
@property (nonatomic, retain) NSNumber *green;
@property (nonatomic, retain) NSNumber *blue;
@property (nonatomic, retain) IBOutlet UILabel *colorLabel;

@end
