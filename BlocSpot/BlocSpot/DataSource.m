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

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.matchingItems forKey:NSStringFromSelector(@selector(matchingItems))];
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    if (self) {
        self.matchingItems = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(matchingItems))];
    }
    return self;
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
                
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFileName:NSStringFromSelector(@selector(matchingItems))];
                NSArray *storedMapItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMapItems.count > 0) {
                        NSMutableArray *mutableMapItems = [storedMapItems mutableCopy];
                        
                        [self willChangeValueForKey:@"matchingItems"];
                        self.matchingItems = mutableMapItems;
                        [self didChangeValueForKey:@"matchingItems"];
                        
                        for (MKMapItem *mapItem in self.matchingItems){
//                            [self downloadMapItemForMatchingItems]
                        }
                    }
                });
            });
            }
        }
    }];
}

//download mapItem

-(void) downloadMapItemForMatchingItems:(MKMapItem *) mapItem{
    if (self.matchingItems) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
        });
    }
}

#pragma mark - NSCoding 

- (NSString *) pathForFileName:(NSString *) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return dataPath;
}

- (void) savedPOI {
    if (self.matchingItems.count > 0) {
        //write changes to disk
        
    }
}

@end
