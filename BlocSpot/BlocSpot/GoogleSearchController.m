//
//  GoogleSearchController.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/13/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "GoogleSearchController.h"

@interface GoogleSearchController ()

@end

@implementation GoogleSearchController

@synthesize googleWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.googleWebView = [[UIWebView alloc] init];
    self.googleWebView.delegate = self;
    // Do any additional setup after loading the view.
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
