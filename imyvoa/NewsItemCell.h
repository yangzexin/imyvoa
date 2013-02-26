//
//  NewsItemCell.h
//  imyvoa
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;
@class TrangleView;

@interface NewsItemCell : UITableViewCell {
    NewsItem *_newsItem;
    
    UIView *_separatorLine;
    UIImageView *_bottomTrangleImgView;
    TrangleView *_trangleView;
}

@property(nonatomic, retain)NewsItem *newsItem;
@property(nonatomic, readonly)UIView *separatorLine;

- (void)setBottomTrangleImgViewHidden:(BOOL)hidden;

@end
