//
//  NewsDetailViewController.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "VoaNewsDetailProvider.h"
#import "Dictionary.h"
#import "GlossaryManager.h"

@class NewsItem;
@class HTTPDownloader;
@class Timer;

@interface NewsDetailViewController : BaseViewController <VoaNewsDetailProviderDelegate> {
    UIToolbar *_toolbar;
    UIWebView *_webView;
    UIView *_topControlView;
    UILabel *_currentTimeLabel;
    UILabel *_totalTimeLabel;
    UISlider *_positionSilder;
    
    UIBarButtonItem *_previousBtn;
    UIBarButtonItem *_nextBtn;
    UIBarButtonItem *_playBtn;
    UIBarButtonItem *_pauseBtn;
    UIBarButtonItem *_downloadBtn;
    UIBarButtonItem *_viewGlossaryBtn;
    
    id<VoaNewsDetailProvider> _voaNewsDetailProvider;
    
    NewsItem *_newsItem;
    NSString *_newsContent;
    
    NSString *_dictionaryName;
    
    HTTPDownloader *_httpDownloader;
    
    Timer *_timer;
    
    BOOL _positionSilderTouching;
    
    id<GlossaryManager> _glossaryManager;
    
    float _scrollPercent; // webView加载完成之后需要滚动到的位置
    
    BOOL _ignoreCache;
}

- (id)initWithNewsItem:(NewsItem *)newsItem;

@property(nonatomic, retain)NewsItem *newsItem;
@property(nonatomic, assign)BOOL ignoreCache;

@end
