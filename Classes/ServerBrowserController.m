//
//  ServerBrowserController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "ServerBrowserController.h"
#import "XMMSClient.h"
#import "PlaylistViewController.h"

@implementation ServerBrowserController

-(id)init
{
	self = [super init];
	if (self) {
		_servers = [[NSMutableArray alloc] init];
		NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
		browser.delegate = self;
		[browser searchForServicesOfType:@"_xmms2._tcp" inDomain:@"local."];
		self.title = NSLocalizedString(@"XMMS2 servers", nil);
	}
	return self;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[_servers addObject:aNetService];
	[self.tableView reloadData];
}

-(void)loadView
{
	[super loadView];
	_logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	_logoView.frame = CGRectMake(0, 20, 320, 460);
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated
{
	[self.navigationController.view addSubview:_logoView];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5];
	_logoView.alpha = 0.0;
	[UIView commitAnimations];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger pos = [indexPath indexAtPosition:1];
	NSNetService *netService = [_servers objectAtIndex:pos];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[netService name]];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[netService name]];
		cell.textLabel.text = [netService name];
	}
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger pos = [indexPath indexAtPosition:1];
	NSNetService *netService = [_servers objectAtIndex:pos];
	[netService resolveWithTimeout:20];
	netService.delegate = self;
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{	
	NSLog(@"Did resolve address!");
	
	XMMSClient *client = [XMMSClient client];
	client.delegate = self;
	NSString *address = [NSString stringWithFormat:@"tcp://%@", [sender hostName]];
	NSLog(@"Connecting to %@", address);
	[client connectToPath:address];
}

-(void)XMMSClientDidConnect:(XMMSClient*)client
{
	PlaylistViewController *playlistCtrl = [PlaylistViewController new];
	[self.navigationController pushViewController:playlistCtrl animated:YES];
	[playlistCtrl release];
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [_servers count];
}

@end
