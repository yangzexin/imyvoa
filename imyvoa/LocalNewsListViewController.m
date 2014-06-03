//
//  LocalNewsListViewController.m
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocalNewsListViewController.h"
#import "SharedResource.h"
#import "NewsItem.h"
#import "NewsDetailViewController.h"
#import "Utils.h"
#import "NewsItemCell.h"
#import "SoundCache.h"
#import "SVUITools.h"
#import "CustomPickerView.h"
#import "Player.h"
#import "SVAlertDialog.h"
#import "ContentProviderFactory.h"

#define kSortByAddDate NSLocalizedString(@"sort_by_add_date", nil)
#define kSortByDate NSLocalizedString(@"sort_by_date", nil)

#define SORT_TYPE_KEY @"sort_type"
#define SORT_ORDER_KEY @"sort_order"

@interface LocalNewsListViewController () <UITableViewDelegate, 
UITableViewDataSource, 
CustomPickerViewDelegate, 
UIPickerViewDelegate, 
UIPickerViewDataSource
>

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)UIBarButtonItem *sortTypeBtn;

@property(nonatomic, retain)id<VoaNewsDetailProvider> voaNewsDetailProvider;

@property(nonatomic, retain)NSMutableArray *sortedNewsItemList;

@property(nonatomic, retain)NSArray *sortTypeTitleList;
@property(nonatomic, copy)NSString *currentSortType;
@property(nonatomic)BOOL orderAscend;

- (void)readLocalNewsListFromCache;
- (NSMutableArray *)sortNewsList:(NSMutableArray *)newsList;

@end

@implementation LocalNewsListViewController

@synthesize tableView = _tableView;
@synthesize sortTypeBtn = _sortTypeBtn;

@synthesize voaNewsDetailProvider = _voaNewsDetailProvider;

@synthesize sortedNewsItemList = _sortedNewsItemList;

@synthesize sortTypeTitleList = _sortTypeTitleList;
@synthesize currentSortType = _currentSortType;
@synthesize orderAscend = _orderAscend;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [_sortTypeBtn release];
    
    [_voaNewsDetailProvider providerWillRemoveFromPool]; [_voaNewsDetailProvider release];
    
    [_sortTypeTitleList release];
    
    [_sortTypeTitleList release];
    [_currentSortType release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"title_local_news_list", nil);
    self.voaNewsDetailProvider = [ContentProviderFactory newsDetailProvider];
    
    NSMutableArray *sortTypeTitleList = [NSMutableArray array];
    [sortTypeTitleList addObject:kSortByAddDate];
    [sortTypeTitleList addObject:kSortByDate];
    self.sortTypeTitleList = sortTypeTitleList;
    
    self.currentSortType = [[NSUserDefaults standardUserDefaults] objectForKey:SORT_TYPE_KEY];
    if(self.currentSortType == nil){
        self.currentSortType = kSortByAddDate;
    }
    self.orderAscend = [[NSUserDefaults standardUserDefaults] boolForKey:SORT_ORDER_KEY];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    
    frame = self.view.bounds;
    self.tableView = [[[UITableView alloc] initWithFrame:frame] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70.0f;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    UIImage *sortImg = [SVUITools createPureColorImageWithColor:[UIColor darkGrayColor]
                                                         size:CGSizeMake(60, 30)];
    UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpBtn setBackgroundImage:sortImg forState:UIControlStateNormal];
    [tmpBtn setTitle:NSLocalizedString(@"title_sort", nil) forState:UIControlStateNormal];
    tmpBtn.frame = CGRectMake(0, 0, sortImg.size.width, sortImg.size.height);
    [tmpBtn addTarget:self action:@selector(onSortTypeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    tmpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.sortTypeBtn = [[[UIBarButtonItem alloc] initWithCustomView:tmpBtn] autorelease];
    self.sortTypeBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"title_sort", nil) 
                                                        style:UIBarButtonItemStyleBordered 
                                                       target:self
                                                       action:@selector(onSortTypeBtnTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = self.sortTypeBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onNewsItemDidAddToCacheNotification:) 
                                                 name:kNewsItemDidAddToCacheNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readLocalNewsListFromCache];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - private methods
- (void)readLocalNewsListFromCache
{
    NSArray *newsItemList = [self.voaNewsDetailProvider localCacheNewsItemList];
    
    self.sortedNewsItemList = [self sortNewsList:[NSMutableArray arrayWithArray:newsItemList]];
    for(NewsItem *tmpItem in self.sortedNewsItemList){
        tmpItem.soundExists = [[SoundCache sharedInstance] filePathForSoundURLString:tmpItem.soundLink] != nil;
    }
    
    self.sortedNewsItemList = [self filterNewsList:self.sortedNewsItemList];
}

- (NSMutableArray *)filterNewsList:(NSMutableArray *)newsList
{
    NSMutableArray *tmpNewsList = [NSMutableArray array];
    for(NewsItem *tmpItem in newsList){
        if(tmpItem.soundExists){
            [tmpNewsList addObject:tmpItem];
        }
    }
    
    return tmpNewsList;
}

