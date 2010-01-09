//
//  SyncManager.h
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncManager : NSObject {
}

typedef enum {
	SyncPreferLocal = 1,
	SyncPreferRemote = 2
} SyncPreference;

+(void)syncWithPreference:(SyncPreference)preference error:(NSError**)error;
+(void)overrideLocal:(NSError**)error;
+(void)overrideRemote:(NSError**)error;
@end
