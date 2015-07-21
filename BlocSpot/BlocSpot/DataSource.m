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
#import "POI.h"


@interface DataSource ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DataSource

//initialize stored properties 
-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
//sharedInstance/Singleton
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
//
-(void) saveSelectedPoiName:(NSString *)name withY:(float)yCoordinate withX:(float)xCoordinate{
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
    
    NSError *saveError = nil;
    
    if (![newPoi.managedObjectContext save:&saveError]) {
        NSLog(@"Unable to save managed object");
        NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
}

@end
