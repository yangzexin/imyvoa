//
//  NewsDetailViewController.m
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "NewsItem.h"
#import "UIWebViewAdditions.h"
#import "SVCommonUtils.h"
#import "SVHTTPDownloader.h"
#import "SharedResource.h"
#import "SVCodeUtils.h"
#import "SoundCache.h"
#import "Player.h"
#import "SVTimer.h"
#import "DictionaryViewController.h"
#import "DBGlossaryManager.h"
#import "GlossaryLibraryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVDataBaseKeyValueManager.h"
#import "ContentProviderFactory.h"
#import "DictionaryFactory.h"
#import "VOWebView.h"

typedef enum{
    ToolbarStatePlaying,
    ToolbarStatePause, 
    ToolbarStateUndownloaded
}ToolbarState;

@interface NewsDetailViewController () <UIWebViewDelegate, 
HTTPDownloaderDelegate, 
SVTimerDelegate, 
DictionaryViewControllerDelegate, 
UIAlertViewDelegate, 
UIScrollViewDelegate
>

@property(nonatomic, retain)UIToolbar *toolbar;
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIView *topControlView;
@property(nonatomic, retain)UILabel *currentTimeLabel;
@property(nonatomic, retain)UILabel *totalTimeLabel;
@property(nonatomic, retain)UISlider *positionSilder;

@property(nonatomic, retain)UIBarButtonItem *previousBtn;
@property(nonatomic, retain)UIBarButtonItem *nextBtn;
@property(nonatomic, retain)UIBarButtonItem *playBtn;
@property(nonatomic, retain)UIBarButtonItem *pauseBtn;
@property(nonatomic, retain)UIBarButtonItem *downloadBtn;
@property(nonatomic, retain)UIBarButtonItem *viewGlossaryBtn;

@property(nonatomic, retain)id<VoaNewsDetailProvider> voaNewsDetailProvider;

@property(nonatomic, retain)NSString *newsContent;

@property(nonatomic, copy)NSString *dictionaryName;

@property(nonatomic, retain)SVHTTPDownloader *httpDownloader;

@property(nonatomic, retain)SVTimer *timer;

@property(nonatomic, assign)BOOL positionSilderTouching;

@property(nonatomic, retain)id<GlossaryManager> glossaryManager;

@property(nonatomic)float scrollPercent;

@property(nonatomic, retain)id<SVKeyValueManager> scrollPositionDict;

- (void)loadContent:(NSString *)content;
- (void)downloadSoundFromURLString:(NSString *)soundURL;
- (UIBarButtonItem *)createFlexibleSpaceBarButtonItem;
- (void)togglePlayingToolbarItemsWithToolbarState:(ToolbarState)state;
- (void)updatePlayerStatus;
- (void)setTopControlViewHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)updateWebViewPadding;
- (void)updatePositionStatus;
- (BOOL)isPlayerPlayingCurrent;
- (void)startTimer;
- (void)didRecieveNewsItem:(NewsItem *)result;
- (void)searchWordInDictionary:(NSString *)word;

@end

@implementation NewsDetailViewController

@synthesize toolbar = _toolbar;
@synthesize webView = _webView;
@synthesize topControlView = _topControlView;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize totalTimeLabel = _totalTimeLabel;
@synthesize positionSilder = _positionSilder;

@synthesize previousBtn = _previousBtn;
@synthesize nextBtn = _nextBtn;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize downloadBtn = _downloadBtn;
@synthesize viewGlossaryBtn = _viewGlossaryBtn;

@synthesize voaNewsDetailProvider = _voaNewsDetailProvider;

@synthesize newsItem = _newsItem;
@synthesize newsContent = _newsContent;

@synthesize dictionaryName = _dictionaryName;

@synthesize httpDownloader = _httpDownloader;

@synthesize timer = _timer;

@synthesize positionSilderTouching = _positionSilderTouching;

@synthesize glossaryManager = _glossaryManager;

@synthesize scrollPercent = _scrollPercent;

@synthesize ignoreCache = _ignoreCache;

@synthesize scrollPositionDict;

