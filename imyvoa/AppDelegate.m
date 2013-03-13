//
//  AppDelegate.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/**
    http://imyvoaspecial.googlecode.com/files/version.txt
    http://imyvoaspecial.googlecode.com/files/script.txt
 */

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "NewsListViewController.h"
#import "LocalNewsListViewController.h"
#import "NewsDetailViewController.h"
#import "LuaVoaNewsContentProvider.h"
#import "OnlineDictionary.h"
#import "SVCommonUtils.h"
#import "SVCodeUtils.h"
#import "DictionaryViewController.h"
#import "SVDataBaseKeyValueManager.h"
#import "SVUITools.h"
#import "AllGlossaryViewController.h"
#import "SettingViewController.h"
#import "LINavigationController.h"
#import "SVApp.h"
#import "SVAppManager.h"
#import "SVApplicationScriptBundle.h"
#import "SVLocalAppBundle.h"
#import "SVTimeCostTracer.h"
#import "SVOnlineAppBundle.h"

@interface AppDelegate () <SplashViewControllerDelegate, UITabBarControllerDelegate>

@property(nonatomic, retain)UINavigationController *newsListNC;
@property(nonatomic, retain)UINavigationController *localNewsListNC;
@property(nonatomic, retain)UITabBarController *tabBarController;
@property(nonatomic, retain)SVApp *pluginApp;

@end

@implementation AppDelegate

@synthesize window = _window;

@synthesize newsListNC = _newsListNC;
@synthesize localNewsListNC = _localNewsListNC;
@synthesize tabBarController;

- (void)dealloc
{
    [_window release];
    
    [_newsListNC release];
    [_localNewsListNC release];
    self.tabBarController = nil;
    self.pluginApp = nil;
    [super dealloc];
}

- (void)printEncryptedScript
{
    //NSString *filePath = [[Utils documentPath] stringByAppendingPathComponent:@"common.lua"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"lua"];
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", script);
    NSLog(@"%@", [SVCodeUtils encodeWithString:script]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    SplashViewController *splashVC = [[[SplashViewController alloc] init] autorelease];
    splashVC.delegate = self;
    self.window.rootViewController = splashVC;
    
//    [self printEncryptedScript];
//    NSLog(@"%@", [CodeUtils encodeWithString:@"词典"]);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - events
- (void)onTabToolbarItemTapped:(UIBarButtonItem *)btnItem
{
    NSInteger index = btnItem.tag;
    [self.tabBarController setSelectedIndex:index];
}

#pragma mark - private methods
- (void)configureNavigationBar:(UINavigationBar *)navigationBar
{
//    if([self.newsListNC.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
//        UIImage *img = [UITools createPureColorImageWithColor:[UIColor darkGrayColor] 
//                                                         size:self.newsListNC.navigationBar.frame.size];
//        [navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
//    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (UIBarButtonItem *)createSpaceBtnItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

- (void)configureTabBarController:(UITabBarController *)controller
{
    UITabBar *tabBar = controller.tabBar;
    
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:tabBar.bounds] autorelease];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbarItems addObject:[self createSpaceBtnItem]];
    
    UIBarButtonItem *newsListBtnItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_news_list.png"] 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(onTabToolbarItemTapped:)] autorelease];
    newsListBtnItem.tag = 0;
    [toolbarItems addObject:newsListBtnItem];
    [toolbarItems addObject:[self createSpaceBtnItem]];
    
    UIBarButtonItem *localListBtnItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_local_list.png"] 
                                                                         style:UIBarButtonItemStylePlain 
                                                                        target:self 
                                                                        action:@selector(onTabToolbarItemTapped:)] autorelease];
    localListBtnItem.tag = 1;
    [toolbarItems addObject:localListBtnItem];
    [toolbarItems addObject:[self createSpaceBtnItem]];
    
    toolbar.items = toolbarItems;
    toolbar.opaque = YES;
    [tabBar addSubview:toolbar];
}

