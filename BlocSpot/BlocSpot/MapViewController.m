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
@property (nonatomic, strong) CLRegion *region;
@property (nonatomic) CLLocationCoordinate2D savedCoordinatesForGeoDistanceCalc;
@property (nonatomic) CLLocationDistance regionRadius;

@property (nonatomic, strong) NSString *savedPoiName;
@property (nonatomic, strong) POI *poi;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[DataSource sharedInstance]fetchRequest];
    
    //register for notifications
    UIUserNotificationType types = UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    self.searchBarMap = [[UISearchBar alloc] init];
    self.searchBarMap.delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:NO];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"%d",status);
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            self.locationManager.distanceFilter = 1;
            [self.locationManager startUpdatingLocation];
            
            for (POI *items in [DataSource sharedInstance].fetchResultItems){
                
                NSString * poiName = items.name;
                float poiLatitude = [items.yCoordinate floatValue];
                float poiLongitude = [items.xCoordinate floatValue];
                self.savedCoordinatesForGeoDistanceCalc = CLLocationCoordinate2DMake(poiLatitude, poiLatitude);
                
                NSString *identifier = poiName;
                CLLocationDegrees latitude = poiLatitude;
                CLLocationDegrees longitude = poiLongitude;
                CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
                self.regionRadius = 10;
                
                self.region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:100 identifier:identifier];
                NSLog(@"region: %@", self.region);
                [self.locationManager startMonitoringForRegion:self.region];
            
        }
    }
}

    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
}

#pragma mark - Geofencing

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    NSLog(@"entered region!!");
    CLLocation *lastLocation = [manager location];
    NSTimeInterval locationAge = -[lastLocation.timestamp timeIntervalSinceNow];
    
    if (lastLocation != nil && locationAge <max) {
        <#statements#>
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    if (localNotification) {
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        localNotification.alertBody = [NSString stringWithFormat:@"You are near %@", self.region.identifier];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    
}

- (CLRegion*)createGeofenceRegion{
    
    for (POI *items in [DataSource sharedInstance].fetchResultItems){
    
    NSString * poiName = items.name;
    float poiLatitude = [items.yCoordinate floatValue];
    float poiLongitude = [items.xCoordinate floatValue];
    self.savedCoordinatesForGeoDistanceCalc = CLLocationCoordinate2DMake(poiLatitude, poiLatitude);
        
    NSString *identifier = poiName;
    CLLocationDegrees latitude = poiLatitude;
    CLLocationDegrees longitude = poiLongitude;
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.regionRadius = 10;
    
    if(self.regionRadius > self.locationManager.maximumRegionMonitoringDistance)
    {
        self.regionRadius = self.locationManager.maximumRegionMonitoringDistance;
    }

    self.region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:10 identifier:identifier];
        NSLog(@"region: %@", self.region);
    }
    return self.region;
}

- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
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
    
    [self.mapView removeAnnotation:[self.mapView.annotations lastObject]];
    
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
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = [NSString stringWithFormat:@"You just saved %@ to your POI's", [DataSource sharedInstance].annotationTitleFromMapView];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
    
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

//-(void)registerRegionWithCircularOverlay:(MKCircle *)overlay andIdentifier:(NSString *)identifier{
//    CLLocationDistance radius = overlay.radius;
//    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
//        radius = self.locationManager.maximumRegionMonitoringDistance;
//    }
//    
//    //create the geographic region to be monitored.
//    CLCircularRegion *geoRegion = [[CLCircularRegion alloc] initWithCenter:overlay.coordinate radius:radius identifier:identifier];
//    [self.locationManager startMonitoringForRegion:geoRegion];
//}

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
