//
//  GoogleSearchController.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/13/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "GoogleSearchController.h"
#import "DataSource.h"

@interface GoogleSearchController ()

@end

@implementation GoogleSearchController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //inspect gloabal search string
    //loadRequest of webview
    [self.googleWebView loadRequest:[DataSource sharedInstance].searchURL];
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
