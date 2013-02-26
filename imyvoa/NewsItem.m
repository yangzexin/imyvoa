//
//  NewsItem.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsItem.h"

@implementation NewsItem

@synthesize title;
@synthesize contentLink;
@synthesize content;
@synthesize soundLink;

@synthesize soundExists;

- (void)dealloc
{
    [title release];
    [contentLink release];
    [content release];
    [soundLink release];
    
    [super dealloc];
}

- (void)setWithNewsItem:(NewsItem *)item
{
    self.title = item.title;
    self.contentLink = item.contentLink;
    self.content = item.content;
    self.soundLink = item.soundLink;
}

- (BOOL)isCached
{
    return self.soundLink != nil;
}

- (void)setNotCached
{
    self.soundLink = nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    NewsItem *item = [[[NewsItem allocWithZone:zone] init] autorelease];
    item.title = title;
    item.contentLink = contentLink;
    item.content = content;
    item.soundLink = soundLink;
    
    return item;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.contentLink forKey:@"contentLink"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.soundLink forKey:@"soundLink"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.contentLink = [aDecoder decodeObjectForKey:@"contentLink"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.soundLink = [aDecoder decodeObjectForKey:@"soundLink"];
    
    return self;
}

@end
