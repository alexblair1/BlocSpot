//
//  TableViewController.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "TableViewController.h"
#import "MapViewController.h"
#import "DataSource.h"
#import "POI.h"
#import "TableViewCell.h"
#import "POI+CoreData.h"

@interface TableViewController ()

@property (nonatomic, strong) POI *poi;
@property (nonatomic, strong) NSMutableArray *filteredList;
@property (nonatomic, strong) NSArray *fetchedResults;

@end

@implementation TableViewController

@synthesize searchResults;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performFetch];
    [self initializeSearchController];
    [self styleTableView];
    [self initializeTableContent];
    [self.tableView reloadData];
    
}

-(void)performFetch{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"POI"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES]]];
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"subtitle" cacheName:nil];
    [self.fetchController setDelegate:self];
    
    NSError *fetchError = nil;
    [self.fetchController performFetch:&fetchError];
    
    if (fetchError) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
    
    NSLog(@"performed fetch!");
}

#pragma mark - Initialization Methods for Filter Table View

- (void)initializeTableContent {
    
    //sections are defined here as a NSArray of string objects (i.e. letters representing each section)
    self.tableSections = [[POI fetchDistinctItemGroupsInManagedObjectContext:self.context] mutableCopy];
    
    //sections and items are defined here as a NSArray of NSDictionaries whereby the key is a letter and the value is a NSArray of string opbjects of names
    self.tableSectionsAndItems = [[POI fetchItemNamesByGroupInManagedObjectContext:self.context] mutableCopy];
}

-(void)initializeSearchController{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    //add the uisearch controllers search bar to the header of this table
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

-(void)styleTableView{
    [[self tableView] setSectionIndexColor:[UIColor yellowColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor lightGrayColor]];
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //get search text from user input
    NSString *searchText = [self.searchController.searchBar text];
    
    //exit if there is no search text (i.e. user tapped on the search bar and did not enter text yet)
    if([searchText length] > 0) {
        if(searchText.length > 0) {
            
            NSDictionary *namesByGroup = [POI fetchItemNamesByGroupFilteredBySearchText:searchText inManagedObjectContext:self.context];
            NSLog(@"namesByGroup: %@", namesByGroup);
            self.tableSectionsAndItems = [[[NSArray alloc] initWithObjects:namesByGroup, nil] mutableCopy];
            NSArray *allKeys = [namesByGroup allKeys];
            self.filteredList = [[NSMutableArray alloc]init];
            for (NSString *key in allKeys) {
                // TODO: these should be POI objects, not just a string
                [self.filteredList addObjectsFromArray:namesByGroup[key]];
            }
            NSLog(@"table sections and items: %@", self.tableSectionsAndItems);
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchController.active = NO;
    
    [self.tableSections removeAllObjects];
    
    [self.tableSectionsAndItems removeAllObjects];
    
    self.tableSections = [[POI fetchDistinctItemGroupsInManagedObjectContext:self.context] mutableCopy];
    
    self.tableSectionsAndItems = [[POI fetchItemNamesByGroupInManagedObjectContext:self.context] mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.searchController.active) {
        return 1;
    } else {
        return [[self.fetchController sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return [self.filteredList count];
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        return  [sectionInfo numberOfObjects];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil) {
        
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (!self.searchController.active) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        return  [sectionInfo name];
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.searchController.active) {
        return [self.fetchController sectionIndexTitles];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (!self.searchController.active) {
        return [self.fetchController sectionForSectionIndexTitle:title atIndex:index];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
}

- (void)configureCell:(TableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (!self.searchController.active) {
        //fetch record
        NSManagedObject *record = [self.fetchController objectAtIndexPath:indexPath];
        [cell.textLabel setText:[record valueForKey:@"name"]];
        [cell.detailTextLabel setText:[record valueForKey:@"subtitle"]];
    } else {
        NSManagedObject *filterRecord = [self.filteredList objectAtIndex:indexPath.row];
        [cell.textLabel setText:[filterRecord valueForKey:@"name"]];
        NSLog(@"filtered name: %@", [filterRecord valueForKey:@"name"]);
        //TODO: this is not a POI, it's just a string (see POI+CoreData)
        [cell.detailTextLabel setText:[filterRecord valueForKey:@"subtitle"]];
        NSLog(@"filtered subtitle: %@", [filterRecord valueForKey:@"subtitle"]);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.searchController.active) {
        self.poi = [self.fetchController objectAtIndexPath: indexPath];
        
        float y = [self.poi.yCoordinate floatValue];
        float x = [self.poi.xCoordinate floatValue];
        
        CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(y, x);
        MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
        MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
        endingItem.name = self.poi.name;
        
        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
        [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
        
        [endingItem openInMapsWithLaunchOptions:launchOptions];
    } else {
        //TODO: this is not a POI, it's just a string
        self.poi = self.filteredList[indexPath.row];
        
        float y = [self.poi.yCoordinate floatValue];
        float x = [self.poi.xCoordinate floatValue];
        
        CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(y, x);
        MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
        MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
        endingItem.name = self.poi.name;
        
        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
        [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
        
        [endingItem openInMapsWithLaunchOptions:launchOptions];
    }
    
}

#pragma mark - Tableview editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchController objectAtIndexPath:indexPath];
        
        if (record) {
            [self.context deleteObject:record];
        }
    }
    
    NSError *error = nil;
    
    if (![self.context save:&error]) {
        if (error) {
            NSLog(@"Unable to save changes.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//
//    if ([segue.identifier isEqualToString:@"cellMapSegue"]) {
//
////      get reference to the destination view controller
//
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        self.poi = [self.fetchController objectAtIndexPath:indexPath];
//
//        float y = [self.poi.yCoordinate floatValue];
//        float x = [self.poi.xCoordinate floatValue];
//
//        CLLocationCoordinate2D addPoint;
//        addPoint.latitude = y;
//        addPoint.longitude = x;
//        NSLog(@"coordiante y: %f x:%f name: %@", addPoint.latitude, addPoint.longitude, self.poi.name);
//
//        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
//        [pointAnnotation setCoordinate:addPoint];
//        [pointAnnotation setTitle:self.poi.name];
//
//        MapViewController *mapVC = [segue destinationViewController];
//        [mapVC view];
//        [mapVC.mapView addAnnotation:pointAnnotation];
//
//    }
//}

@end
