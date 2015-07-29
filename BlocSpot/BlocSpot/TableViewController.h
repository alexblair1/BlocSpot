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

@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) NSMutableArray *tableSectionsAndItems;

@end
