// 
//  Context.m
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

#import "Task.h"

@implementation Context 

@dynamic gpsY;
@dynamic contextId;
@dynamic name;
@dynamic gpsX;
@dynamic tasks;

- (NSString *)description {
	return self.name;
}

@end
