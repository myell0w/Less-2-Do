//
//  HomeFirstLevelViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table View Controller for first Level of Tab "Home"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface HomeFirstLevelViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	// the table View to show
	UITableView *tableView;
	// the Second-Level-Controllers in the first section of Tab "Home"
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Home" 
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

// returns the section Array for the given Section-Index
- (NSArray *)sectionForIndex:(NSInteger)index;

- (IBAction)taskAdded;

@end
