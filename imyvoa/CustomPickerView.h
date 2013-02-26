//
//  CustomPickerView.h
//  GWRBar
//
//  Created by gewara on 11-12-2.
//  Copyright (c) 2011年 gewara. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomPickerView;

@protocol CustomPickerViewDelegate <NSObject>

@optional
- (void)customPickerViewDidApproved:(CustomPickerView *)pickerView;
- (void)customPickerViewDidCanceled:(CustomPickerView *)pickerView;
- (void)customPickerViewDidAppeared:(CustomPickerView *)pickerView;
- (void)customPickerViewWillAppear:(CustomPickerView *)pickerView;

@end

@interface CustomPickerView : UIView {
    UIPickerView *_pickerView;
    UIToolbar *toolbarTop;
    UILabel *lblTitle;
    id<CustomPickerViewDelegate> _delegate;
    CGFloat bottomEdge;
    BOOL modal;
    UIActivityIndicatorView *indicatorView;
}

@property(nonatomic, assign)id<CustomPickerViewDelegate> delegate;
/**
    bottomEdge:底部边缘，用于设置隐藏时的位置
 */
@property(nonatomic, assign)CGFloat bottomEdge;
@property(nonatomic, retain)UIPickerView *pickerView;
@property(nonatomic, retain)UIActivityIndicatorView *indicatorView;

- (void)setPickerViewDelegate:(id<UIPickerViewDelegate>) delegate;
- (void)setPickerViewDataSource:(id<UIPickerViewDataSource>) dataSource;
- (id<UIPickerViewDelegate>)pickerViewDelegate;
- (id<UIPickerViewDataSource>)pickerViewDataSource;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (void)reloadComponent:(NSInteger)component;
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (void)setTitle:(NSString *)title;
- (void)hide;
- (void)show;
- (void)hideWithAnimation;
- (void)showWithAnimation;
- (void)present;// 模态形式弹出
- (void)setLoading:(BOOL)loading;
@end
