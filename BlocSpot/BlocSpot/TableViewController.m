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

@end

@implementation TableViewController

@synthesize searchResults;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"BlocSpot";
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"POI"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES]]];
    //initialize the fetched results controller
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"subtitle" cacheName:nil];
    //configure fetched results controller
    [self.fetchController setDelegate:self];
    //perform fetch
    NSError *fetchError = nil;
    [self.fetchController performFetch:&fetchError];
    
    if (fetchError) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
    
    [self initializeSearchController];
    [self styleTableView];
    [self initializeTableContent];
    
    [self.tableView reloadData];
    
//     Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
//    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Initialization Methods for Filter Table View

- (void)initializeTableContent {
    
    //sections are defined here as a NSArray of string objects (i.e. letters representing each section)
    self.tableSections = [[POI fetchDistinctItemGroupsInManagedObjectContext:self.context] mutableCopy];
    
    //sections and items are defined here as a NSArray of NSDictionaries whereby the key is a letter and the value is a NSArray of string opbjects of names
    self.tableSectionsAndItems = [[POI fetchItemNamesByGroupInManagedObjectContext:self.context] mutableCopy];
}

-(void)initializeSearchController{
    //instantiate a search controller for presenting the serach/filter results. Will be presented on top of the parent table view.
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    //instantiate a UISearchController - passing in the search results controller table
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    //this view controller can be covered by the UISearchController's view (search/filter table)
    self.definesPresentationContext = YES;
    
    //define the frame for the uisearchcontrollers search bar and tint
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    //add the uisearch controllers search bar to the header of this table
    self.tableView.tableHeaderView= self.searchController.searchBar;
    
    //this view controller will be responsible for implementing UISearchResultsDialog protocol methods - it handles what happens when the user types into the search bar
    self.searchController.searchResultsUpdater = self;
    
    //this view controller will also be responsible for implementing UISearchBarDelegate protocal methods
    self.searchController.searchBar.delegate = self;
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
    
        
        //based on the user's search, we will update the contents of the tableSections and tableSectionsAndItems properties
        [self.tableSections removeAllObjects];
        
        [self.tableSectionsAndItems removeAllObjects];
        
        
        NSString *firstSearchCharacter = [searchText substringToIndex:1];
        
        //handle when user taps into search bear and there is no text entered yet
        if([searchText length] == 0) {
            
            self.tableSections = [[POI fetchDistinctItemGroupsInManagedObjectContext:self.context] mutableCopy];
            
            self.tableSectionsAndItems = [[POI fetchItemNamesByGroupInManagedObjectContext:self.context] mutableCopy];
        }
        //handle when user types in one or more characters in the search bar
        else if(searchText.length > 0) {
            NSLog(@"search text: %@", searchText);
            //the table section will always be based off of the first letter of the group
            NSString *upperCaseFirstSearchCharacter = [firstSearchCharacter uppercaseString];
            
            self.tableSections = [[[NSArray alloc] initWithObjects:upperCaseFirstSearchCharacter, nil] mutableCopy];
            NSLog(@"table sections array: %@", self.tableSections);
            //there will only be one section (based on the first letter of the search text) - but the property requires an array for cases when there are multiple sections
            NSDictionary *namesByGroup = [POI fetchItemNamesByGroupFilteredBySearchText:searchText inManagedObjectContext:self.context];
            NSLog(@"namesByGroup: %@", namesByGroup);
            self.tableSectionsAndItems = [[[NSArray alloc] initWithObjects:namesByGroup, nil] mutableCopy];
            NSLog(@"table sections and items: %@", self.tableSectionsAndItems);
        }
        
        //now that the tableSections and tableSectionsAndItems properties are updated, reload the UISearchController's tableview
        [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.tableSections removeAllObjects];
    
    [self.tableSectionsAndItems removeAllObjects];
    
    self.tableSections = [[POI fetchDistinctItemGroupsInManagedObjectContext:self.context] mutableCopy];
    
    self.tableSectionsAndItems = [[POI fetchItemNamesByGroupInManagedObjectContext:self.context] mutableCopy];
}
    
#pragma mark - Fetched Results Controller Delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            [self configureCell:(TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([[self.fetchController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        return  [sectionInfo numberOfObjects];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
//    static NSString *CellReuseId = @"ReuseCell";
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil) {

        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];

    }
    
    //TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return  [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchController sectionForSectionIndexTitle:title atIndex:index];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
}

- (void)configureCell:(TableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //Fetch Record
    NSManagedObject *record = [self.fetchController objectAtIndexPath:indexPath];
    [cell.textLabel setText:[record valueForKey:@"name"]];
    [cell.detailTextLabel setText:[record valueForKey:@"subtitle"]];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.poi = [self.fetchController objectAtIndexPath:indexPath];
    
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
