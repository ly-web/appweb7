/*
    mprSsl.c -- Multithreaded Portable Runtime SSL Source

    This file is a catenation of all the source code. Amalgamating into a
    single file makes embedding simpler and the resulting application faster.

    Prepared by: magnetar.local
 */


/************************************************************************/
/*
    Start of file "src/ssl/matrixssl.c"
 */
/************************************************************************/

/*
    matrixssl.c -- Support for secure sockets via MatrixSSL

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "bit.h"

#if BIT_PACK_MATRIXSSL
/* 
    Work-around to allow the windows 7.* SDK to be used with VS 2013 
 */
#if _MSC_VER >= 1700
    #define SAL_SUPP_H
    #define SPECSTRING_SUPP_H
#endif
/*
    Matrixssl defines int32, uint32, int64 and uint64, but does not provide HAS_XXX to disable. 
    So must include matrixsslApi.h first and then workaround. 
 */
#if WIN32
 #include   <winsock2.h>
 #include   <windows.h>
#endif
 #include    "matrixsslApi.h"

#define     HAS_INT32 1
#define     HAS_UINT32 1
#define     HAS_INT64 1
#define     HAS_UINT64 1

#include    "mpr.h"

/************************************* Defines ********************************/
/*
    Per SSL configuration structure
 */
typedef struct MatrixConfig {
    sslKeys_t       *keys;
    sslSessionId_t  *session;
} MatrixConfig;

/*
    Per socket extended state
 */
typedef struct MatrixSocket {
    MprSocket       *sock;
    ssl_t           *handle;            /* MatrixSSL ssl_t structure */
    char            *outbuf;            /* Pending output data */
    ssize           outlen;             /* Length of outbuf */
    ssize           written;            /* Number of unencoded bytes written */
    int             more;               /* MatrixSSL stack has buffered data */
} MatrixSocket;

/*
    Empty CA cert.
 */
static uchar CAcertSrvBuf[] = { 
    48, 130, 2, 144, 48, 130, 1, 249, 160, 3, 2, 1, 2,
    2, 1, 31, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13,
    1, 1, 5, 5, 0, 48, 129, 129, 49, 35, 48, 33, 6,
    3, 85, 4, 3, 12, 26, 77, 97, 116, 114, 105, 120, 83,
    83, 76, 32, 83, 97, 109, 112, 108, 101, 32, 83, 101, 114,
    118, 101, 114, 32, 67, 65, 49, 11, 48, 9, 6, 3, 85,
    4, 6, 12, 2, 85, 83, 49, 11, 48, 9, 6, 3, 85,
    4, 8, 12, 2, 87, 65, 49, 16, 48, 14, 6, 3, 85,
    4, 7, 12, 7, 83, 101, 97, 116, 116, 108, 101, 49, 31,
    48, 29, 6, 3, 85, 4, 10, 12, 22, 80, 101, 101, 114, 
    83, 101, 99, 32, 78, 101, 116, 119, 111, 114, 107, 115, 44,
    32, 73, 110, 99, 46, 49, 13, 48, 11, 6, 3, 85, 4,
    11, 12, 4, 84, 101, 115, 116, 48, 30, 23, 13, 49, 48,
    48, 51, 48, 50, 49, 55, 49, 57, 48, 55, 90, 23, 13, 
    49, 51, 48, 51, 48, 49, 49, 55, 49, 57, 48, 55, 90,
    48, 129, 129, 49, 35, 48, 33, 6, 3, 85, 4, 3, 12,
    26, 77, 97, 116, 114, 105, 120, 83, 83, 76, 32, 83, 97,
    109, 112, 108, 101, 32, 83, 101, 114, 118, 101, 114, 32, 67,
    65, 49, 11, 48, 9, 6, 3, 85, 4, 6, 12, 2, 85,
    83, 49, 11, 48, 9, 6, 3, 85, 4, 8, 12, 2, 87,
    65, 49, 16, 48, 14, 6, 3, 85, 4, 7, 12, 7, 83,
    101, 97, 116, 116, 108, 101, 49, 31, 48, 29, 6, 3, 85, 
    4, 10, 12, 22, 80, 101, 101, 114, 83, 101, 99, 32, 78,
    101, 116, 119, 111, 114, 107, 115, 44, 32, 73, 110, 99, 46, 
    49, 13, 48, 11, 6, 3, 85, 4, 11, 12, 4, 84, 101,
    115, 116, 48, 129, 159, 48, 13, 6, 9, 42, 134, 72, 134,
    247, 13, 1, 1, 1, 5, 0, 3, 129, 141, 0, 48, 129,
    137, 2, 129, 129, 0, 161, 37, 100, 65, 3, 153, 4, 51,
    190, 127, 211, 25, 110, 88, 126, 201, 223, 171, 11, 203, 100,
    10, 206, 214, 152, 173, 187, 96, 24, 202, 103, 225, 54, 18,
    236, 171, 140, 125, 209, 68, 184, 212, 195, 191, 210, 98, 123,
    237, 205, 213, 23, 209, 245, 108, 70, 236, 20, 25, 140, 68,
    255, 68, 53, 29, 23, 231, 200, 206, 199, 45, 74, 46, 86, 
    10, 229, 243, 126, 72, 33, 184, 21, 16, 76, 55, 28, 97, 
    3, 79, 192, 236, 241, 47, 12, 220, 59, 158, 29, 243, 133,
    125, 83, 30, 232, 243, 131, 16, 217, 8, 2, 185, 80, 197,
    139, 49, 11, 191, 233, 160, 55, 73, 239, 43, 151, 12, 31,
    151, 232, 145, 2, 3, 1, 0, 1, 163, 22, 48, 20, 48,
    18, 6, 3, 85, 29, 19, 1, 1, 1, 4, 8, 48, 6,
    1, 1, 1, 2, 1, 1, 48, 13, 6, 9, 42, 134, 72,
    134, 247, 13, 1, 1, 5, 5, 0, 3, 129, 129, 0, 11,
    36, 231, 0, 168, 211, 179, 52, 55, 21, 63, 125, 230, 86,
    116, 204, 101, 189, 20, 132, 242, 238, 119, 80, 44, 174, 74,
    125, 81, 98, 111, 223, 242, 96, 20, 192, 210, 7, 248, 91,
    101, 37, 85, 46, 0, 132, 72, 12, 21, 100, 132, 5, 122,
    170, 109, 207, 114, 159, 182, 95, 106, 103, 135, 80, 158, 99, 
    44, 126, 86, 191, 79, 126, 249, 99, 3, 18, 40, 128, 21,
    127, 185, 53, 51, 128, 20, 24, 249, 23, 90, 5, 171, 46,
    164, 3, 39, 94, 98, 103, 213, 169, 59, 10, 10, 74, 205,
    201, 16, 116, 204, 66, 111, 187, 36, 87, 144, 81, 194, 26,
    184, 76, 67, 209, 132, 6, 150, 183, 119, 59
};

/***************************** Forward Declarations ***************************/

static void     closeMss(MprSocket *sp, bool gracefully);
static MatrixConfig *createMatrixConfig(MprSsl *ssl);
static void     disconnectMss(MprSocket *sp);
static int      doHandshake(MprSocket *sp, short cipherSuite);
static ssize    flushMss(MprSocket *sp);
static ssize    innerRead(MprSocket *sp, char *userBuf, ssize len);
static int      listenMss(MprSocket *sp, cchar *host, int port, int flags);
static void     manageMatrixSocket(MatrixSocket *msp, int flags);
static void     manageMatrixConfig(MatrixConfig *cfg, int flags);
static ssize    processMssData(MprSocket *sp, char *buf, ssize size, ssize nbytes, int *readMore);
static ssize    readMss(MprSocket *sp, void *buf, ssize len);
static int      upgradeMss(MprSocket *sp, MprSsl *ssl, cchar *peerName);
static int      verifyCert(ssl_t *ssl, psX509Cert_t *cert, int32 alert);
static ssize    writeMss(MprSocket *sp, cvoid *buf, ssize len);

/************************************ Code ************************************/

PUBLIC int mprCreateMatrixSslModule()
{
    MprSocketProvider   *provider;

    if ((provider = mprAllocObj(MprSocketProvider, 0)) == NULL) {
        return MPR_ERR_MEMORY;
    }
    provider->closeSocket = closeMss;
    provider->disconnectSocket = disconnectMss;
    provider->flushSocket = flushMss;
    provider->listenSocket = listenMss;
    provider->readSocket = readMss;
    provider->writeSocket = writeMss;
    provider->upgradeSocket = upgradeMss;
    mprAddSocketProvider("matrixssl", provider);

    if (matrixSslOpen() < 0) {
        return 0;
    }
    return 0;
}


/*
    Initialize the SSL configuration. An application can have multiple different SSL
    configurations for different routes. There is default SSL configuration that is used
    when a route does not define a configuration and also for clients.
 */
static MatrixConfig *createMatrixConfig(MprSsl *ssl)
{
    MatrixConfig    *cfg;
    char            *password;

    assure(ssl);

    if ((ssl->pconfig = mprAllocObj(MatrixConfig, manageMatrixConfig)) == 0) {
        return 0;
    }
    cfg = ssl->pconfig;

    //  OPT - does this need to be done for each MprSsl or just once?
    if (matrixSslNewKeys(&cfg->keys) < 0) {
        mprError("MatrixSSL: Cannot create new MatrixSSL keys");
        return 0;
    }
    /*
        Read the certificate and the key file for this server. FUTURE - If using encrypted private keys, 
        we could prompt through a dialog box or on the console, for the user to enter the password
        rather than using NULL as the password here.
     */
    password = NULL;
    if (matrixSslLoadRsaKeys(cfg->keys, ssl->certFile, ssl->keyFile, password, NULL) < 0) {
        mprError("MatrixSSL: Could not read or decode certificate or key file."); 
        return 0;
    }
    return cfg;
}


static void manageMatrixConfig(MatrixConfig *cfg, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        ;
    } else if (flags & MPR_MANAGE_FREE) {
        if (cfg->keys) {
            matrixSslDeleteKeys(cfg->keys);
            cfg->keys = 0;
        }
        matrixSslClose();
    }
}


static void manageMatrixSocket(MatrixSocket *msp, int flags)
{
    MprSocketService    *ss;

    if (flags & MPR_MANAGE_MARK) {
        mprMark(msp->sock);

    } else if (flags & MPR_MANAGE_FREE) {
        if (msp->handle) {
            matrixSslDeleteSession(msp->handle);
        }
        ss = MPR->socketService;
        mprRemoveItem(ss->secureSockets, msp->sock);
    }
}


/*
    Close the socket
 */
static void closeMss(MprSocket *sp, bool gracefully)
{
    MatrixSocket    *msp;
    uchar           *obuf;
    int             nbytes;

    assure(sp);

    lock(sp);
    msp = sp->sslSocket;
    assure(msp);

    if (!(sp->flags & MPR_SOCKET_EOF) && msp->handle) {
        /*
            Flush data. Append a closure alert to any buffered output data, and try to send it.
            Don't bother retrying or blocking, we're just closing anyway.
         */
        matrixSslEncodeClosureAlert(msp->handle);
        if ((nbytes = matrixSslGetOutdata(msp->handle, &obuf)) > 0) {
            /* Ignore return */
            sp->service->standardProvider->writeSocket(sp, obuf, nbytes);
        }
    }
    sp->service->standardProvider->closeSocket(sp, gracefully);
    unlock(sp);
}


static int listenMss(MprSocket *sp, cchar *host, int port, int flags)
{
    return sp->service->standardProvider->listenSocket(sp, host, port, flags);
}


