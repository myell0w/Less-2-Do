//
//  TagDAO.h
//  Less2Do
//
//  Created by Blackandcold on 24.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Less2DoAppDelegate.h"
#import "Tag.h"

@interface TagDAO : NSObject 
{
	
}

+(NSArray*)allTags:(NSError**)error;
+(Tag*)addTagWithName:(NSString*)theName error:(NSError**)error;
+(BOOL)deleteTag:(Tag*)tag error:(NSError**)error;
+(BOOL)updateTag:(Tag*)tag error:(NSError**)error;

@end