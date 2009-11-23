//
//  FolderFirstLevelController.h
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FolderFirstLevelController : UITableViewController <UITableViewDelegate, UITableViewDataSource>  {
	//The Table View to show
	UITableView	*tableView;
	// the Second-Level-Controllers in the first section of Tab "Folder" (includes all Tables)
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Folder" (includes "Any Folder" and "No Folder")
	NSArray *controllersSection1;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *controllersSection0;
@property (nonatomic, retain) NSArray *controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)sectionForIndex:(NSInteger)index;

@end