- (NSMutableArray *)sortNewsList:(NSMutableArray *)newsList
{
    if([self.currentSortType isEqualToString:kSortByDate]){
        NSMutableArray *mutableNewsList = [NSMutableArray arrayWithArray:newsList];
        [mutableNewsList sortUsingComparator:^NSComparisonResult(NewsItem *obj1, NewsItem *obj2) {
            NSString *date1 = [Utils formattedDateStringFromNewsItemTitle:obj1.title];
            NSString *date2 = [Utils formattedDateStringFromNewsItemTitle:obj2.title];
            if(date1 != nil && date2 != nil){
                date1 = [date1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
                date2 = [date2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSInteger intDate1 = [date1 intValue];
                NSInteger intDate2 = [date2 intValue];
                if(self.orderAscend){
                    return intDate1 > intDate2 ? NSOrderedDescending : NSOrderedAscending;
                }else{
                    return intDate1 > intDate2 ? NSOrderedAscending : NSOrderedDescending;
                }
            }
            return NSOrderedSame;
        }];
        return mutableNewsList;
    }else if([self.currentSortType isEqualToString:kSortByAddDate]){
        if(!self.orderAscend){
            NSMutableArray *mutableNewsList = [NSMutableArray array];
            for(NSInteger i = newsList.count - 1; i >= 0; --i){
                [mutableNewsList addObject:[newsList objectAtIndex:i]];
            }
            return mutableNewsList;
        }
    }
    
    return newsList;
}

- (void)viewNewsItem:(NewsItem *)item
{
    [self viewNewsItem:item animated:YES];
}

- (void)viewNewsItem:(NewsItem *)item animated:(BOOL)animated
{
    NewsDetailViewController *vc = [[[NewsDetailViewController alloc] initWithNewsItem:item] autorelease];
    vc.ignoreCache = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:animated];
}

#pragma mark - events
- (void)onNewsItemDidAddToCacheNotification:(NSNotification *)notification
{
    [self readLocalNewsListFromCache];
    [self.tableView reloadData];
}

- (void)onSortTypeBtnTapped
{
    CustomPickerView *pickerView = [[[CustomPickerView alloc] init] autorelease];
    pickerView.delegate = self;
    pickerView.pickerView.delegate = self;
    pickerView.pickerView.dataSource = self;
    [pickerView present];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    UINavigationController *firstNavigationController = [self.tabBarController.viewControllers objectAtIndex:0];
    if(firstNavigationController.viewControllers.count == 1 && [Player sharedInstance].playing){
        NewsItem *targetItem = nil;
        for(NewsItem *tmpItem in self.sortedNewsItemList){
            if([[[SoundCache sharedInstance] filePathForSoundURLString:tmpItem.soundLink] isEqualToString:[Player sharedInstance].currentSoundFilePath]){
                targetItem = tmpItem;
                break;
            }
        }
        if(targetItem){
            self.tabBarController.selectedIndex = 1;
            self.navigationController.viewControllers = [NSArray arrayWithObject:self];
            [self viewNewsItem:targetItem animated:NO];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsItem *item = [self.sortedNewsItemList objectAtIndex:indexPath.row];
    [self viewNewsItem:item];
}

- (void)removeItem:(NewsItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.voaNewsDetailProvider removeCacheWithNewsItem:item];
    [self.sortedNewsItemList removeObjectAtIndex:indexPath.row];
    [[SoundCache sharedInstance] removeSoundCacheForSoundURLString:item.soundLink];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsItemDidRemoveFromCacheNotification object:item];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NewsItem *item = [self.sortedNewsItemList objectAtIndex:indexPath.row];
        if([[[SoundCache sharedInstance] filePathForSoundURLString:item.soundLink] isEqualToString:[[Player sharedInstance] currentSoundFilePath]]){
            [SVAlertDialog showWithTitle:@"" message:@"正在播放该新闻，是否停止并删除?" completion:^void(NSInteger buttonIndex, NSString *buttonTitle){
                if(buttonIndex == 1){
                    [[Player sharedInstance] stop];
                    [self removeItem:item atIndexPath:indexPath];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }else{
            [self removeItem:item atIndexPath:indexPath];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedNewsItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"id__";
    NewsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[NewsItemCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                    reuseIdentifier:identifier] autorelease];
    }
    
    NewsItem *item = [self.sortedNewsItemList objectAtIndex:indexPath.row];
    
    [cell setNewsItem:item];
    
    return cell;
}

#pragma mark - CustomPickerViewDelegate
- (void)customPickerViewDidApproved:(CustomPickerView *)pickerView
{
    NSString *selectedSortType = [self.sortTypeTitleList objectAtIndex:[pickerView selectedRowInComponent:0]];
    if([selectedSortType isEqualToString:self.currentSortType]){
        self.orderAscend = !self.orderAscend;
    }else{
        self.orderAscend = NO;
    }
    self.currentSortType = selectedSortType;
    if([self.currentSortType isEqualToString:kSortByAddDate]){
        [self readLocalNewsListFromCache];
    }else{
        self.sortedNewsItemList = [self sortNewsList:self.sortedNewsItemList];
    }
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.currentSortType forKey:SORT_TYPE_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:self.orderAscend forKey:SORT_ORDER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)customPickerViewWillAppear:(CustomPickerView *)pickerView
{
    NSInteger targetIndex = 0;
    for(int i = 0; i < self.sortTypeTitleList.count; ++i){
        if([[self.sortTypeTitleList objectAtIndex:i] isEqualToString:self.currentSortType]){
            targetIndex = i;
            break;
        }
    }
    [pickerView selectRow:targetIndex inComponent:0 animated:NO];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.sortTypeTitleList objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.sortTypeTitleList.count;
}

@end
