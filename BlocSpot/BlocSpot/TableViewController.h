//
//  TableViewController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UITableViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *poiArray;
@property (nonatomic, strong) UISearchBar *searchBarTable;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;

- (IBAction)searchButtonPressed:(id)sender;

@end
