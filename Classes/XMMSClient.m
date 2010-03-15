//
//  XMMSClient.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "XMMSClient.h"

unsigned int xmmsc_mainloop_cf_init (xmmsc_connection_t *c, CFRunLoopSourceRef *source);

#pragma mark XMMSConnectOperation

@implementation XMMSConnectOperation

-(id)initWithClient:(XMMSClient*)client
{
	self = [super init];
	_client = client;
	[_client retain];
	return self;
}

-(void)main
{
	NSLog(@"Connecting");
	if (xmmsc_connect(_client.xmmsConnection, [_client.xmmsPath UTF8String])) {
		[_client performSelectorOnMainThread:@selector(didConnect) withObject:nil waitUntilDone:NO];
	} else {
		[_client performSelectorOnMainThread:@selector(errorOnConnect) withObject:nil waitUntilDone:NO];
	}
}

-(void)dealloc
{
	NSLog(@"DEALLOC: XMMSConnectOperation");
	[_client release];
	[super dealloc];
}

@end

#pragma mark broadcast callbacks

static int cb_current_id (xmmsv_t *value, void *udata)
{
	
	XMMSClient *client = udata;
	NSNumber *mid = [XMMSClient objectWithXMMSV:value];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XMMSClientNotificationPlaybackCurrentID 
														object:client
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																mid, @"medialibid", nil]];
	return YES;
}

static int cb_playback_status (xmmsv_t *value, void *udata)
{
	XMMSClient *client = udata;
	NSNumber *status = [XMMSClient objectWithXMMSV:value];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XMMSClientNotificationPlaybackStatus
														object:client
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																status, @"status", nil]];

	
	return YES;
}

static int cb_quit (xmmsv_t *value, void *udata)
{
	XMMSClient *client = udata;
	[[NSNotificationCenter defaultCenter] postNotificationName:XMMSClientNotificationQuit
														object:client];
	return YES;
}

static int cb_current_pos (xmmsv_t *value, void *udata)
{
	XMMSClient *client = udata;
	
	/* contains keys name and position */
	id posDict = [XMMSClient objectWithXMMSV:value];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XMMSClientNotificationPlaylistPosition
														object:client
													  userInfo:posDict];
	return YES;
}


#pragma mark XMMSClient

@implementation XMMSClient

static XMMSClient *__globalClient = NULL;

@synthesize xmmsConnection = _client;
@synthesize xmmsPath = _xmmsPath;
@synthesize isConnected = _isConnected;
@synthesize delegate = _delegate;
@synthesize defaultSources = _sources;
@synthesize defaultOrder = _defaultOrder;


+(XMMSClient*)client
{
	if (!__globalClient) {
		__globalClient = [[XMMSClient alloc] init];
	}
	
	return __globalClient;
}

-(id)init
{
	NSLog(@"Alloc of client");

	self = [super init];
	_client = xmmsc_init("XMMS2Remote");
	_isConnected = NO;
	
	self.defaultSources = [NSMutableArray arrayWithObjects:
						   @"client/XMMSRemote",
						   @"server",
						   @"plugin/*",
						   @"client/*",
						   @"*",
						   nil];
	
	_defaultOrder = xmmsv_new_list();
	xmmsv_list_append(_defaultOrder, xmmsv_new_string("artist"));
	xmmsv_list_append(_defaultOrder, xmmsv_new_string("album"));
	xmmsv_list_append(_defaultOrder, xmmsv_new_string("tracknr"));
	xmmsv_list_append(_defaultOrder, xmmsv_new_string("title"));

	
	return self;
}

-(void)connectToPath:(NSString*)path
{
	if (_isConnected) {
		NSLog(@"Already connected");
		return;
	}
	
	
	/* Not connected. We'll connect with a Operation since it's a blocking call */
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	_xmmsPath = [path retain];
	XMMSConnectOperation *op = [[XMMSConnectOperation alloc] initWithClient:self];
	[queue addOperation:op];
	[op release];
	[queue release];
}

