//
//  LocalNewsListViewController.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "VoaNewsDetailProvider.h"

@interface LocalNewsListViewController : BaseViewController {
    UITableView *_tableView;
    UIBarButtonItem *_sortTypeBtn;
    
    id<VoaNewsDetailProvider> _voaNewsDetailProvider;
    
    NSMutableArray *_sortedNewsItemList;
    
    NSArray *_sortTypeTitleList;
    NSString *_currentSortType;
    BOOL _orderAscend;
}

@end
