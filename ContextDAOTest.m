//
//  ContextDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHUnit.h"
#import "ContextDAO.h"
#import "Context.h"
#import "DAOError.h"

@interface ContextDAOTest : GHTestCase {
	
}

- (void)testAddContextWithNameWithoutTitle;

@end

@implementation ContextDAOTest

- (void)setUp {
	/* whatever has to be set up */
}

- (void)tearDown {
	/* whatever has to be teared down */
	/* e.g. releasing set up objects and set them to nil */
}

// Tests adding a folder without a folder parameter
- (void)testAddContextWithNameWithoutTitle {
	/*NSError *error = nil;
	Context *returnValue = [ContextDAO addContextWithName:nil error:&error];
	GHAssertTrue([error code] == DAOMissingParametersError, @"Context must not be added without name");
	GHAssertTrue(returnValue == nil, @"Return value must be nil.");*/
}

@end