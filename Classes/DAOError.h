//
//  DAOError.h
//  Less2Do
//
//  Created by Gerhard Schraml on 26.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// This constant defines the GtdApi error domain.
extern NSString *const DAOErrorDomain;
// NSString *const DAOErrorDomain = @"com.ASE_06.Less2Do.DAOErrorDomain";
@protocol DAOError

typedef enum {
	DAOMissingParametersError = 1,
	DAONotFetchedError = 10,
	DAONotAddedError   = 11,
	DAONotDeletedError = 12,
	DAONotEditedError  = 13
	/* ... and so on ... */
} L2DError;

@end
