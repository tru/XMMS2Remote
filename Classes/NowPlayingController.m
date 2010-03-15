//
//  NowPlayingController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-04.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "NowPlayingController.h"


@implementation NowPlayingController

-(id)init
{
	self = [super init];
	
	if (self) {
		self.title = NSLocalizedString(@"Now playing...", nil);
	}
	
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;
}

@end
