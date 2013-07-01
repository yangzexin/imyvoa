//
//  NewsListViewController.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoaNewsListProvider.h"
#import "VoaNewsDetailProvider.h"
#import "BaseViewController.h"

@class YXHTTPDownloader;
@class PopOutTableView;

@interface NewsListViewController : BaseViewController {
    id<VoaNewsListProvider> _voaNewsListProvider;
    id<VoaNewsDetailProvider> _voaNewsDetailProvider;
    
    YXHTTPDownloader *_httpDownloader;
    
    NSArray *_newsItemList;
    
    UIButton *_downloadBtn;
    
    UIBarButtonItem *_gotoNowPlayingBtn;
    
    PopOutTableView *_popOutTableView;
}

@end
