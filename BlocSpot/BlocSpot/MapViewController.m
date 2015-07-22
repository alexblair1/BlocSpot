//
//  MapViewController.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/2/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarMap;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;

@property (nonatomic, strong) NSString *savedPoiName;

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
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"%d",status);
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
}

#pragma mark - Annotation View 

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //custom annotation view
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:self.pointAnnotation reuseIdentifier:@"detailViewController"];
    customPinView.pinColor = MKPinAnnotationColorPurple;
    customPinView.animatesDrop = YES;
    customPinView.canShowCallout = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [rightButton addTarget:self action:@selector(savePoiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    customPinView.rightCalloutAccessoryView = rightButton;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [leftButton addTarget:self action:@selector(leftAnnotationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    customPinView.leftCalloutAccessoryView = leftButton;
    
    return customPinView;
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
            
            NSLog(@"%@", items.name);
        }
    }];
}

#pragma mark - Get Map Info Method

- (void) getAnnotationInfo{
    [DataSource sharedInstance].pointFromMapView = [self.mapView.selectedAnnotations objectAtIndex:([self.mapView.selectedAnnotations count]) -1];
    [DataSource sharedInstance].annotationTitleFromMapView = [DataSource sharedInstance].pointFromMapView.title;
    
    [DataSource sharedInstance].latitude = [DataSource sharedInstance].pointFromMapView.coordinate.latitude;
    [DataSource sharedInstance].longitude = [DataSource sharedInstance].pointFromMapView.coordinate.longitude;
    
    NSLog(@"latitude: %f", [DataSource sharedInstance].latitude);
    NSLog(@"longitude: %f", [DataSource sharedInstance].longitude);
}

#pragma mark - Buttons

-(void)savePoiButtonPressed:(UIButton *)sender{
    [self getAnnotationInfo];
    
    [[DataSource sharedInstance] saveSelectedPoiName:[DataSource sharedInstance].annotationTitleFromMapView withSubtitle:self.searchBarMap.text withY:[DataSource sharedInstance].latitude withX:[DataSource sharedInstance].longitude];
    
    NSLog(@"savedPOI: %@", [DataSource sharedInstance].annotationTitleFromMapView);
    
    NSLog(@"latitude: %f", [DataSource sharedInstance].latitude);
    NSLog(@"longitude: %f", [DataSource sharedInstance].longitude);
    
}

- (void) leftAnnotationButtonPressed:(UIButton *)sender {
    [self getAnnotationInfo];
    
    NSString *googleString = @"http://www.google.com/search?q=";
    NSString *appendedUrlString = [googleString stringByAppendingString:[DataSource sharedInstance].annotationTitleFromMapView];
    
    if ([appendedUrlString containsString:@" "]) {
        appendedUrlString = [appendedUrlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    } else {
        appendedUrlString = appendedUrlString;
    }
    
    NSURL *url = [NSURL URLWithString:appendedUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [DataSource sharedInstance].searchURL = request;
    NSLog(@"appended string: %@", request);
    NSLog(@"saved poi name: %@", appendedUrlString);
    
    self.savedPoiName = appendedUrlString;
    NSLog(@"saved poi name: %@", appendedUrlString);
    
    [self performSegueWithIdentifier:@"googleSearch" sender:nil];

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