static int upgradeMss(MprSocket *sp, MprSsl *ssl, cchar *peerName)
{
    MprSocketService    *ss;
    MatrixSocket        *msp;
    MatrixConfig        *cfg;
    uint32              cipherSuite;

    ss = sp->service;
    assure(ss);
    assure(sp);

    if ((msp = (MatrixSocket*) mprAllocObj(MatrixSocket, manageMatrixSocket)) == 0) {
        return MPR_ERR_MEMORY;
    }
    //  MOB - why locking?
    lock(sp);
    msp->sock = sp;
    sp->sslSocket = msp;
    sp->ssl = ssl;

    mprAddItem(ss->secureSockets, sp);

    if (!ssl->pconfig && (ssl->pconfig = createMatrixConfig(ssl)) == 0) {
        unlock(sp);
        return MPR_ERR_CANT_INITIALIZE;
    }
    cfg = ssl->pconfig;

    /* 
        Associate a new ssl session with this socket. The session represents the state of the ssl protocol 
        over this socket. Session caching is handled automatically by this api.
     */
    if (sp->flags & MPR_SOCKET_SERVER) {
        if (matrixSslNewServerSession(&msp->handle, cfg->keys, NULL) < 0) {
            unlock(sp);
            return MPR_ERR_CANT_CREATE;
        }
    } else {
        if (matrixSslLoadRsaKeysMem(cfg->keys, NULL, 0, NULL, 0, CAcertSrvBuf, sizeof(CAcertSrvBuf)) < 0) {
            mprError("MatrixSSL: Could not read or decode certificate or key file."); 
            unlock(sp);
            return MPR_ERR_CANT_INITIALIZE;
        }
        cipherSuite = 0;
        if (matrixSslNewClientSession(&msp->handle, cfg->keys, NULL, cipherSuite, verifyCert, NULL, NULL) < 0) {
            unlock(sp);
            return MPR_ERR_CANT_CONNECT;
        }
        //  MOB - need to verify peerName
        if (doHandshake(sp, 0) < 0) {
            unlock(sp);
            return MPR_ERR_CANT_CONNECT;
        }
    }
    unlock(sp);
    return 0;
}


/*
    Validate certificates
    UGLY: really need a MatrixConfig handle here
 */
static int verifyCert(ssl_t *ssl, psX509Cert_t *cert, int32 alert)
{
    MprSocketService    *ss;
    MprSocket           *sp;
    struct tm           t;
    char                *c;
    int                 next, y, m, d;

    ss = MPR->socketService;
    lock(ss);
    sp = 0;
    for (ITERATE_ITEMS(ss->secureSockets, sp, next)) {
        if (sp->ssl && ((MatrixSocket*) sp->sslSocket)->handle == ssl) {
            break;
        }
    }
    unlock(ss);
    if (!sp) {
        /* Should not get here */
        assure(sp);
        return SSL_ALLOW_ANON_CONNECTION;
    }
    if (alert > 0) {
        if (!sp->ssl->verifyPeer) {
            return SSL_ALLOW_ANON_CONNECTION;
        }
        return alert;
    }
    mprDecodeLocalTime(&t, mprGetTime());

	/* 
        Validate the 'not before' date 
     */
	if ((c = cert->notBefore) != NULL) {
		if (strlen(c) < 8) {
			return PS_FAILURE;
		}
		/* 
            UTCTIME, defined in 1982, has just a 2 digit year 
         */
		if (cert->timeType == ASN_UTCTIME) {
			y =  2000 + 10 * (c[0] - '0') + (c[1] - '0'); 
            c += 2;
		} else {
			y = 1000 * (c[0] - '0') + 100 * (c[1] - '0') + 10 * (c[2] - '0') + (c[3] - '0'); 
            c += 4;
		}
		m = 10 * (c[0] - '0') + (c[1] - '0'); 
        c += 2;
		d = 10 * (c[0] - '0') + (c[1] - '0'); 
        y -= 1900;
        m -= 1;
		if (t.tm_year < y) {
            return PS_FAILURE; 
        }
		if (t.tm_year == y) {
			if (t.tm_mon < m || (t.tm_mon == m && t.tm_mday < d)) {
                mprError("Certificate not yet valid");
                return PS_FAILURE;
            }
		}
	}
	/* 
        Validate the 'not after' date 
     */
	if ((c = cert->notAfter) != NULL) {
		if (strlen(c) < 8) {
			return PS_FAILURE;
		}
		if (cert->timeType == ASN_UTCTIME) {
			y =  2000 + 10 * (c[0] - '0') + (c[1] - '0'); 
            c += 2;
		} else {
			y = 1000 * (c[0] - '0') + 100 * (c[1] - '0') + 10 * (c[2] - '0') + (c[3] - '0'); 
            c += 4;
		}
		m = 10 * (c[0] - '0') + (c[1] - '0'); 
        c += 2;
		d = 10 * (c[0] - '0') + (c[1] - '0'); 
        y -= 1900;
        m -= 1;
		if (t.tm_year > y) {
            return PS_FAILURE; 
        } else if (t.tm_year == y) {
			if (t.tm_mon > m || (t.tm_mon == m && t.tm_mday > d)) {
                mprError("Certificate has expired");
                return PS_FAILURE;
            }
		}
	}
	return PS_SUCCESS;
}


static void disconnectMss(MprSocket *sp)
{
    sp->service->standardProvider->disconnectSocket(sp);
}


static ssize blockingWrite(MprSocket *sp, cvoid *buf, ssize len)
{
    MprSocketProvider   *standard;
    ssize               written, bytes;
    int                 prior;

    standard = sp->service->standardProvider;
    prior = mprSetSocketBlockingMode(sp, 1);
    for (written = 0; len > 0; ) {
        if ((bytes = standard->writeSocket(sp, buf, len)) < 0) {
            mprSetSocketBlockingMode(sp, prior);
            return bytes;
        }
        buf = (char*) buf + bytes;
        len -= bytes;
        written += bytes;
    }
    mprSetSocketBlockingMode(sp, prior);
    return written;
}


/*
    Construct the initial HELLO message to send to the server and initiate
    the SSL handshake. Can be used in the re-handshake scenario as well.
    This is a blocking routine.
 */
static int doHandshake(MprSocket *sp, short cipherSuite)
{
    MatrixSocket    *msp;
    ssize           rc, written, toWrite;
    char            *obuf, buf[BIT_MAX_BUFFER];
    int             mode;

    msp = sp->sslSocket;

    toWrite = matrixSslGetOutdata(msp->handle, (uchar**) &obuf);
    if ((written = blockingWrite(sp, obuf, toWrite)) < 0) {
        mprError("MatrixSSL: Error in socketWrite");
        return MPR_ERR_CANT_INITIALIZE;
    }
    matrixSslSentData(msp->handle, (int) written);
    mode = mprSetSocketBlockingMode(sp, 1);

    while (1) {
        /*
            Reading handshake records should always return 0 bytes, we aren't expecting any data yet.
         */
        if ((rc = innerRead(sp, buf, sizeof(buf))) == 0) {
            if (mprIsSocketEof(sp)) {
                mprSetSocketBlockingMode(sp, mode);
                return MPR_ERR_CANT_INITIALIZE;
            }
            if (matrixSslHandshakeIsComplete(msp->handle)) {
                break;
            }
        } else {
            mprError("MatrixSSL: sslRead error in sslDoHandhake, rc %d", rc);
            mprSetSocketBlockingMode(sp, mode);
            return MPR_ERR_CANT_INITIALIZE;
        }
    }
    mprSetSocketBlockingMode(sp, mode);
    return 0;
}


/*
    Process incoming data. Some is app data, some is SSL control data.
 */
static ssize processMssData(MprSocket *sp, char *buf, ssize size, ssize nbytes, int *readMore)
{
    MatrixSocket    *msp;
    uchar           *data, *obuf;
    ssize           toWrite, written, copied, sofar;
    uint32          dlen;
    int                 rc;

    msp = (MatrixSocket*) sp->sslSocket;
    *readMore = 0;
    sofar = 0;

    /*
        Process the received data. If there is application data, it is returned in data/dlen
     */
    rc = matrixSslReceivedData(msp->handle, (int) nbytes, &data, &dlen);

    while (1) {
        switch (rc) {
        case PS_SUCCESS:
            return sofar;

        case MATRIXSSL_REQUEST_SEND:
            toWrite = matrixSslGetOutdata(msp->handle, &obuf);
            if ((written = blockingWrite(sp, obuf, toWrite)) < 0) {
                mprError("MatrixSSL: Error in process");
                return MPR_ERR_CANT_INITIALIZE;
            }
            matrixSslSentData(msp->handle, (int) written);
            *readMore = 1;
            return 0;

        case MATRIXSSL_REQUEST_RECV:
            /* Partial read. More read data required */
            *readMore = 1;
            msp->more = 1;
            return 0;

        case MATRIXSSL_HANDSHAKE_COMPLETE:
            *readMore = 0;
            return 0;

        case MATRIXSSL_RECEIVED_ALERT:
            assure(dlen == 2);
            if (data[0] == SSL_ALERT_LEVEL_FATAL) {
                return MPR_ERR;
            } else if (data[1] == SSL_ALERT_CLOSE_NOTIFY) {
                //  ignore - graceful close
                return 0;
            } else {
                //  ignore
            }
            rc = matrixSslProcessedData(msp->handle, &data, &dlen);
            break;

        case MATRIXSSL_APP_DATA:
            copied = min((ssize) dlen, size);
            memcpy(buf, data, copied);
            buf += copied;
            size -= copied;
            data += copied;
            dlen = dlen - (int) copied;
            sofar += copied;
            msp->more = ((ssize) dlen > size) ? 1 : 0;
            if (!msp->more) {
                /* The MatrixSSL buffer has been consumed, see if we can get more data */
                rc = matrixSslProcessedData(msp->handle, &data, &dlen);
                break;
            }
            return sofar;

        default:
            return MPR_ERR;
        }
    }
}


/*
    Return number of bytes read. Return -1 on errors and EOF
 */
static ssize innerRead(MprSocket *sp, char *buf, ssize size)
{
    MprSocketProvider   *standard;
    MatrixSocket        *msp;
    uchar               *mbuf;
    ssize               nbytes;
    int                 msize, readMore;

    msp = (MatrixSocket*) sp->sslSocket;
    standard = sp->service->standardProvider;
    do {
        /*
            Get the MatrixSSL read buffer to read data into
         */
        if ((msize = matrixSslGetReadbuf(msp->handle, &mbuf)) < 0) {
            return MPR_ERR_BAD_STATE;
        }
        readMore = 0;
        if ((nbytes = standard->readSocket(sp, mbuf, msize)) > 0) {
            if ((nbytes = processMssData(sp, buf, size, nbytes, &readMore)) > 0) {
                return nbytes;
            }
        }
    } while (readMore);
    return 0;
}


/*
    Return number of bytes read. Return -1 on errors and EOF.
 */
static ssize readMss(MprSocket *sp, void *buf, ssize len)
{
    MatrixSocket    *msp;
    ssize           bytes;

    if (len <= 0) {
        return -1;
    }
    lock(sp);
    bytes = innerRead(sp, buf, len);
    msp = (MatrixSocket*) sp->sslSocket;
    if (msp->more) {
        sp->flags |= MPR_SOCKET_PENDING;
        mprRecallWaitHandlerByFd(sp->fd);
    }
    unlock(sp);
    return bytes;
}


/*
    Non-blocking write data. Return the number of bytes written or -1 on errors.
    Returns zero if part of the data was written.

    Encode caller's data buffer into an SSL record and write to socket. The encoded data will always be 
    bigger than the incoming data because of the record header (5 bytes) and MAC (16 bytes MD5 / 20 bytes SHA1)
    This would be fine if we were using blocking sockets, but non-blocking presents an interesting problem.  Example:

        A 100 byte input record is encoded to a 125 byte SSL record
        We can send 124 bytes without blocking, leaving one buffered byte
        We can't return 124 to the caller because it's more than they requested
        We can't return 100 to the caller because they would assume all data
        has been written, and we wouldn't get re-called to send the last byte

    We handle the above case by returning 0 to the caller if the entire encoded record could not be sent. Returning 
    0 will prompt us to select this socket for write events, and we'll be called again when the socket is writable.  
    We'll use this mechanism to flush the remaining encoded data, ignoring the bytes sent in, as they have already 
    been encoded.  When it is completely flushed, we return the originally requested length, and resume normal 
    processing.
 */
