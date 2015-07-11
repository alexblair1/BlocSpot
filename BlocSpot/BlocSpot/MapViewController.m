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

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarMap;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIBarButtonItem *categoryButton;
@property (nonatomic, strong) NSString *storedItemNames;

@property (nonatomic, strong) MKPlacemark *placemark;


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

//annotation view

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //custom annotation view
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:self.pointAnnotation reuseIdentifier:@"detailViewController"];
    customPinView.pinColor = MKPinAnnotationColorPurple;
    customPinView.animatesDrop = YES;
    customPinView.canShowCallout = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(detailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    customPinView.rightCalloutAccessoryView = rightButton;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [leftButton addTarget:self action:@selector(leftButtonAnnotationPressed:) forControlEvents:UIControlEventTouchUpInside];
    customPinView.leftCalloutAccessoryView = leftButton;
    
    return customPinView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBarMap = [[UISearchBar alloc] init];
    self.searchBarMap.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.searchBarMap.delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.categoryButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Categories", @"category button") style:UIBarButtonItemStylePlain target:self action:@selector(categoryButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObject:self.categoryButton];
    
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

#pragma mark - Map Search

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarMap resignFirstResponder];
    
    [[DataSource sharedInstance] requestNewItemsWithText:self.searchBarMap.text withRegion:self.mapView.region completion:^{
        for (MKMapItem *items in [DataSource sharedInstance].matchingItems){
            self.pointAnnotation = [[MKPointAnnotation alloc] init];
            self.pointAnnotation.coordinate = items.placemark.coordinate;
            self.pointAnnotation.title = items.name;
            [self.mapView addAnnotation:self.pointAnnotation];
            self.storedItemNames = items.name;
            
            NSLog(@"%@", self.storedItemNames);
        }
    }];
}

#pragma mark - Buttons 

-(void)leftButtonAnnotationPressed:(UIButton *)sender {
    NSString *appendString = self.pointAnnotation.title;
    NSString *urlString = @"http://www.google.com/search?q=";
    NSString *appendedUrlString = [urlString stringByAppendingString:appendString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appendedUrlString]];
    
    NSLog(@"%@", appendedUrlString);
//    NSRange rangeOfString = [appendString rangeOfString:@" "];
    
//    if (rangeOfString.location == NSNotFound) {
//        NSString *searchOneWord = @"http://www.google.com/search?q=";
//        appendString = [searchOneWord stringByAppendingString:searchOneWord];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appendString]];
//    }
    
    
//    if ([appendString containsString:@" "]) {
//        appendString = [appendString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//        NSString *googleSearch = @"http://www.google.com/search?q=";
//        appendString = [googleSearch stringByAppendingString:appendString];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appendString]];
//        
//        NSLog(@"%@", appendString);
//    } else {
//        NSString *searchOneWord = @"http://www.google.com/search?q=";
//        appendString = [searchOneWord stringByAppendingString:appendString];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appendString]];
//    }
}

-(void)detailButtonPressed:(UIButton *)sender{
    [self performSegueWithIdentifier:@"detailViewSegue" sender:nil];
}

- (void)categoryButtonPressed:(UIBarButtonItem *)sender{
    
    [self performSegueWithIdentifier:@"categorySegueMap" sender:nil];
}

- (IBAction)searchButtonDidPress:(id)sender {
    self.navigationItem.titleView = self.searchBarMap;
    
    self.searchBarMap.showsCancelButton = NO;
    
    if (self.searchBarMap.hidden == YES) {
        self.searchBarMap.hidden = NO;
    }
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
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
