//
//  XMMS2RemoteAppDelegate.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright Purple Scout 2010. All rights reserved.
//

#import "XMMS2RemoteAppDelegate.h"
#import "PlaylistViewController.h"
#import "XMMSClient.h"
#import "ServerBrowserController.h"

@implementation XMMS2RemoteAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_navCtrl = [[UINavigationController alloc] initWithRootViewController:nil];
	
	ServerBrowserController *serverBrowser = [ServerBrowserController new];
	[_navCtrl pushViewController:serverBrowser animated:NO];
	
	[window addSubview:_navCtrl.view];
	[window makeKeyAndVisible];

	
	return YES;
}

-(void)dealloc {
    [window release];
    [super dealloc];
}


@end
