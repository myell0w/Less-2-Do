//
//  FolderDAO.h
//  Less2Do
//
//  Created by BlackandCold on 27.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "Less2DoAppDelegate.h"

@interface FolderDAO : NSObject {

}

+(NSArray*)allFolders:(NSError**)error;
+(Folder*)addFolderWithName:(NSString*)theName error:(NSError**)error;
+(Folder*)addFolderWithName:(NSString*)theName theOrder:(NSNumber *)theOrder error:(NSError**)error;
+(Folder*)addFolderWithName:(NSString*)theName theOrder:(NSNumber *)theOrder theTasks:(NSSet *)theTask error:(NSError**)error;
+(BOOL)deleteFolder:(Folder*)folder error:(NSError**)error;
+(BOOL)updateFolder:(Folder*)oldFolder newFolder:(Folder*)newFolder error:(NSError**)error;


@end
