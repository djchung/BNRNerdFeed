//
//  ListViewController.h
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSSChannel;
@class WebViewController;

typedef enum {
    ListViewControllerRSSTypeBNR,
    ListViewControllerRSSTypeApple
}ListViewControllerRSSType;

@interface ListViewController : UITableViewController
{
    
    RSSChannel *channel;
    ListViewControllerRSSType rssType;
}
- (void)fetchEntries;
@property (nonatomic, strong) WebViewController *webViewController;
@end
