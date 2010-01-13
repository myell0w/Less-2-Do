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

typedef enum {
	DateTypeYoungest = 0,
	DateTypeOldest = 1
} DateType;

@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) NSDate * lastSyncDate;
@property (nonatomic, retain) NSDate * lastLocalModification;

+ (NSDate *) modificationDateOfType:(NSString *)type dateType:(DateType)dateType error:(NSError **)error;
+ (NSDate *) syncDateOfType:(NSString *)type dateType:(DateType)dateType error:(NSError **)error;

@end