- (void)dealloc
{
    [_toolbar release];
    [_webView release];
    [_topControlView release];
    [_currentTimeLabel release];
    [_totalTimeLabel release];
    [_positionSilder release];
    
    [_previousBtn release];
    [_nextBtn release];
    [_playBtn release];
    [_pauseBtn release];
    [_downloadBtn release];
    [_viewGlossaryBtn release];
    
    [_voaNewsDetailProvider providerWillRemoveFromPool]; [_voaNewsDetailProvider release];
    
    [_newsItem release];
    [_newsContent release];
    
    [_dictionaryName release];
    
    [_httpDownloader cancel]; [_httpDownloader release];
    
    [_timer cancel]; [_timer stop]; [_timer release];
    
    [_glossaryManager release];
    self.scrollPositionDict = nil;
    [super dealloc];
}

- (id)initWithNewsItem:(NewsItem *)newsItem
{
    self = [super init];
    
    self.newsItem = newsItem;
    
    self.title = NSLocalizedString(@"title_news_detail", nil);
    self.voaNewsDetailProvider = [ContentProviderFactory newsDetailProvider];
    self.dictionaryName = [[DictionaryFactory defaultDictionary] name];
    self.glossaryManager = [[DBGlossaryManager alloc] initWithIdentifier:self.newsItem.title];
    self.scrollPositionDict = [[[SVDataBaseKeyValueManager alloc] initWithDBName:@"position_dict" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    self.scrollPercent = 0.0f;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    // webview
    frame = self.view.bounds;
    self.webView = [[[VOWebView alloc] initWithFrame:frame] autorelease];
    self.webView.delegate = self;
    [self.webView getScrollView].delegate = self;
    [self.webView removeShadow];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
    if(self.dictionaryName){
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        NSMutableArray *menuItems = [NSMutableArray arrayWithArray:menuController.menuItems];
        BOOL dictMenuItemExists = NO;
        for(UIMenuItem *menuItem in menuItems){
            if([menuItem.title isEqualToString:self.dictionaryName]){
                dictMenuItemExists = YES;
                break;
            }
        }
        if(!dictMenuItemExists){
            UIMenuItem *dictMenuItem = [[UIMenuItem alloc] initWithTitle:self.dictionaryName 
                                                                  action:@selector(onDictMenuItemTapped)];
            [menuItems addObject:dictMenuItem];
            [dictMenuItem release];
            menuController.menuItems = menuItems;
        }
    }
    
    // toolbar
    frame = self.view.bounds;
    frame.size.height = 44.0f;
    frame.origin.y = self.view.bounds.size.height;
    frame.origin.y -= frame.size.height - 1;
    self.toolbar = [[[UIToolbar alloc] initWithFrame:frame] autorelease];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.toolbar];
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self addViewToNonPrefersList:self.toolbar];
    
    // topControlView
    frame = self.view.bounds;
    frame.size.height = 44.0f;
    self.topControlView = [[[UIView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:self.topControlView];
    self.topControlView.backgroundColor = [UIColor clearColor];
    self.topControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self setTopControlViewHidden:![self isPlayerPlayingCurrent] animated:NO];
    
    // position slider
    frame = self.view.bounds;
    frame.size.height = 44.0f;
    UIView *topBlackBar = [[[UIView alloc] initWithFrame:frame] autorelease];
    [self.topControlView addSubview:topBlackBar];
    topBlackBar.backgroundColor = [UIColor blackColor];
    topBlackBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topBlackBar.alpha = 0.52f;
    
    frame.origin.y = topBlackBar.frame.origin.y + topBlackBar.frame.size.height;
    frame.origin.x = 0;
    frame.size.width = topBlackBar.frame.size.width;
    frame.size.height = 1;
    UIView *bottomLine = [[[UIView alloc] initWithFrame:frame] autorelease];
    [self.topControlView addSubview:bottomLine];
    bottomLine.backgroundColor = [UIColor blackColor];
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLine.alpha = 0.67f;
    
    frame.origin.x = 47;
    frame.size.width = self.view.bounds.size.width - (frame.origin.x * 2);
    frame.size.height = 20.0f;
    frame.origin.y = topBlackBar.frame.origin.y + (topBlackBar.frame.size.height - frame.size.height) / 2;
    self.positionSilder = [[[UISlider alloc] initWithFrame:frame] autorelease];
    self.positionSilder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.positionSilder addTarget:self 
                            action:@selector(onPositionSilderDragEnter) 
                  forControlEvents:UIControlEventTouchDown];
    [self.positionSilder addTarget:self 
                            action:@selector(onPositionSilderDragExit) 
                  forControlEvents:UIControlEventTouchUpInside];
    [self.positionSilder addTarget:self 
                            action:@selector(onPositionSilderDragExit) 
                  forControlEvents:UIControlEventTouchUpOutside];
    [self.positionSilder addTarget:self 
                            action:@selector(onPositionSilderDragging) 
                  forControlEvents:UIControlEventTouchDragInside];
    [self.positionSilder addTarget:self 
                            action:@selector(onPositionSilderDragging) 
                  forControlEvents:UIControlEventTouchDragOutside];
    [self.topControlView addSubview:self.positionSilder];
    
    // time labels
    UIFont *timeFont = [UIFont systemFontOfSize:12.0f];
    frame.size.width = [@"00:00" sizeWithFont:timeFont].width;
    frame.origin.x = self.positionSilder.frame.origin.x - frame.size.width - 2;
    frame.origin.y = self.positionSilder.frame.origin.y;
    frame.size.height = self.positionSilder.frame.size.height;
    self.currentTimeLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [self.topControlView addSubview:self.currentTimeLabel];
    self.currentTimeLabel.backgroundColor = [UIColor clearColor];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.font = timeFont;
    self.currentTimeLabel.text = @"00:00";
    
    frame = self.currentTimeLabel.frame;
    frame.origin.x = self.positionSilder.frame.origin.x + self.positionSilder.frame.size.width + 2;
    self.totalTimeLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [self.topControlView addSubview:self.totalTimeLabel];
    self.totalTimeLabel.backgroundColor = [UIColor clearColor];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.font = timeFont;
    self.totalTimeLabel.text = @"00:00";
    self.totalTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    // previous btn
    UIBarButtonItem *previousBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind 
                                                                                 target:self 
                                                                                 action:@selector(onPreviousBtnTapped:)];
    self.previousBtn = previousBtn;
    [previousBtn release];
    
    // play or pause btn 
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay 
                                                                             target:self 
                                                                             action:@selector(onPlayBtnTapped:)];
    self.playBtn = playBtn;
    [playBtn release];
    UIBarButtonItem *pauseBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause 
                                                                              target:self 
                                                                              action:@selector(onPlayBtnTapped:)];
    self.pauseBtn = pauseBtn;
    [pauseBtn release];
    
    // next btn
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward 
                                                                             target:self 
                                                                             action:@selector(onNextBtnTapped:)];
    self.nextBtn = nextBtn;
    [nextBtn release];
    
    // download btn
    UIBarButtonItem *downloadBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_download"] 
                                                   style:UIBarButtonItemStylePlain 
                                                  target:self 
                                                  action:@selector(onDownloadBtnTapped:)];
    self.downloadBtn = downloadBtn;
    [downloadBtn release];
    
    // view glossary btn
    self.viewGlossaryBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Glossary", nil) 
                                                            style:UIBarButtonItemStyleBordered 
                                                           target:self 
                                                           action:@selector(onViewGlossaryBtnTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = self.viewGlossaryBtn;
    
    if(self.newsItem.isCached && self.ignoreCache){
        // 内容已经下载
        NewsItem *item = [self.voaNewsDetailProvider newsItemFromLocalCache:self.newsItem];
        [self didRecieveNewsItem:item];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerStartPlayNotification:) 
                                                 name:kPlayerDidStartPlayNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerPauseNotification:) 
                                                 name:kPlayerDidPauseNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerStopNotification:) 
                                                 name:kPlayerDidStopNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerChangeSoundNotification:) 
                                                 name:kPlayerDidChangeSoundNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidPlayFinishNotification:) 
                                                 name:kPlayerDidPlayFinishNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.newsContent == nil){
        [self setLoading:YES];
        [self.voaNewsDetailProvider requestWithNewsItem:self.newsItem delegate:self ignoreCache:self.ignoreCache];
    }
    
    self.viewGlossaryBtn.title = [NSString stringWithFormat:@"%@(%d)", 
                                  NSLocalizedString(@"Glossary", nil), [self.glossaryManager wordList].count];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIScrollView *scrollView = [self.webView getScrollView];
    [self.scrollPositionDict setValue:[NSString stringWithFormat:@"%f", scrollView.contentOffset.y] 
                               forKey:[SVCodeUtils encodeWithString:self.newsItem.title]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
        if([Player sharedInstance].currentSoundFilePath.length != 0){
            [Player sharedInstance].playing ? [[Player sharedInstance] pause] : [[Player sharedInstance] play];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - events
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.dictionaryName && action == @selector(onDictMenuItemTapped)){
        NSString *selectedText = [self.webView getSelectedText];
        if([selectedText length] != 0){
            return ![SVCommonUtils stringContainsChinese:selectedText];
        }
    }
    BOOL can = [super canPerformAction:action withSender:sender];
    return can;
}

