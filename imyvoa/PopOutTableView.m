//
//  PopOutTableView.m
//  imyvoa
//
//  Created by yzx on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopOutTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface PopOutTableView () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic)NSInteger insertedIndex;
@property(nonatomic, readonly)UITableViewCell *popOutCell;

@property(nonatomic, retain)UIView *dragView;
@property(nonatomic, retain)UILabel *indicatorLabel;

@end

@implementation PopOutTableView

@synthesize delegate = _delegate;

@synthesize tableView = _tableView;
@synthesize insertedIndex = _insertedIndex;
@synthesize popOutCell = _popOutCell;
@synthesize dragView;
@synthesize indicatorLabel;

- (void)dealloc
{
    [_tableView release];
    [_popOutCell release];
    self.dragView = nil;
    self.indicatorLabel = nil;
    [super dealloc];
}

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.titleDragToTrigger = NSLocalizedString(@"title_drag_to_trigger", nil);
    self.titleReleaseToRefresh = NSLocalizedString(@"title_release_to_refresh", nil);
    
    self.insertedIndex = -1;
    _tappingIndex = -1;
    
    _popOutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                         reuseIdentifier:@"popout"];
    self.popOutCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    
    self.dragView = [[[UIView alloc] init] autorelease];
    self.dragView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    [self addSubview:self.dragView];
    
    self.indicatorLabel = [[[UILabel alloc] init] autorelease];
    self.indicatorLabel.backgroundColor = [UIColor clearColor];
    self.indicatorLabel.textAlignment = UITextAlignmentCenter;
    self.indicatorLabel.font = [UIFont systemFontOfSize:14.0f];
    self.indicatorLabel.text = self.titleDragToTrigger;
    [self.dragView addSubview:self.indicatorLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    
    self.dragView.frame = CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
}

#pragma mark - private methods
- (void)scrollToBottom
{
    NSInteger lastRow = [self tableView:self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath 
                          atScrollPosition:UITableViewScrollPositionTop 
                                  animated:YES];
}

- (void)popOutViewWillShow
{
    if([self.delegate respondsToSelector:@selector(popOutCellWillShowAtPopOutTableView:)]){
        [self.delegate popOutCellWillShowAtPopOutTableView:self];
    }
}

- (void)hidePopOutCell
{
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.23f];
    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:self.insertedIndex inSection:0];
    self.insertedIndex = -1;
    [self.tableView.layer removeAllAnimations];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath] 
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - instance methods
- (NSInteger)selectedCellIndex
{
    if(self.insertedIndex == -1){
        return -1;
    }
    return self.insertedIndex - 1;
}

- (NSInteger)tappingIndex
{
    return _tappingIndex;
}

- (void)addSubviewToPopOutCell:(UIView *)view
{
    [self.popOutCell addSubview:view];
    CGRect frame = self.popOutCell.frame;
    frame.size.height = view.frame.size.height;
    self.popOutCell.frame = frame;
    [self.tableView reloadData];
}

- (void)setHidePopOutCell
{
//    if(self.insertedIndex != -1){
//        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0]];
//    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger targetRow = indexPath.row;
    if(self.insertedIndex != -1){
        if(indexPath.row == self.insertedIndex){
            return self.popOutCell.frame.size.height;
        }else if(indexPath.row > self.insertedIndex){
            --targetRow;
        }
    }
    if([self.delegate respondsToSelector:@selector(popOutTableView:heightForRowAtIndex:)]){
        return [self.delegate popOutTableView:self heightForRowAtIndex:targetRow];
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(popOutCellTableView:shouldShowAtIndex:)]){
        BOOL should = [self.delegate popOutCellTableView:self shouldShowAtIndex:indexPath.row];
        if(!should){
            return;
        }
    }
    if(self.insertedIndex == -1){
        if(indexPath.row + 1 > [self tableView:tableView numberOfRowsInSection:0] - 2){
            [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.01f];
        }
        _tappingIndex = indexPath.row;
        [self.tableView reloadData];
        
        self.insertedIndex = indexPath.row + 1;
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.insertedIndex inSection:0];
        [self popOutViewWillShow];
        [tableView.layer removeAllAnimations];
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }else if(self.insertedIndex == indexPath.row){
        
    }else{
        if(self.insertedIndex - 1 != indexPath.row){
            NSInteger newSelectIndex = indexPath.row;
            if(newSelectIndex > self.insertedIndex){
                --newSelectIndex;
            }
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newSelectIndex inSection:0];
            
            _tappingIndex = -1;
            self.insertedIndex = -1;
            [tableView reloadData];
            
            [self tableView:tableView didSelectRowAtIndexPath:newIndexPath];
        }else{
            _tappingIndex = -1;
            [self.tableView reloadData];
            [self performSelector:@selector(hidePopOutCell) withObject:nil afterDelay:0.02];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nums = 0;
    if([self.delegate respondsToSelector:@selector(numberOfRowsInPopOutTableView:)]){
        nums = [self.delegate numberOfRowsInPopOutTableView:self];
    }
    if(nums == 0){
        return 0;
    }
    if(self.insertedIndex != -1){
        nums += 1;
    }
    return nums;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger targetRow = indexPath.row;
    if(self.insertedIndex != -1){
        if(indexPath.row == self.insertedIndex){
            return self.popOutCell;
        }else if(indexPath.row > self.insertedIndex){
            --targetRow;
        }
    }
    UITableViewCell *cell = [self.delegate popOutTableView:self cellForRowAtIndex:targetRow];
    
    return cell;
}

- (void)updateDragViewYWithScrollY:(CGFloat)y
{
    CGRect tmpRect = self.dragView.frame;
    tmpRect.origin.y = - (self.dragView.frame.size.height + y);
    self.dragView.frame = tmpRect;
    self.indicatorLabel.frame = CGRectMake(0, self.dragView.bounds.size.height - 40.0f, self.dragView.bounds.size.width, self.indicatorLabel.font.lineHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY < 0){
        [self updateDragViewYWithScrollY:offsetY];
    }
    if(offsetY < -60.0f){
        self.indicatorLabel.text = self.titleReleaseToRefresh;
    }else if(self.indicatorLabel.text == self.titleDragToTrigger){
        self.indicatorLabel.text = self.titleDragToTrigger;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([self.indicatorLabel.text isEqualToString:self.titleDragToTrigger]){
        
    }else if([self.indicatorLabel.text isEqualToString:self.titleReleaseToRefresh]){
        if([self.delegate respondsToSelector:@selector(popOutCellTableViewWantToRefreshData:)]){
            [self.delegate popOutCellTableViewWantToRefreshData:self];
        }
        
//        [self.tableView.layer removeAllAnimations];
//        
//        __block typeof(self) bself = self;
//        [UIView animateWithDuration:0.30 animations:^{
//            bself.tableView.contentOffset = CGPointMake(0, 0);
//            bself.dragView.frame = CGRectMake(0, -bself.dragView.bounds.size.height, bself.dragView.bounds.size.width, bself.dragView.bounds.size.height);
//        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.indicatorLabel.text = self.titleDragToTrigger;
}

@end
