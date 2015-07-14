//
//  GoogleSearchController.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/13/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleSearchController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *googleWebView;

@end
