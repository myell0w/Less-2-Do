//
//  SyncManager.h
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDApi.h"
#import "GtdApi.h"
#import "Tag.h"
#import "Less2DoAppDelegate.h"


@interface SyncManager : NSObject {
	TDApi *tdApi;
	BOOL isConnected;
	NSError *syncError;
	NSDate *currentDate;
}

@property(nonatomic,retain) TDApi *tdApi;
@property(nonatomic) BOOL isConnected;
@property(nonatomic,retain) NSError *syncError;
@property(nonatomic,retain) NSDate *currentDate;

typedef enum {
	SyncPreferLocal = 1,
	SyncPreferRemote = 2
} SyncPreference;

/* Public usable functions */
+(BOOL)syncWithPreferenceOld:(SyncPreference)preference error:(NSError**)error; //deprecated
-(BOOL)syncWithPreference:(SyncPreference)preference error:(NSError**)error;
-(BOOL)overwriteLocal:(NSError**)error;
-(BOOL)overwriteRemote:(NSError**)error;

+(NSString *)gtdErrorMessage:(NSInteger)errorCode;

/* Internal functions */
-(BOOL)syncFoldersPreferLocal;
-(BOOL)syncFoldersPreferRemote;
-(BOOL)syncContextsPreferLocal;
-(BOOL)syncContextsPreferRemote;

-(BOOL)deleteAllLocalFolders;
-(BOOL)deleteAllLocalContexts;
-(BOOL)deleteAllLocalTags;
-(BOOL)deleteAllLocalTasks;

-(BOOL)deleteAllRemoteFolders;
-(BOOL)deleteAllRemoteContexts;
-(BOOL)deleteAllRemoteTasks;

-(BOOL)exitFailure:(NSError**)error;

/* helpers */
-(void)stopAutocommit;
-(void)startAutocommit;

@end
