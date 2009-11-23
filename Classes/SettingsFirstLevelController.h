//
//  SettingsFirstLevelController.h
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsFirstLevelController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	//The Table View to show
	UITableView	*tableView;
	// the Second-Level-Controllers in the first section of Tab "Settings"
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Settings"
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
