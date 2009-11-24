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

+(NSArray *)getAllContexts;
+(int)addContextWithName:(NSString*)theName;

@end
