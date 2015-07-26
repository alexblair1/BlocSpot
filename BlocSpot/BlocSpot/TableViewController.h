//
//  TableViewController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


@interface TableViewController : UITableViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *poiArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
