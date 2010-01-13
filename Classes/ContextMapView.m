//
//  ContextMapView.m
//  Less2Do
//
//  Created by Philip Messlehner on 13.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextMapView.h"
#import "MapViewControllerProtocol.h"

@implementation ContextMapView
@synthesize viewTouched;

//The basic idea here is to intercept the view which is sent back as the firstresponder in hitTest.
//We keep it preciously in the property viewTouched and we return our view as the firstresponder.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"Hit Test");
    viewTouched = [super hitTest:point withEvent:event];
    return self;
}

//Then, when an event is fired, we log this one and then send it back to the viewTouched we kept, and voilà!!! :)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.delegate conformsToProtocol:@protocol(MapViewControllerProtocol)]) {
		id<MapViewControllerProtocol> p = (id<MapViewControllerProtocol>)self.delegate;
		[p resignActualFirstResponder];
	}
    [viewTouched touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Moved");
    [viewTouched touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Ended");
    [viewTouched touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Cancelled");
}

@end