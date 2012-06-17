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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:items forKey:@"items"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:infoString forKey:@"infoString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        items = [aDecoder decodeObjectForKey:@"items"];
        self.infoString = [aDecoder decodeObjectForKey:@"infoString"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
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
    }else if ([elementName isEqual:@"item"] || [elementName isEqual:@"entry"]){
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
    if ([elementName isEqual:@"item"] || [elementName isEqual:@"entry"]) {
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

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    NSDictionary *feed = [d objectForKey:@"feed"];
    
    self.title = [feed objectForKey:@"title"];
    
    NSArray *entries = [feed objectForKey:@"entry"];
    for (NSDictionary *entry in entries) {
        RSSItem *i = [[RSSItem alloc]init];
        
        [i readFromJSONDictionary:entry];
        [items addObject:i];
    }
}

- (void)addItemsFromChannel:(RSSChannel *)otherChannel
{
    for (RSSItem *i in [otherChannel items]) {
        if(![self.items containsObject:i])
        {
            [self.items addObject:i];
        }
    }
    
    [self.items sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [[obj2 publicationDate] compare:[obj1 publicationDate]];
    }];
}

- (id)copyWithZone:(NSZone *)zone
{
    RSSChannel *c = [[self.class alloc]init];
    c.title = self.title;
    c.infoString = self.infoString;
    c->items = [items mutableCopy];
    
    return c;
}
@end
