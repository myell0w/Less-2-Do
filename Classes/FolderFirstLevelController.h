//
//  FolderFirstLevelController.h
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table View Controller for first Level of Tab "Folders"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FolderFirstLevelController : UITableViewController <UITableViewDelegate, UITableViewDataSource>  {
	//The Table View to show
	NSMutableArray	*list;
	// the Second-Level-Controllers in the first section of Tab "Folder" (includes "Any Folder" and "No Folder")
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Folder" 
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

-(NSArray *)sectionForIndex:(NSInteger)index;
- (IBAction) toggleEdit:(id)sender;
- (IBAction) toggleAdd:(id)sender;

@end
