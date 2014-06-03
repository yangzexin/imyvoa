//
//  SelectRestoreBackupController.m
//  imyvoa
//
//  Created by yangzexin on 3/7/13.
//
//

#import "SelectRestoreBackupController.h"
#import "SVCommonUtils.h"
#import "SVAlertDialog.h"

@interface SelectRestoreBackupController ()

@property(nonatomic, retain)NSArray *backupFileNameList;

@end

@implementation SelectRestoreBackupController

- (void)dealloc
{
    self.restoreHandler = nil;
    self.backupFileNameList = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(cancelButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"恢复"
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(restoreButtonTapped)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    if(self.backupFileNameList.count == 0){
        NSArray *allFileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SVCommonUtils documentPath] error:nil];
        NSMutableArray *zipFileNameList = [NSMutableArray array];
        for(NSString *fileName in allFileNameList){
            NSString *lowerFileName = [fileName lowercaseString];
            if([lowerFileName hasSuffix:@".zip"] && [lowerFileName hasPrefix:@"backup"]){
                [zipFileNameList addObject:lowerFileName];
            }
        }
        self.backupFileNameList = zipFileNameList;
    }
    self.navigationItem.rightBarButtonItem.enabled = self.backupFileNameList.count != 0;
}

#pragma mark - events
- (void)cancelButtonTapped
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)restoreButtonTapped
{
    if(self.tableView.indexPathForSelectedRow == nil){
        return;
    }
    if(self.restoreHandler){
        [SVAlertDialog showWithTitle:@"警告" message:@"恢复到此缓存会清空当前的所有缓存，是否继续？" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if(buttonIndex == 1){
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                if(indexPath){
                    self.restoreHandler([[SVCommonUtils documentPath] stringByAppendingPathComponent:[self.backupFileNameList objectAtIndex:indexPath.row]]);
                }
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    }
}

#pragma mark - UITableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.backupFileNameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    cell.textLabel.text = [self.backupFileNameList objectAtIndex:indexPath.row];
    
    return cell;
}

@end
