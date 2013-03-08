//
//  NewsItemCell.m
//  imyvoa
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsItemCell.h"
#import "NewsItem.h"
#import "Utils.h"
#import "TrangleView.h"

@interface NewsItemCell ()

@property(nonatomic, retain)UIImageView *bottomTrangleImgView;
@property(nonatomic, retain)TrangleView *trangleView;

@end

@implementation NewsItemCell

@synthesize newsItem = _newsItem;

@synthesize separatorLine = _separatorLine;
@synthesize bottomTrangleImgView = _bottomTrangleImgView;
@synthesize trangleView = _trangleView;

- (void)dealloc
{
    [_newsItem release];
    
    [_separatorLine release];
    [_bottomTrangleImgView release];
    
    [_trangleView release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    self.textLabel.numberOfLines = 2;
    
    self.bottomTrangleImgView = [[[UIImageView alloc] init] autorelease];
    [self addSubview:self.bottomTrangleImgView];
    self.bottomTrangleImgView.backgroundColor = [UIColor whiteColor];
    self.bottomTrangleImgView.frame = CGRectMake(0, 0, 20, 10);
    self.bottomTrangleImgView.hidden = YES;
    
    _separatorLine = [[[UIView alloc] init] autorelease];
    [self addSubview:_separatorLine];
    _separatorLine.frame = CGRectMake(0, 0, 0, 1);
    _separatorLine.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
    
    self.trangleView = [[[TrangleView alloc] initWithFrame:CGRectMake(0, 0, 25, 15)] autorelease];
    [self addSubview:self.trangleView];
    self.trangleView.backgroundColor = [UIColor underPageBackgroundColor];
    self.trangleView.hidden = YES;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *title = [self.newsItem.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *dateString = [Utils formattedDateStringFromNewsItemTitle:title];
    NSString *realTitle = [Utils newsTitleFromNewsItemTitle:title];
    if(dateString && realTitle){
        title = [NSString stringWithFormat:@"%@ %@", dateString, realTitle];
    }
    self.textLabel.text = title;
//    self.textLabel.numberOfLines = [title sizeWithFont:self.textLabel.font
//                                     constrainedToSize:CGSizeMake(self.textLabel.frame.size.width, 200)].height / self.textLabel.font.lineHeight;
    
    if(self.newsItem.isCached){
        self.textLabel.textColor = [UIColor colorWithRed:0 green:43.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    }else{
        self.textLabel.textColor = [UIColor blackColor];
    }
    
    self.imageView.image = self.newsItem.soundExists 
        ? [UIImage imageNamed:@"icon_sound"] : [UIImage imageNamed:@"icon_no_sound"];
    
    CGRect frame;
    frame = self.bottomTrangleImgView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    frame.origin.y = self.frame.size.height - frame.size.height;
    self.bottomTrangleImgView.frame = frame;
    
    frame = self.trangleView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    frame.origin.y = self.frame.size.height - frame.size.height;
    self.trangleView.frame = frame;
    
    frame = _separatorLine.frame;
    frame.origin.y = self.frame.size.height - frame.size.height;
    frame.size.width = self.frame.size.width;
    _separatorLine.frame = frame;
    _separatorLine.hidden = !self.trangleView.hidden;
}

#pragma mark - instance methods
- (void)setNewsItem:(NewsItem *)newsItem
{
    if(_newsItem != newsItem){
        [_newsItem release];
        _newsItem = [newsItem retain];
    }
    [self layoutSubviews];
}

- (void)setBottomTrangleImgViewHidden:(BOOL)hidden
{
    self.trangleView.hidden = hidden;
    [self layoutSubviews];
}

@end
