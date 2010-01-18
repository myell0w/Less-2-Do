//
//  Setting.h
//  Less2Do
//
//  Created by Gerhard Schraml on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface Setting : BaseManagedObject {

}

@property (nonatomic, retain) NSString * tdEmail;
@property (nonatomic, retain) NSNumber * useTDSync;
@property (nonatomic, retain) NSNumber * preferToodleDo;

+(Setting*) getSettings:(NSError **)error;
-(NSString *) getPassword:(NSError **)error;

@end
