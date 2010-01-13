//
//  ContextMapView.h
//  Less2Do
//
//  Created by Philip Messlehner on 13.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContextMapView : MKMapView {
    UIView *viewTouched;
}
@property (nonatomic, retain) UIView * viewTouched;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
