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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "xmmsclient/xmmsclient.h"
#include "xmmsclientpriv/xmmsclient.h"
#include "xmmsclientpriv/xmmsclient_ipc.h"
#include "xmmsc/xmmsc_idnumbers.h"
#include "xmmsc/xmmsc_stringport.h"

/** 
 * Add binary data to the servers bindata directory.
 */
xmmsc_result_t *
xmmsc_bindata_add (xmmsc_connection_t *c,
                   const unsigned char *data,
                   unsigned int len)
{
	xmmsc_result_t *res;
	xmmsv_t *bin;

	x_check_conn (c, NULL);

	bin = xmmsv_new_bin (data, len);

	return xmmsc_send_cmd (c, XMMS_IPC_OBJECT_BINDATA, XMMS_IPC_CMD_ADD_DATA,
	                       XMMSV_LIST_ENTRY (bin), XMMSV_LIST_END);
}

/**
 * Retrieve a file from the servers bindata directory,
 * based on the hash.
 */
xmmsc_result_t *
xmmsc_bindata_retrieve (xmmsc_connection_t *c, const char *hash)
{
	x_check_conn (c, NULL);

	return xmmsc_send_cmd (c, XMMS_IPC_OBJECT_BINDATA, XMMS_IPC_CMD_GET_DATA,
	                       XMMSV_LIST_ENTRY_STR (hash), XMMSV_LIST_END);
}

/**
 * Remove a file with associated with the hash from the server
 */
xmmsc_result_t *
xmmsc_bindata_remove (xmmsc_connection_t *c, const char *hash)
{
	x_check_conn (c, NULL);

	return xmmsc_send_cmd (c, XMMS_IPC_OBJECT_BINDATA, XMMS_IPC_CMD_REMOVE_DATA,
	                       XMMSV_LIST_ENTRY_STR (hash), XMMSV_LIST_END);
}

/**
 * List all bindata hashes stored on the server
 */
xmmsc_result_t *
xmmsc_bindata_list (xmmsc_connection_t *c)
{
	x_check_conn (c, NULL);

	return xmmsc_send_cmd (c, XMMS_IPC_OBJECT_BINDATA, XMMS_IPC_CMD_LIST_DATA,
	                       XMMSV_LIST_END);
}
