//
//  WebViewController.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (void)loadView
{
    CGRect screenFrame = [[UIScreen mainScreen]applicationFrame];
    UIWebView *wv = [[UIWebView alloc]initWithFrame:screenFrame];
    [wv setScalesPageToFit:YES];
    self.view = wv;
}

- (UIWebView *)webView
{
    return (UIWebView *)self.view;
}
@end
