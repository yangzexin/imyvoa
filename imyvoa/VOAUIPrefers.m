//
//  VOAUIPrefers.m
//  imyvoa
//
//  Created by yangzexin on 13-3-13.
//
//

#import "VOAUIPrefers.h"

@implementation VOAUIPrefers

- (id)configureBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    return barButtonItem;
}

-(id)configureButton:(UIButton *)button
{
    return button;
}

- (id)configureImageView:(UIImageView *)imageView
{
    return imageView;
}

- (id)configureLabel:(UILabel *)label
{
    return label;
}

- (id)configureNavigationBar:(UINavigationBar *)navigationBar
{
    navigationBar.tintColor = [UIColor colorWithRed:94.0f/255.0f green:0.0f/255.0f blue:3.0f/255.0f alpha:1.0f];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        navigationBar.barStyle = UIBarStyleBlack;
    }
    return navigationBar;
}

- (id)configureSearchBar:(UISearchBar *)searchBar
{
    return searchBar;
}

- (id)configureSlider:(UISlider *)slider
{
    return slider;
}

- (id)configureTabBar:(UITabBar *)tabbar
{
    return tabbar;
}

- (id)configureTableView:(UITableView *)tableView
{
    return tableView;
}

- (id)configureTableViewCell:(UITableViewCell *)tableViewCell
{
    return tableViewCell;
}

- (id)configureTextField:(UITextField *)textField
{
    return textField;
}

- (id)configureToolbar:(UIToolbar *)toolbar
{
    return toolbar;
}

@end
