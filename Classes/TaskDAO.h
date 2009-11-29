//
//  TastDAO.h
//  Less2Do
//
//  Created by BlackandCold on 29.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "Less2DoAppDelegate.h"


@interface TaskDAO : NSObject 
{

}


+(NSArray*)allTasks:(NSError**)error;
/*
+(Task*)addTask:(Task *)theTask error:(NSError**)error;

+(BOOL)deleteTask:(Task*)theTask error:(NSError**)error;
+(BOOL)updateTask:(Task*)oldTask newTask:(Folder*)newTast error:(NSError**)error;
*/

@end
