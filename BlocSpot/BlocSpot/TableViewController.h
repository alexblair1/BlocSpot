//
//  TableViewController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *poiArray;
@property (nonatomic, strong) UISearchBar *searchBarTable;
- (IBAction)searchButtonTable:(id)sender;

@end
