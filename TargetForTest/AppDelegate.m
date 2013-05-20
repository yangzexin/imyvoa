//
//  AppDelegate.m
//  TargetForTest
//
//  Created by yangzexin on 13-4-26.
//
//

#import "AppDelegate.h"
#import "NewsItem.h"
#import "SVRuntimeUtils.h"
#import "SVSerializationUtils.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NewsItem *item = [[NewsItem new] autorelease];
    item.title = @"news title中文";
    item.content =  @"news content";
    item.soundExists = YES;
    
    NSMutableArray *items = [NSMutableArray array];
    for(NSInteger i = 0; i < 10; ++i){
        NewsItem *tmpItem = [[NewsItem new] autorelease];
        tmpItem.title = [NSString stringWithFormat:@"new title - %0d", i];
        [items addObject:tmpItem];
        if(i % 2 == 0){
            tmpItem.soundExists = YES;
        }
    }
    
    NSString *tmpstring = [SVSerializationUtils stringBySerializingObject:item];
    NSLog(@"%@", [SVRuntimeUtils descriptionOfObject:[SVSerializationUtils objectByDeserializingString:tmpstring objectClass:[NewsItem class]]]);
    
    tmpstring = [SVSerializationUtils stringBySerializingObjects:items];
    NSLog(@"%@", [SVRuntimeUtils descriptionOfObjects:[SVSerializationUtils objectsByDeserializingString:tmpstring objectClass:[NewsItem class]]]);
    
    NSLog(@"%@", [SVSerializationUtils XMLStringBySerializingObject:item]);
    NSLog(@"%@", [SVSerializationUtils XMLStringBySerializingObjects:items]);
    
    NSLog(@"%@", [SVRuntimeUtils propertiesOfObject:item]);
    
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

@end