- (void)onDictMenuItemTapped
{
    NSString *selectedText = [self.webView getSelectedText];
    selectedText = [selectedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL multiLine = NO;
    if(selectedText.length > 32){
        multiLine = YES;
    }
    if([selectedText rangeOfString:@" "].length != 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:multiLine ? @"\n\n\n\n" : @"\n" 
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        if(multiLine){
            UIView *bgView = [[[UIView alloc] init] autorelease];
            [alertView addSubview:bgView];
            bgView.frame = CGRectMake(15, 20, 252, 90);
            bgView.backgroundColor = [UIColor whiteColor];
            bgView.layer.cornerRadius = 7.0f;
            
            UITextView *textView = [[[UITextView alloc] init] autorelease];
            [alertView addSubview:textView];
            textView.backgroundColor = [UIColor clearColor];
            textView.tag = 100;
            textView.font = [UIFont systemFontOfSize:16.0f];
            CGFloat marginLeft = 4;
            CGFloat marginTop = 0;
            textView.frame = CGRectMake(bgView.frame.origin.x - marginLeft, 
                                        bgView.frame.origin.y - marginTop, 
                                        bgView.frame.size.width + marginLeft * 2, 
                                        bgView.frame.size.height + marginTop * 2);
            textView.text = selectedText;
            [textView becomeFirstResponder];
        }else{
            UITextField *textField = [[[UITextField alloc] init] autorelease];
            [alertView addSubview:textField];
            textField.tag = 100;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.frame = CGRectMake(15, 20, 252, 30);
            textField.text = selectedText;
            [textField becomeFirstResponder];
        }
        [alertView show];
        [alertView release];
    }else{
        [self searchWordInDictionary:selectedText];
    }
}

- (void)onPreviousBtnTapped:(UIBarButtonItem *)btn
{
    
}

- (void)onDownloadBtnTapped:(UIBarButtonItem *)btn
{
    if(self.newsItem.soundLink.length != 0){
        [self downloadSoundFromURLString:self.newsItem.soundLink];
    }else{
        [self showToastWithString:NSLocalizedString(@"msg_error_data_not_complete", nil) hideAfterInterval:2.0f];
    }
}

- (void)onViewGlossaryBtnTapped
{
    GlossaryLibraryViewController *vc = [[GlossaryLibraryViewController alloc] initWithGlossaryManager:self.glossaryManager];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)n
{
    [self viewWillDisappear:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)n
{
    [self webViewDidFinishLoad:self.webView];
}

- (void)onPlayBtnTapped:(UIBarButtonItem *)btn
{
    if([self isPlayerPlayingCurrent]){
        if([Player sharedInstance].playing){
            [[Player sharedInstance] pause];
        }else{
            [[Player sharedInstance] resume];
            if(self.topControlView.hidden){
                [self setTopControlViewHidden:NO animated:YES];
            }
        }
    }else{
        NSString *filePath = [[SoundCache sharedInstance] filePathForSoundURLString:self.newsItem.soundLink];
        if(filePath){
            [[Player sharedInstance] playSoundAtFilePath:filePath];
        }else{
            [[Player sharedInstance] stop];
            [self downloadSoundFromURLString:self.newsItem.soundLink];
        }
    }
}

- (void)onNextBtnTapped:(UIBarButtonItem *)btn
{
    
}

- (void)onCancelDownloadBtnTapped
{
    [self.httpDownloader cancel];
    
    self.navigationItem.rightBarButtonItem = self.viewGlossaryBtn;
    [self setDownloading:NO];
}

- (void)onPlayerStartPlayNotification:(NSNotification *)notification
{
    [self togglePlayingToolbarItemsWithToolbarState:ToolbarStatePause];
    [SharedResource sharedInstance].currentPlayingNewsItem = self.newsItem;
    [self startTimer];
}

- (void)onPlayerPauseNotification:(NSNotification *)notification
{
    [self togglePlayingToolbarItemsWithToolbarState:ToolbarStatePlaying];
}

- (void)onPlayerStopNotification:(NSNotification *)notification
{
    [self togglePlayingToolbarItemsWithToolbarState:ToolbarStatePlaying];
//    [self setTopControlViewHidden:YES animated:YES];
    [self.timer stop];
    self.currentTimeLabel.text = @"00:00";
    self.positionSilder.value = self.positionSilder.minimumValue;
    [SharedResource sharedInstance].currentPlayingNewsItem = nil;
}

- (void)onPlayerChangeSoundNotification:(NSNotification *)notification
{
    BOOL topControlViewHidden = self.topControlView.hidden;
    [self setTopControlViewHidden:![self isPlayerPlayingCurrent] animated:YES];
    if(topControlViewHidden != self.topControlView.hidden){
        [self updateWebViewPadding];
    }
}

- (void)onPositionSilderDragEnter
{
    self.positionSilderTouching = YES;
}

- (void)onPositionSilderDragExit
{
    self.positionSilderTouching = NO;
    [Player sharedInstance].currentTime = self.positionSilder.value;
    [self updatePositionStatus];
}

- (void)onPositionSilderDragging
{
    NSTimeInterval currentTime = self.positionSilder.value;
    NSInteger minute = currentTime / 60;
    NSInteger second = (NSInteger)currentTime % 60;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@:%@", [SVCommonUtils formatNumber:minute], 
                                  [SVCommonUtils formatNumber:second]];
    
    NSTimeInterval totalTime = [Player sharedInstance].duration;
    minute = totalTime / 60;
    second = (NSInteger)totalTime % 60;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%@:%@", [SVCommonUtils formatNumber:minute], 
                                [SVCommonUtils formatNumber:second]];
}

