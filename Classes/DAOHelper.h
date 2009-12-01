//
//  DaoHelper.h
//  Less2Do
//
//  Created by Matthias Tretter on 01.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAOHelper : NSObject {

}

+ (NSManagedObject *)objectOfType:(NSString *)type;

@end
