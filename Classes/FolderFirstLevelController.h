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
	NSMutableArray	*_list;
	// the Second-Level-Controllers in the first section of Tab "Folder" (includes "Any Folder" and "No Folder")
	NSArray *_controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Folder" 
	NSMutableArray *_controllersSection1;
	// Flag which indicates if the List has to be reorderd
	BOOL _mustReorder;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSArray *controllersSection0;
@property (nonatomic, retain) NSMutableArray *controllersSection1;
@property (nonatomic) BOOL mustReorder;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)sectionForIndex:(NSInteger)index;
- (void) reorderList;
- (IBAction) toggleEdit:(id)sender;
- (IBAction) toggleAdd:(id)sender;

@end
