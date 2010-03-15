//
//  XMMS2RemoteAppDelegate.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright Purple Scout 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMMS2RemoteAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *_navCtrl;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

