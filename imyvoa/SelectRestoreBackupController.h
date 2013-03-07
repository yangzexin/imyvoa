//
//  SelectRestoreBackupController.h
//  imyvoa
//
//  Created by yangzexin on 3/7/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@interface SelectRestoreBackupController : BaseTableViewController

@property(nonatomic, copy)void(^restoreHandler)(NSString *zipFilePath);

@end
