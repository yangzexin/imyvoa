//
//  PluginNavigationController.m
//  imyvoa
//
//  Created by yangzexin on 13-3-19.
//
//

#import "PluginNavigationController.h"
#import "YXOnlineAppBundle.h"
#import "YXTimeCostTracer.h"
#import "YXApp.h"
#import "YXAppManager.h"
#import "YXScriptBundleRepository.h"

@interface PluginNavigationController ()

@property(nonatomic, retain)YXApp *pluginApp;

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
        [YXTimeCostTracer markWithIdentifier:@"load_plugin_app"];
        id<YXScriptBundle> bundle = [[[YXOnlineAppBundle alloc]
                                      initWithURL:[NSURL URLWithString:@"http://imyvoaspecial.googlecode.com/files/com.yzx.imyvoa.plugins.pkg"]] autorelease];
        if(!bundle){
            bundle = [[YXScriptBundleRepository defaultRespository] scriptBundleWithBundleId:@"com.yzx.imyvoa.plugins"];
        }else{
            [[YXScriptBundleRepository defaultRespository] repositScriptBundle:bundle newBundleId:@"com.yzx.imyvoa.plugins"];
        }
        if(bundle){
            YXApp *app = [[[YXApp alloc] initWithScriptBundle:bundle relatedViewController:self] autorelease];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.pluginApp = app;
                [YXTimeCostTracer markWithIdentifier:@"run_app"];
                [YXAppManager runApp:app];
                [YXTimeCostTracer timeCostWithIdentifier:@"run_app" print:YES];
                [YXTimeCostTracer timeCostWithIdentifier:@"load_plugin_app" print:YES];
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
