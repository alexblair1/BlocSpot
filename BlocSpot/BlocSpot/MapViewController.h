//
//  MapViewController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DataSource.h"
#import "AppDelegate.h"
#import "TableViewController.h"
#import "GoogleSearchController.h"



@interface MapViewController : UIViewController <UIWebViewDelegate, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *poiArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButtonMap;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)searchButtonDidPress:(id)sender;

@end
