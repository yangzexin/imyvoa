//
//  PopOutTableView.h
//  imyvoa
//
//  Created by yzx on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PopOutTableView;

@protocol PopOutTableViewDelegate <NSObject>

@required
- (NSInteger)numberOfRowsInPopOutTableView:(PopOutTableView *)popOutTableView;
- (UITableViewCell *)popOutTableView:(PopOutTableView *)popOutTableView cellForRowAtIndex:(NSInteger)index;

@optional
- (BOOL)popOutCellTableView:(PopOutTableView *)popOutTableView shouldShowAtIndex:(NSInteger)index;
- (void)popOutCellWillShowAtPopOutTableView:(PopOutTableView *)popOutTableView;
- (CGFloat)popOutTableView:(PopOutTableView *)popOutTableView heightForRowAtIndex:(NSInteger)index;
- (void)popOutCellTableViewWantToRefreshData:(PopOutTableView *)popOutTableView;

@end

@interface PopOutTableView : UIView {
@private
    id<PopOutTableViewDelegate> _delegate;
    
    UITableView *_tableView;
    NSInteger _insertedIndex;
    NSInteger _tappingIndex;
    
    UITableViewCell *_popOutCell;
    
}

@property(nonatomic, assign)id<PopOutTableViewDelegate> delegate;

@property(nonatomic, readonly)UITableView *tableView;
@property(nonatomic, copy)NSString *titleDragToTrigger;
@property(nonatomic, copy)NSString *titleReleaseToRefresh;

- (void)addSubviewToPopOutCell:(UIView *)view;

- (NSInteger)selectedCellIndex;
- (NSInteger)tappingIndex;
- (void)setHidePopOutCell;

@end
