//
//  XMMSClient.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xmmsclient/xmmsclient.h>
#import "XMMSCollection.h"


@interface XMMSClient : NSObject {
	xmmsc_connection_t *_client;
	NSString *_xmmsPath;
	BOOL _isConnected;
	id _delegate;
	NSMutableArray *_sources;
	xmmsv_t *_defaultOrder;
}

typedef enum _XMMSErrorCode {
	XMMSErrorCodeConnectionFailed,
	XMMSErrorCodeServerError,
	XMMSErrorCodeUnknownError,
	XMMSErrorCodeValueConversionError,
} XMMSErrorCode;

#define XMMSErrorDomain @"org.xmms2.XMMSClient.ErrorDomain"

/* Our notifications */
#define XMMSClientNotificationPlaybackStatus @"org.xmms2.XMMSClient.playback.Status"
#define XMMSClientNotificationPlaybackCurrentID @"org.xmms2.XMMSClient.playback.CurrentID"
#define XMMSClientNotificationPlaylistPosition @"org.xmms2.XMMSClient.playlist.Position"
#define XMMSClientNotificationQuit @"org.xmms2.XMMSClient.Quit"

/* Public API */
+(XMMSClient*)client;
-(id)init;
-(void)connectToPath:(NSString *)path;
+(id)objectWithXMMSV:(xmmsv_t *)value;
+(xmmsv_t*)XMMSVFromObject:(id)object;

/* Private API */
-(void)didConnect;
-(void)errorOnConnect;
+(NSError*)errorWithCode:(XMMSErrorCode)errCode;
+(NSError*)errorFromXMMSV:(xmmsv_t *)value;
+(NSError*)errorWithCode:(XMMSErrorCode)errCode andErrorString:(NSString *)errString;

@property (readonly, nonatomic) xmmsc_connection_t *xmmsConnection;
@property (nonatomic, copy) NSString *xmmsPath;
@property (readonly, nonatomic) BOOL isConnected;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSMutableArray *defaultSources;
@property (nonatomic, readonly, assign) xmmsv_t *defaultOrder;

@end

@interface XMMSConnectOperation : NSOperation
{
	XMMSClient *_client;
}
@end