#pragma mark - SplashViewControllerDelegate
- (void)splashViewControllerDidFinished:(SplashViewController *)splashVC
{
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.delegate = self;
    
    NewsListViewController *newsListVC = [[[NewsListViewController alloc] init] autorelease];
    self.newsListNC = [[[UINavigationController alloc] initWithRootViewController:newsListVC] autorelease];
//    self.newsListNC.navigationBar.barStyle = UIBarStyleBlack;
    self.newsListNC.title = NSLocalizedString(@"title_news_list", nil);
    self.newsListNC.tabBarItem.image = [UIImage imageNamed:@"icon_news_list"];
    [self configureNavigationBar:self.newsListNC.navigationBar];
    
    LocalNewsListViewController *localNewsListVC 
        = [[[LocalNewsListViewController alloc] init] autorelease];
    self.localNewsListNC = [[[UINavigationController alloc] initWithRootViewController:localNewsListVC] autorelease];
//    self.localNewsListNC.navigationBar.barStyle = UIBarStyleBlack;
    self.localNewsListNC.title = NSLocalizedString(@"title_local_news_list", nil);
    self.localNewsListNC.tabBarItem.image = [UIImage imageNamed:@"icon_local_list"];
    [self configureNavigationBar:self.localNewsListNC.navigationBar];
    
    AllGlossaryViewController *glossaryVC = [[[AllGlossaryViewController alloc] init] autorelease];
    UINavigationController *glossaryNC = [[[UINavigationController alloc] initWithRootViewController:glossaryVC] autorelease];
    glossaryNC.title = NSLocalizedString(@"Glossary", nil);
    glossaryNC.tabBarItem.image = [UIImage imageNamed:@"icon_glossary_list.png"];
    [self configureNavigationBar:glossaryNC.navigationBar];
    
    UINavigationController *pluginNC = [[LINavigationController new] autorelease];
    pluginNC.title = NSLocalizedString(@"Plugins", nil);
    pluginNC.tabBarItem.image = [UIImage imageNamed:@"icon_plugin.png"];
    [self configureNavigationBar:pluginNC.navigationBar];
    
    SettingViewController *settingVC = [[SettingViewController new] autorelease];
    UINavigationController *settingNC = [[[UINavigationController alloc] initWithRootViewController:settingVC] autorelease];
    settingNC.title = NSLocalizedString(@"Settings", nil);
    settingNC.tabBarItem.image = [UIImage imageNamed:@"icon_settings.png"];
    [self configureNavigationBar:settingNC.navigationBar];
    
    tabBarController.viewControllers = [NSArray arrayWithObjects:self.newsListNC, self.localNewsListNC, glossaryNC, pluginNC, settingNC, nil];
    
//    [self configureTabBarController:tabBarController];
    self.window.rootViewController = tabBarController;
    
    if([tabBarController.tabBar respondsToSelector:@selector(setBackgroundImage:)]){
        tabBarController.tabBar.backgroundImage = [SVUITools createPureColorImageWithColor:[UIColor blackColor]
                                                                                    size:CGSizeMake(320, 44.0f)];
    }
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(self.tabBarController.selectedIndex == 3 && self.pluginApp == nil){
        [viewController setLoading:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString *appFilePath = [[NSBundle mainBundle] pathForResource:@"WebBrowser.pkg" ofType:nil];
            [SVTimeCostTracer markWithIdentifier:@"load_plugin_app"];
            id<SVScriptBundle> bundle = [[[SVOnlineAppBundle alloc]
                                          initWithURL:[NSURL URLWithString:@"http://imyvoaspecial.googlecode.com/files/com.yzx.imyvoa.plugins.pkg"]] autorelease];
            if(!bundle){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [viewController setCenterLabelText:@"加载失败"];
                    [viewController setLoading:NO];
                });
                return;
            }
            SVApp *app = [[[SVApp alloc] initWithScriptBundle:bundle relatedViewController:viewController] autorelease];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVTimeCostTracer markWithIdentifier:@"run_app"];
                [SVAppManager runApp:app];
                [SVTimeCostTracer timeCostWithIdentifier:@"run_app" print:YES];
                self.pluginApp = app;
                [SVTimeCostTracer timeCostWithIdentifier:@"load_plugin_app" print:YES];
                [viewController setLoading:NO];
            });
        });
    }
}

@end

//@implementation UINavigationBar (CustomBackground)
//
//- (void)drawRect:(CGRect)rect
//{
//    static UIImage *img = nil;
//    if(img == nil){
//        img = [UITools createPureColorImageWithColor:[UIColor darkGrayColor] 
//                                                size:rect.size];
//    }
//    [img drawInRect:rect];
//}
//
//@end

//@implementation UITabBar (CustomBackground)
//
//- (void)drawRect:(CGRect)rect
//{
//    static UIImage *img = nil;
//    if(img == nil){
//        img = [UITools createPureColorImageWithColor:[UIColor blackColor] 
//                                                size:rect.size];
//    }
//    if(img){
//        [img drawInRect:rect];
//    }
//}

//@end

//@end

#ifdef __IPHONE_6_0
@implementation UINavigationController (AutorotationFix)

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@implementation UITabBarController (AutorotationFix)

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end
#endif