static ssize writeMss(MprSocket *sp, cvoid *buf, ssize len)
{
    MatrixSocket    *msp;
    uchar           *obuf;
    ssize           encoded, nbytes, written;

    msp = (MatrixSocket*) sp->sslSocket;

    while (len > 0 || msp->outlen > 0) {
        if ((encoded = matrixSslGetOutdata(msp->handle, &obuf)) <= 0) {
            if (msp->outlen <= 0) {
                msp->outbuf = (char*) buf;
                msp->outlen = len;
                msp->written = 0;
                len = 0;
            }
            nbytes = min(msp->outlen, SSL_MAX_PLAINTEXT_LEN);
            if ((encoded = matrixSslEncodeToOutdata(msp->handle, (uchar*) buf, (int) nbytes)) < 0) {
                return encoded;
            }
            msp->outbuf += nbytes;
            msp->outlen -= nbytes;
            msp->written += nbytes;
        }
        if ((written = sp->service->standardProvider->writeSocket(sp, obuf, encoded)) < 0) {
            return written;
        } else if (written == 0) {
            break;
        }
        matrixSslSentData(msp->handle, (int) written);
    }
    /*
        Only signify all the data has been written if MatrixSSL has absorbed all the data
     */
    return msp->outlen == 0 ? msp->written : 0;
}


/*
    Blocking flush
 */
static ssize flushMss(MprSocket *sp)
{
    return blockingWrite(sp, 0, 0);
}

#endif /* BIT_PACK_MATRIXSSL */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */

/************************************************************************/
/*
    Start of file "src/ssl/est.c"
 */
/************************************************************************/

/*
    est.c - Embedded Secure Transport

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "mpr.h"

#if BIT_PACK_EST

#include    "est.h"

/************************************* Defines ********************************/
/*
    Per-route SSL configuration
 */
typedef struct EstConfig {
    rsa_context     rsa;                /* RSA context */
    x509_cert       cert;               /* Certificate (own) */
    x509_cert       cabundle;           /* Certificate bundle to veryify peery */
    int             *ciphers;           /* Set of acceptable ciphers */
    char            *dhKey;             /* DH keys */
} EstConfig;

/*
    Per socket state
 */
typedef struct EstSocket {
    MprSocket       *sock;              /* MPR socket object */
    EstConfig       *cfg;               /* Configuration */
    havege_state    hs;                 /* Random HAVEGE state */
    ssl_context     ctx;                /* SSL state */
    ssl_session     session;            /* SSL sessions */
} EstSocket;

static MprSocketProvider *estProvider;  /* EST socket provider */
static EstConfig *defaultEstConfig;     /* Default configuration */

//  MOB - GENERATE
//  #include "est-dh.h"
static char *dhKey =
    "E4004C1F94182000103D883A448B3F80"
    "2CE4B44A83301270002C20D0321CFD00"
    "11CCEF784C26A400F43DFB901BCA7538"
    "F2C6B176001CF5A0FD16D2C48B1D0C1C"
    "F6AC8E1DA6BCC3B4E1F96B0564965300"
    "FFA1D0B601EB2800F489AA512C4B248C"
    "01F76949A60BB7F00A40B1EAB64BDD48" 
    "E8A700D60B7F1200FA8E77B0A979DABF";

static char *dhg = "4";

//  MOB - push into ets

//MOB http://www.iana.org/assignments/tls-parameters/tls-parameters.xml

typedef struct Ciphers {
    int     code;
    char    *name;
    int     iana;
} Ciphers;

/** MOB - should have a high security and a fast security list */
static Ciphers cipherList[] = {
{ 0x2F, "TLS_RSA_WITH_AES_128_CBC_SHA",          TLS_RSA_WITH_AES_128_CBC_SHA           },
{ 0x35, "TLS_RSA_WITH_AES_256_CBC_SHA",          TLS_RSA_WITH_AES_256_CBC_SHA           },
{ 0x05, "TLS_RSA_WITH_RC4_128_SHA",              TLS_RSA_WITH_RC4_128_SHA               },      /* MED */
{ 0x0A, "TLS_RSA_WITH_3DES_EDE_CBC_SHA",         TLS_RSA_WITH_3DES_EDE_CBC_SHA          },
{ 0x04, "TLS_RSA_WITH_RC4_128_MD5",              TLS_RSA_WITH_RC4_128_MD5               },      /* MED */
{ 0x39, "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",      TLS_DHE_RSA_WITH_AES_256_CBC_SHA       },
{ 0x16, "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA",     TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA      },

#if UNUSED
{ 0x41, "TLS_RSA_WITH_CAMELLIA_128_CBC_SHA",     TLS_RSA_WITH_CAMELLIA_128_CBC_SHA      },
{ 0x88, "TLS_RSA_WITH_CAMELLIA_256_CBC_SHA",     TLS_RSA_WITH_CAMELLIA_256_CBC_SHA      },
{ 0x84, "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA", TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA  },
#endif
{ 0x00, 0, 0 },
};

static MprList *sessions;

/***************************** Forward Declarations ***************************/

static void     closeEst(MprSocket *sp, bool gracefully);
static void     disconnectEst(MprSocket *sp);
static void     estTrace(void *fp, int level, char *str);
static int      estHandshake(MprSocket *sp);
static char     *getEstState(MprSocket *sp);
static int      listenEst(MprSocket *sp, cchar *host, int port, int flags);
static void     manageEstConfig(EstConfig *cfg, int flags);
static void     manageEstProvider(MprSocketProvider *provider, int flags);
static void     manageEstSocket(EstSocket *ssp, int flags);
static ssize    readEst(MprSocket *sp, void *buf, ssize len);
static int      upgradeEst(MprSocket *sp, MprSsl *sslConfig, cchar *peerName);
static ssize    writeEst(MprSocket *sp, cvoid *buf, ssize len);

static int      setSession(ssl_context *ssl);
static int      getSession(ssl_context *ssl);

/************************************* Code ***********************************/
/*
    Create the Openssl module. This is called only once
    MOB - should this be Create or Open
 */
PUBLIC int mprCreateEstModule()
{
    if ((estProvider = mprAllocObj(MprSocketProvider, manageEstProvider)) == NULL) {
        return MPR_ERR_MEMORY;
    }
    estProvider->upgradeSocket = upgradeEst;
    estProvider->closeSocket = closeEst;
    estProvider->disconnectSocket = disconnectEst;
    estProvider->listenSocket = listenEst;
    estProvider->readSocket = readEst;
    estProvider->writeSocket = writeEst;
    estProvider->socketState = getEstState;
    mprAddSocketProvider("est", estProvider);
    sessions = mprCreateList(-1, -1);

    if ((defaultEstConfig = mprAllocObj(EstConfig, manageEstConfig)) == 0) {
        return MPR_ERR_MEMORY;
    }
    defaultEstConfig->dhKey = dhKey;
    return 0;
}


static void manageEstProvider(MprSocketProvider *provider, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(defaultEstConfig);
        mprMark(sessions);
    }
}


static void manageEstConfig(EstConfig *cfg, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(cfg->ciphers);

    } else if (flags & MPR_MANAGE_FREE) {
        rsa_free(&cfg->rsa);
        x509_free(&cfg->cert);
        x509_free(&cfg->cabundle);
    }
}


/*
    Destructor for an EstSocket object
 */
static void manageEstSocket(EstSocket *est, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(est->cfg);
        mprMark(est->sock);

    } else if (flags & MPR_MANAGE_FREE) {
        ssl_free(&est->ctx);
    }
}


static void closeEst(MprSocket *sp, bool gracefully)
{
    EstSocket       *est;

    est = sp->sslSocket;
    if (!(sp->flags & MPR_SOCKET_EOF)) {
        ssl_close_notify(&est->ctx);
    }
    sp->service->standardProvider->closeSocket(sp, gracefully);
}


/*
    Initialize a new server-side connection
 */
static int listenEst(MprSocket *sp, cchar *host, int port, int flags)
{
    assure(sp);
    assure(port);
    return sp->service->standardProvider->listenSocket(sp, host, port, flags);
}


//  MOB - move to est
static int *createCiphers(cchar *cipherSuite)
{
    Ciphers     *cp;
    char        *suite, *cipher, *next;
    int         nciphers, i, *ciphers;

    nciphers = sizeof(cipherList) / sizeof(Ciphers);
    ciphers = mprAlloc((nciphers + 1) * sizeof(int));
   
    suite = sclone(cipherSuite);
    i = 0;
    while ((cipher = stok(suite, ":, \t", &next)) != 0) {
        for (cp = cipherList; cp->name; cp++) {
            if (scaselessmatch(cp->name, cipher)) {
                break;
            }
        }
        if (cp) {
            ciphers[i++] = cp->iana;
            mprLog(0, "EST: Select cipher 0x%02x: %s", cp->iana, cp->name);
        } else {
            mprLog(0, "Requested cipher %s is not supported", cipher);
        }
        suite = 0;
    }
    if (i == 0) {
        for (i = 0; i < nciphers; i++) {
            ciphers[i] = ssl_default_ciphers[i];
        }
        ciphers[i] = 0;
    }
    return ciphers;
}


/*
    Initiate or continue SSL handshaking with the peer. This routine does not block.
    Return -1 on errors, 0 incomplete and awaiting I/O, 1 if successful
 */
static int estHandshake(MprSocket *sp)
{
    EstSocket   *est;
    int         rc, vrc, trusted;

    est = (EstSocket*) sp->sslSocket;
    trusted = 1;

    while (est->ctx.state != SSL_HANDSHAKE_OVER && (rc = ssl_handshake(&est->ctx)) != 0) {
        if (rc == EST_ERR_NET_TRY_AGAIN) {
            if (!mprGetSocketBlockingMode(sp)) {
                return 0;
            }
            continue;
        }
        break;
    }
    /*
        Analyze the handshake result
     */
    if (rc < 0) {
        sp->errorMsg = sfmt("Cannot handshake: error -0x%x", -rc);
        mprLog(4, "%s", sp->errorMsg);
        sp->flags |= MPR_SOCKET_EOF;
        errno = EPROTO;
        return -1;
       
    } else if ((vrc = ssl_get_verify_result(&est->ctx)) != 0) {
        if (vrc & BADCERT_EXPIRED) {
            sp->errorMsg = sfmt("Certificate expired");

        } else if (vrc & BADCERT_REVOKED) {
            sp->errorMsg = sfmt("Certificate revoked");

        } else if (vrc & BADCERT_CN_MISMATCH) {
            sp->errorMsg = sfmt("Certificate common name mismatch");

        } else if (vrc & BADCERT_NOT_TRUSTED) {
            if (est->ctx.peer_cert->next && est->ctx.peer_cert->next->version == 0) {
                //  MOB - est should have dedicated EST error code for this.
                sp->errorMsg = sfmt("Self-signed certificate");
            } else {
                sp->errorMsg = sfmt("Certificate not trusted");
            }
            trusted = 0;

        } else {
            if (est->ctx.client_auth && !sp->ssl->certFile) {
                sp->errorMsg = sfmt("Server requires a client certificate");
            } else if (rc == EST_ERR_NET_CONN_RESET) {
                sp->errorMsg = sfmt("Peer disconnected");
            } else {
                sp->errorMsg = sfmt("Cannot handshake: error -0x%x", -rc);
            }
        }
        mprLog(4, "%s", sp->errorMsg);
        if (sp->ssl->verifyPeer) {
            /* 
               If not verifying the issuer, permit certs that are only untrusted (no other error).
               This allows self-signed certs.
             */
            if (!sp->ssl->verifyIssuer && !trusted) {
                return 1;
            } else {
                sp->flags |= MPR_SOCKET_EOF;
                errno = EPROTO;
                return -1;
            }
        }
    }
    return 1;
}


