//
//  TagsFirstLevelController.h
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsFirstLevelController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	//The Table View to show
	TableView		*tableView;
}

@property (nonatomic, retain) IBOutlet TableView *tableView;

@end
