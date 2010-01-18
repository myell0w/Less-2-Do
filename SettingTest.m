//
//  SettingTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import "Setting.h"
#import "CustomGHUnitAppDelegate.h";

@interface SettingTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation SettingTest

- (void)setUp {
	
	/* delete all contexts from the persistent store */
	CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 managedObjectContext = [delegate managedObjectContext];
	 
	 NSFetchRequest *request = [[NSFetchRequest alloc] init];
	 [request setEntity:[NSEntityDescription entityForName:@"Setting" inManagedObjectContext:managedObjectContext]];
	 
	 NSError *error;
	 NSArray *allContexts = [managedObjectContext executeFetchRequest:request error:&error];
	 [request release];
	 for (NSManagedObject* context in allContexts)
	 {
	 [managedObjectContext deleteObject:context];
	 }
	 if([managedObjectContext save:&error] == NO)
	 GHFail(@"Error at setUp");
}

- (void)tearDown {
	/* do nothing */
	ALog(@"got here");
}

- (void) testGetSettingsWithoutSettings
{
	NSError *error = nil;
	Setting *setting = [Setting getSettings:&error];
	GHAssertNil(setting, @"variable setting should be nil");
	GHAssertEquals([error code], SettingNotFound, @"error should be SettingNotFound");
}

-(void) testGetSettings
{
	NSError *error = nil;
	Setting *newSetting = (Setting*)[Setting objectOfType:@"Setting"];
	newSetting.tdEmail = @"g.schraml@gmx.at";
	newSetting.useTDSync = [NSNumber numberWithBool:YES];
	[Setting commit];
	Setting *setting = [Setting getSettings:&error];
	GHAssertNotNil(setting, @"setting should arrive here");
}


@end
