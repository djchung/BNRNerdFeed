//
//  ListViewController.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"
#import "BNRFeedStore.h"

@implementation ListViewController
@synthesize webViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        UISegmentedControl *rssTypeControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"BNR", @"Apple", nil]];
        rssTypeControl.selectedSegmentIndex = 0;
        rssTypeControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [rssTypeControl addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = rssTypeControl;
        [self fetchEntries];
        
        
    }
    return self;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    RSSItem *item = [[channel items]objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:webViewController animated:YES];
    
    RSSItem *entry = [[channel items]objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:entry.link];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [webViewController.webView loadRequest:req];
    webViewController.navigationItem.title = entry.title;
    
}


- (void)fetchEntries
{
    UIView *currentTitleView = self.navigationItem.titleView;
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.titleView = aiView;
    [aiView startAnimating];
    
    void (^completionBlock)(RSSChannel *obj, NSError *err) =
    ^(RSSChannel *obj, NSError *err){
        //when request completes, this block is called
        
        self.navigationItem.titleView = currentTitleView;
        
        if (!err) {
            channel = obj;
            [self.tableView reloadData];
        }else {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
    };
    
    if (rssType == ListViewControllerRSSTypeBNR) {
        channel = [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion:^(RSSChannel *obj, NSError *err) {
            self.navigationItem.titleView = currentTitleView;
            
            if (!err) {
                int currentItemCount = [[channel items]count];
                
                channel = obj;
                
                int newItemCount = [[channel items]count];
                
                int itemDelta = newItemCount - currentItemCount;
                
                if (itemDelta >0) {
                    NSMutableArray *rows = [NSMutableArray array];
                    for (int i = 0; i < itemDelta; i++) {
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                        [rows addObject:ip];
                    }
                    [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
                }
            }
        }];
        [self.tableView reloadData];
    }else if (rssType == ListViewControllerRSSTypeApple){
        [[BNRFeedStore sharedStore] fetchTopSongs:10 withCompletion:completionBlock]; 
    }
}

- (void)changeType:(id)sender
{
    rssType = [sender selectedSegmentIndex];
    [self fetchEntries];
}
@end
