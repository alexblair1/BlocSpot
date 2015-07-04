//
//  DataSource.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;


@property (nonatomic, strong) NSMutableArray *searchHistory;
@property (nonatomic, strong) NSArray *poiResults;
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, assign) BOOL favoritesSortedByCategory;
@property (nonatomic, strong) NSArray *sortedResults;
@property (nonatomic, strong) NSMutableArray *lastFavoriteLocalNotifications;

//-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;

@end
