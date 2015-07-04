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

@property (nonatomic, strong) NSArray *mapItems;
@property (nonatomic, strong) NSMutableArray *savedMapItems;

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

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.savedMapItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//#pragma mark - Map
//
//-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock{
//    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
//    request.naturalLanguageQuery = text;
//    request.region = region;
//    MKLocalSearch *search = [[MKLocalSearch alloc] init];
//    
//    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        self.mapItems = response.mapItems;
//        
//        if (response.mapItems != nil && response.mapItems.count > 0) {
//            completionBlock();
//        }
//    }];
//}

@end
