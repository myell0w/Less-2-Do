//
//  TagsFirstLevelController.h
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsFirstLevelController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	// Array which holds the different Tags
	NSMutableArray	*list;
	// the Second-Level-Controllers in the first section of Tab "Tags" (includes "untagged")
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Tags"
	NSMutableArray *controllersSection1;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSArray *controllersSection0;
@property (nonatomic, retain) NSMutableArray *controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *) sectionForIndex:(NSInteger)index;
- (IBAction) toggleEdit:(id)sender;
- (IBAction) toggleAdd:(id)sender;

@end
