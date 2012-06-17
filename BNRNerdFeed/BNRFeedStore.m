//
//  BNRFeedStore.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRFeedStore.h"
#import "RSSChannel.h"
#import "BNRConnection.h"

@implementation BNRFeedStore

+ (BNRFeedStore *)sharedStore
{
    static BNRFeedStore *feedStore = nil;
    if (!feedStore) {
        feedStore = [[BNRFeedStore alloc]init];
    }
    
    return feedStore;
}

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://forums.bignerdranch.com/"
                  @"smartfeed.php?limit=1_DAY&sort_by=standard"
                  @"&feed_type=RSS2.0&feed_style=COMPACT"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    RSSChannel *channel = [[RSSChannel alloc] init];
    
    //create a connection actor object to transfer data from the server
    
    BNRConnection *connection = [[BNRConnection alloc]initWithRequest:req];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    cachePath = [cachePath stringByAppendingPathComponent:@"nerd.archive"];
    
    RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    
    if (!cachedChannel) {
        cachedChannel = [[RSSChannel alloc]init];
        
    }
    
    RSSChannel *channelCopy = [cachedChannel copy];
    
    connection.completionBlock = ^(RSSChannel *obj, NSError *err){
        if (!err) {
            [channelCopy addItemsFromChannel:obj];
            [NSKeyedArchiver archiveRootObject:channelCopy toFile:cachePath];
        }
        block(channelCopy, err);
    };
    
    connection.xmlRootObject = channel;
    
    [connection start];
    
    return cachedChannel;
    
}

- (void)fetchTopSongs:(int)count withCompletion:(void(^)(RSSChannel *obj, NSError *err))block
{
    NSString *cachePath = 
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"apple.archive"];
    
    NSDate *tscDate = [self topSongsCacheDate];
    if (tscDate) {
        NSTimeInterval cacheAge = [tscDate timeIntervalSinceNow];
        
        if (cacheAge > -300.0) {
            NSLog(@"Reading cache!");
            
            RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
            
            if (cachedChannel) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    block(cachedChannel, nil);
                }];
                
                return;
            }
        }
    }
    
    NSString *requestString = [NSString stringWithFormat:@"http://itunes.apple.com/us/rss/topsongs/limit=%d/json", count];
    
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    RSSChannel *channel = [[RSSChannel alloc]init];
    
    BNRConnection *connection = [[BNRConnection alloc]initWithRequest:req];
    connection.completionBlock = ^(RSSChannel *obj, NSError *err){
        if (!err) {
            [self setTopSongsCacheDate:[NSDate date]];
            [NSKeyedArchiver archiveRootObject:obj toFile:cachePath];
        }
        block(obj,err);
    };
    connection.jsonRootObject = channel;
    [connection start];
}

- (void)setTopSongsCacheDate:(NSDate *)topSongsCacheDate
{
    [[NSUserDefaults standardUserDefaults] setObject:topSongsCacheDate forKey:@"topSongsCacheDate"];
}

- (NSDate *)topSongsCacheDate
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"topSongsCacheDate"];
}
@end