- (void)onPlayerDidPlayFinishNotification:(NSNotification *)n
{
    [self onPlayBtnTapped:nil];
}


#pragma mark - private methods
- (void)loadContent:(NSString *)content
{
    [self.webView loadHTMLString:content baseURL:nil];
}

- (void)downloadSoundFromURLString:(NSString *)soundURL
{
    [self setDownloading:YES];
    
    self.httpDownloader = [[[SVHTTPDownloader alloc] initWithURLString:soundURL 
                                                          saveToPath:[SharedResource sharedInstance].soundTempFilePath] autorelease];
    self.httpDownloader.delegate = self;
    [self.httpDownloader startDownload];
}

- (UIBarButtonItem *)createFlexibleSpaceBarButtonItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:nil] autorelease];
}

- (void)togglePlayingToolbarItemsWithToolbarState:(ToolbarState)state
{
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    if(state == ToolbarStatePlaying){
//        [toolbarItems addObject:self.previousBtn];
//        [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
        [toolbarItems addObject:self.playBtn];
//        [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
//        [toolbarItems addObject:self.nextBtn];
    }else if(state == ToolbarStatePause){
//        [toolbarItems addObject:self.previousBtn];
//        [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
        [toolbarItems addObject:self.pauseBtn];
//        [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
//        [toolbarItems addObject:self.nextBtn];
    }else if(state == ToolbarStateUndownloaded){
        [toolbarItems addObject:self.downloadBtn];
    }
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    
    self.toolbar.items = toolbarItems;
}