/*
    Upgrade a standard socket to use TLS
 */
static int upgradeEst(MprSocket *sp, MprSsl *ssl, cchar *peerName)
{
    EstSocket   *est;
    EstConfig   *cfg;
    int         verifyMode;

    assure(sp);

    if (ssl == 0) {
        ssl = mprCreateSsl(sp->flags & MPR_SOCKET_SERVER);
    }
    if ((est = (EstSocket*) mprAllocObj(EstSocket, manageEstSocket)) == 0) {
        return MPR_ERR_MEMORY;
    }
    est->sock = sp;
    sp->sslSocket = est;
    sp->ssl = ssl;

    lock(ssl);
    if (ssl->pconfig) {
        est->cfg = cfg = ssl->pconfig;
    } else {
        /*
            One time setup for the SSL configuration for this MprSsl
         */
        if ((cfg = mprAllocObj(EstConfig, manageEstConfig)) == 0) {
            unlock(ssl);
            return MPR_ERR_MEMORY;
        }
        est->cfg = ssl->pconfig = cfg;
        if (ssl->certFile) {
            //  MOB - openssl uses encrypted and/not 
            if (x509parse_crtfile(&cfg->cert, ssl->certFile) != 0) {
                sp->errorMsg = sfmt("Unable to parse certificate %s", ssl->certFile); 
                unlock(ssl);
                return MPR_ERR_CANT_READ;
            }
        }
        if (ssl->keyFile) {
            //  MOB - last arg is password
            if (x509parse_keyfile(&cfg->rsa, ssl->keyFile, 0) != 0) {
                sp->errorMsg = sfmt("Unable to parse key file %s", ssl->keyFile); 
                unlock(ssl);
                return MPR_ERR_CANT_READ;
            }
        }
        if (ssl->caFile) {
            if (x509parse_crtfile(&cfg->cabundle, ssl->caFile) != 0) {
                sp->errorMsg = sfmt("Unable to parse certificate bundle %s", ssl->caFile); 
                unlock(ssl);
                return MPR_ERR_CANT_READ;
            }
        }
        cfg->dhKey = defaultEstConfig->dhKey;
        //  MOB - see openssl for client certificate config
        cfg->ciphers = createCiphers(ssl->ciphers);
    }
    unlock(ssl);
    ssl_free(&est->ctx);

    //  MOB - convert to proper entropy source API
    //  MOB - can't put this in cfg yet as it is not thread safe
    havege_init(&est->hs);
    ssl_init(&est->ctx);
	ssl_set_endpoint(&est->ctx, sp->flags & MPR_SOCKET_SERVER ? SSL_IS_SERVER : SSL_IS_CLIENT);

    /* Optional means to manually verify in estHandshake */
    if (sp->flags & MPR_SOCKET_SERVER) {
        verifyMode = ssl->verifyPeer ? SSL_VERIFY_OPTIONAL : SSL_VERIFY_NO_CHECK;
    } else {
        verifyMode = SSL_VERIFY_OPTIONAL;
    }
    ssl_set_authmode(&est->ctx, verifyMode);
    ssl_set_rng(&est->ctx, havege_rand, &est->hs);
	ssl_set_dbg(&est->ctx, estTrace, NULL);
	ssl_set_bio(&est->ctx, net_recv, &sp->fd, net_send, &sp->fd);

    //  MOB - better if the API took a handle (est)
	ssl_set_scb(&est->ctx, getSession, setSession);
    ssl_set_ciphers(&est->ctx, cfg->ciphers);

	ssl_set_session(&est->ctx, 1, 0, &est->session);
	memset(&est->session, 0, sizeof(ssl_session));

	ssl_set_ca_chain(&est->ctx, &cfg->cabundle, (char*) peerName);
	ssl_set_own_cert(&est->ctx, &cfg->cert, &cfg->rsa);
	ssl_set_dh_param(&est->ctx, dhKey, dhg);

    if (estHandshake(sp) < 0) {
        return -1;
    }
    return 0;
}


static void disconnectEst(MprSocket *sp)
{
    sp->service->standardProvider->disconnectSocket(sp);
}


//  MOB - move to est
static void traceCert(MprSocket *sp)
{
    EstSocket   *est;
    Ciphers     *cp;
    char        cbuf[5120];
   
    est = (EstSocket*) sp->sslSocket;

    if (est->ctx.session) {
        for (cp = cipherList; cp->name; cp++) {
            if (cp->iana == est->ctx.session->cipher) {
                break;
            }
        }
        if (cp) {
            mprLog(4, "EST connected using cipher: %s, %x", cp->name, est->ctx.session->cipher);
        }
    }
    if (sp->ssl->caFile) {
        mprLog(4, "Using certificates from %s", sp->ssl->caFile);
    } else if (sp->ssl->caPath) {
        mprLog(4, "Using certificates from directory %s", sp->ssl->caPath);
    }
    if (!est->ctx.peer_cert) {
        mprLog(4, "Client supplied no certificate");
    } else {
        mprLog(4, "Client certificate: %s", x509parse_cert_info("", cbuf, sizeof(cbuf), est->ctx.peer_cert));
    }
}


/*
    Return the number of bytes read. Return -1 on errors and EOF. Distinguish EOF via mprIsSocketEof.
    If non-blocking, may return zero if no data or still handshaking.
 */
static ssize readEst(MprSocket *sp, void *buf, ssize len)
{
    EstSocket   *est;
    int         rc;

    est = (EstSocket*) sp->sslSocket;
    assure(est);
    assure(est->cfg);

    if (est->ctx.state != SSL_HANDSHAKE_OVER) {
        if ((rc = estHandshake(sp)) <= 0) {
            return rc;
        }
    }
    if (!(sp->flags & MPR_SOCKET_TRACED)) {
        traceCert(sp);
        sp->flags |= MPR_SOCKET_TRACED;
    }
    while (1) {
        rc = ssl_read(&est->ctx, buf, (int) len);
        mprLog(5, "EST: ssl_read %d", rc);
        if (rc < 0) {
            if (rc == EST_ERR_NET_TRY_AGAIN)  {
                break;
            } else if (rc == EST_ERR_SSL_PEER_CLOSE_NOTIFY) {
                mprLog(5, "EST: connection was closed gracefully\n");
                sp->flags |= MPR_SOCKET_EOF;
                return -1;
            } else if (rc == EST_ERR_NET_CONN_RESET) {
                mprLog(5, "EST: connection reset");
                sp->flags |= MPR_SOCKET_EOF;
                return -1;
            } else {
                //  MOB - what about other errors?
                mprLog(4, "EST: read error -0x%", -rc);
                sp->flags |= MPR_SOCKET_EOF;
                return -1;
            }
        }
        break;
    }
    //  MOB - API: ssl_has_pending()
    if (est->ctx.in_left > 0) {
        sp->flags |= MPR_SOCKET_BUFFERED_READ;
        if (sp->handler) {
            mprRecallWaitHandler(sp->handler);
        }
    }
    return rc;
}


/*
    Write data. Return the number of bytes written or -1 on errors or socket closure.
    If non-blocking, may return zero if no data or still handshaking.
 */
static ssize writeEst(MprSocket *sp, cvoid *buf, ssize len)
{
    EstSocket   *est;
    ssize       totalWritten;
    int         rc;

    est = (EstSocket*) sp->sslSocket;
    if (len <= 0) {
        assure(0);
        return -1;
    }
    if (est->ctx.state != SSL_HANDSHAKE_OVER) {
        if ((rc = estHandshake(sp)) <= 0) {
            return rc;
        }
    }
    totalWritten = 0;
    do {
        rc = ssl_write(&est->ctx, (uchar*) buf, (int) len);
        mprLog(7, "EST: written %d, requested len %d", rc, len);
        if (rc <= 0) {
            if (rc == EST_ERR_NET_TRY_AGAIN) {                                                          
                /* MOB - but what about buffered pending data? */
                break;
            }
            if (rc == EST_ERR_NET_CONN_RESET) {                                                         
                mprLog(0, "ssl_write peer closed");
                return -1;
            } else {
                mprLog(0, "ssl_write failed rc -0x%x", -rc);
                return -1;
            }
        } else {
            totalWritten += rc;
            buf = (void*) ((char*) buf + rc);
            len -= rc;
            mprLog(7, "EST: write: len %d, written %d, total %d", len, rc, totalWritten);
        }
    } while (len > 0);

    if (est->ctx.out_left > 0) {
        sp->flags |= MPR_SOCKET_BUFFERED_WRITE;
        if (sp->handler) {
            mprRecallWaitHandler(sp->handler);
        }
    }
    return totalWritten;
}


//  MERGE with traceCert
static char *getEstState(MprSocket *sp)
{
    EstSocket       *est;
    ssl_context     *ctx;
    Ciphers         *cp;
    MprBuf          *buf;
    char            *own, *peer;
    char            cbuf[5120];

    est = sp->sslSocket;
    ctx = &est->ctx;
    buf = mprCreateBuf(0, 0);

    if (est->ctx.session) {
        for (cp = cipherList; cp->name; cp++) {
            if (cp->iana == est->ctx.session->cipher) {
                break;
            }
        }
        if (cp) {
            mprPutFmtToBuf(buf, "CIPHER=%s, ", cp->name);
            mprPutFmtToBuf(buf, "CIPHER_IANA=0x%x, ", est->ctx.session->cipher);
        }
    }
    own =  sp->acceptIp ? "SERVER_" : "CLIENT_";
    peer = sp->acceptIp ? "CLIENT_" : "SERVER_";
    x509parse_cert_info(peer, cbuf, sizeof(cbuf), ctx->peer_cert);
    mprPutStringToBuf(buf, cbuf);
    x509parse_cert_info(own, cbuf, sizeof(cbuf), ctx->own_cert);
    mprPutStringToBuf(buf, cbuf);
    return mprGetBufStart(buf);
}


//  MOB - move back into EST?
static int getSession(ssl_context *ssl)
{
    ssl_session     *sp;
	time_t          t;
    int             next;

	t = time(NULL);

	if (!ssl->resume) {
		return 1;
    }
    for (ITERATE_ITEMS(sessions, sp, next)) {
        if (ssl->timeout && (t - sp->start) > ssl->timeout) continue;
		if (ssl->session->cipher != sp->cipher || ssl->session->length != sp->length) {
			continue;
        }
		if (memcmp(ssl->session->id, sp->id, sp->length) != 0) {
			continue;
        }
		memcpy(ssl->session->master, sp->master, sizeof(ssl->session->master));
        return 0;
    }
	return 1;
}


static int setSession(ssl_context *ssl)
{
	time_t          t;
    ssl_session     *sp;
    int             next;

	t = time(NULL);
    for (ITERATE_ITEMS(sessions, sp, next)) {
		if (ssl->timeout != 0 && (t - sp->start) > ssl->timeout) {
            /* expired, reuse this slot */
			break;	
        }
		if (memcmp(ssl->session->id, sp->id, sp->length) == 0) {
            /* client reconnected */
			break;	
        }
	}
	if (sp == NULL) {
		if ((sp = mprAlloc(sizeof(ssl_session))) == 0) {
			return 1;
        }
        mprAddItem(sessions, sp);
	}
	memcpy(sp, ssl->session, sizeof(ssl_session));
	return 0;
}


static void estTrace(void *fp, int level, char *str)
{
    level += 3;
    if (level <= MPR->logLevel) {
        str = sclone(str);
        str[slen(str) - 1] = '\0';
        mprLog(level, "EST: %s", str);
    }
}

#endif /* BIT_PACK_EST */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */

/************************************************************************/
/*
    Start of file "src/ssl/openssl.c"
 */
