//
//  PluginNavigationController.m
//  imyvoa
//
//  Created by yangzexin on 13-3-19.
//
//

#import "PluginNavigationController.h"
#import "SVOnlineAppBundle.h"
#import "SVTimeCostTracer.h"
#import "SVApp.h"
#import "SVAppManager.h"
#import "SVScriptBundleRepository.h"

@interface PluginNavigationController ()

@property(nonatomic, retain)SVApp *pluginApp;

@end

@implementation PluginNavigationController

- (void)dealloc
{
    self.pluginApp = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.pluginApp){
        return;
    }
    static BOOL isLoadingScript = NO;
    if(isLoadingScript){
        return;
    }
    [self setLoading:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SVTimeCostTracer markWithIdentifier:@"load_plugin_app"];
        id<SVScriptBundle> bundle = [[[SVOnlineAppBundle alloc]
                                      initWithURL:[NSURL URLWithString:@"http://1.myvoa.applinzi.com/com.yzx.imyvoa.plugins.pkg"]] autorelease];
        if(!bundle){
            bundle = [[SVScriptBundleRepository defaultRespository] scriptBundleWithBundleId:@"com.yzx.imyvoa.plugins"];
        }else{
            [[SVScriptBundleRepository defaultRespository] repositScriptBundle:bundle newBundleId:@"com.yzx.imyvoa.plugins"];
        }
        if(bundle){
            SVApp *app = [[[SVApp alloc] initWithScriptBundle:bundle relatedViewController:self] autorelease];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.pluginApp = app;
                [SVTimeCostTracer markWithIdentifier:@"run_app"];
                [SVAppManager runApp:app];
                [SVTimeCostTracer timeCostWithIdentifier:@"run_app" print:YES];
                [SVTimeCostTracer timeCostWithIdentifier:@"load_plugin_app" print:YES];
                [self setLoading:NO];
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self setCenterLabelText:@"加载失败，请检查网络连接"];
                [self setLoading:NO];
            });
        }
        isLoadingScript = NO;
    });
}

@end
