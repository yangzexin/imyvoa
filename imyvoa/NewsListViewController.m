//
//  NewsListViewController.m
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsListViewController.h"
#import "NewsItem.h"
#import "SVHTTPDownloader.h"
#import "SVCommonUtils.h"
#import "SVCodeUtils.h"
#import "SoundCache.h"
#import "SharedResource.h"
#import "Player.h"
#import "PopOutTableView.h"
#import "NewsDetailViewController.h"
#import "Utils.h"
#import "NewsItemCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SVUITools.h"
#import "DictionaryViewController.h"
#import "AllGlossaryManager.h"
#import "UIViewBlocked.h"
#import "ContentProviderFactory.h"
#import "SVGridViewWrapper.h"
#import "SVScriptBundle.h"
#import "SVOnlineAppBundle.h"
#import "SVApplicationScriptBundle.h"
#import "SVApp.h"
#import "SVAppManager.h"

#define BTN_BG_COLOR [UIColor clearColor]

@interface NewsListViewController () <
VoaNewsListProviderDelegate, 
VoaNewsDetailProviderDelegate, 
HTTPDownloaderDelegate, 
PopOutTableViewDelegate,
UISearchBarDelegate,
DictionaryViewControllerDelegate,
UITableViewDataSource,
UITableViewDelegate,
GridViewWrapperDelegate
>

@property(nonatomic, retain)id<VoaNewsListProvider> voaNewsListProvider;
@property(nonatomic, retain)id<VoaNewsDetailProvider> voaNewsDetailProvider;

@property(nonatomic, retain)SVHTTPDownloader *httpDownloader;

@property(nonatomic, retain)NSArray *newsItemList;

@property(nonatomic, retain)UIButton *downloadBtn;

@property(nonatomic, retain)UIBarButtonItem *gotoNowPlayingBtn;

@property(nonatomic, retain)PopOutTableView *popOutTableView;
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)UISearchBar *searchBar;
@property(nonatomic, retain)SVGridViewWrapper *gridViewWrapper;
@property(nonatomic, retain)SVGridViewWrapper *gridViewWrapperForLandscape;

- (void)requestNewsList;
- (void)downloadSoundFromURLString:(NSString *)soundURL;
- (void)viewNewsItem:(NewsItem *)item;

@end

@implementation NewsListViewController

@synthesize voaNewsListProvider = _voaNewsListProvider;
@synthesize voaNewsDetailProvider = _voaNewsDetailProvider;

@synthesize httpDownloader = _httpDownloader;

@synthesize newsItemList = _newsItemList;

@synthesize downloadBtn = _downloadBtn;

@synthesize gotoNowPlayingBtn = _gotoNowPlayingBtn;

@synthesize popOutTableView = _popOutTableView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_voaNewsListProvider providerWillRemoveFromPool]; [_voaNewsListProvider release];
    [_voaNewsDetailProvider providerWillRemoveFromPool]; [_voaNewsDetailProvider release];
    [_httpDownloader cancel]; [_httpDownloader release];
    
    [_newsItemList release];
    
    [_downloadBtn release];
    
    [_gotoNowPlayingBtn release];
    
    [_popOutTableView release];
    self.tableView = nil;
    self.searchBar = nil;
    self.gridViewWrapper = nil;
    self.gridViewWrapperForLandscape = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"title_news_list", nil);
    self.voaNewsDetailProvider = [ContentProviderFactory newsDetailProvider];
    self.voaNewsListProvider = [ContentProviderFactory newsListProvider];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *reloadImg = [SVUITools createPureColorImageWithColor:BTN_BG_COLOR 
                                                           size:CGSizeMake(60, 30)];
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reloadBtn.frame = CGRectMake(0, 0, reloadImg.size.width, reloadImg.size.height);
    [reloadBtn setBackgroundImage:reloadImg forState:UIControlStateNormal];
    [reloadBtn setTitle:NSLocalizedString(@"title_reload", nil) forState:UIControlStateNormal];
    [reloadBtn addTarget:self action:@selector(onReloadBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    reloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    UIBarButtonItem *reloadBtnItem = [[[UIBarButtonItem alloc] initWithCustomView:reloadBtn] autorelease];
    UIBarButtonItem *reloadBtnItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"title_reload", nil) 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(onReloadBtnTapped)] autorelease];
    self.navigationItem.leftBarButtonItem = reloadBtnItem;
    self.navigationItem.leftBarButtonItem = nil;
    
