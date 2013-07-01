//
//  ViewHTMLViewController.m
//  imyvoa
//
//  Created by gewara on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DictionaryViewController.h"
#import "UIWebViewAdditions.h"
#import "YXCommonUtils.h"
#import "WebViewStackImpl.h"
#import "SharedResource.h"
#import "PlaySoundView.h"
#import "DictionaryFactory.h"
#import "BaseViewController.h"

@interface DictionaryViewController () <UIWebViewDelegate>

@property(nonatomic, retain)UIViewController *dictVC;
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIBarButtonItem *backBtn;
@property(nonatomic, retain)UIBarButtonItem *forwardBtn;
@property(nonatomic, retain)UIBarButtonItem *bookmarkBtn;

@property(nonatomic, retain)id<Dictionary> dictionary;

@property(nonatomic, retain)id<WebViewStack> webViewStack;

@property(nonatomic, retain)PlaySoundView *playSoundView;

- (void)updateBtnStatus;
- (void)query:(NSString *)word pushToStack:(BOOL)pushToStack movePointerToEnd:(BOOL)movePointerToEnd;
- (void)setLoading;
- (void)setNotLoading;
- (UIBarButtonItem *)createFlexibleSpaceBarButtonItem;

@end

@implementation DictionaryViewController

@synthesize dictionaryViewControllerDelegate = _dictionaryViewControllerDelegate;

@synthesize dictVC = _dictVC;
@synthesize webView = _webView;
@synthesize backBtn = _backBtn;
@synthesize forwardBtn = _forwardBtn;
@synthesize bookmarkBtn = _bookmarkBtn;

@synthesize dictionary = _dictionary;

@synthesize webViewStack = _webViewStack;

@synthesize playSoundView;

+ (DictionaryViewController *)sharedInstance
{
    static DictionaryViewController *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[DictionaryViewController alloc] init];
        }
    }
    return instance;
}

- (void)dealloc
{
    [_dictVC release];
    [_webView release];
    [_backBtn release];
    [_forwardBtn release];
    [_bookmarkBtn release];
    
    [_dictionary providerWillRemoveFromPool]; [_dictionary release];
    
    [_webViewStack release];
    
    self.playSoundView = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.webViewStack = [[[WebViewStackImpl alloc] init] autorelease];
    self.dictionary = [DictionaryFactory defaultDictionary];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toolbarHidden = NO;
    self.toolbar.barStyle = self.navigationBar.barStyle;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.toolbar.barStyle = UIBarStyleBlack;
    }
    
    self.dictVC = [[[BaseViewController alloc] init] autorelease];
    self.dictVC.title = [self.dictionary name];
    [self pushViewController:self.dictVC animated:NO];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    self.backBtn = [[[UIBarButtonItem alloc] init] autorelease];
    [toolbarItems addObject:self.backBtn];
    self.backBtn.image = [UIImage imageNamed:@"btn_back"];
    self.backBtn.style = UIBarButtonItemStylePlain;
    self.backBtn.target = self;
    self.backBtn.action = @selector(goBack);
    self.backBtn.enabled = NO;
    
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    self.forwardBtn = [[[UIBarButtonItem alloc] init] autorelease];
    [toolbarItems addObject:self.forwardBtn];
    self.forwardBtn.image = [UIImage imageNamed:@"btn_forward"];
    self.forwardBtn.style = UIBarButtonItemStylePlain;
    self.forwardBtn.target = self;
    self.forwardBtn.action = @selector(goForward);
    self.forwardBtn.enabled = NO;
    
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    UIBarButtonItem *bookmarkBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
                                                                                 target:self 
                                                                                 action:@selector(onBookmarkBtnTapped:)];
    [toolbarItems addObject:bookmarkBtn];
    self.bookmarkBtn = bookmarkBtn;
    [bookmarkBtn release];
    
    [toolbarItems addObject:[self createFlexibleSpaceBarButtonItem]];
    self.dictVC.toolbarItems = toolbarItems;
    
    CGRect frame = self.dictVC.view.bounds;
    
    self.webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    self.webView.opaque = YES;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.webView removeShadow];
    [self.dictVC.view addSubview:self.webView];
    
    self.playSoundView = [[[PlaySoundView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 80, 80)] autorelease];
    self.playSoundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.dictVC.view addSubview:self.playSoundView];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:self 
                                                                             action:@selector(onDoneBtnTapped)];
    self.dictVC.navigationItem.rightBarButtonItem = doneBtn;
    [doneBtn release];
    
    if([self.dictionary name]){
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        NSMutableArray *menuItems = [NSMutableArray arrayWithArray:menuController.menuItems];
        BOOL dictMenuItemExists = NO;
        for(UIMenuItem *menuItem in menuItems){
            if([menuItem.title isEqualToString:[self.dictionary name]]){
                dictMenuItemExists = YES;
                break;
            }
        }
        if(!dictMenuItemExists){
            UIMenuItem *dictMenuItem = [[UIMenuItem alloc] initWithTitle:[self.dictionary name]
                                                                  action:@selector(onDictMenuItemTapped)];
            [menuItems addObject:dictMenuItem];
            [dictMenuItem release];
            menuController.menuItems = menuItems;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bookmarkBtn.enabled = self.dictionaryViewControllerDelegate != nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.dictionaryViewControllerDelegate = nil;
}

#pragma mark - instance methods
- (void)query:(NSString *)word
{
    [self query:word pushToStack:YES movePointerToEnd:YES];
}

- (UIViewController *)dictionaryVC
{
    return self.dictVC;
}

#pragma mark - private methods
- (void)updateBtnStatus
{
    self.backBtn.enabled = [self.webViewStack canBack];
    self.forwardBtn.enabled = [self.webViewStack canForward];
}

- (void)query:(NSString *)word pushToStack:(BOOL)pushToStack movePointerToEnd:(BOOL)movePointerToEnd
{
    self.playSoundView.hidden = NO;
    if(movePointerToEnd){
        [self.webViewStack movePointerToEnd];
    }
    
    if(pushToStack){
        NSString *lastPushed = [self.webViewStack peek];
        if(lastPushed && [lastPushed isEqualToString:word]){
//            NSLog(@"last pushed:%@", lastPushed);
        }else{
            [self.webViewStack push:word];
        }
    }
    
//    id<DictionaryQueryResult> result = [self.dictionary queryFromCache:word];
//    if(result){
//        [self dictionary:self.dictionary didFinishWithResult:result];
//    }else{
        [self setLoading];
        [self.dictionary query:word delegate:self];
//    }
}

- (void)setLoading
{
    [self.dictVC setLoading:YES];
}

- (void)setNotLoadingRun
{
    [self.dictVC setLoading:NO];
}

- (void)setNotLoading
{
    [self performSelector:@selector(setNotLoadingRun) withObject:nil afterDelay:0.10f];
}

- (UIBarButtonItem *)createFlexibleSpaceBarButtonItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:nil] autorelease];
}

