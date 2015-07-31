//
//  DataSource.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "DataSource.h"
#import "MapViewController.h"
#import "TableViewController.h"



@interface DataSource ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Map
//when functional... refactor and pass in a completion block for error handling
-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock{
    
    self.searchRequest = [[MKLocalSearchRequest alloc] init];
    self.searchRequest.naturalLanguageQuery = text;
    self.searchRequest.region = region;
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.searchRequest];
    
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        if (response.mapItems.count == 0) {
            NSLog(@"no matches found");
        }else{
            self.matchingItems = response.mapItems;
            NSLog(@"self.matchingItems: %@",self.matchingItems);
            if (completionBlock) {
                completionBlock();
                
            }
        }
    }];
}

#pragma mark - General Fetch Request

-(void)fetchRequest{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"POI"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES]]];
     self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"subtitle" cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    self.fetchResultItems = [self.fetchedResultsController fetchedObjects];
    NSLog(@"items: %@", self.fetchResultItems);

}

#pragma mark - Persist Data Methods 

-(void) saveSelectedPoiName:(NSString *)name withSubtitle:(NSString *)subtitle withY:(float)yCoordinate withX:(float)xCoordinate{
    self.pointFromMapView = [[MKPointAnnotation alloc] init];
    self.annotationTitleFromMapView = [[NSString alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    self.annotationTitleFromMapView = name;
    self.latitude = yCoordinate;
    self.longitude = xCoordinate;
    
    NSEntityDescription *entityPOI = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:context];
    NSManagedObject *newPoi = [[NSManagedObject alloc] initWithEntity:entityPOI insertIntoManagedObjectContext:context];
    //create new POI record
    [newPoi setValue:name forKey:@"name"];
    [newPoi setValue:[NSNumber numberWithFloat:yCoordinate] forKey:@"yCoordinate"];
    [newPoi setValue:[NSNumber numberWithFloat:xCoordinate] forKey:@"xCoordinate"];
    [newPoi setValue:subtitle forKey:@"subtitle"];
    
    NSError *saveError = nil;
    
    if (![newPoi.managedObjectContext save:&saveError]) {
        NSLog(@"Unable to save managed object");
        NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
}

-(void) saveCategoryInfo:(NSString *)name withColors:(float)redColor withBlue:(float)blueColor withGreen:(float)greenColor{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityCategory = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:context];
    NSManagedObject *newCategory = [[NSManagedObject alloc] initWithEntity:entityCategory insertIntoManagedObjectContext:context];
    
    NSString *nameString = [[NSString alloc] init];
    nameString = name;
    
    self.randomRedColor = redColor;
    self.randomBlueColor = blueColor;
    self.randomGreenColor = greenColor;
    
    [newCategory setValue:name forKey:@"name"];
    [newCategory setValue:[NSNumber numberWithFloat:redColor] forKey:@"red"];
    [newCategory setValue:[NSNumber numberWithFloat:blueColor] forKey:@"blue"];
    [newCategory setValue:[NSNumber numberWithFloat:greenColor] forKey:@"green"];
    
    
    NSError *error = nil;
    
    if (![newCategory.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

@end
