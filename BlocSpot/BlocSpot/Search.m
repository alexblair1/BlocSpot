//
//  Search.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/3/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "Search.h"

@implementation Search

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)executeSearch:(NSString *)searchString withMapView:(MKMapView *)mapView{
    if (self.localSearch.searching) {
        [self.localSearch cancel];
    }
    
    MKCoordinateRegion currentRegion;
    currentRegion.center.latitude = self.userLocation.latitude;
    currentRegion.center.latitude = self.userLocation.longitude;
    
    currentRegion.span.latitudeDelta = 0.9;
    currentRegion.span.longitudeDelta = 0.9;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = currentRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error){
        if (error != nil) {
            NSString *errorString = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Find Places", @"error message")
                                                            message:errorString delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        
        if (self.localSearch != nil)
        {
            self.localSearch = nil;
        }
        self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        
        [self.localSearch startWithCompletionHandler:completionHandler];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        };
}

@end
