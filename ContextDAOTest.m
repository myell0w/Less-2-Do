//
//  ContextDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHUnit.h"

@interface ContextDAOTest : GHTestCase

- (void)testAddContext;

@end

@implementation ContextDAOTest

-(void)testAddContext {	
	int value1 = 2;
	int value2 = 1; //change this value to see what happens when the 
	GHAssertTrue(value1 == value2, @"Value1 != Value2. Expected %i, got %i", value1, value2);
}

@end
