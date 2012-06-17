//
//  BNRFeedStore.h
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@class RSSChannel;

@interface BNRFeedStore : NSObject

+ (BNRFeedStore *)sharedStore;

- (RSSChannel *)fetchRSSFeedWithCompletion:(void(^)(RSSChannel *obj, NSError *err))block;
- (void)fetchTopSongs:(int)count withCompletion:(void(^)(RSSChannel *obj, NSError *err))block;

@property (nonatomic, strong) NSDate *topSongsCacheDate;

@end
