//
//  PlaylistCell.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-03.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "PlaylistCell.h"
#import "NSDictionary+PropDict.h"

@implementation PlaylistCell

@synthesize currentItem = _currentItem;
@synthesize properties = _properties;

-(id)initWithMID:(NSUInteger)mid andPosition:(NSUInteger)position
{
	NSString *ident = [NSString stringWithFormat:@"%d@%d", mid, position];
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
	
	_position = position;
	_properties = nil;
	_currentItem = NO;
	
	self.textLabel.text = ident;
	UIFont *f = [self.textLabel.font fontWithSize:14]; /*FIXME: config value */
	self.textLabel.font = f;
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	self.showsReorderControl = YES;
	
	return self;
}

-(void)setProperties:(NSDictionary*)properties
{
	_properties = properties;
	
	NSString *artist = [_properties propertyObjectForKey:@"artist"];
	if (!artist || [artist length] < 1) {
		artist = @"Unknown";
	}
	
	NSString *title = [_properties propertyObjectForKey:@"title"];
	if (!title || [title length] < 1) {
		title = @"Unknown";
	}
	
	self.textLabel.text = [NSString stringWithFormat:@"%@ - %@", artist, title];
}

-(void)setCurrentItem:(BOOL)current
{
	if (current == _currentItem) {
		return;
	}
	
	_currentItem = current;
	
	if (current) {
		NSLog(@"adding the imageview!");
		self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"current.png"]];
	} else {
		NSLog(@"Removing the imageView");
		[self.accessoryView release];
		self.accessoryView = nil;
	}
	
}

-(void)dealloc
{
	NSLog(@"DEALLOC: PlaylistCell(%d)", _position);
	[_properties release];
	[super dealloc];
}


@end