#pragma mark - events
- (void)goBack
{
    if([self.webViewStack canBack]){
        NSString *key = [self.webViewStack back];
        [self query:key pushToStack:NO movePointerToEnd:NO];
    }
    
    [self updateBtnStatus];
}

- (void)goForward
{
    if([self.webViewStack canForward]){
        NSString *key = [self.webViewStack forward];
        [self query:key pushToStack:NO movePointerToEnd:NO];
    }
    
    [self updateBtnStatus];
}

- (void)onDoneBtnTapped
{
    self.dictionaryViewControllerDelegate = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.dictionary && action == @selector(onDictMenuItemTapped)){
        NSString *selectedText = [self.webView getSelectedText];
        if([selectedText length] != 0){
            return ![YXCommonUtils stringContainsChinese:selectedText];
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)onDictMenuItemTapped
{
    NSString *selectedWord = [self.webView getSelectedText];
    [self query:selectedWord pushToStack:YES movePointerToEnd:NO];
}

- (void)onBookmarkBtnTapped:(UIBarButtonItem *)btn
{
    NSString *word = [self.webViewStack peek];
    if(word.length == 0){
        return;
    }
    if([self.dictionary queryFromCache:word] == nil){
        NSString *errMsg = NSLocalizedString(@"msg_book_word_failed_not_cached", nil);
        errMsg = [errMsg stringByReplacingOccurrencesOfString:@"$word" withString:word];
        [self showToastWithString:errMsg 
                hideAfterInterval:2.0f];
        return;
    }
    if([self.dictionaryViewControllerDelegate 
        respondsToSelector:@selector(dictionaryViewController:bookmarkWord:)]){
        BOOL succeed = [self.dictionaryViewControllerDelegate dictionaryViewController:self 
                                                                          bookmarkWord:word];
        if(succeed){
            NSString *msg = NSLocalizedString(@"msg_bookmark_word_succeed", nil);
            msg = [msg stringByReplacingOccurrencesOfString:@"$word" withString:word];
            [self showToastWithString:msg 
                    hideAfterInterval:1.0f];
        }else{
            NSString *msg = NSLocalizedString(@"msg_bookmark_word_failed", nil);
            msg = [msg stringByReplacingOccurrencesOfString:@"$word" withString:word];
            [self showToastWithString:msg 
                    hideAfterInterval:1.0f];
        }
    }
}

#pragma mark - DictionaryDelegate
- (void)dictionary:(id)dictionary didFinishWithResult:(id<DictionaryQueryResult>)result
{
    NSString *contentHTML = [result contentHTML];
    if(contentHTML.length != 0){
        self.playSoundView.word = [self.webViewStack peek];
        [self.webView loadHTMLString:contentHTML baseURL:nil];
    }else{
        NSString *errorMsg = [NSLocalizedString(@"word_can_not_found", nil) 
                              stringByReplacingOccurrencesOfString:@"$word" withString:[result word]];
        [self.webViewStack pop];
        NSString *lastWord = [self.webViewStack peek];
        if(lastWord){
            [self showToastWithString:errorMsg hideAfterInterval:2.0f];
            [self query:lastWord pushToStack:NO movePointerToEnd:NO];
            [self updateBtnStatus];
        }else{
            self.playSoundView.hidden = YES;
            [self setNotLoading];
            [self showToastWithString:errorMsg hideAfterInterval:2.0f];
        }
    }
}

- (void)dictionary:(id)dictionary didFailWithError:(NSError *)error
{
    self.playSoundView.hidden = YES;
    [self setNotLoading];
    [self.webView loadHTMLString:nil baseURL:nil];
    [self showToastWithString:NSLocalizedString(@"error_network", nil) hideAfterInterval:2.0f];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setNotLoading];
    
    [self updateBtnStatus];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setNotLoading];
}

@end
