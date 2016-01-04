//
//  AppDelegate.m
//  filterVideo
//
//  Created by bd 001 on 12/18/15.
//  Copyright © 2015 bd 001. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
{
    UIView *viewLoadingData;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)ShowLoading
{
    viewLoadingData = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    viewLoadingData.backgroundColor = [UIColor clearColor];
    
    UIView *viewLoadingContainer = [[UIView alloc] initWithFrame:CGRectMake(self.window.frame.origin.x+((self.window.frame.size.width/2)-75), self.window.frame.origin.y+((self.window.frame.size.height/2)-40), 150, 80)];
    viewLoadingContainer.backgroundColor = [UIColor blackColor];
    viewLoadingContainer.layer.cornerRadius = 10.0;
    [viewLoadingData addSubview:viewLoadingContainer];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((viewLoadingContainer.frame.size.width/2)-18.5, (viewLoadingContainer.frame.size.height/2)-18.5, 37, 37)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activityView startAnimating];
    [viewLoadingContainer addSubview:activityView];
    [_window addSubview:viewLoadingData];
}
-(void)HideLoading{
    [viewLoadingData removeFromSuperview];
}


@end
