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

@interface ListViewController : UITableViewController <NSXMLParserDelegate>
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
    
    RSSChannel *channel;
}
- (void)fetchEntries;
@property (nonatomic, strong) WebViewController *webViewController;
@end
