//
//  RSSChannel.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"

@implementation RSSChannel 

@synthesize items, title, infoString, parentParserDelegate;

- (id)init
{
    self = [super init];
    
    if (self) {
        items = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t%@ found a %@ element", self, elementName);
    
    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc]init];
        self.title = currentString;
    }else if ([elementName isEqual:@"description"]){
        currentString = [[NSMutableString alloc]init];
        self.infoString = currentString;
    }else if ([elementName isEqual:@"item"]){
        RSSItem *entry = [[RSSItem alloc]init];
        
        entry.parentParserDelegate = self;
        
        parser.delegate = entry;
        
        [items addObject:entry];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName    
{
    currentString = nil;
    if ([elementName isEqual:@"channel"]) {
        parser.delegate = parentParserDelegate;
        [self trimItemTitles];
    }
}

- (void)trimItemTitles
{
    NSRegularExpression *reg = [[NSRegularExpression alloc]initWithPattern:@".* :: (.*) :: .*" options:0 error:nil];
    
    for (RSSItem *i in items)
    {
        NSString *itemTitle = i.title;
        NSArray *matches = [reg matchesInString:itemTitle options:0 range:NSMakeRange(0,itemTitle.length)];
        
        if ([matches count] > 0) {
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSRange r = [result range];
            
            if ([result numberOfRanges] == 2) {
                NSRange r = [result rangeAtIndex:1];
                
                i.title = [itemTitle substringWithRange:r];
            }
        }
    }
}
@end
