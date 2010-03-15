//
//  main.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright Purple Scout 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"XMMS2RemoteAppDelegate");
    [pool release];
    return retVal;
}
