/*  XMMS2 - X Music Multiplexer System
 *  Copyright (C) 2003-2009 XMMS2 Team
 *
 *  PLUGINS ARE NOT CONSIDERED TO BE DERIVED WORK !!!
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 */

/** @file
 * Miscellaneous internal utility functions.
 */

#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <time.h>
#include <errno.h>

//#include "xmms_configuration.h"
#include "xmmsc/xmmsc_util.h"

#import <Foundation/Foundation.h>

/**
 * Get the absolute path to the user cache dir.
 * @param buf a char buffer
 * @param len the lenght of buf (PATH_MAX is a good choice)
 * @return A pointer to buf, or NULL if an error occurred.
**/
const char *
xmms_usercachedir_get (char *buf, int len)
{
	NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *path = [[[arr objectAtIndex:0] stringByAppendingPathComponent:@"XMMS2Remote"] stringByAppendingPathComponent:@"bindata"];
	
	return [path UTF8String];
}

/**
 * Get the absolute path to the user config dir.
 *
 * @param buf A char buffer
 * @param len The length of buf (PATH_MAX is a good choice)
 * @return A pointer to buf, or NULL if an error occurred.
 */
const char *
xmms_userconfdir_get (char *buf, int len)
{
	NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *path = [[arr objectAtIndex:0] stringByAppendingPathComponent:@"XMMS2Remote"];
	return [path UTF8String];
}

/**
 * Get the fallback connection path (if XMMS_PATH is not accessible)
 *
 * @param buf A char buffer
 * @param len The length of buf (PATH_MAX is a good choice)
 * @return A pointer to buf, or NULL if an error occured.
 */
const char *
xmms_fallback_ipcpath_get (char *buf, int len)
{
	return "tcp://10.0.42.1";
}

/**
 * Sleep for n milliseconds.
 *
 * @param n The number of milliseconds to sleep.
 * @return true when we waited the full time, false otherwise.
 */
bool
xmms_sleep_ms (int n)
{
	struct timespec sleeptime;

	sleeptime.tv_sec = (time_t) (n / 1000);
	sleeptime.tv_nsec = (n % 1000) * 1000000;

	while (nanosleep (&sleeptime, &sleeptime) == -1) {
		if (errno != EINTR) {
			return false;
		}
	}

	return true;
}
