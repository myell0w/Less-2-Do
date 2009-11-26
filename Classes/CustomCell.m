//
//  CustomCell.m
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

+(id)loadFromNib:(NSString *)nib withOwner:(id)owner {
	NSArray* nibArr = [[NSBundle mainBundle] loadNibNamed:nib owner:owner options:nil];
	
	for (id obj in nibArr) {
		if ([obj isKindOfClass:[CustomCell class]])
			return (CustomCell *)obj;
	}
	
	return nil;
}



@end
