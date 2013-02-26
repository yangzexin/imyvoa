//
//  NewsItem.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsItem : NSObject <NSCopying, NSCoding> {
    NSString *title;
    NSString *contentLink;
    NSString *content;
    NSString *soundLink;
    
    BOOL soundExists;
}

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *contentLink;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, copy)NSString *soundLink;

@property(nonatomic, assign)BOOL soundExists;

- (void)setWithNewsItem:(NewsItem *)item;
- (BOOL)isCached;
- (void)setNotCached;

@end
