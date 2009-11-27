//
//  ContextDAO.h
//  Less2Do
//
//  Created by Gerhard Schraml on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Less2DoAppDelegate.h"

@interface ContextDAO : NSObject {
	
}

+(NSArray*)allContexts:(NSError**)error;
+(Context*)addContextWithName:(NSString*)theName error:(NSError**)error;
+(BOOL)deleteContext:(Context*)context error:(NSError**)error;
+(BOOL)updateContext:(Context*)oldContext newContext:(Context*)newContext error:(NSError**)error;

@end