//
//  TagDAOTest.m
//  Less2Do
//
//  Created by Gerhard Schraml on 27.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"
#import "CustomGHUnitAppDelegate.h";

@interface TagTest : GHTestCase {
	NSManagedObjectContext* managedObjectContext;
}

@end

@implementation TagTest

- (void)setUp {
	
	/* delete all tags from the persistent store */
	CustomGHUnitAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	managedObjectContext = [delegate managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext]];
	
	NSError *error;
	NSArray *allTags = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	for (NSManagedObject* tag in allTags)
	{
		[managedObjectContext deleteObject:tag];
	}
	if([managedObjectContext save:&error] == NO)
		GHFail(@"Error at setUp");
}

- (void)tearDown {
	/* do nothing */
}

/* Tests receiving all tags without adding tags before */
- (void)testAllTagsEmpty {
	NSError *error = nil;
	NSArray *tags = [Tag getAllTags:&error];
	GHAssertEquals([tags count], (NSUInteger)0, @"Tag count must be 0");
}

/* adds 3 tags - count must be 3 */
- (void)testAddTag {
	NSError *error = nil;
	
	Tag *newTag1 = (Tag*)[Tag objectOfType:@"Tag"];
	Tag *newTag2 = (Tag*)[Tag objectOfType:@"Tag"];
	Tag *newTag3 = (Tag*)[Tag objectOfType:@"Tag"];
	newTag1.name = @"c1";
	newTag2.name = @"c2";
	newTag3.name = @"c3";
	
	NSArray *tags = [Tag getAllTags:&error];
	GHAssertEquals([tags count], (NSUInteger)3, @"Add tag not successful");
}

/* Tests deleting a tag with nil as parameter */
- (void)testDeleteTagWithNilParameter {
	NSError *error = nil;
	BOOL returnValue = [Tag deleteObjectFromPersistentStore:nil error:&error];
	GHAssertEquals([error code], DAOMissingParametersError, @"Tag must not be deleted without reference");
	GHAssertFalse(returnValue, @"Return value must be NO.");
}

/* first adds a tag and then deletes it - count then must be 0 */
- (void)testDeleteTag {
	NSError *error = nil;
	Tag *newTag = (Tag*)[Tag objectOfType:@"Tag"];
	
	NSArray *tags = [Tag getAllTags:&error];
	GHAssertEquals([tags count], (NSUInteger)1, @"Add tag not successful");
	
	BOOL deleteSuccessful = [Tag deleteObjectFromPersistentStore:newTag error:&error];
	GHAssertTrue(deleteSuccessful, @"Delete tag not successful");
	
	tags = [Tag getAllTags:&error];
	GHAssertEquals([tags count], (NSUInteger)0, @"Delete tag not successful");
}
@end
