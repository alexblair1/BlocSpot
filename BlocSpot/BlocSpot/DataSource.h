//
//  DataSource.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DataSource : NSObject <NSCoding>

+(instancetype) sharedInstance;

@property (nonatomic, strong) NSMutableArray *mapItems;
@property (nonatomic, strong) NSArray *matchingItems;
@property (nonatomic, strong) MKLocalSearchRequest *searchRequest;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;



@property (nonatomic, strong) NSMutableArray *searchHistory;
@property (nonatomic, strong) NSArray *poiResults;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, assign) BOOL favoritesSortedByCategory;
@property (nonatomic, strong) NSArray *sortedResults;
@property (nonatomic, strong) NSMutableArray *lastFavoriteLocalNotifications;

-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;

@end