- (void)updatePlayerStatus
{
    Player *player = [Player sharedInstance];
    NSString *soundFilePath = [[SoundCache sharedInstance] filePathForSoundURLString:self.newsItem.soundLink];
    if(player.playing && [player.currentSoundFilePath isEqualToString:soundFilePath]){
        [self togglePlayingToolbarItemsWithToolbarState:ToolbarStatePause];
        [self startTimer];
        self.scrollPercent = player.currentTime / player.duration;
    }else{
        if(soundFilePath){
            // 已经下载
            [self togglePlayingToolbarItemsWithToolbarState:ToolbarStatePlaying];
        }else{
            // 未下载
            [self togglePlayingToolbarItemsWithToolbarState:ToolbarStateUndownloaded];
        }
    }
    [self updatePositionStatus];
}

- (void)updateWebViewPadding
{
    if([self.newsContent length] == 0){
        return;
    }
    BOOL hidden = self.topControlView.hidden;
    CGFloat paddingTop = hidden ? 0.0f : self.topControlView.frame.size.height;
    NSString *js = [NSString stringWithFormat:@"document.body.style.paddingTop='%.0fpx';", paddingTop];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    js = @"document.body.style.fontFamily='Verdana';";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)updatePositionStatus
{
    NSTimeInterval currentTime = [Player sharedInstance].currentTime;
    NSInteger minute = currentTime / 60;
    NSInteger second = (NSInteger)currentTime % 60;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@:%@", [SVCommonUtils formatNumber:minute], 
                                  [SVCommonUtils formatNumber:second]];
    
    NSTimeInterval totalTime = [Player sharedInstance].duration;
    minute = totalTime / 60;
    second = (NSInteger)totalTime % 60;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%@:%@", [SVCommonUtils formatNumber:minute], 
                                [SVCommonUtils formatNumber:second]];
    
    self.positionSilder.minimumValue = 0.0f;
    self.positionSilder.maximumValue = [Player sharedInstance].duration;
    
    if(!self.positionSilderTouching){
        self.positionSilder.value = currentTime;
    }
}