/************************************************************************/

/*
    openssl.c - Support for secure sockets via OpenSSL

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "mpr.h"

#if BIT_PACK_OPENSSL

/* Clashes with WinCrypt.h */
#undef OCSP_RESPONSE
#include    <openssl/ssl.h>
#include    <openssl/evp.h>
#include    <openssl/rand.h>
#include    <openssl/err.h>
#include    <openssl/dh.h>

/************************************* Defines ********************************/

typedef struct OpenConfig {
    SSL_CTX         *context;
    RSA             *rsaKey512;
    RSA             *rsaKey1024;
    DH              *dhKey512;
    DH              *dhKey1024;
} OpenConfig;

typedef struct MprOpenSocket {
    MprSocket       *sock;
    SSL             *handle;
    BIO             *bio;
} MprOpenSocket;

typedef struct RandBuf {
    MprTime     now;
    int         pid;
} RandBuf;

static int      numLocks;
static MprMutex **olocks;
static MprSocketProvider *openProvider;
static OpenConfig *defaultOpenConfig;

struct CRYPTO_dynlock_value {
    MprMutex    *mutex;
};
typedef struct CRYPTO_dynlock_value DynLock;

/***************************** Forward Declarations ***************************/

static void     closeOss(MprSocket *sp, bool gracefully);
static int      configureCertificateFiles(MprSsl *ssl, SSL_CTX *ctx, char *key, char *cert);
static OpenConfig *createOpenSslConfig(MprSsl *ssl);
static DH       *dhCallback(SSL *ssl, int isExport, int keyLength);
static void     disconnectOss(MprSocket *sp);
static ssize    flushOss(MprSocket *sp);
static int      listenOss(MprSocket *sp, cchar *host, int port, int flags);
static void     manageOpenConfig(OpenConfig *cfg, int flags);
static void     manageOpenProvider(MprSocketProvider *provider, int flags);
static void     manageOpenSocket(MprOpenSocket *ssp, int flags);
static ssize    readOss(MprSocket *sp, void *buf, ssize len);
static RSA      *rsaCallback(SSL *ssl, int isExport, int keyLength);
static int      upgradeOss(MprSocket *sp, MprSsl *ssl, cchar *peerName);
static int      verifyX509Certificate(int ok, X509_STORE_CTX *ctx);
static ssize    writeOss(MprSocket *sp, cvoid *buf, ssize len);

static DynLock  *sslCreateDynLock(const char *file, int line);
static void     sslDynLock(int mode, DynLock *dl, const char *file, int line);
static void     sslDestroyDynLock(DynLock *dl, const char *file, int line);
static void     sslStaticLock(int mode, int n, const char *file, int line);
static ulong    sslThreadId(void);

static DH       *get_dh512();
static DH       *get_dh1024();

/************************************* Code ***********************************/
/*
    Create the Openssl module. This is called only once
 */
PUBLIC int mprCreateOpenSslModule()
{
    RandBuf     randBuf;
    int         i;

    /*
        Get some random data
     */
    randBuf.now = mprGetTime();
    randBuf.pid = getpid();
    RAND_seed((void*) &randBuf, sizeof(randBuf));
#if BIT_UNIX_LIKE
    mprLog(6, "OpenSsl: Before calling RAND_load_file");
    RAND_load_file("/dev/urandom", 256);
    mprLog(6, "OpenSsl: After calling RAND_load_file");
#endif

    if ((openProvider = mprAllocObj(MprSocketProvider, manageOpenProvider)) == NULL) {
        return MPR_ERR_MEMORY;
    }
    openProvider->upgradeSocket = upgradeOss;
    openProvider->closeSocket = closeOss;
    openProvider->disconnectSocket = disconnectOss;
    openProvider->flushSocket = flushOss;
    openProvider->listenSocket = listenOss;
    openProvider->readSocket = readOss;
    openProvider->writeSocket = writeOss;
    mprAddSocketProvider("openssl", openProvider);

    /*
        Pre-create expensive keys
     */
    if ((defaultOpenConfig = mprAllocObj(OpenConfig, manageOpenConfig)) == 0) {
        return MPR_ERR_MEMORY;
    }
    defaultOpenConfig->rsaKey512 = RSA_generate_key(512, RSA_F4, 0, 0);
    defaultOpenConfig->rsaKey1024 = RSA_generate_key(1024, RSA_F4, 0, 0);
    defaultOpenConfig->dhKey512 = get_dh512();
    defaultOpenConfig->dhKey1024 = get_dh1024();

    /*
        Configure the SSL library. Use the crypto ID as a one-time test. This allows
        users to configure the library and have their configuration used instead.
     */
    if (CRYPTO_get_id_callback() == 0) {
        numLocks = CRYPTO_num_locks();
        if ((olocks = mprAlloc(numLocks * sizeof(MprMutex*))) == 0) {
            return MPR_ERR_MEMORY;
        }
        for (i = 0; i < numLocks; i++) {
            olocks[i] = mprCreateLock();
        }
        CRYPTO_set_id_callback(sslThreadId);
        CRYPTO_set_locking_callback(sslStaticLock);

        CRYPTO_set_dynlock_create_callback(sslCreateDynLock);
        CRYPTO_set_dynlock_destroy_callback(sslDestroyDynLock);
        CRYPTO_set_dynlock_lock_callback(sslDynLock);
#if !BIT_WIN_LIKE
        /* OPT - Should be a configure option to specify desired ciphers */
        OpenSSL_add_all_algorithms();
#endif
        /*
            WARNING: SSL_library_init() is not reentrant. Caller must ensure safety.
         */
        SSL_library_init();
        SSL_load_error_strings();
    }
    return 0;
}


static void manageOpenConfig(OpenConfig *cfg, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        ;
    } else if (flags & MPR_MANAGE_FREE) {
        if (cfg->context != 0) {
            SSL_CTX_free(cfg->context);
            cfg->context = 0;
        }
        if (cfg == defaultOpenConfig) {
            if (cfg->rsaKey512) {
                RSA_free(cfg->rsaKey512);
                cfg->rsaKey512 = 0;
            }
            if (cfg->rsaKey1024) {
                RSA_free(cfg->rsaKey1024);
                cfg->rsaKey1024 = 0;
            }
            if (cfg->dhKey512) {
                DH_free(cfg->dhKey512);
                cfg->dhKey512 = 0;
            }
            if (cfg->dhKey1024) {
                DH_free(cfg->dhKey1024);
                cfg->dhKey1024 = 0;
            }
        }
    }
}


static void manageOpenProvider(MprSocketProvider *provider, int flags)
{
    int     i;

    if (flags & MPR_MANAGE_MARK) {
        /*
            Mark global locks
         */
        if (olocks) {
            mprMark(olocks);
            for (i = 0; i < numLocks; i++) {
                mprMark(olocks[i]);
            }
        }
        mprMark(defaultOpenConfig);

    } else if (flags & MPR_MANAGE_FREE) {
        olocks = 0;
    }
}


/*
    Create an SSL configuration for a route. An application can have multiple different SSL 
    configurations for different routes. There is default SSL configuration that is used
    when a route does not define a configuration and also for clients.
 */
static OpenConfig *createOpenSslConfig(MprSsl *ssl)
{
    OpenConfig      *cfg;
    SSL_CTX         *context;
    uchar           resume[16];

    assure(ssl);

    //  MOB - rename pconfig =>config
    if ((ssl->pconfig = mprAllocObj(OpenConfig, manageOpenConfig)) == 0) {
        return 0;
    }
    cfg = ssl->pconfig;
    cfg->rsaKey512 = defaultOpenConfig->rsaKey512;
    cfg->rsaKey1024 = defaultOpenConfig->rsaKey1024;
    cfg->dhKey512 = defaultOpenConfig->dhKey512;
    cfg->dhKey1024 = defaultOpenConfig->dhKey1024;

    cfg = ssl->pconfig;
    assure(cfg);

    if ((context = SSL_CTX_new(SSLv23_method())) == 0) {
        mprError("OpenSSL: Unable to create SSL context"); 
        return 0;
    }
    SSL_CTX_set_app_data(context, (void*) ssl);
    SSL_CTX_sess_set_cache_size(context, 512);
    RAND_bytes(resume, sizeof(resume));
    SSL_CTX_set_session_id_context(context, resume, sizeof(resume));

    /*
        Configure the certificates
     */
    if (ssl->keyFile || ssl->certFile) {
        if (configureCertificateFiles(ssl, context, ssl->keyFile, ssl->certFile) != 0) {
            SSL_CTX_free(context);
            return 0;
        }
    }
    SSL_CTX_set_cipher_list(context, ssl->ciphers);

    if (ssl->caFile || ssl->caPath) {
        if ((!SSL_CTX_load_verify_locations(context, ssl->caFile, ssl->caPath)) ||
                (!SSL_CTX_set_default_verify_paths(context))) {
            mprError("OpenSSL: Unable to set certificate locations"); 
            SSL_CTX_free(context);
            return 0;
        }
        if (ssl->caFile) {
            STACK_OF(X509_NAME) *certNames;
            certNames = SSL_load_client_CA_file(ssl->caFile);
            if (certNames) {
                /*
                    Define the list of CA certificates to send to the client
                    before they send their client certificate for validation
                 */
                SSL_CTX_set_client_CA_list(context, certNames);
            }
        }
    }
    if (sp->flags & MPR_SOCKET_SERVER) {
        if (ssl->verifyPeer) {
            if (!ssl->caFile == 0 && !ssl->caPath) {
                mprError("OpenSSL: Must define CA certificates if using client verification");
                SSL_CTX_free(context);
                return 0;
            }
            SSL_CTX_set_verify(context, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, verifyX509Certificate);
            SSL_CTX_set_verify_depth(context, ssl->verifyDepth);
        } else {
            /* With this, the server will not request a client certificate */
            SSL_CTX_set_verify(context, SSL_VERIFY_NONE, verifyX509Certificate);
        }
    } else {
        if (ssl->verifyPeer) {
            SSL_CTX_set_verify(context, SSL_VERIFY_PEER, verifyX509Certificate);
        } else {
            SSL_CTX_set_verify(context, SSL_VERIFY_NONE, verifyX509Certificate);
        }
    }
    /*
        Define callbacks
     */
    SSL_CTX_set_tmp_rsa_callback(context, rsaCallback);
    SSL_CTX_set_tmp_dh_callback(context, dhCallback);

    SSL_CTX_set_options(context, SSL_OP_ALL);
#ifdef SSL_OP_NO_TICKET
    SSL_CTX_set_options(context, SSL_OP_NO_TICKET);
#endif
#ifdef SSL_OP_NO_SESSION_RESUMPTION_ON_RENEGOTIATION
    SSL_CTX_set_options(context, SSL_OP_NO_SESSION_RESUMPTION_ON_RENEGOTIATION);
#endif
    SSL_CTX_set_mode(context, SSL_MODE_ENABLE_PARTIAL_WRITE | SSL_MODE_AUTO_RETRY);

    /*
        Select the required protocols
        Disable SSLv2 by default -- it is insecure.
     */
    SSL_CTX_set_options(context, SSL_OP_NO_SSLv2);
    if (!(ssl->protocols & MPR_PROTO_SSLV3)) {
        SSL_CTX_set_options(context, SSL_OP_NO_SSLv3);
    }
    if (!(ssl->protocols & MPR_PROTO_TLSV1)) {
        SSL_CTX_set_options(context, SSL_OP_NO_TLSv1);
    }
    /* 
        Ensure we generate a new private key for each connection
     */
    SSL_CTX_set_options(context, SSL_OP_SINGLE_DH_USE);
    cfg->context = context;
    return cfg;
}


/*
    Configure the SSL certificate information using key and cert files
 */