//    CGRect frame = self.view.bounds;
    
//    self.popOutTableView = [[[PopOutTableView alloc] init] autorelease];
//    self.popOutTableView.frame = frame;
//    self.popOutTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.popOutTableView addSubviewToPopOutCell:self.viewForPopOut];
//    self.popOutTableView.delegate = self;
//    self.popOutTableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:self.popOutTableView];
    
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSInteger numOfColumns = 2;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        numOfColumns = 4;
        self.gridViewWrapperForLandscape = [[[SVGridViewWrapper alloc] initWithNumberOfColumns:5] autorelease];
        self.gridViewWrapperForLandscape.delegate = self;
    }
    self.gridViewWrapper = [[[SVGridViewWrapper alloc] initWithNumberOfColumns:numOfColumns] autorelease];
    self.gridViewWrapper.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.dataSource = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ?
//        self.gridViewWrapperForLandscape : self.gridViewWrapper;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    UIImage *playingImg = [SVUITools createPureColorImageWithColor:[UIColor darkGrayColor]
                                                            size:CGSizeMake(80, 30)];
    UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpBtn setBackgroundImage:playingImg forState:UIControlStateNormal];
    [tmpBtn setTitle:NSLocalizedString(@"title_now_playing", nil) forState:UIControlStateNormal];
    tmpBtn.frame = CGRectMake(0, 0, playingImg.size.width, playingImg.size.height);
    tmpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [tmpBtn addTarget:self action:@selector(onGotoNowPlayingBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.gotoNowPlayingBtn = [[[UIBarButtonItem alloc] initWithCustomView:tmpBtn] autorelease];
    self.gotoNowPlayingBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"title_now_playing", nil) 
                                                              style:UIBarButtonItemStyleDone 
                                                             target:self 
                                                             action:@selector(onGotoNowPlayingBtnTapped)] autorelease];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:self.navigationController.navigationBar.bounds] autorelease];
    self.searchBar.delegate = self;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    for(UIView *subview in [self.searchBar subviews]){
        if([subview isKindOfClass:[UITextField class]]){
            UITextField *field = (id)subview;
            field.placeholder = @"输入查询单词";
            field.autocapitalizationType = UITextAutocapitalizationTypeNone;
            field.autocorrectionType = UITextAutocorrectionTypeNo;
        }else if([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            [subview removeFromSuperview];
        }
    }
    self.navigationItem.titleView = [[[UIView alloc] init] autorelease];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerStopNotification:) 
                                                 name:kPlayerDidStopNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onNewsItemDidRemoveFromCacheNotification:) 
                                                 name:kNewsItemDidRemoveFromCacheNotification 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.searchBar.hidden){
        self.searchBar.hidden = NO;
        [self.navigationController.navigationBar addSubview:self.searchBar];
        CGRect tmpRect = self.searchBar.frame;
        tmpRect.origin.y = -self.searchBar.frame.size.height;
        self.searchBar.frame = tmpRect;
        tmpRect.origin.y = 0;
        __block typeof(self) bself = self;
        [UIView animateWithDuration:0.20f delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            bself.searchBar.frame = tmpRect;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if(self.newsItemList.count == 0){
        if([SharedResource sharedInstance].scriptApp == nil){
            [self setLoading:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                id<SVScriptBundle> scriptBundle = [[[SVOnlineAppBundle alloc]
                                                    initWithURL:[NSURL URLWithString:@"http://imyvoaspecial.googlecode.com/files/com.yzx.imyvoa.pkg"]] autorelease];
                if(!scriptBundle){
                    scriptBundle = [[[SVApplicationScriptBundle alloc] initWithMainScriptName:@"main"] autorelease];
                }
                SVApp *app = [[[SVApp alloc] initWithScriptBundle:scriptBundle] autorelease];
                [SharedResource sharedInstance].scriptApp = app;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self requestNewsList];
                });
            });
        }else{
            [self requestNewsList];
        }
    }
    [self updateRightBarButtonItemStatus];
    
    [self.popOutTableView.tableView reloadData];
    [self popOutCellWillShowAtPopOutTableView:self.popOutTableView];
    
    [self updateSoundStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.popOutTableView.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
    if(self.searchBar.hidden){
        self.searchBar.hidden = NO;
        CGRect tmpRect = self.searchBar.frame;
        tmpRect.origin.y = -self.searchBar.bounds.size.height;
        __block typeof(self) bself = self;
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bself.searchBar.frame = tmpRect;
        } completion:^(BOOL finished) {
            [bself.searchBar removeFromSuperview];
            bself.searchBar.hidden = YES;
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.downloadBtn = nil;
    self.gotoNowPlayingBtn = nil;
    self.popOutTableView = nil;
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
}

- (NSInteger)numberOfRows
{
    return [self.newsItemList count];
}

- (UIView *)viewForPopOut
{
    UIViewBlocked *view = [[[UIViewBlocked alloc] init] autorelease];
    view.backgroundColor = [UIColor underPageBackgroundColor];
    
    CGRect frame = view.frame;
    frame.size.height = 60.0f;
    frame.size.width = self.view.frame.size.width;
    view.frame = frame;
    
    UIButton *viewBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [view addSubview:viewBtn];
    viewBtn.frame = CGRectMake(10, 10, (view.frame.size.width - 30) / 2, CGRectGetHeight(view.frame) - 20);
//    UIColor *color = BTN_BG_COLOR;
//    UIImage *pureColorImg = [UITools createPureColorImageWithColor:color 
//                                                              size:view.frame.size];
    [viewBtn setTitle:NSLocalizedString(@"view_news_detail", nil) forState:UIControlStateNormal];
//    [viewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    viewBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [viewBtn setBackgroundImage:pureColorImg forState:UIControlStateNormal];
    [viewBtn addTarget:self action:@selector(onViewBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [view addSubview:downloadBtn];
    downloadBtn.frame = CGRectMake(viewBtn.frame.origin.x + viewBtn.frame.size.width + 10, 10, viewBtn.frame.size.width, CGRectGetHeight(view.frame) - 20);
    [downloadBtn setTitle:NSLocalizedString(@"download_news", nil) forState:UIControlStateNormal];
    [downloadBtn setTitle:NSLocalizedString(@"did_downloaded", nil) forState:UIControlStateDisabled];
    [downloadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
//    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    downloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [downloadBtn setBackgroundImage:[viewBtn backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(onDownloadBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.downloadBtn = downloadBtn;
    
    [view setLayoutSubviewsBlock:^{
        viewBtn.frame = CGRectMake(10, 10, (view.frame.size.width - 30) / 2, CGRectGetHeight(view.frame) - 20);
        downloadBtn.frame = CGRectMake(viewBtn.frame.origin.x + viewBtn.frame.size.width + 10, 10, viewBtn.frame.size.width, CGRectGetHeight(view.frame) - 20);
    }];
    
    return view;
}

- (BOOL)shouldAutorotate
{
    if(self.tableView.dataSource == self.gridViewWrapper || self.tableView.dataSource == self.gridViewWrapperForLandscape){
        BOOL reloadData = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        if(reloadData){
            self.tableView.dataSource = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ?
            self.gridViewWrapperForLandscape : self.gridViewWrapper;
            [self.tableView reloadData];
        }
    }
    return UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM();
}

#pragma mark - events
- (void)onReloadBtnTapped
{
    [self requestNewsList];
}

- (void)onViewBtnTapped
{
    NewsItem *selectedItem = [self.newsItemList objectAtIndex:self.popOutTableView.selectedCellIndex];
    [self viewNewsItem:selectedItem];
}

- (void)onDownloadBtnTapped
{
    [self setWaiting:YES];
    NewsItem *selectedItem = [self.newsItemList objectAtIndex:self.popOutTableView.selectedCellIndex];
    [self.voaNewsDetailProvider requestWithNewsItem:selectedItem 
                                           delegate:self 
                                        ignoreCache:YES];
}

- (void)onCancelDownloadBtnTapped
{
    [self.httpDownloader cancel];
    
    self.navigationItem.rightBarButtonItem = nil;
    [self setDownloading:NO];
    [self updateRightBarButtonItemStatus];
}

- (void)onGotoNowPlayingBtnTapped
{
    NewsItem *nowPlayingItem = [SharedResource sharedInstance].currentPlayingNewsItem;
    [self viewNewsItem:nowPlayingItem];
}

- (void)onPlayerStopNotification:(NSNotification *)notification
{
    [SharedResource sharedInstance].currentPlayingNewsItem = nil;
    if(self.httpDownloader.downloading){
        return;
    }
    self.navigationItem.rightBarButtonItem = nil;
    [self updateRightBarButtonItemStatus];
}

- (void)onNewsItemDidRemoveFromCacheNotification:(NSNotification *)notification
{
    NewsItem *targetItem = notification.object;
    for(NewsItem *item in self.newsItemList){
        if([item.title isEqualToString:targetItem.title]){
            [item setNotCached];
            break;
        }
    }
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    if([Player sharedInstance].playing){
        NewsItem *targetItem = nil;
        for(NewsItem *tmpItem in self.newsItemList){
            if([[[SoundCache sharedInstance] filePathForSoundURLString:tmpItem.soundLink] isEqualToString:[Player sharedInstance].currentSoundFilePath]){
                targetItem = tmpItem;
                break;
            }
        }
        if(targetItem){
            self.navigationController.viewControllers = [NSArray arrayWithObject:self];
            self.tabBarController.selectedIndex = 0;
            [self viewNewsItem:targetItem animated:NO];
        }
    }
}

#pragma mark - private methods
- (void)requestNewsList
{
    [self setLoading:YES];
    [self.voaNewsListProvider providerWillRemoveFromPool];
    
    [self.voaNewsListProvider requestNewsListWithDelegate:self];
}

- (void)downloadSoundFromURLString:(NSString *)soundURL
{
    [self setDownloading:YES];
    
    self.httpDownloader = [[[SVHTTPDownloader alloc] initWithURLString:soundURL 
                                                          saveToPath:[SharedResource sharedInstance].soundTempFilePath] autorelease];
    self.httpDownloader.delegate = self;
    [self.httpDownloader startDownload];
}

- (void)viewNewsItem:(NewsItem *)item
{
    [self viewNewsItem:item animated:YES];
}

- (void)viewNewsItem:(NewsItem *)item animated:(BOOL)animated
{
    self.searchBar.hidden = YES;
    NewsDetailViewController *vc = [[[NewsDetailViewController alloc] initWithNewsItem:item] autorelease];
    vc.ignoreCache = NO;
    vc.hidesBottomBarWhenPushed =  YES;
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)updateRightBarButtonItemStatus
{
    BOOL downloading = self.httpDownloader.downloading;
    if(!downloading){
        self.navigationItem.rightBarButtonItem
            = [SharedResource sharedInstance].currentPlayingNewsItem == nil ? nil : self.gotoNowPlayingBtn;
    }
    CGRect tmpRect = self.navigationController.navigationBar.bounds;
    if(self.navigationItem.rightBarButtonItem != nil){
        CGFloat buttonWidth = [self.navigationItem.rightBarButtonItem.title sizeWithFont:[UIFont systemFontOfSize:12.0f]].width + 40;
        tmpRect.size.width -= buttonWidth;
    }
    __block typeof(self) bself = self;
    [UIView animateWithDuration:0.25f animations:^{
        bself.searchBar.frame = tmpRect;
    }];
}

- (void)updateSoundStatus
{
    // 从本地缓存中获取声音链接
    for(NewsItem *item in self.newsItemList){
        NewsItem *cacheItem = [self.voaNewsDetailProvider newsItemFromLocalCache:item];
        item.soundExists = NO;
        item.soundLink = nil;
        if(cacheItem){
            item.soundLink = cacheItem.soundLink;
            item.soundExists = [[SoundCache sharedInstance] filePathForSoundURLString:item.soundLink] != nil;
            item.content = cacheItem.content;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - PopOutTableViewDelegate
//- (BOOL)popOutCellTableView:(PopOutTableView *)popOutTableView shouldShowAtIndex:(NSInteger)index
//{
//    BOOL soundFileExists = NO;
//    NewsItem *selectedItem = [self.newsItemList objectAtIndex:index];
//    if(selectedItem.soundLink != nil){
//        if([[SoundCache sharedInstance] filePathForSoundURLString:selectedItem.soundLink] != nil){
//            soundFileExists = YES;
//        }
//    }
//    if(soundFileExists){
//        [self.popOutTableView setHidePopOutCell];
//        [self viewNewsItem:selectedItem];
//    }
//    
//    return !soundFileExists;
//}

- (void)popOutCellWillShowAtPopOutTableView:(PopOutTableView *)tableView
{
    if(self.popOutTableView.selectedCellIndex != -1){
        BOOL soundFileExists = NO;
        NewsItem *selectedItem = [self.newsItemList objectAtIndex:self.popOutTableView.selectedCellIndex];
        if(selectedItem.soundLink != nil){
            if([[SoundCache sharedInstance] filePathForSoundURLString:selectedItem.soundLink] != nil){
                soundFileExists = YES;
            }
        }
        self.downloadBtn.enabled = !soundFileExists;
    }
}

- (CGFloat)popOutTableView:(PopOutTableView *)popOutTableView heightForRowAtIndex:(NSInteger)index
{
    return 70.0f;
}

- (NSInteger)numberOfRowsInPopOutTableView:(PopOutTableView *)tableView
{
    return self.newsItemList.count;
}

- (UITableViewCell *)popOutTableView:(PopOutTableView *)tableView cellForRowAtIndex:(NSInteger)index
{
    static NSString *identifier = @"__id";
    NewsItemCell *cell = [tableView.tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[NewsItemCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                    reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NewsItem *item = [self.newsItemList objectAtIndex:index];
    [cell setNewsItem:item];
    
    [cell setBottomTrangleImgViewHidden:tableView.tappingIndex != index];
    
    return cell;
}

- (void)popOutCellTableViewWantToRefreshData:(PopOutTableView *)popOutTableView
{
    [self setWaiting:YES];
    [self.voaNewsListProvider providerWillRemoveFromPool];
    
    [self.voaNewsListProvider requestNewsListWithDelegate:self];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self viewNewsItem:[self.newsItemList objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.gridViewWrapper && (tableView.dataSource == self.gridViewWrapper || tableView.dataSource == self.gridViewWrapperForLandscape)){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
            return 215;
        }
        return self.view.frame.size.width / self.gridViewWrapper.numberOfColumns + 10;
    }
    return 70.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsItemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    NewsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[NewsItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:identifier] autorelease];
    }
    
    NewsItem *item = [self.newsItemList objectAtIndex:indexPath.row];
    [cell setNewsItem:item];
    
    return cell;
}


#pragma mark - VoaNewsDetailProviderDelegate
- (void)voaNewsContentProvider:(id)provider didRecieveResult:(NewsItem *)result
{
    [self setWaiting:NO];
    NewsItem *selectedItem = [self.newsItemList objectAtIndex:self.popOutTableView.selectedCellIndex];
    selectedItem.soundLink = result.soundLink;
    
    if([selectedItem.soundLink length] != 0){
        [self downloadSoundFromURLString:selectedItem.soundLink];
        [self.popOutTableView.tableView reloadData];
    }else{
        NSLog(@"failed to load news detail for downloading sound");
    }
}

- (void)voaNewsContentProvider:(id)provider didFailedWithError:(NSError *)error
{
    [self setWaiting:NO];
    [self showToastWithString:NSLocalizedString(@"msg_download_did_fail", nil) hideAfterInterval:2.0f];
}

#pragma mark - VoaNewsListProviderDelegate
- (void)voaNewsListProvider:(id)provider didRecieveList:(NSArray *)list
{
    [self setLoading:NO];
    self.newsItemList = list;
    [self updateSoundStatus];
    [self.popOutTableView.tableView reloadData];
    [self.tableView reloadData];
}

- (void)voaNewsListProvider:(id)provider didFailedWithError:(NSError *)error
{
    [self setLoading:NO];
    [self alert:NSLocalizedString(@"msg_fail_to_load_news_list", nil)];
    self.newsItemList = nil;
}

#pragma mark - HTTPDownloaderDelegate
- (void)HTTPDownloaderDidStarted:(SVHTTPDownloader *)downloader
{
    UIImage *cancelImg = [SVUITools createPureColorImageWithColor:[UIColor redColor]
                                                           size:CGSizeMake(60, 30)];
    UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpBtn setBackgroundImage:cancelImg forState:UIControlStateNormal];
    [tmpBtn setTitle:NSLocalizedString(@"cancel_download", nil) forState:UIControlStateNormal];
    tmpBtn.frame = CGRectMake(0, 0, cancelImg.size.width, cancelImg.size.height);
    tmpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [tmpBtn addTarget:self action:@selector(onCancelDownloadBtnTapped) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *cancelDownloadBtn = [[[UIBarButtonItem alloc] initWithCustomView:tmpBtn] autorelease];
    UIBarButtonItem *cancelDownloadBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel_download", nil) 
                                                                          style:UIBarButtonItemStyleDone 
                                                                         target:self 
                                                                         action:@selector(onCancelDownloadBtnTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = cancelDownloadBtn;
    [self updateRightBarButtonItemStatus];
}

- (void)HTTPDownloaderDidFinished:(SVHTTPDownloader *)downloader
{
    [self setDownloading:NO];
    [self updateRightBarButtonItemStatus];
    
    // rename sound file
    NewsItem *selectedItem = [self.newsItemList objectAtIndex:self.popOutTableView.selectedCellIndex];
    NSString *newPath = [[SoundCache soundCachePath] stringByAppendingPathComponent:
                         [SVCodeUtils md5ForString:selectedItem.title]];
    [[NSFileManager defaultManager] moveItemAtPath:[SharedResource sharedInstance].soundTempFilePath 
                                            toPath:newPath 
                                             error:nil];
    
    [[SoundCache sharedInstance] addSoundURLString:downloader.URLString atFilePath:newPath];
    [self.downloadBtn setEnabled:NO];
    [self updateSoundStatus];
    [self showToastWithString:NSLocalizedString(@"msg_download_did_finish", nil) hideAfterInterval:2.0f];
}

- (void)HTTPDownloader:(SVHTTPDownloader *)downloader didErrored:(NSError *)error
{
    [self setDownloading:NO];
    [self showToastWithString:NSLocalizedString(@"msg_download_did_fail", nil) hideAfterInterval:2.0f];
}

- (void)HTTPDownloaderDownloading:(SVHTTPDownloader *)downloader downloaded:(long long)downloaded total:(long long)total
{
    [self setDownloadingPercent:(double)downloaded / total];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *text = self.searchBar.text;
    DictionaryViewController *vc = [DictionaryViewController sharedInstance];
    vc.dictionaryViewControllerDelegate = self;
    [self.navigationController presentModalViewController:vc animated:YES];
    [vc query:text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
}

#pragma mark - DictionaryViewControllerDelegate
- (BOOL)dictionaryViewController:(DictionaryViewController *)dictVC bookmarkWord:(NSString *)word
{
    return [[AllGlossaryManager sharedManager] addWord:word];
}

#pragma mark - GridViewWrapperDelegate
- (NSInteger)numberOfItemsInGridViewWrapper:(SVGridViewWrapper *)gridViewWrapper
{
    return self.newsItemList.count;
}

- (void)gridViewWrapper:(SVGridViewWrapper *)gridViewWrapper configureView:(UIView *)view atIndex:(NSInteger)index
{
    UIView *containerView = [view viewWithTag:101];
    UILabel *titleLabel = nil;
    UILabel *contentLabel = nil;
    if(!containerView){
        containerView = [[[UIView alloc] initWithFrame:CGRectMake(10, 5, view.frame.size.width - 20, view.frame.size.height)] autorelease];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.tag = 101;
        
        UIView *shadowView = [[[UIView alloc] initWithFrame:containerView.frame] autorelease];
        shadowView.backgroundColor = [UIColor whiteColor];
        shadowView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        shadowView.layer.shadowOpacity = 1.0f;
        shadowView.layer.shadowRadius = 2.0f;
        shadowView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        shadowView.layer.shouldRasterize = YES;
        [view addSubview:shadowView];
        [view addSubview:containerView];
        
        titleLabel = [[UILabel new] autorelease];
        titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        titleLabel.numberOfLines = 4;
        titleLabel.frame = CGRectMake(5, 5, containerView.frame.size.width - 10, titleLabel.font.lineHeight * titleLabel.numberOfLines);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 1001;
        [containerView addSubview:titleLabel];
        
        contentLabel = [[UILabel new] autorelease];
        contentLabel.font = [UIFont systemFontOfSize:12.0f];
        contentLabel.backgroundColor = [UIColor clearColor];
        CGFloat tmpY = titleLabel.frame.origin.y + titleLabel.frame.size.height + 5;
        contentLabel.frame = CGRectMake(5, tmpY, titleLabel.frame.size.width - 10, containerView.frame.size.height - 5 - tmpY);
        contentLabel.tag = 1002;
        contentLabel.numberOfLines = 0;
        [containerView addSubview:contentLabel];
    }else{
        titleLabel = (id)[containerView viewWithTag:1001];
        contentLabel = (id)[containerView viewWithTag:1002];
    }
    
    NewsItem *item = [self.newsItemList objectAtIndex:index];
    titleLabel.text = item.title;
    contentLabel.text = item.content.length == 0 ? @"" : [Utils stripHTMLTags:item.content];
    if(contentLabel.text.length != 0){
        contentLabel.text = [[contentLabel.text substringFromIndex:item.title.length]
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self resizeLabel:titleLabel y:titleLabel.frame.origin.y];
        [self resizeLabel:contentLabel y:titleLabel.frame.origin.y + titleLabel.frame.size.height + 5];
        CGRect tmpRect = contentLabel.frame;
        tmpRect.size.height = containerView.frame.size.height - 5 - contentLabel.frame.origin.y;
        contentLabel.frame = tmpRect;
    }
//    contentLabel.textColor = item.isCached ? [UIColor colorWithRed:0 green:43.0f/255.0f blue:148.0f/255.0f alpha:1.0f] : [UIColor blackColor];
}

- (void)resizeLabel:(UILabel *)label y:(CGFloat)y
{
    CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size];
    CGRect tmpRect = label.frame;
    tmpRect.size.height = textSize.height;
    tmpRect.origin.y = y;
    label.frame = tmpRect;
}

- (void)gridViewWrapper:(SVGridViewWrapper *)gridViewWrapper viewItemTappedAtIndex:(NSInteger)index
{
    [self viewNewsItem:[self.newsItemList objectAtIndex:index]];
}

@end
