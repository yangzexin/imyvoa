//
//  SettingViewController.m
//  imyvoa
//
//  Created by yangzexin on 13-2-4.
//
//

#import "SettingViewController.h"
#import "ContentProviderFactory.h"
#import "SoundCache.h"
#import "SVZipHandler.h"
#import "SVZipHandlerFactory.h"
#import "SVCommonUtils.h"
#import "SVAlertDialog.h"

#define kBackupCache            @"备份缓存"
#define kClearNewContentCache   @"清除新闻内容缓存"
#define kAboutUs                @"关于我们"

@interface SettingViewController ()

@property(nonatomic, retain)NSDictionary *sectionDictionary;

@end

@implementation SettingViewController

- (void)dealloc
{
    self.sectionDictionary = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    self.title = NSLocalizedString(@"Settings", nil);
    self.sectionDictionary = @{@"s1" : @[kBackupCache, kClearNewContentCache, kAboutUs]};
    
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = [self.sectionDictionary objectForKey:[[self.sectionDictionary allKeys] objectAtIndex:indexPath.section]];
    NSString *field = [array objectAtIndex:indexPath.row];
    if([field isEqualToString:kClearNewContentCache]){
        [SVAlertDialog showWithTitle:@"警告" message:@"本地缓存的新闻将会被全部清除，确定要清除吗？" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if(buttonIndex == 1){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    id<VoaNewsDetailProvider> provider = [ContentProviderFactory newsDetailProvider];
                    for(NewsItem *item in [provider localCacheNewsItemList]){
                        if([[SoundCache sharedInstance] filePathForSoundURLString:item.soundLink] == nil){
                            NSLog(@"remove cache item:%@", item.title);
                            [provider removeCacheWithNewsItem:item];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alert:@"清除完毕"];
                    });
                });
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }else if([field isEqualToString:kBackupCache]){
        id<SVZipHandler> zip = [SVZipHandlerFactory defaultZipHandler];
        [self setWaiting:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
            NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *backupFileName = [NSString stringWithFormat:@"backup_%@.zip", [dateFormatter stringFromDate:[[NSDate new] autorelease]]];
            backupFileName = [SVCommonUtils countableTempFileName:backupFileName atDirectory:documentPath];
            [zip zipWithDirectoryPath:[[SharedResource sharedInstance] cachePath]
                           toFilePath:[documentPath stringByAppendingPathComponent:backupFileName]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setWaiting:NO];
                [self alert:[NSString stringWithFormat:@"备份成功, 文件名：%@，可通过iTunes将文件提取出", backupFileName]];
            });
        });
    }else if([field isEqualToString:kAboutUs]){
        NSString *about = [NSString stringWithFormat:@"版本:%@，电子邮箱：yang3800650071@163.com", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        [SVAlertDialog showWithTitle:kAboutUs message:about completion:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionDictionary count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.sectionDictionary objectForKey:[[self.sectionDictionary allKeys] objectAtIndex:section]];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierDefaultRow = @"default_row";
    NSArray *array = [self.sectionDictionary objectForKey:[[self.sectionDictionary allKeys] objectAtIndex:indexPath.section]];
    NSString *field = [array objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    
    if([field isEqualToString:kBackupCache] || [field isEqualToString:kAboutUs] || [field isEqualToString:kClearNewContentCache]){
        cell = [tableView dequeueReusableCellWithIdentifier:identifierDefaultRow];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierDefaultRow] autorelease];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = field;
    }
    
    return cell;
}

@end