static int configureCertificateFiles(MprSsl *ssl, SSL_CTX *ctx, char *key, char *cert)
{
    assure(ctx);

    if (cert == 0) {
        return 0;
    }
    if (cert && SSL_CTX_use_certificate_chain_file(ctx, cert) <= 0) {
        if (SSL_CTX_use_certificate_file(ctx, cert, SSL_FILETYPE_ASN1) <= 0) {
            mprError("OpenSSL: Cannot open certificate file: %s", cert); 
            return -1;
        }
    }
    key = (key == 0) ? cert : key;
    if (key) {
        if (SSL_CTX_use_PrivateKey_file(ctx, key, SSL_FILETYPE_PEM) <= 0) {
            /* attempt ASN1 for self-signed format */
            if (SSL_CTX_use_PrivateKey_file(ctx, key, SSL_FILETYPE_ASN1) <= 0) {
                mprError("OpenSSL: Cannot define private key file: %s", key); 
                return -1;
            }
        }
        if (!SSL_CTX_check_private_key(ctx)) {
            mprError("OpenSSL: Check of private key file failed: %s", key);
            return -1;
        }
    }
    return 0;
}


/*
    Destructor for an MprOpenSocket object
 */
static void manageOpenSocket(MprOpenSocket *osp, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(osp->sock);

    } else if (flags & MPR_MANAGE_FREE) {
        if (osp->handle) {
            SSL_set_shutdown(osp->handle, SSL_SENT_SHUTDOWN | SSL_RECEIVED_SHUTDOWN);
            SSL_free(osp->handle);
            osp->handle = 0;
        }
    }
}


static void closeOss(MprSocket *sp, bool gracefully)
{
    MprOpenSocket    *osp;

    osp = sp->sslSocket;
    SSL_free(osp->handle);
    osp->handle = 0;
    sp->service->standardProvider->closeSocket(sp, gracefully);
}


/*
    Initialize a new server-side connection
 */
static int listenOss(MprSocket *sp, cchar *host, int port, int flags)
{
    assure(sp);
    assure(port);
    return sp->service->standardProvider->listenSocket(sp, host, port, flags);
}


/*
    Upgrade a standard socket to use SSL/TLS
 */
static int upgradeOss(MprSocket *sp, MprSsl *ssl, cchar *peerName)
{
    MprOpenSocket   *osp;
    OpenConfig      *cfg;
    char            ebuf[BIT_MAX_BUFFER];
    ulong           error;
    int             rc;

    assure(sp);

    if (ssl == 0) {
        ssl = mprCreateSsl(sp->flags & MPR_SOCKET_SERVER);
    }
    //  MOB - why lock here
    lock(sp);
    if ((osp = (MprOpenSocket*) mprAllocObj(MprOpenSocket, manageOpenSocket)) == 0) {
        unlock(sp);
        return MPR_ERR_MEMORY;
    }
    osp->sock = sp;
    sp->sslSocket = osp;
    sp->ssl = ssl;

    if (!ssl->pconfig && (ssl->pconfig = createOpenSslConfig(ssl)) == 0) {
        unlock(sp);
        return MPR_ERR_CANT_INITIALIZE;
    }
    /*
        Create and configure the SSL struct
     */
    cfg = sp->ssl->pconfig;
    if ((osp->handle = (SSL*) SSL_new(cfg->context)) == 0) {
        unlock(sp);
        return MPR_ERR_BAD_STATE;
    }
    SSL_set_app_data(osp->handle, (void*) osp);

    /*
        Create a socket bio
     */
    osp->bio = BIO_new_socket(sp->fd, BIO_NOCLOSE);
    SSL_set_bio(osp->handle, osp->bio, osp->bio);
    if (sp->flags & MPR_SOCKET_SERVER) {
        SSL_set_accept_state(osp->handle);
    } else {
        /* Block while connecting */
        mprSetSocketBlockingMode(sp, 1);
        if ((rc = SSL_connect(osp->handle)) < 1) {
            error = ERR_get_error();
            ERR_error_string_n(error, ebuf, sizeof(ebuf) - 1);
            sp->errorMsg = sclone(ebuf);
            mprLog(4, "SSL_read error %s", ebuf);
            unlock(sp);
            return MPR_ERR_CANT_CONNECT;
        }
        mprSetSocketBlockingMode(sp, 0);
    }
    unlock(sp);

    //  MOB - must do something with peerName
    return 0;
}


static void disconnectOss(MprSocket *sp)
{
    sp->service->standardProvider->disconnectSocket(sp);
}


/*
    Return the number of bytes read. Return -1 on errors and EOF
 */
static ssize readOss(MprSocket *sp, void *buf, ssize len)
{
    MprOpenSocket   *osp;
    MprSsl          *ssl;
    X509_NAME       *xSubject;
    X509            *cert;
    char            subject[260], issuer[260], peer[260], ebuf[BIT_MAX_BUFFER];
    ulong           serror;
    int             rc, error, retries, i;

    lock(sp);
    osp = (MprOpenSocket*) sp->sslSocket;
    assure(osp);

    if (osp->handle == 0) {
        assure(osp->handle);
        unlock(sp);
        return -1;
    }
    /*  
        Limit retries on WANT_READ. If non-blocking and no data, then this can spin forever.
     */
    retries = 5;
    for (i = 0; i < retries; i++) {
        rc = SSL_read(osp->handle, buf, (int) len);
        if (rc < 0) {
            error = SSL_get_error(osp->handle, rc);
            if (error == SSL_ERROR_WANT_READ || error == SSL_ERROR_WANT_CONNECT || error == SSL_ERROR_WANT_ACCEPT) {
                continue;
            }
            serror = ERR_get_error();
            ERR_error_string_n(serror, ebuf, sizeof(ebuf) - 1);
            mprLog(5, "SSL_read %s", ebuf);
        }
        break;
    }
    if (rc > 0 && !(sp->flags & MPR_SOCKET_TRACED)) {
        ssl = sp->ssl;
        mprLog(4, "OpenSSL connected using cipher: \"%s\" from set %s", SSL_get_cipher(osp->handle), ssl->ciphers);
        if (ssl->caFile) {
            mprLog(4, "OpenSSL: Using certificates from %s", ssl->caFile);
        } else if (ssl->caPath) {
            mprLog(4, "OpenSSL: Using certificates from directory %s", ssl->caPath);
        }
        cert = SSL_get_peer_certificate(osp->handle);
        if (cert == 0) {
            mprLog(4, "OpenSSL: client supplied no certificate");
        } else {
            xSubject = X509_get_subject_name(cert);
            X509_NAME_oneline(xSubject, subject, sizeof(subject) -1);
            X509_NAME_oneline(X509_get_issuer_name(cert), issuer, sizeof(issuer) -1);
            X509_NAME_get_text_by_NID(xSubject, NID_commonName, peer, sizeof(peer) - 1);
            mprLog(4, "OpenSSL Subject %s", subject);
            mprLog(4, "OpenSSL Issuer: %s", issuer);
            mprLog(4, "OpenSSL Peer: %s", peer);
            X509_free(cert);
        }
        sp->flags |= MPR_SOCKET_TRACED;
    }
    if (rc <= 0) {
        error = SSL_get_error(osp->handle, rc);
        if (error == SSL_ERROR_WANT_READ) {
            rc = 0;
        } else if (error == SSL_ERROR_WANT_WRITE) {
            mprNap(10);
            rc = 0;
        } else if (error == SSL_ERROR_ZERO_RETURN) {
            sp->flags |= MPR_SOCKET_EOF;
            rc = -1;
        } else if (error == SSL_ERROR_SYSCALL) {
            sp->flags |= MPR_SOCKET_EOF;
            rc = -1;
        } else if (error != SSL_ERROR_ZERO_RETURN) {
            /* SSL_ERROR_SSL */
            serror = ERR_get_error();
            ERR_error_string_n(serror, ebuf, sizeof(ebuf) - 1);
            mprLog(4, "OpenSSL: connection with protocol error: %s", ebuf);
            rc = -1;
            sp->flags |= MPR_SOCKET_EOF;
        }
    } else if (SSL_pending(osp->handle) > 0) {
        sp->flags |= MPR_SOCKET_PENDING;
        mprRecallWaitHandlerByFd(sp->fd);
    }
    unlock(sp);
    return rc;
}


/*
    Write data. Return the number of bytes written or -1 on errors.
 */
static ssize writeOss(MprSocket *sp, cvoid *buf, ssize len)
{
    MprOpenSocket    *osp;
    ssize           totalWritten;
    int             rc;

    lock(sp);
    osp = (MprOpenSocket*) sp->sslSocket;

    if (osp->bio == 0 || osp->handle == 0 || len <= 0) {
        assure(0);
        unlock(sp);
        return -1;
    }
    totalWritten = 0;
    ERR_clear_error();

    do {
        rc = SSL_write(osp->handle, buf, (int) len);
        mprLog(7, "OpenSSL: written %d, requested len %d", rc, len);
        if (rc <= 0) {
            rc = SSL_get_error(osp->handle, rc);
            if (rc == SSL_ERROR_WANT_WRITE) {
                mprNap(10);
                continue;
            } else if (rc == SSL_ERROR_WANT_READ) {
                //  AUTO-RETRY should stop this
                assure(0);
                unlock(sp);
                return -1;
            } else {
                unlock(sp);
                return -1;
            }
        }
        totalWritten += rc;
        buf = (void*) ((char*) buf + rc);
        len -= rc;
        mprLog(7, "OpenSSL: write: len %d, written %d, total %d, error %d", len, rc, totalWritten, 
            SSL_get_error(osp->handle, rc));

    } while (len > 0);

    unlock(sp);
    return totalWritten;
}


/*
    Called to verify X509 client certificates
 */
static int verifyX509Certificate(int ok, X509_STORE_CTX *xContext)
{
    X509            *cert;
    SSL             *handle;
    MprOpenSocket   *osp;
    MprSsl          *ssl;
    char            subject[260], issuer[260], peer[260];
    int             error, depth;
    
    subject[0] = issuer[0] = '\0';

    handle = (SSL*) X509_STORE_CTX_get_app_data(xContext);
    osp = (MprOpenSocket*) SSL_get_app_data(handle);
    ssl = osp->sock->ssl;

    cert = X509_STORE_CTX_get_current_cert(xContext);
    depth = X509_STORE_CTX_get_error_depth(xContext);
    error = X509_STORE_CTX_get_error(xContext);

    ok = 1;
    if (X509_NAME_oneline(X509_get_subject_name(cert), subject, sizeof(subject) - 1) < 0) {
        ok = 0;
    }
    if (X509_NAME_oneline(X509_get_issuer_name(xContext->current_cert), issuer, sizeof(issuer) - 1) < 0) {
        ok = 0;
    }
    if (X509_NAME_get_text_by_NID(X509_get_subject_name(xContext->current_cert), NID_commonName, peer, 
            sizeof(peer) - 1) < 0) {
        ok = 0;
    }
    //  MOB - must verify peer name here

    if (ok && ssl->verifyDepth < depth) {
        if (error == 0) {
            error = X509_V_ERR_CERT_CHAIN_TOO_LONG;
        }
    }
    switch (error) {
    case X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT:
        /* Normal self signed certificate */
    case X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN:
    case X509_V_ERR_CERT_UNTRUSTED:
    case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY:
        if (ssl->verifyIssuer) {
            /* Issuer can't be verified */
            ok = 0;
        }
        break;

    case X509_V_ERR_CERT_CHAIN_TOO_LONG:
    case X509_V_ERR_CERT_HAS_EXPIRED:
    case X509_V_ERR_CERT_NOT_YET_VALID:
    case X509_V_ERR_CERT_REJECTED:
    case X509_V_ERR_CERT_SIGNATURE_FAILURE:
    case X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD:
    case X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD:
    case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
    case X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE:
    case X509_V_ERR_INVALID_CA:
    default:
        ok = 0;
        break;
    }
    if (ok) {
        mprLog(3, "OpenSSL: Certificate verified: subject %s", subject);
        mprLog(4, "OpenSSL: Issuer: %s", issuer);
        mprLog(4, "OpenSSL: Peer: %s", peer);
    } else {
        mprLog(1, "OpenSSL: Certification failed: subject %s (more trace at level 4)", subject);
        mprLog(4, "OpenSSL: Issuer: %s", issuer);
        mprLog(4, "OpenSSL: Peer: %s", peer);
        mprLog(4, "OpenSSL: Error: %d: %s", error, X509_verify_cert_error_string(error));
    }
    return ok;
}


