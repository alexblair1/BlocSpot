//
//  MapViewController.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "MapViewController.h"
#import "Search.h"
#import "TableViewController.h"
#import <CoreLocation/CoreLocation.h>


#define METERS_PER_MILE 1609.344

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarMap;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) MKAnnotationView *annotationView;
@property (nonatomic, strong) MKLocalSearchRequest *searchReguest;
@property (nonatomic, strong) MKLocalSearch *search;
@property (nonatomic, strong) MKLocalSearchResponse *searchResponse;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;
@property (nonatomic, strong) MKPinAnnotationView *pinAnnotationView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBarMap = [[UISearchBar alloc] init];
    self.searchBarMap.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.searchBarMap.delegate = self;
    self.mapView.delegate = self;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"%d",status);
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
            self.mapView.showsUserLocation = YES;
        }
    }
}

- (IBAction)searchButtonDidPress:(id)sender {
    self.navigationItem.titleView = self.searchBarMap;
    
    self.searchBarMap.showsCancelButton = NO;
    
    if (self.searchBarMap.hidden == YES) {
        self.searchBarMap.hidden = NO;
    }
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarMap resignFirstResponder];
    
    Search *search =[[Search alloc] init];
    searchBar = self.searchBarMap;
    [search executeSearch:searchBar.text withMapView:self.mapView];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{\
    self.searchBarMap.showsCancelButton = YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarMap resignFirstResponder];
    self.searchBarMap.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
