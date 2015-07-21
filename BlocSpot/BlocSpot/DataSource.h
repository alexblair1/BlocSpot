//
//  DataSource.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface DataSource : NSObject 

+(instancetype) sharedInstance;

@property (nonatomic, strong) NSMutableArray *mapItems;
@property (nonatomic, strong) NSArray *matchingItems;
@property (nonatomic, strong) MKLocalSearchRequest *searchRequest;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;
//stored properties
@property (nonatomic, strong) NSURLRequest *searchURL;
@property (nonatomic, strong) MKPointAnnotation *pointFromMapView;
@property (nonatomic, strong) NSString *annotationTitleFromMapView;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
//core data
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *searchHistory;
@property (nonatomic, strong) NSArray *poiResults;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, assign) BOOL favoritesSortedByCategory;
@property (nonatomic, strong) NSArray *sortedResults;
@property (nonatomic, strong) NSMutableArray *lastFavoriteLocalNotifications;


-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;
-(void) saveSelectedPoiName:(NSString *)name withY:(float)yCoordinate withX:(float)xCoordinate;
@end
