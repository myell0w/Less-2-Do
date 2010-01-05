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

+(void)sync:(NSError**)error;
+(void)syncForceLocal:(NSError**)error;
+(void)syncForceRemote:(NSError**)error;
@end