-(void)didConnect
{
	CFRunLoopSourceRef ref;
	
	xmmsc_playback_status(_client);
	if (!xmmsc_mainloop_cf_init(_client, &ref)) {
		NSLog(@"Ouch, cf_init failed!");
	}
	
	_isConnected = YES;
	if ([_delegate respondsToSelector:@selector(XMMSClientDidConnect:)]) {
		[_delegate performSelector:@selector(XMMSClientDidConnect:) withObject:self];
	}
	
	/* set up some callbacks that we want to transmit with notfiers later */
	xmmsc_result_t *res = xmmsc_broadcast_playback_status(_client);
	xmmsc_result_notifier_set(res, cb_playback_status, self);
	xmmsc_result_unref(res);
	
	res = xmmsc_broadcast_quit(_client);
	xmmsc_result_notifier_set(res, cb_quit, self);
	xmmsc_result_unref(res);
	
	res = xmmsc_broadcast_playback_current_id(_client);
	xmmsc_result_notifier_set(res, cb_current_id, self);
	xmmsc_result_unref(res);

	res = xmmsc_broadcast_playlist_current_pos(_client);
	xmmsc_result_notifier_set(res, cb_current_pos, self);
	xmmsc_result_unref(res);
	
	/* we need current id, status and position to start of as well */
	res = xmmsc_playback_current_id(_client);
	xmmsc_result_notifier_set(res, cb_current_id, self);
	xmmsc_result_unref(res);

	res = xmmsc_playlist_current_pos(_client, NULL);
	xmmsc_result_notifier_set(res, cb_current_pos, self);
	xmmsc_result_unref(res);
	
	res = xmmsc_playback_status(_client);
	xmmsc_result_notifier_set(res, cb_playback_status, self);
	xmmsc_result_unref(res);
}

-(void)errorOnConnect
{
	if ([_delegate respondsToSelector:@selector(XMMSClientConnectDidFail:)]) {
		NSError *err = [NSError errorWithDomain:@"org.xmms2" code:1 userInfo:nil];
		[_delegate performSelector:@selector(XMMSClientConnectDidFail:) withObject:err];
	}
}

static void convert_dict (const char *key, xmmsv_t *value, void *userdata)
{
	NSMutableDictionary *dict = (NSMutableDictionary*)userdata;
	id object = [XMMSClient objectWithXMMSV:value];
	if (object) {
		[dict setObject:object forKey:[NSString stringWithUTF8String:key]];
	} else if (!object && key) {
		[dict setObject:@"" forKey:[NSString stringWithUTF8String:key]];
	} else {
		/* No object or key */
		return;
	}
}

+(xmmsv_t*)XMMSVFromObject:(id)object
{
	if ([object isKindOfClass:[NSString class]]) {
		return xmmsv_new_string([object UTF8String]);
	} else if ([object isKindOfClass:[NSArray class]]) {
		xmmsv_t *list = xmmsv_new_list();
		for (id obj in object) {
			xmmsv_list_append(list, [self XMMSVFromObject:obj]);
		}
		return list;
	} else if ([object isKindOfClass:[NSDictionary class]]) {
		xmmsv_t *dict = xmmsv_new_dict();
		for (NSString *key in [object allKeys]) {
			xmmsv_dict_set(dict, [key UTF8String], [self XMMSVFromObject:[object objectForKey:key]]);
		}
		return dict;
	} else if ([object isKindOfClass:[NSNumber class]]) {
		return xmmsv_new_int([object intValue]);
	} else if ([object isKindOfClass:[NSData class]]) {
		return xmmsv_new_bin((unsigned char *)[object bytes], [object count]);
	} else {
		return xmmsv_new_none();
	}
}

