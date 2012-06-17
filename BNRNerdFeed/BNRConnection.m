//
//  BNRConnection.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRConnection.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation BNRConnection
@synthesize request, completionBlock, xmlRootObject;
@synthesize jsonRootObject;

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        self.request = req;
    }
    
    return self;
}

- (void)start
{
    container = [[NSMutableData alloc]init];
    
    //spawn connection
    internalConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    
    if (!sharedConnectionList) {
        sharedConnectionList = [[NSMutableArray alloc]init];
        
        [sharedConnectionList addObject:self];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id rootObject = nil;
    if (self.xmlRootObject) {
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:container];
        parser.delegate = self.xmlRootObject;
        [parser parse];
        rootObject = [self xmlRootObject];
    }else if ([self jsonRootObject]){
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
        [self.jsonRootObject readFromJSONDictionary:d];
        
        rootObject = self.jsonRootObject;
    }
    
    if (self.completionBlock) {
        self.completionBlock(rootObject, nil);
        
    }
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock) {
        self.completionBlock(nil,error);
    }
    [sharedConnectionList removeObject:self];
}
@end
