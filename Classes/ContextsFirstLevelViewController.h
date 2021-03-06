//
//  ContextsFirstLevelViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Context.h"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table View Controller for first Level of Tab "Contexts"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ContextsFirstLevelViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	// Array which holds the different Contexts
	NSMutableArray *list;
	// the Second-Level-Controllers in the first section of Tab "Home"
	NSArray *controllersSection0;
	// the Second-Level-Controllers in the second section of Tab "Home" 
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
