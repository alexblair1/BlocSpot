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

@interface TableViewController ()


@property (nonatomic, strong) UIPopoverController *buttonPopOverController;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) POI *poi;

@property BOOL isFiltered;

@end

@implementation TableViewController

#define SectionHeaderHeight 40

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"BlocSpot";

    self.searchBarTable = [[UISearchBar alloc] init];
    self.searchBarTable.placeholder = NSLocalizedString(@"Search", @"search bar place holder");
    self.searchBarTable.delegate = self;
    
    //fetch request core data
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
    
//     Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
//    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Fetched Results Controller Delegate Protocol

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
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
        }
        case NSFetchedResultsChangeMove:{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Buttons

-(void) categoryButtonDidPress:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"categoryButtonSegue" sender:nil];
}

- (IBAction)searchButtonPressed:(id)sender {
    self.navigationItem.titleView = self.searchBarTable;
    
    self.searchBarTable.showsCancelButton = NO;
    
    if (self.searchBarTable.hidden == YES) {
        self.searchBarTable.hidden = NO;
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarTable resignFirstResponder];
    self.searchBarTable.hidden = YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchBarTable.showsCancelButton = YES;
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
    } else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //configure table view cell
//    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    editButton.frame = CGRectMake(250.0f, 5.0f, 75.0f, 69.0f);
//    [editButton setTitle:NSLocalizedString(@"Edit", @"Edit button to add category") forState:UIControlStateNormal];
//    [cell addSubview:editButton];
//    [editButton addTarget:self action:@selector(categoryButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - TableViewCell Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"cellMapSegue"]) {
        
        //get reference to the destination view controller
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.poi = [self.fetchController objectAtIndexPath:indexPath];
        
        float y = [self.poi.yCoordinate floatValue];
        float x = [self.poi.xCoordinate floatValue];
        
        CLLocationCoordinate2D addPoint;
        addPoint.latitude = y;
        addPoint.longitude = x;
        NSLog(@"coordiante y: %f x:%f name: %@", addPoint.latitude, addPoint.longitude, self.poi.name);
        
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        [pointAnnotation setCoordinate:addPoint];
        [pointAnnotation setTitle:self.poi.name];
        
        MapViewController *mapVC = [segue destinationViewController];
        [mapVC view];
        [mapVC.mapView addAnnotation:pointAnnotation];
        
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

@end
