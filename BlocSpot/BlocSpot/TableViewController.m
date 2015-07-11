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
#import "CategoryViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) UIBarButtonItem *categoryButtonItem;
@property (nonatomic, strong) UIPopoverController *buttonPopOverController;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"BlocSpot";

    self.searchBarTable = [[UISearchBar alloc] init];
    self.searchBarTable.delegate = self;

    self.categoryButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Categories", @"categories button") style:UIBarButtonItemStylePlain target:self action:@selector(categoryButtonDidPress:)];
    
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObject:self.categoryButtonItem];
    
    self.poiArray = [[NSMutableArray alloc] init];
    
    NSDictionary *obj1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"some title", @"title", @"some subtitle", @"detail", nil];
    NSDictionary *obj2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"some title 2", @"title", @"some subtitle 2", @"detail", nil];
    
    [self.poiArray addObject:obj1];
    [self.poiArray addObject:obj2];

    
//     Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
//    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) categoryButtonDidPress:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"categorySegueTable" sender:nil];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.poiArray count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[self.poiArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [[self.poiArray objectAtIndex:indexPath.row] objectForKey:@"detail"];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