static ssize flushOss(MprSocket *sp)
{
#if NOT_REQUIRED && KEEP
    MprOpenSocket    *osp;
    osp = (MprOpenSocket*) sp->sslSocket;
    return BIO_flush(osp->bio);
#endif
    return 0;
}

 
static ulong sslThreadId()
{
    return (long) mprGetCurrentOsThread();
}


static void sslStaticLock(int mode, int n, const char *file, int line)
{
    assure(0 <= n && n < numLocks);

    if (olocks) {
        if (mode & CRYPTO_LOCK) {
            mprLock(olocks[n]);
        } else {
            mprUnlock(olocks[n]);
        }
    }
}


static DynLock *sslCreateDynLock(const char *file, int line)
{
    DynLock     *dl;

    dl = mprAllocZeroed(sizeof(DynLock));
    dl->mutex = mprCreateLock(dl);
    mprHold(dl->mutex);
    return dl;
}


static void sslDestroyDynLock(DynLock *dl, const char *file, int line)
{
    if (dl->mutex) {
        mprRelease(dl->mutex);
        dl->mutex = 0;
    }
}


static void sslDynLock(int mode, DynLock *dl, const char *file, int line)
{
    if (mode & CRYPTO_LOCK) {
        mprLock(dl->mutex);
    } else {
        mprUnlock(dl->mutex);
    }
}


/*
    Used for ephemeral RSA keys
 */
static RSA *rsaCallback(SSL *handle, int isExport, int keyLength)
{
    MprSocket       *sp;
    MprOpenSocket   *osp;
    OpenConfig      *cfg;
    RSA             *key;

    osp = (MprOpenSocket*) SSL_get_app_data(handle);
    sp = osp->sock;
    assure(sp);
    cfg = sp->ssl->pconfig;

    key = 0;
    switch (keyLength) {
    case 512:
        key = cfg->rsaKey512;
        break;

    case 1024:
    default:
        key = cfg->rsaKey1024;
    }
    return key;
}


/*
    Used for ephemeral DH keys
 */
static DH *dhCallback(SSL *handle, int isExport, int keyLength)
{
    MprSocket       *sp;
    MprOpenSocket   *osp;
    OpenConfig      *cfg;
    DH              *key;

    osp = (MprOpenSocket*) SSL_get_app_data(handle);
    sp = osp->sock;
    cfg = sp->ssl->pconfig;

    key = 0;
    switch (keyLength) {
    case 512:
        key = cfg->dhKey512;
        break;

    case 1024:
    default:
        key = cfg->dhKey1024;
    }
    return key;
}


/*
    openSslDh.c - OpenSSL DH get routines. Generated by openssl.
    Use bit gendh to generate new content.
 */
static DH *get_dh512()
{
    static unsigned char dh512_p[] = {
        0x8E,0xFD,0xBE,0xD3,0x92,0x1D,0x0C,0x0A,0x58,0xBF,0xFF,0xE4,
        0x51,0x54,0x36,0x39,0x13,0xEA,0xD8,0xD2,0x70,0xBB,0xE3,0x8C,
        0x86,0xA6,0x31,0xA1,0x04,0x2A,0x09,0xE4,0xD0,0x33,0x88,0x5F,
        0xEF,0xB1,0x70,0xEA,0x42,0xB6,0x0E,0x58,0x60,0xD5,0xC1,0x0C,
        0xD1,0x12,0x16,0x99,0xBC,0x7E,0x55,0x7C,0xE4,0xC1,0x5D,0x15,
        0xF6,0x45,0xBC,0x73,
    };
    static unsigned char dh512_g[] = {
        0x02,
    };

    DH *dh;

    if ((dh = DH_new()) == NULL) {
        return(NULL);
    }
    dh->p=BN_bin2bn(dh512_p,sizeof(dh512_p),NULL);
    dh->g=BN_bin2bn(dh512_g,sizeof(dh512_g),NULL);

    if ((dh->p == NULL) || (dh->g == NULL)) { 
        DH_free(dh); 
        return(NULL); 
    }
    return dh;
}


static DH *get_dh1024()
{
    static unsigned char dh1024_p[] = {
        0xCD,0x02,0x2C,0x11,0x43,0xCD,0xAD,0xF5,0x54,0x5F,0xED,0xB1,
        0x28,0x56,0xDF,0x99,0xFA,0x80,0x2C,0x70,0xB5,0xC8,0xA8,0x12,
        0xC3,0xCD,0x38,0x0D,0x3B,0xE1,0xE3,0xA3,0xE4,0xE9,0xCB,0x58,
        0x78,0x7E,0xA6,0x80,0x7E,0xFC,0xC9,0x93,0x3A,0x86,0x1C,0x8E,
        0x0B,0xA2,0x1C,0xD0,0x09,0x99,0x29,0x9B,0xC1,0x53,0xB8,0xF3,
        0x98,0xA7,0xD8,0x46,0xBE,0x5B,0xB9,0x64,0x31,0xCF,0x02,0x63,
        0x0F,0x5D,0xF2,0xBE,0xEF,0xF6,0x55,0x8B,0xFB,0xF0,0xB8,0xF7,
        0xA5,0x2E,0xD2,0x6F,0x58,0x1E,0x46,0x3F,0x74,0x3C,0x02,0x41,
        0x2F,0x65,0x53,0x7F,0x1C,0x7B,0x8A,0x72,0x22,0x1D,0x2B,0xE9,
        0xA3,0x0F,0x50,0xC3,0x13,0x12,0x6C,0xD2,0x17,0xA9,0xA5,0x82,
        0xFC,0x91,0xE3,0x3E,0x28,0x8A,0x97,0x73,
    };

    static unsigned char dh1024_g[] = {
        0x02,
    };

    DH *dh;

    if ((dh = DH_new()) == NULL) {
        return(NULL);
    }
    dh->p = BN_bin2bn(dh1024_p,sizeof(dh1024_p),NULL);
    dh->g = BN_bin2bn(dh1024_g,sizeof(dh1024_g),NULL);
    if ((dh->p == NULL) || (dh->g == NULL)) {
        DH_free(dh); 
        return(NULL); 
    }
    return dh;
}

#else
PUBLIC int mprCreateOpenSslModule() { return -1; }
#endif /* BIT_PACK_OPENSSL */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */

/************************************************************************/
/*
    Start of file "src/ssl/mocana.c"
 */
/************************************************************************/

/*
    mocana.c - Mocana NanoSSL

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "mpr.h"

#if BIT_PACK_MOCANA
 #include "common/moptions.h"
 #include "common/mdefs.h"
 #include "common/mtypes.h"
 #include "common/merrors.h"
 #include "common/mrtos.h"
 #include "common/mtcp.h"
 #include "common/mocana.h"
 #include "common/random.h"
 #include "common/vlong.h"
 #include "crypto/hw_accel.h"
 #include "crypto/crypto.h"
 #include "crypto/pubcrypto.h"
 #include "crypto/ca_mgmt.h"
 #include "ssl/ssl.h"
 #include "asn1/oiddefs.h"

/************************************* Defines ********************************/
/*
    Per-route SSL configuration
 */
typedef struct MocConfig {
    certDescriptor  cert;
#if UNUSED
    char            *dhKey;
    rsa_context     rsa;
#endif
} MocConfig;

/*
    Per socket state
 */
typedef struct MocSocket {
    MprSocket       *sock;
    MocConfig       *cfg;
    sbyte4          handle;
#if UNUSED
    int             *ciphers;
    havege_state    hs;
    ssl_context     ssl;
    ssl_session     session;
#endif
} MocSocket;

static MprSocketProvider *mocProvider;
static MocConfig *defaultMocConfig;

//  MOB Cleanup
#define SSL_HELLO_TIMEOUT     15000
#define SSL_RECV_TIMEOUT      300000
#define KEY_SIZE            1024

#if TEST_CERT || 1
nameAttr pNames1[] = {
    {countryName_OID, 0, (ubyte*)"US", 2}                                /* country */
};
nameAttr pNames2[] = {
    {stateOrProvinceName_OID, 0, (ubyte*)"California", 10}               /* state or providence */
};
nameAttr pNames3[] = {
    {localityName_OID, 0, (ubyte*)"Menlo Park", 10}                      /* locality */
};
nameAttr pNames4[] = {
    {organizationName_OID, 0, (ubyte*)"Mocana Corporation", 18}          /* company name */
};
nameAttr pNames5[] = {
    {organizationalUnitName_OID, 0, (ubyte*)"Engineering", 11}           /* organizational unit */
};
nameAttr pNames6[] = {
    {commonName_OID, 0, (ubyte*)"sslexample.mocana.com", 21}             /* common name */
};
nameAttr pNames7[] = {
    {pkcs9_emailAddress_OID, 0, (ubyte*)"info@mocana.com", 15}           /* pkcs-9-at-emailAddress */
};
relativeDN pRDNs[] = {
    {pNames1, 1},
    {pNames2, 1},
    {pNames3, 1},
    {pNames4, 1},
    {pNames5, 1},
    {pNames6, 1},
    {pNames7, 1}
};
certDistinguishedName testCert = {
    pRDNs,
    7,
    (sbyte*) "030526000126Z",    /* certificate start date (time format yymmddhhmmss) */
    (sbyte*) "330524230126Z"     /* certificate end date */
};
#endif
/***************************** Forward Declarations ***************************/

static void     closeMoc(MprSocket *sp, bool gracefully);
static void     disconnectMoc(MprSocket *sp);
static int      listenMoc(MprSocket *sp, cchar *host, int port, int flags);
static void     manageMocConfig(MocConfig *cfg, int flags);
static void     manageMocProvider(MprSocketProvider *provider, int flags);
static void     manageMocSocket(MocSocket *ssp, int flags);
static ssize    readMoc(MprSocket *sp, void *buf, ssize len);
static int      upgradeMoc(MprSocket *sp, MprSsl *sslConfig, cchar *peerName);
static ssize    writeMoc(MprSocket *sp, cvoid *buf, ssize len);

/************************************* Code ***********************************/
/*
    Create the Openssl module. This is called only once
 */
PUBLIC int mprCreateMocanaModule()
{
    sslSettings     *settings;

    if ((mocProvider = mprAllocObj(MprSocketProvider, manageMocProvider)) == NULL) {
        return MPR_ERR_MEMORY;
    }
    mocProvider->upgradeSocket = upgradeMoc;
    mocProvider->closeSocket = closeMoc;
    mocProvider->disconnectSocket = disconnectMoc;
    mocProvider->listenSocket = listenMoc;
    mocProvider->readSocket = readMoc;
    mocProvider->writeSocket = writeMoc;
    mprAddSocketProvider("est", mocProvider);

    if ((defaultMocConfig = mprAllocObj(MocConfig, manageMocConfig)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (SSL_init(SOMAXCONN, 0) < 0) {
        mprError("SSL_init failed");
        return MPR_ERR_CANT_INITIALIZE;
    }

    settings = SSL_sslSettings();
    settings->sslTimeOutHello = SSL_HELLO_TIMEOUT;
    settings->sslTimeOutReceive = SSL_RECV_TIMEOUT;

#if UNUSED
    //  MOB - should generate
    defaultMocConfig->dhKey = dhKey;
#endif
    return 0;
}


static void manageMocProvider(MprSocketProvider *provider, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(defaultMocConfig);

    } else if (flags & MPR_MANAGE_FREE) {
        SSL_releaseTables();
        MOCANA_freeMocana();
    }
}


static void manageMocConfig(MocConfig *cfg, int flags)
{
    if (flags & MPR_MANAGE_FREE) {
        MOCANA_freeReadFile(&cfg->cert.pCertificate);
        MOCANA_freeReadFile(&cfg->cert.pKeyBlob);    
    }
}


/*
    Create an SSL configuration for a route. An application can have multiple different SSL configurations for 
    different routes. There is default SSL configuration that is used when a route does not define a configuration 
    and also for clients.
 */
/*
    Destructor for an MocSocket object
 */
static void manageMocSocket(MocSocket *mp, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(mp->cfg);
        mprMark(mp->sock);
#if UNUSED
        mprMark(mp->ciphers);
#endif

    } else if (flags & MPR_MANAGE_FREE) {
        if (mp->handle) {
            SSL_closeConnection(mp->handle);
        }
    }
}


