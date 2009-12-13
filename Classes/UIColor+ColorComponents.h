//
//  UIColor+ColorComponents.h
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (ColorComponents)

- (NSNumber *)redColorComponent;
- (NSNumber *)greenColorComponent;
- (NSNumber *)blueColorComponent;
- (NSNumber *) colorComponents;

@end
