//
//  RSSItem.m
//  BNRNerdFeed
//
//  Created by DJ Chung on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem

@synthesize title, link, parentParserDelegate;
@synthesize publicationDate;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:link forKey:@"link"];
    [aCoder encodeObject:publicationDate forKey:@"publicationDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.link = [aDecoder decodeObjectForKey:@"link"];
        self.publicationDate = [aDecoder decodeObjectForKey:@"publicationDate"];
    }
    return self;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t\t%@ found a %@ element", self, elementName);
    
    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc]init];
        self.title = currentString;
    }else if ([elementName isEqual:@"link"]){
        currentString = [[NSMutableString alloc]init];
        self.link = currentString;
    }else if ([elementName isEqualToString:@"pubDate"]){
        currentString = [[NSMutableString alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"pubDate"]) {
        static NSDateFormatter *dateFormatter = nil;
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
        }
        self.publicationDate = [dateFormatter dateFromString:currentString];
    }
    currentString = nil;
    if ([elementName isEqual:@"item"]) {
        parser.delegate = parentParserDelegate;
    }
}

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    self.title = [[d objectForKey:@"title"] objectForKey:@"label"];
    
    NSArray *links = [d objectForKey:@"link"];
    if ([links count] > 1) {
        NSDictionary *sampleDict = [[links objectAtIndex:1]objectForKey:@"attributes"];
        
        self.link = [sampleDict objectForKey:@"href"];
    }
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[RSSItem class]]) {
        return NO;
    }
    return [self.link isEqual:[object link]];
}
@end
