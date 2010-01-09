//
//  BaseRemoteObject.h
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseRemoteObject : BaseManagedObject {

}

@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) NSDate * lastSyncDate;
@property (nonatomic, retain) NSDate * lastLocalModification;

+ (NSDate *) oldestModificationDateOfType:(NSString *)type error:(NSError **)error;
+ (NSDate *) oldestSyncDateOfType:(NSString *)type error:(NSError **)error;

@end
