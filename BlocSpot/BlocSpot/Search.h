//
//  Search.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/3/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Search;

@protocol SearchDelegate <NSObject>

-(void) didCompleteSearch:(Search *)sender;

@end

@interface Search : NSObject

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) NSMutableArray *poiResults;
@property (nonatomic) MKCoordinateRegion boundingRegion;

@property (nonatomic, strong) id<SearchDelegate> delegate;

-(void)executeSearch:(NSString *)searchString withMapView:(MKMapView *)mapView;

@end
