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
#import "SelectRestoreBackupController.h"

#define kBackupCache            @"备份缓存"
#define kRestoreFromBackup      @"从备份中恢复"
#define kClearNewContentCache   @"清空缓存"
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
    self.sectionDictionary = @{@"1" : @[kBackupCache, kRestoreFromBackup, kClearNewContentCache],
                               @"3" : @[kAboutUs]
                               };
    
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
        [SVAlertDialog showWithTitle:@"清空" message:@"本地缓存的新闻内容将会被全部清空，是否继续？" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
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
        [SVAlertDialog showWithTitle:@"备份" message:@"备份可能需要一段时间，是否继续?" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if(buttonIndex == 1){id<SVZipHandler> zip = [SVZipHandlerFactory defaultZipHandler];
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
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    }else if([field isEqualToString:kRestoreFromBackup]){
        SelectRestoreBackupController *selectRestoreVC = [[SelectRestoreBackupController new] autorelease];
        selectRestoreVC.title = @"恢复缓存";;
        [selectRestoreVC setRestoreHandler:^(NSString *zipFilePath) {
            [selectRestoreVC setWaiting:YES];
            [[NSFileManager defaultManager] removeItemAtPath:[SharedResource sharedInstance].cachePath error:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                id<SVZipHandler> zip = [SVZipHandlerFactory defaultZipHandler];
                [zip unzipWithFilePath:zipFilePath toDirectoryPath:[[SharedResource sharedInstance].cachePath stringByDeletingLastPathComponent]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selectRestoreVC setWaiting:NO];
                    [SVAlertDialog showWithTitle:@"恢复" message:@"恢复成功" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                        [self dismissModalViewControllerAnimated:YES];
                    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
                });
            });
        }];
        UINavigationController *tmpNC = [[[UINavigationController alloc] initWithRootViewController:selectRestoreVC] autorelease];
        tmpNC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:tmpNC animated:YES];
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
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifierDefaultRow];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierDefaultRow] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if([field isEqualToString:kBackupCache]
       || [field isEqualToString:kRestoreFromBackup]
       || [field isEqualToString:kAboutUs]
       || [field isEqualToString:kClearNewContentCache]){
        cell.textLabel.text = field;
    }
    
    return cell;
}

@end
