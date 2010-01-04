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

@property (nonatomic, retain) NSDate * lastSyncDate;
@property (nonatomic, retain) NSDate * lastLocalModification;

@end
