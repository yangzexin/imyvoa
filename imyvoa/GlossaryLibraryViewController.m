//
//  GlossaryLibraryViewController.m
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GlossaryLibraryViewController.h"
#import "DictionaryViewController.h"
#import "GlossaryDetailViewController.h"
#import "WordSoundListCache.h"
#import "WordSoundListReader.h"
#import "ApplicationKeeper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface GlossaryLibraryViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain)id<GlossaryManager> glossaryManager;
@property(nonatomic, retain)NSArray *glossaryList;

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)id<WordSoundListReader> wordListReader;

@end

@implementation GlossaryLibraryViewController

@synthesize glossaryManager = _glossaryManager;
@synthesize glossaryList = _glossaryList;

@synthesize tableView = _tableView;

- (void)dealloc
{
    [_glossaryManager release];
    [_glossaryList release];
    
    [_tableView release];
    [self.wordListReader stop];
    [[ApplicationKeeper sharedInstance] stop];
    [super dealloc];
}

- (id)initWithGlossaryManager:(id<GlossaryManager>)glossaryManager
{
    self = [super init];
    
    self.title = NSLocalizedString(@"Glossary", nil);
    
    self.glossaryManager = glossaryManager;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    
    frame = self.view.bounds;
    self.tableView = [[[UITableView alloc] initWithFrame:frame 
                                                   style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *rightButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"recite_words", nil)
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(onReciteWordsButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.glossaryList = self.glossaryManager.wordList;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - private methods
- (void)startReciteWords
{
    if(self.glossaryList.count == 0){
        [[ApplicationKeeper sharedInstance] stop];
        return;
    }
    self.wordListReader = [[[WordSoundListReader alloc] init] autorelease];
    __block typeof(self) bself = self;
    
    // reverse word list
    NSArray *tmpList = [NSArray arrayWithArray:self.glossaryManager.wordList];
    NSMutableArray *tmpGlossaryList = [NSMutableArray array];
    for(NSInteger i = tmpList.count - 1; i > -1; --i){
        [tmpGlossaryList addObject:[tmpList objectAtIndex:i]];
    }
    
    [self.wordListReader playWithWordList:tmpGlossaryList completion:^{
        [bself startReciteWords];
    }];
    [self updateRightButtonItem];
}

#pragma mark - events
- (void)onBackBtnTapped
{
}

- (void)onReciteWordsButtonTapped
{
    if([self.wordListReader playing]){
        [self.wordListReader stop];
        [[ApplicationKeeper sharedInstance] stop];
        [self updateRightButtonItem];
    }else{
        [[ApplicationKeeper sharedInstance] keep];
        [self setWaiting:YES];
        __block typeof(self) bself = self;
        id<WordSoundListCache> listCache = [[[WordSoundListCache alloc] init] autorelease];
        [listCache cacheWordList:[self.glossaryManager wordList] step:^(NSString *word) {
            NSLog(@"caching:%@", word);
            [bself setLoadingText:[NSString stringWithFormat:@"preparing %@", word]];
        } completion:^(NSArray *wordList, NSArray *failureList) {
            NSLog(@"failureList:%@", failureList);
            [bself setWaiting:NO];
            [bself startReciteWords];
        }];
        [self addProviderToPool:listCache];
    }
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeCallback, self);
}

void audioRouteChangeCallback(
                              void *                  inClientData,
                              AudioSessionPropertyID	inID,
                              UInt32                  inDataSize,
                              const void *            inData)
{
    CFDictionaryRef    routeChangeDictionary = inData;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    if(routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable){
        [(id)inClientData onReciteWordsButtonTapped];
    }else if(routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable){
    }
}

- (void)updateRightButtonItem
{
    self.navigationItem.rightBarButtonItem.title = [self.wordListReader playing]
        ? NSLocalizedString(@"stop_play", nil) : NSLocalizedString(@"recite_words", nil);
    self.navigationItem.rightBarButtonItem.style = [self.wordListReader playing]
        ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GlossaryDetailViewController *vc = [[GlossaryDetailViewController alloc] 
                                        initWithWord:[self.glossaryList objectAtIndex:indexPath.row]];
    vc.glossaryManager = self.glossaryManager;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [tableView beginUpdates];
        [self.glossaryManager removeWord:[self.glossaryList objectAtIndex:indexPath.row]];
        self.glossaryList = [self.glossaryManager wordList];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.glossaryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:identifier] autorelease];
    }
    
    cell.textLabel.text = [self.glossaryList objectAtIndex:indexPath.row];
    
    return cell;
}

@end