+(id)objectWithXMMSV:(xmmsv_t *)value
{
	if (xmmsv_is_error(value)) {
		return [self errorFromXMMSV:value]; 
	}
	
	switch (xmmsv_get_type(value)) {
		case XMMSV_TYPE_INT32:
			{
				int32_t intval;
				
				if (!xmmsv_get_int(value, &intval)) {
					return [self errorWithCode:XMMSErrorCodeValueConversionError];
				}
				
				return [NSNumber numberWithInt:intval];
			}
			break;
		case XMMSV_TYPE_STRING:
			{
				const char *strval;
				if (!xmmsv_get_string(value, &strval)) {
					return [self errorWithCode:XMMSErrorCodeValueConversionError];
				}
				return [NSString stringWithUTF8String:strval];
			}
			break;
		case XMMSV_TYPE_BIN:
			{
				const unsigned char *bindata;
				unsigned int binlen;
				if (!xmmsv_get_bin(value, &bindata, &binlen)) {
					return [self errorWithCode:XMMSErrorCodeValueConversionError];
				}
				return [NSData dataWithBytes:bindata length:binlen];
			}
			break;
		case XMMSV_TYPE_DICT:
			{
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				xmmsv_dict_foreach(value, convert_dict, (void*)dict);
				return [dict autorelease];
			}
			break;
		case XMMSV_TYPE_LIST:
			{
				NSMutableArray *array = [[NSMutableArray alloc] init];
				xmmsv_list_iter_t *iter;
				
				if (!xmmsv_get_list_iter(value, &iter)) {
					return [self errorWithCode:XMMSErrorCodeValueConversionError];
				}
				
				for (xmmsv_list_iter_first(iter);
					 xmmsv_list_iter_valid(iter);
					 xmmsv_list_iter_next(iter)) {
					xmmsv_t *entry;
					
					if (!xmmsv_list_iter_entry(iter, &entry)) {
						return [self errorWithCode:XMMSErrorCodeValueConversionError];
					}
					
					[array addObject:[self objectWithXMMSV:entry]];
				}
				return [array autorelease];
			}
			break;
		case XMMSV_TYPE_NONE:
			NSLog(@"XMMSV_TYPE_NONE?");
			return nil;
		case XMMSV_TYPE_COLL:
			NSLog(@"Won't handle coll yet!");
			return nil;
		case XMMSV_TYPE_ERROR:
			NSLog(@"error?");
			return nil;
			
		default:
			 NSLog(@"Seriously broken xmmsv_t %d", xmmsv_get_type(value));
			 return [self errorWithCode:XMMSErrorCodeValueConversionError];

	}
}

+(NSError*)errorWithCode:(XMMSErrorCode)errCode andErrorString:(NSString*)errString
{
	NSString *localizedError;
	NSString *localizedRecoverySuggestion;
	NSString *localizedRecoveryOptions;
	NSString *tmp;
	
	switch (errCode) {
		case XMMSErrorCodeConnectionFailed:
			localizedError = NSLocalizedString(@"Connection to XMMS2 server failed", nil);
			localizedRecoverySuggestion = NSLocalizedString(@"Try to connect again?", nil);
			localizedRecoveryOptions = NSLocalizedString(@"Try again", nil);
			break;
		case XMMSErrorCodeServerError:
			tmp = NSLocalizedString(@"Error from XMMS2", nil);
			if (errString) {
				localizedError = [tmp stringByAppendingFormat:@": %@", errString];
			} else {
				localizedError = tmp;
			}
			localizedRecoverySuggestion = nil;
			localizedRecoveryOptions = nil;
			break;
		case XMMSErrorCodeValueConversionError:
			localizedError = NSLocalizedString(@"Failed when trying to convert a XMMS2 value", nil);
			localizedRecoverySuggestion = NSLocalizedString(@"Abort?", nil);
			localizedRecoveryOptions = NSLocalizedString(@"Abort?", nil);
			break;			
		case XMMSErrorCodeUnknownError:
		default:
			localizedError = NSLocalizedString(@"Unknown error!", nil);
			localizedRecoverySuggestion = NSLocalizedString(@"Restart application?", nil);
			localizedRecoveryOptions = NSLocalizedString(@"Get me out of here!", nil);
			break;
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  localizedError, NSLocalizedDescriptionKey,
						  localizedRecoverySuggestion, NSLocalizedRecoverySuggestionErrorKey,
						  localizedRecoveryOptions, NSLocalizedRecoveryOptionsErrorKey,
						  nil];
	
	return [NSError errorWithDomain:XMMSErrorDomain code:errCode userInfo:dict];

}

+(NSError*)errorWithCode:(XMMSErrorCode)errCode
{
	return [XMMSClient errorWithCode:errCode andErrorString:nil];
}

+(NSError*)errorFromXMMSV:(xmmsv_t *)value
{
	const char *err;
	
	if (xmmsv_get_error (value, &err)) {
		return [XMMSClient errorWithCode:XMMSErrorCodeServerError andErrorString:[NSString stringWithUTF8String:err]];
	}
	
	return [XMMSClient errorWithCode:XMMSErrorCodeUnknownError];
}

-(void)dealloc
{
	NSLog(@"DEALLOC: XMMSClient");
	xmmsc_unref (_client);
	if (_delegate) {
		[_delegate release];
	}
	[super dealloc];
}

@end