- (BOOL)isPlayerPlayingCurrent
{
    NSString *filePath = [[SoundCache sharedInstance] filePathForSoundURLString:self.newsItem.soundLink];
    if([[Player sharedInstance].currentSoundFilePath isEqualToString:filePath]){
        return YES;
    }
    return NO;
}

- (void)startTimer
{
    if(self.timer){
        [self.timer stop];
        [self.timer cancel];
        self.timer = nil;
    }
    self.timer = [[[SVTimer alloc] init] autorelease];
    self.timer.delegate = self;
    [self.timer startWithTimeInterval:0.50f];
}

- (void)didRecieveNewsItem:(NewsItem *)result
{
    self.newsContent = result.content;
    self.newsItem.soundLink = result.soundLink;
    [self updatePlayerStatus];
    [self loadContent:self.newsContent];
}

- (void)searchWordInDictionary:(NSString *)word
{
    DictionaryViewController *vc = [DictionaryViewController sharedInstance];
    vc.dictionaryViewControllerDelegate = self;
    [self.navigationController presentModalViewController:vc animated:YES];
    [vc query:word];
}

- (void)setTopControlViewHiddenAnimationDidStop
{
    self.topControlView.hidden = YES;
    [self updateWebViewPadding];
}

- (void)setTopControlViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGRect frame = self.topControlView.frame;
    frame.origin.y = !hidden ? -frame.size.height : 0.0f;
    self.topControlView.frame = frame;
    if(!hidden){
        self.topControlView.hidden = NO;
    }
    
    frame.origin.y = hidden ? -frame.size.height : 0.0f;
    
    if(animated){
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        if(hidden){
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(setTopControlViewHiddenAnimationDidStop)];
        }
        [UIView setAnimationDuration:0.27f];
    }else{
        self.topControlView.hidden = hidden;
    }
    self.topControlView.frame = frame;
    if(animated){
        [UIView commitAnimations];
    }
    
    [self updateWebViewPadding];
}

#pragma mark - TimerDelegate
- (void)timer:(SVTimer *)timer timerRunningWithInterval:(CGFloat)interval
{
    if(!self.positionSilderTouching){
        [self updatePositionStatus];
    }
}

- (void)timerDidStart:(SVTimer *)timer
{
}

- (void)timerDidStop:(SVTimer *)timer{
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if(scrollView.contentOffset.y < self.navigationController.navigationBar.bounds.size.height){
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }else{
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.scrollPositionDict setValue:[NSString stringWithFormat:@"%f", scrollView.contentOffset.y] 
                               forKey:[SVCodeUtils encodeWithString:self.newsItem.title]];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        id textField = [alertView viewWithTag:100];
        NSString *selectedText = [textField text];
        selectedText = [selectedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(selectedText.length != 0){
            [self searchWordInDictionary:selectedText];
        }
    }
}

