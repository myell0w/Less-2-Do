//
//  UICheckBox.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UICheckBox : UIControl {
	UIImage *offImage;
	UIImage *onImage;
}

@property (nonatomic, retain) UIImage *offImage;
@property (nonatomic, retain) UIImage *onImage;

- (id)initWithFrame:(CGRect)frame andOffImage:(NSString *)offImageName andOnImage:(NSString *)onImageName;
- (id)initWithFrame:(CGRect)frame andOffImage:(NSString *)offImageName andOnImage:(NSString *)onImageName andState:(BOOL)state;

-(IBAction)changeSelection;

@end