static void closeMoc(MprSocket *sp, bool gracefully)
{
    MocSocket       *mp;

    mp = sp->sslSocket;
    if (!(sp->flags & MPR_SOCKET_EOF)) {
        if (mp->handle) {
            SSL_closeConnection(mp->handle);
        }
        mp->handle = 0;
    }
    sp->service->standardProvider->closeSocket(sp, gracefully);
}


/*
    Initialize a new server-side connection
 */
static int listenMoc(MprSocket *sp, cchar *host, int port, int flags)
{
    assure(sp);
    assure(port);
    return sp->service->standardProvider->listenSocket(sp, host, port, flags);
}


/*
    Upgrade a standard socket to use TLS
 */
static int upgradeMoc(MprSocket *sp, MprSsl *ssl, cchar *peerName)
{
    MocSocket   *mp;
    MocConfig   *cfg;
    int         rc, handle;

    assure(sp);

    if (ssl == 0) {
        ssl = mprCreateSsl(sp->flags & MPR_SOCKET_SERVER);
    }
    if ((mp = (MocSocket*) mprAllocObj(MocSocket, manageMocSocket)) == 0) {
        return MPR_ERR_MEMORY;
    }
    mp->sock = sp;
    sp->sslSocket = mp;
    sp->ssl = ssl;

    lock(ssl);
    if (ssl->pconfig) {
        mp->cfg = cfg = ssl->pconfig;
    } else {
        /*
            One time setup for the SSL configuration for this MprSsl
         */
        //  LOCKING
        if ((cfg = mprAllocObj(MocConfig, manageMocConfig)) == 0) {
            unlock(ssl);
            return MPR_ERR_MEMORY;
        }
        mp->cfg = ssl->pconfig = cfg;
        if (ssl->certFile) {
            if ((rc = MOCANA_readFile((sbyte*) ssl->certFile, &cfg->cert.pCertificate, &cfg->cert.certLength))) {
                mprError("MOCANA: Unable to read certificate %s", ssl->certFile); 
                CA_MGMT_freeCertificate(&cfg->cert);
                unlock(ssl);
                return MPR_ERR_CANT_READ;
            }
        }
        if (ssl->keyFile) {
            if ((rc = MOCANA_readFile((sbyte*) ssl->keyFile, &cfg->cert.pKeyBlob, &cfg->cert.keyBlobLength)) < 0) {
                mprError("MOCANA: Unable to read key file %s", ssl->keyFile); 
                CA_MGMT_freeCertificate(&cfg->cert);
                unlock(ssl);
            }
        }
        if (SSL_initServerCert(&cfg->cert, FALSE, 0)) {
            mprError("SSL_initServerCert failed");
            unlock(ssl);
            return MPR_ERR_CANT_INITIALIZE;
        }
    }
    unlock(ssl);

    //  MOB - must verify peerName
    if (sp->flags & MPR_SOCKET_SERVER) {
        if ((handle = SSL_acceptConnection(sp->fd)) < 0) {
            return -1;
        }
    } else {
        //  MOB - need client side
    }
    return 0;
}


static void disconnectMoc(MprSocket *sp)
{
    //  MOB - anything to do here?
    sp->service->standardProvider->disconnectSocket(sp);
}


#if UNUSED
//  MOB - move to est
static void traceCert(MprSocket *sp)
{
    MprSsl      *ssl;
    Ciphers     *cp;
   
    ssl = sp->ssl;
    if (ssl->session) {
        for (cp = cipherList; cp->name; cp++) {
            if (cp->iana == ssl->session->cipher) {
                break;
            }
        }
        if (cp) {
            mprLog(4, "MOCANA connected using cipher: %s, %x", cp->name, ssl->session->cipher);
        }
    }
    if (ssl->caFile) {
        mprLog(4, "MOCANA: Using certificates from %s", ssl->caFile);
    } else if (ssl->caPath) {
        mprLog(4, "MOCANA: Using certificates from directory %s", ssl->caPath);
    }
    if (ssl->peer_cert) {
        mprLog(4, "MOCANA: client supplied no certificate");
    } else {
        mprRawLog(4, "%s", x509parse_cert_inf("", ssl->peer_cert));
    }
    sp->flags |= MPR_SOCKET_TRACED;
}
#endif


/*
    Return the number of bytes read. Return -1 on errors and EOF. Distinguish EOF via mprIsSocketEof
 */
static ssize readMoc(MprSocket *sp, void *buf, ssize len)
{
    MocSocket   *mp;
    int         rc, nbytes;

    mp = (MocSocket*) sp->sslSocket;
    assure(mp);
    assure(mp->cfg);

    if ((rc = SSL_negotiateConnection(mp->handle)) < 0) {
        mprLog(4, "MOCANA: readMoc: Cannot handshake: error %d", rc);
        sp->flags |= MPR_SOCKET_EOF;
        return -1;
    }
    while (1) {
        rc = SSL_recv(mp->handle, buf, (int) len, &nbytes, SSL_RECV_TIMEOUT);
        mprLog(5, "MOCANA: ssl_read %d", rc);
        if (rc < 0) {
            sp->flags |= MPR_SOCKET_EOF;
            return -1;
        }
        break;
    }
#if UNUSED
    if (mp->ssl.in_left > 0) {
        sp->flags |= MPR_SOCKET_PENDING;
        mprRecallWaitHandlerByFd(sp->fd);
    }
#endif
    return rc;
}


/*
    Write data. Return the number of bytes written or -1 on errors.
 */
static ssize writeMoc(MprSocket *sp, cvoid *buf, ssize len)
{
    MocSocket   *mp;
    ssize       totalWritten;
    int         rc;

    mp = (MocSocket*) sp->sslSocket;
    if (len <= 0) {
        assure(0);
        return -1;
    }
    totalWritten = 0;

    do {
        rc = SSL_send(mp->handle, (sbyte*) buf, (int) len);
        mprLog(7, "MOCANA: written %d, requested len %d", rc, len);
        if (rc <= 0) {
            //  MOB - should this set EOF. What about other providers?
            mprLog(0, "MOCANA: SSL_send failed rc %d", rc);
            return -1;

        } else {
            totalWritten += rc;
            buf = (void*) ((char*) buf + rc);
            len -= rc;
            mprLog(7, "MOCANA: write: len %d, written %d, total %d", len, rc, totalWritten);
        }
    } while (len > 0);
    return totalWritten;
}


#if KEEP
/*
    Called to verify X509 client certificates
    MOB -- what about this?
 */
static int verifyX509Certificate(int ok, X509_STORE_CTX *xContext)
{
    X509        *cert;
    SSL         *handle;
    MocSocket   *mp;
    MprSsl      *ssl;
    char        subject[260], issuer[260], peer[260];
    int         error, depth;
    
    subject[0] = issuer[0] = '\0';

    handle = (SSL*) X509_STORE_CTX_get_app_data(xContext);
    mp = (MocSocket*) SSL_get_app_data(handle);
    ssl = mp->sock->ssl;

    cert = X509_STORE_CTX_get_current_cert(xContext);
    depth = X509_STORE_CTX_get_error_depth(xContext);
    error = X509_STORE_CTX_get_error(xContext);

    ok = 1;
    if (X509_NAME_oneline(X509_get_subject_name(cert), subject, sizeof(subject) - 1) < 0) {
        ok = 0;
    }
    if (X509_NAME_oneline(X509_get_issuer_name(xContext->current_cert), issuer, sizeof(issuer) - 1) < 0) {
        ok = 0;
    }
    if (X509_NAME_get_text_by_NID(X509_get_subject_name(xContext->current_cert), NID_commonName, peer, 
            sizeof(peer) - 1) < 0) {
        ok = 0;
    }
    if (ok && ssl->verifyDepth < depth) {
        if (error == 0) {
            error = X509_V_ERR_CERT_CHAIN_TOO_LONG;
        }
    }
    switch (error) {
    case X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT:
        /* Normal self signed certificate */
    case X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN:
    case X509_V_ERR_CERT_UNTRUSTED:
    case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY:
        if (ssl->verifyIssuer) {
            /* Issuer can't be verified */
            ok = 0;
        }
        break;

    case X509_V_ERR_CERT_CHAIN_TOO_LONG:
    case X509_V_ERR_CERT_HAS_EXPIRED:
    case X509_V_ERR_CERT_NOT_YET_VALID:
    case X509_V_ERR_CERT_REJECTED:
    case X509_V_ERR_CERT_SIGNATURE_FAILURE:
    case X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD:
    case X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD:
    case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
    case X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE:
    case X509_V_ERR_INVALID_CA:
    default:
        ok = 0;
        break;
    }
    if (ok) {
        mprLog(3, "MOCANA: Certificate verified: subject %s", subject);
        mprLog(4, "MOCANA: Issuer: %s", issuer);
        mprLog(4, "MOCANA: Peer: %s", peer);
    } else {
        mprLog(1, "MOCANA: Certification failed: subject %s (more trace at level 4)", subject);
        mprLog(4, "MOCANA: Issuer: %s", issuer);
        mprLog(4, "MOCANA: Peer: %s", peer);
        mprLog(4, "MOCANA: Error: %d: %s", error, X509_verify_cert_error_string(error));
    }
    return ok;
}
#endif


#if UNUSED
static void mocTrace(void *fp, int level, char *str)
{
    level += 3;
    if (level <= MPR->logLevel) {
        str = sclone(str);
        str[slen(str) - 1] = '\0';
        mprLog(level, "%s", str);
    }
}
#endif

#endif /* BIT_PACK_MOCANA */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */

/************************************************************************/
/*
    Start of file "src/ssl/ssl.c"
 */
/************************************************************************/

/**
    ssl.c -- Initialization for libmprssl. Load the SSL provider.

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************* Includes ***********************************/

#include    "mpr.h"

#if BIT_SSL
/************************************ Code ************************************/
/*
    Module initialization entry point
 */
PUBLIC int mprSslInit(void *unused, MprModule *module)
{
    assure(module);

    /*
        Order matters. The last enabled stack becomes the default.
     */
#if BIT_PACK_MATRIXSSL
    if (mprCreateMatrixSslModule() < 0) {
        return MPR_ERR_CANT_OPEN;
    }
    MPR->socketService->defaultProvider = sclone("matrixssl");
#endif
#if BIT_PACK_MOCANA
    if (mprCreateMocanaModule() < 0) {
        return MPR_ERR_CANT_OPEN;
    }
    MPR->socketService->defaultProvider = sclone("mocana");
#endif
#if BIT_PACK_OPENSSL
    if (mprCreateOpenSslModule() < 0) {
        return MPR_ERR_CANT_OPEN;
    }
    MPR->socketService->defaultProvider = sclone("openssl");
#endif
#if BIT_PACK_EST
    if (mprCreateEstModule() < 0) {
        return MPR_ERR_CANT_OPEN;
    }
    MPR->socketService->defaultProvider = sclone("est");
#endif
    return 0;
}

#endif /* BLD_PACK_SSL */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