#pragma mark - DictionaryViewControllerDelegate
- (BOOL)dictionaryViewController:(DictionaryViewController *)dictVC bookmarkWord:(NSString *)word
{
    return [self.glossaryManager addWord:word];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setLoading:NO];
    
    [self updateWebViewPadding];
    
    NSString *positionValue = [self.scrollPositionDict valueForKey:[SVCodeUtils encodeWithString:self.newsItem.title]];
    CGPoint position = [webView getScrollView].contentOffset;
    position.y = [positionValue floatValue];
    [webView getScrollView].contentOffset = position;
    
    // 根据播放进度自动滚动新闻（滚动位置暂时有问题）
//    if(self.scrollPercent != 0.0f){
//        UIScrollView *scrollView = [webView scrollView];
//        if(!scrollView){
//            for(UIView *subview in [webView subviews]){
//                if([subview isKindOfClass:[UIScrollView class]]){
//                    scrollView = (id)subview;
//                    break;
//                }
//            }
//        }
//        if(scrollView){
//            CGFloat targetY = (scrollView.contentSize.height + webView.frame.size.height) * self.scrollPercent;
//            [scrollView scrollRectToVisible:CGRectMake(0, targetY, 10, 10) animated:YES];
//        }
//        self.scrollPercent = 0.0f;
//    }
}

#pragma mark - VoaNewsDetailProviderDelegate
- (void)voaNewsContentProvider:(id)provider didRecieveResult:(NewsItem *)result
{
    [self didRecieveNewsItem:result];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsItemDidAddToCacheNotification object:nil];
}

- (void)voaNewsContentProvider:(id)provider didFailedWithError:(NSError *)error
{
    [self setWaiting:NO];
    [self setCenterLabelText:NSLocalizedString(@"unable_to_get_news_detail", nil)];
}

#pragma mark - HTTPDownloaderDelegate
- (void)HTTPDownloaderDidStarted:(SVHTTPDownloader *)downloader
{
    UIBarButtonItem *cancelDownloadBtn = [[[UIBarButtonItem alloc] init] autorelease];
    cancelDownloadBtn.target = self;
    cancelDownloadBtn.action = @selector(onCancelDownloadBtnTapped);
    cancelDownloadBtn.title = NSLocalizedString(@"cancel_download", nil);
    cancelDownloadBtn.style = UIBarButtonItemStyleDone;
    self.navigationItem.rightBarButtonItem = cancelDownloadBtn;
}
- (void)HTTPDownloaderDidFinished:(SVHTTPDownloader *)downloader
{
    [self setDownloading:NO];
    self.navigationItem.rightBarButtonItem = self.viewGlossaryBtn;
    
    // rename sound file
    NSString *newPath = [[SoundCache soundCachePath] stringByAppendingPathComponent:
                         [SVCodeUtils md5ForString:self.newsItem.title]];
    [[NSFileManager defaultManager] moveItemAtPath:[SharedResource sharedInstance].soundTempFilePath 
                                            toPath:newPath 
                                             error:nil];
    
    [[SoundCache sharedInstance] addSoundURLString:downloader.URLString atFilePath:newPath];
    
    [self showToastWithString:NSLocalizedString(@"msg_download_did_finish", nil) hideAfterInterval:2.0f];
//    if(![Player sharedInstance].playing){
//        [self onPlayBtnTapped:self.playBtn];
//    }else{
        [self updatePlayerStatus];
//    }
}
- (void)HTTPDownloader:(SVHTTPDownloader *)downloader didErrored:(NSError *)error
{
    [self setDownloading:NO];
    [self updatePlayerStatus];
    self.navigationItem.rightBarButtonItem = self.viewGlossaryBtn;
    
    [self showToastWithString:NSLocalizedString(@"msg_download_did_fail", nil) hideAfterInterval:2.0f];
}
- (void)HTTPDownloaderDownloading:(SVHTTPDownloader *)downloader downloaded:(long long)downloaded total:(long long)total
{
    [self setDownloadingPercent:(double)downloaded / total];
}

@end
