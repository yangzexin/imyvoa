//
//  GlossaryDetailViewController.m
//  imyvoa
//
//  Created by gewara on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GlossaryDetailViewController.h"
#import "SharedResource.h"
#import "UIWebViewAdditions.h"
#import "PlaySoundView.h"
#import <QuartzCore/QuartzCore.h>
#import "DictionaryViewController.h"
#import "DictionaryFactory.h"

@interface GlossaryDetailViewController () <UIWebViewDelegate, DictionaryDelegate, DictionaryViewControllerDelegate>

@property(nonatomic, retain)NSString *word;
@property(nonatomic, retain)id<Dictionary> dictionary;

@property(nonatomic, retain)UIWebView *webView;

@end

@implementation GlossaryDetailViewController

@synthesize word = _word;
@synthesize dictionary = _dictionary;

@synthesize webView = _webView;

- (void)dealloc
{
    [_word release];
    [_dictionary release];
    
    [_webView release];
    [super dealloc];
}

- (id)initWithWord:(NSString *)word
{
    self = [super init];
    
    self.title = word;
    self.word = word;
    self.dictionary = [DictionaryFactory defaultDictionary];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    
    frame = self.view.bounds;
    self.webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [self.webView removeShadow];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    PlaySoundView *playSoundView = [[[PlaySoundView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 80, 80)] autorelease];
    playSoundView.word = self.word;
    [self.view addSubview:playSoundView];
    
    if([DictionaryFactory defaultDictionary].name){
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        NSMutableArray *menuItems = [NSMutableArray arrayWithArray:menuController.menuItems];
        BOOL dictMenuItemExists = NO;
        for(UIMenuItem *menuItem in menuItems){
            if([menuItem.title isEqualToString:[DictionaryFactory defaultDictionary].name]){
                dictMenuItemExists = YES;
                break;
            }
        }
        if(!dictMenuItemExists){
            UIMenuItem *dictMenuItem = [[UIMenuItem alloc] initWithTitle:[DictionaryFactory defaultDictionary].name
                                                                  action:@selector(onDictMenuItemTapped)];
            [menuItems addObject:dictMenuItem];
            [dictMenuItem release];
            menuController.menuItems = menuItems;
        }
    }
    
    [self.dictionary query:self.word delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)searchWordInDictionary:(NSString *)word
{
    DictionaryViewController *vc = [DictionaryViewController sharedInstance];
    vc.dictionaryViewControllerDelegate = self;
    [self.navigationController presentModalViewController:vc animated:YES];
    [vc query:word];
}

#pragma mark - events
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

#pragma mark - DictionaryDelegate
- (void)dictionary:(id)dictionary didFinishWithResult:(id<DictionaryQueryResult>)result
{
    NSString *html = [result contentHTML];
    if(html.length != 0){
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (void)dictionary:(id)dictionary didFailWithError:(NSError *)error
{
    [self showToastWithString:NSLocalizedString(@"error_network", nil) hideAfterInterval:2.0f];
}

#pragma mark - DictionaryViewControllerDelegate
- (BOOL)dictionaryViewController:(DictionaryViewController *)dictVC bookmarkWord:(NSString *)word
{
    return [self.glossaryManager addWord:word];
}

@end
