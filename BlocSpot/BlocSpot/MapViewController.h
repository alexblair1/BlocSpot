//
//  MapViewController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataSource.h"
#import "DetailViewController.h"


@interface MapViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *poiArray;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButtonMap;

- (IBAction)searchButtonDidPress:(id)sender;

@end
