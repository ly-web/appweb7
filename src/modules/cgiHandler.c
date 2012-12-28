/* 
    cgiHandler.c -- Common Gateway Interface Handler

    Support the CGI/1.1 standard for external gateway programs to respond to HTTP requests.
    This CGI handler uses async-pipes and non-blocking I/O for all communications.
 
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/*********************************** Includes *********************************/

#include    "appweb.h"

#if BIT_PACK_CGI
/************************************ Locals ***********************************/

typedef struct Cgi {
    HttpConn    *conn;                  /**< Client connection object */
    MprCmd      *cmd;                   /**< CGI command object */
    HttpQueue   *writeq;                /**< Queue to write to the CGI */
    HttpQueue   *readq;                 /**< Queue to read from the CGI */
    HttpPacket  *headers;               /**< CGI response headers */
    char        *location;              /**< Redirection location */
    int         seenHeader;             /**< Parsed response header from CGI */
} Cgi;

/*********************************** Forwards *********************************/

static void browserToCgiService(HttpQueue *q);
static void buildArgs(HttpConn *conn, MprCmd *cmd, int *argcp, cchar ***argvp);
static void cgiCallback(MprCmd *cmd, int channel, void *data);
static void cgiToBrowserData(HttpQueue *q, HttpPacket *packet);
static int copyVars(cchar **envv, int index, MprHash *vars, cchar *prefix);
static char *getCgiToken(MprBuf *buf, cchar *delim);
static void manageCgi(Cgi *cgi, int flags);
static bool parseFirstCgiResponse(Cgi *cgi, HttpPacket *packet);
static bool parseCgiHeaders(Cgi *cgi, HttpPacket *packet);
static void readFromCgi(Cgi *cgi, int channel);

#if BIT_DEBUG
    static void traceCGIData(MprCmd *cmd, char *src, ssize size);
    #define traceData(cmd, src, size) traceCGIData(cmd, src, size)
#else
    #define traceData(cmd, src, size)
#endif

#if BIT_WIN_LIKE || VXWORKS
    static void findExecutable(HttpConn *conn, char **program, char **script, char **bangScript, char *fileName);
#endif
#if BIT_WIN_LIKE
    static void checkCompletion(HttpQueue *q, MprEvent *event);
    static void waitForCgi(Cgi *cgi, MprEvent *event);
#endif

/************************************* Code ***********************************/
/*
    Open the handler for a new request
 */
static void openCgi(HttpQueue *q)
{
    HttpRx      *rx;
    HttpConn    *conn;
    Cgi         *cgi;

    conn = q->conn;
    rx = conn->rx;
    mprLog(5, "Open CGI handler");
    if (!httpValidateLimits(conn->endpoint, HTTP_VALIDATE_OPEN_PROCESS, q->conn)) {
        /* Too many active CGI processes */
        return;
    }
    if (rx->flags & (HTTP_OPTIONS | HTTP_TRACE)) {
        httpHandleOptionsTrace(q->conn, "DELETE,GET,HEAD,POST,PUT");
    } else {
        httpTrimExtraPath(q->conn);
        httpMapFile(q->conn, rx->route);
        httpCreateCGIParams(q->conn);
    }
    if ((cgi = mprAllocObj(Cgi, manageCgi)) == 0) {
        return;
    }
    q->queueData = q->pair->queueData = cgi;
    cgi->conn = conn;
    cgi->readq = httpCreateQueue(conn, conn->http->cgiConnector, HTTP_QUEUE_RX, 0);
    cgi->writeq = httpCreateQueue(conn, conn->http->cgiConnector, HTTP_QUEUE_TX, 0);
    cgi->readq->pair = cgi->writeq;
    cgi->writeq->pair = cgi->readq;
    cgi->writeq->queueData = cgi->readq->queueData = cgi;
}


static void manageCgi(Cgi *cgi, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(cgi->conn);
        mprMark(cgi->writeq);
        mprMark(cgi->readq);
        mprMark(cgi->cmd);
        mprMark(cgi->headers);
        mprMark(cgi->location);
    } else {
        if (cgi->cmd) {
            /* Just for safety */
            mprDestroyCmd(cgi->cmd);
        }
    }
}


static void closeCgi(HttpQueue *q)
{
    Cgi     *cgi;
    MprCmd  *cmd;

    mprLog(5, "CGI: close");
    cgi = q->queueData;
    cmd = cgi->cmd;
    if (cmd) {
        mprSetCmdCallback(cmd, NULL, NULL);
        mprDestroyCmd(cmd);
    }
    httpValidateLimits(q->conn->endpoint, HTTP_VALIDATE_CLOSE_PROCESS, q->conn);
}


/*  
    Start the CGI command program. This commences the CGI gateway program. This will be called after content for
    form and upload requests (or if "RunHandler" before specified), otherwise it runs before receiving content data.
 */
static void startCgi(HttpQueue *q)
{
    HttpRx          *rx;
    HttpTx          *tx;
    HttpConn        *conn;
    MprCmd          *cmd;
    Cgi             *cgi;
    cchar           *baseName;
    cchar           **argv, *fileName;
    cchar           **envv;
    int             argc, varCount, count;

    argv = 0;
    argc = 0;
    cgi = q->queueData;
    conn = q->conn;
    rx = conn->rx;
    tx = conn->tx;
    mprLog(5, "CGI: Start");

    /*
        The command uses the conn dispatcher. This serializes all I/O for both the connection and the CGI gateway.
     */
    if ((cmd = mprCreateCmd(conn->dispatcher)) == 0) {
        return;
    }
    cgi->cmd = cmd;

    if (conn->http->forkCallback) {
        cmd->forkCallback = conn->http->forkCallback;
        cmd->forkData = conn->http->forkData;
    }
    argc = 1;                                   /* argv[0] == programName */
    buildArgs(conn, cmd, &argc, &argv);
    fileName = argv[0];
    baseName = mprGetPathBase(fileName);
    
    /*
        nph prefix means non-parsed-header. Don't parse the CGI output for a CGI header
     */
    if (strncmp(baseName, "nph-", 4) == 0 || 
            (strlen(baseName) > 4 && strcmp(&baseName[strlen(baseName) - 4], "-nph") == 0)) {
        /* Pretend we've seen the header for Non-parsed Header CGI programs */
        cgi->seenHeader = 1;
        tx->flags |= HTTP_TX_USE_OWN_HEADERS;
    }
    /*  
        Build environment variables
     */
    varCount = mprGetHashLength(rx->headers) + mprGetHashLength(rx->svars);
    if (rx->params) {
        varCount += mprGetHashLength(rx->params);
    }
    if ((envv = mprAlloc((varCount + 1) * sizeof(char*))) != 0) {
        count = copyVars(envv, 0, rx->params, "");
        count = copyVars(envv, 0, rx->svars, "");
        count = copyVars(envv, count, rx->headers, "HTTP_");
        assure(count <= varCount);
    }
#if !VXWORKS
    /*
        This will be ignored on VxWorks because there is only one global current directory for all tasks
     */
    mprSetCmdDir(cmd, mprGetPathDir(fileName));
#endif
    mprSetCmdCallback(cmd, cgiCallback, cgi);

    if (mprStartCmd(cmd, argc, argv, envv, MPR_CMD_IN | MPR_CMD_OUT | MPR_CMD_ERR) < 0) {
        httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot run CGI process: %s, URI %s", fileName, rx->uri);
        return;
    }
#if BIT_WIN_LIKE
    /*
        Start the windows-waiter via an event. This ensures it is serialized in the request dispatcher
     */
    mprCreateEvent(conn->dispatcher, "cgi-win", 10, waitForCgi, cgi, MPR_EVENT_CONTINUOUS);
#endif
}


#if BIT_WIN_LIKE
/*
    Windows can't select on named pipes. So poll for events.
    This runs on the connection dispatcher thread. Don't actually service events here. Otherwise it becomes too
    complex with nested calls to mprWaitForEvent().
 */
static void waitForCgi(Cgi *cgi, MprEvent *event)
{
    HttpConn    *conn;
    MprCmd      *cmd;

    conn = cgi->conn;
    cmd = cgi->cmd;
    if (!cmd->complete) {
        mprPollWinCmd(cmd, 0);
        if (conn->error && cmd->pid) {
            mprStopCmd(cmd, -1);
        }
    }
}
#endif


/*
    Accept incoming body data from the client destined for the CGI gateway. This is typically POST or PUT data.
    Note: For POST "form" requests, this will be called before the command is actually started. 
 */
static void browserToCgiData(HttpQueue *q, HttpPacket *packet)
{
    HttpConn    *conn;
    Cgi         *cgi;

    assure(q);
    assure(packet);
    cgi = q->queueData;
    conn = q->conn;
    assure(q == conn->readq);

    if (httpGetPacketLength(packet) == 0) {
        /* End of input */
        if (conn->rx->remainingContent > 0) {
            /* Short incoming body data. Just kill the CGI process */
            if (cgi->cmd) {
                mprDestroyCmd(cgi->cmd);
            }
            httpError(conn, HTTP_CODE_BAD_REQUEST, "Client supplied insufficient body data");
        }
    }
    httpPutForService(cgi->writeq, packet, HTTP_SCHEDULE_QUEUE);
}


static void browserToCgiService(HttpQueue *q)
{
    HttpConn    *conn;
    HttpPacket  *packet;
    Cgi         *cgi;
    MprCmd      *cmd;
    MprBuf      *buf;
    ssize       rc, len;
    int         err;

    cgi = q->queueData;
    assure(q == cgi->writeq);
    cmd = cgi->cmd;
    assure(cmd);
    conn = cgi->conn;

    for (packet = httpGetPacket(q); packet; packet = httpGetPacket(q)) {
        if ((buf = packet->content) == 0) {
            /* End packet */
            continue;
        }
        len = mprGetBufLength(buf);
        rc = mprWriteCmd(cmd, MPR_CMD_STDIN, mprGetBufStart(buf), len);
        if (rc < 0) {
            err = mprGetError();
            if (err == EINTR) {
                continue;
            } else if (err == EAGAIN || err == EWOULDBLOCK) {
                httpPutBackPacket(q, packet);
                break;
            }
            mprLog(2, "CGI: write to gateway failed for %d bytes, rc %d, errno %d", len, rc, mprGetOsError());
            mprCloseCmdFd(cmd, MPR_CMD_STDIN);
            httpDiscardQueueData(q, 1);
            httpError(conn, HTTP_CODE_BAD_GATEWAY, "Cannot write body data to CGI gateway");
            break;
        }
        LOG(6, "CGI: browserToCgiService %d/%d, qmax %d", rc, len, q->max);
        mprAdjustBufStart(buf, rc);
        if (mprGetBufLength(buf) > 0) {
            httpPutBackPacket(q, packet);
            break;
        }
    }
    if (q->count > 0) {
        /* Wait for writable event so cgiCallback can recall this routine */
        mprEnableCmdEvents(cmd, MPR_CMD_STDIN);
    } else if (conn->rx->eof) {
        mprCloseCmdFd(cmd, MPR_CMD_STDIN);
    } else {
        mprDisableCmdEvents(cmd, MPR_CMD_STDIN);
    }
}


static void cgiToBrowserData(HttpQueue *q, HttpPacket *packet)
{
    httpPutForService(q->conn->writeq, packet, HTTP_SCHEDULE_QUEUE);
}


static void cgiToBrowserService(HttpQueue *q)
{
    HttpConn    *conn;
    MprCmd      *cmd;
    Cgi         *cgi;

    cgi = q->queueData;
    conn = q->conn;
    assure(q == conn->writeq);
    cmd = cgi->cmd;

    /*
        This will copy outgoing packets downstream toward the network connector and on to the browser. 
        This may disable the CGI queue if the downstream net connector queue overflows because the socket 
        is full. In that case, httpEnableConnEvents will setup to listen for writable events. When the 
        socket is writable again, the connector will drain its queue which will re-enable this queue 
        and schedule it for service again.
     */ 
    httpDefaultOutgoingServiceStage(q);
    if (q->count < q->low) {
        mprEnableCmdOutputEvents(cmd, 1);
        LOG(6, "CGI: ENABLE CGI events: cgiToBrowserService");
    } else if (q->count > q->max && conn->tx->writeBlocked) {
        LOG(6, "CGI: SUSPEND WRITEQ: cgiToBrowserData writeq %d/%d", conn->writeq->count, conn->writeq->max);
        httpSuspendQueue(conn->writeq);
    }
    LOG(6, "CGI: cgiToBrowserService pid %d, q->count %d, q->flags %x, blocked %d", 
        cmd->pid, q->count, q->flags, conn->tx->writeBlocked);
}


/*
    Read the output data from the CGI script and return it to the client. This is called by the MPR in response to
    I/O events from the CGI process for stdout/stderr data from the CGI script and for EOF from the CGI's stdin.
    This event runs on the connection's dispatcher. (ie. single threaded and safe)
 */
static void cgiCallback(MprCmd *cmd, int channel, void *data)
{
    HttpConn    *conn;
    Cgi         *cgi;
    int         suspended;

    cgi = data;
    if ((conn = cgi->conn) == 0) {
        return;
    }
    conn->lastActivity = conn->http->now;
    LOG(6, "CGI: cgiCallback event channel %d", channel);

    switch (channel) {
    case MPR_CMD_STDIN:
        /* Stdin can absorb more data */
        httpResumeQueue(cgi->writeq);
        break;

    case MPR_CMD_STDOUT:
    case MPR_CMD_STDERR:
        readFromCgi(cgi, channel);
        break;
            
    default:
        /* Child death notification */
        break;
    }
    if (cgi->location) {
        httpRedirect(conn, conn->tx->status, cgi->location);
    }
    if (cmd->complete || cgi->location) {
        cgi->location = 0;
        httpFinalize(conn);
        httpServiceQueues(conn);
        httpPumpRequest(conn, NULL);
        /* WARNING: this will complete this request and prep for the next */
        httpPostEvent(conn);
        return;
    } 
    httpServiceQueues(conn);
    if (channel >= 0 && conn->state <= HTTP_STATE_FINALIZED) {
        httpEnableConnEvents(conn);
        mprLog(6, "CGI: ENABLE CONN: cgiCallback mask %x", conn->sock->handler ? conn->sock->handler->desiredMask : 0);
    }
    suspended = httpIsQueueSuspended(conn->writeq);
    mprLog(6, "CGI: %s CGI: cgiCallback. Conn->writeq %d", suspended ? "DISABLE" : "ENABLE", conn->writeq->count);
    assure(!suspended || conn->tx->writeBlocked);
    mprEnableCmdOutputEvents(cmd, !suspended);

    if (conn->state == HTTP_STATE_FINALIZED) {
        httpPumpRequest(conn, NULL);
        /* WARNING: the request may be completed here */
    }
}


static void readFromCgi(Cgi *cgi, int channel)
{
    HttpConn    *conn;
    HttpPacket  *packet;
    HttpTx      *tx;
    HttpQueue   *q, *writeq;
    MprCmd      *cmd;
    ssize       nbytes;
    int         err;

    cmd = cgi->cmd;
    conn = cgi->conn;
    tx = conn->tx;
    q = cgi->readq;
    writeq = conn->writeq;
    assure(conn->sock);
    assure(conn->state > HTTP_STATE_BEGIN);

    if (tx->finalized) {
        mprCloseCmdFd(cmd, channel);
    }
    while (mprGetCmdFd(cmd, channel) >= 0 && !tx->finalized && writeq->count < writeq->max) {
        if ((packet = cgi->headers) != 0) {
            if (mprGetBufSpace(packet->content) < BIT_MAX_BUFFER && mprGrowBuf(packet->content, BIT_MAX_BUFFER) < 0) {
                break;
            }
        } else if ((packet = httpCreateDataPacket(BIT_MAX_BUFFER)) == 0) {
            break;
        }
        nbytes = mprReadCmd(cmd, channel, mprGetBufEnd(packet->content), BIT_MAX_BUFFER);
        if (nbytes < 0) {
            err = mprGetError();
            if (err == EINTR) {
                continue;
            } else if (err == EAGAIN || err == EWOULDBLOCK) {
                break;
            }
            mprLog(6, "CGI: Gateway read error %d for %s", err, (channel == MPR_CMD_STDOUT) ? "stdout" : "stderr");
            mprCloseCmdFd(cmd, channel);
            break;
            
        } else if (nbytes == 0) {
            mprLog(6, "CGI: Gateway EOF for %s, pid %d", (channel == MPR_CMD_STDOUT) ? "stdout" : "stderr", cmd->pid);
            mprCloseCmdFd(cmd, channel);
            break;

        } else {
            mprLog(6, "CGI: Gateway read %d bytes from %s", nbytes, (channel == MPR_CMD_STDOUT) ? "stdout" : "stderr");
            traceData(cmd, mprGetBufEnd(packet->content), nbytes);
            mprAdjustBufEnd(packet->content, nbytes);
        }
        if (channel == MPR_CMD_STDERR) {
            mprError("CGI: Error for \"%s\"\n\n%s", conn->rx->uri, mprGetBufStart(packet->content));
            httpSetStatus(conn, HTTP_CODE_SERVICE_UNAVAILABLE);
            cgi->seenHeader = 1;
        }
        if (!cgi->seenHeader) {
            if (!parseCgiHeaders(cgi, packet)) {
                cgi->headers = packet;
                return;
            }
            cgi->headers = 0;
            cgi->seenHeader = 1;
        } 
        if (!tx->finalizedOutput && httpGetPacketLength(packet) > 0) {
            /* Put the data to the CGI readq, then cgiToBrowserService will take care of it */
            httpPutPacket(q, packet);
        }
    }
}


/*
    Parse the CGI output headers. Sample CGI program output:
        Content-type: text/html

        <html.....
 */
static bool parseCgiHeaders(Cgi *cgi, HttpPacket *packet)
{
    HttpConn    *conn;
    MprBuf      *buf;
    char        *endHeaders, *headers, *key, *value;
    ssize       blen;
    int         len;

    conn = cgi->conn;
    value = 0;
    buf = packet->content;
    headers = mprGetBufStart(buf);
    blen = mprGetBufLength(buf);
    
    /*
        Split the headers from the body. Add null to ensure we can search for line terminators.
     */
    len = 0;
    if ((endHeaders = sncontains(headers, "\r\n\r\n", blen)) == NULL) {
        if ((endHeaders = sncontains(headers, "\n\n", blen)) == NULL) {
            if (mprGetCmdFd(cgi->cmd, MPR_CMD_STDOUT) >= 0 && strlen(headers) < BIT_MAX_HEADERS) {
                /* Not EOF and less than max headers and have not yet seen an end of headers delimiter */
                return 0;
            }
        } 
        len = 2;
    } else {
        len = 4;
    }
    if (endHeaders > buf->end) {
        assure(endHeaders <= buf->end);
        return 0;
    }
    if (endHeaders) {
        endHeaders[len - 1] = '\0';
        endHeaders += len;
    }
    /*
        Want to be tolerant of CGI programs that omit the status line.
     */
    if (strncmp((char*) buf->start, "HTTP/1.", 7) == 0) {
        if (!parseFirstCgiResponse(cgi, packet)) {
            /* httpError already called */
            return 0;
        }
    }
    if (endHeaders && strchr(mprGetBufStart(buf), ':')) {
        while (mprGetBufLength(buf) > 0 && buf->start[0] && (buf->start[0] != '\r' && buf->start[0] != '\n')) {
            if ((key = getCgiToken(buf, ":")) == 0) {
                key = "Bad Header";
            }
            value = getCgiToken(buf, "\n");
            while (isspace((uchar) *value)) {
                value++;
            }
            mprLog(4, "CGI: parseCgiHeader: key %s = %s", key, value);
            len = (int) strlen(value);
            while (len > 0 && (value[len - 1] == '\r' || value[len - 1] == '\n')) {
                value[len - 1] = '\0';
                len--;
            }
            key = slower(key);

            if (strcmp(key, "location") == 0) {
                cgi->location = value;

            } else if (strcmp(key, "status") == 0) {
                httpSetStatus(conn, atoi(value));

            } else if (strcmp(key, "content-type") == 0) {
                httpSetHeaderString(conn, "Content-Type", value);

            } else if (strcmp(key, "content-length") == 0) {
                httpSetContentLength(conn, (MprOff) stoi(value));
                httpSetChunkSize(conn, 0);

            } else {
                /*
                    Now pass all other headers back to the client
                 */
                httpSetHeader(conn, key, "%s", value);
            }
        }
        buf->start = endHeaders;
    }
#if UNUSED
    if (location) {
        httpRedirect(conn, tx->status, location);
        if (conn->state == HTTP_STATE_FINALIZED) {
            httpPumpRequest(conn, NULL);
            /* WARNING: the request may be completed here */
        }
    }
#endif
    return 1;
}


/*
    Parse the CGI output first line
 */
static bool parseFirstCgiResponse(Cgi *cgi, HttpPacket *packet)
{
    MprBuf      *buf;
    char        *protocol, *status, *message;
    
    buf = packet->content;
    protocol = getCgiToken(buf, " ");
    if (protocol == 0 || protocol[0] == '\0') {
        httpError(cgi->conn, HTTP_CODE_BAD_GATEWAY, "Bad CGI HTTP protocol response");
        return 0;
    }
    if (strncmp(protocol, "HTTP/1.", 7) != 0) {
        httpError(cgi->conn, HTTP_CODE_BAD_GATEWAY, "Unsupported CGI protocol");
        return 0;
    }
    status = getCgiToken(buf, " ");
    if (status == 0 || *status == '\0') {
        httpError(cgi->conn, HTTP_CODE_BAD_GATEWAY, "Bad CGI header response");
        return 0;
    }
    message = getCgiToken(buf, "\n");
    mprLog(4, "CGI: Status line: %s %s %s", protocol, status, message);
    return 1;
}


/*
    Build the command arguments. NOTE: argv is untrusted input.
 */
static void buildArgs(HttpConn *conn, MprCmd *cmd, int *argcp, cchar ***argvp)
{
    HttpRx      *rx;
    HttpTx      *tx;
    char        **argv;
    char        *fileName, *indexQuery, *cp, *tok;
    cchar       *actionProgram;
    size_t      len;
    int         argc, argind, i;

    rx = conn->rx;
    tx = conn->tx;

    fileName = tx->filename;
    assure(fileName);

    actionProgram = 0;
    argind = 0;
    argc = *argcp;

    if (tx->ext) {
        actionProgram = mprGetMimeProgram(rx->route->mimeTypes, tx->ext);
        if (actionProgram != 0) {
            argc++;
        }
        /*
            This is an Apache compatible hack for PHP 5.3
         */
        mprAddKey(rx->headers, "REDIRECT_STATUS", itos(HTTP_CODE_MOVED_TEMPORARILY));
    }
    /*
        Count the args for ISINDEX queries. Only valid if there is not a "=" in the query. 
        If this is so, then we must not have these args in the query env also?
     */
    indexQuery = rx->parsedUri->query;
    if (indexQuery && !strchr(indexQuery, '=')) {
        argc++;
        for (cp = indexQuery; *cp; cp++) {
            if (*cp == '+') {
                argc++;
            }
        }
    } else {
        indexQuery = 0;
    }

#if BIT_WIN_LIKE || VXWORKS
{
    char    *bangScript, *cmdBuf, *program, *cmdScript;

    /*
        On windows we attempt to find an executable matching the fileName.
        We look for *.exe, *.bat and also do unix style processing "#!/program"
     */
    findExecutable(conn, &program, &cmdScript, &bangScript, fileName);
    assure(program);

    if (cmdScript) {
        /*
            Cmd/Batch script (.bat | .cmd)
            Convert the command to the form where there are 4 elements in argv
            that cmd.exe can interpret.

                argv[0] = cmd.exe
                argv[1] = /Q
                argv[2] = /C
                argv[3] = ""script" args ..."
         */
        argc = 4;

        len = (argc + 1) * sizeof(char*);
        argv = (char**) mprAlloc(len);
        memset(argv, 0, len);

        argv[argind++] = program;               /* Duped in findExecutable */
        argv[argind++] = "/Q";
        argv[argind++] = "/C";

        len = strlen(cmdScript) + 2 + 1;
        cmdBuf = mprAlloc(len);
        fmt(cmdBuf, len, "\"%s\"", cmdScript);
        argv[argind++] = cmdBuf;

        mprSetCmdDir(cmd, cmdScript);
        /*  program will get freed when argv[] gets freed */
        
    } else if (bangScript) {
        /*
            Script used "#!/program". NOTE: this may be overridden by a mime Action directive.
         */
        argc++;     /* Adding bangScript arg */

        len = (argc + 1) * sizeof(char*);
        argv = (char**) mprAlloc(len);
        memset(argv, 0, len);

        argv[argind++] = program;       /* Will get freed when argv[] is freed */
        argv[argind++] = bangScript;    /* Will get freed when argv[] is freed */
        mprSetCmdDir(cmd, bangScript);

    } else {
        /*
            Either unknown extension or .exe (.out) program.
         */
        len = (argc + 1) * sizeof(char*);
        argv = (char**) mprAlloc(len);
        memset(argv, 0, len);
        if (actionProgram) {
            argv[argind++] = sclone(actionProgram);
        }
        argv[argind++] = program;
    }
}
#else
    len = (argc + 1) * sizeof(char*);
    argv = mprAlloc(len);
    memset(argv, 0, len);

    if (actionProgram) {
        argv[argind++] = sclone(actionProgram);
    }
    //  OPT - why clone all these string?
    argv[argind++] = sclone(fileName);
#endif
    /*
        ISINDEX queries. Only valid if there is not a "=" in the query. If this is so, then we must not
        have these args in the query env also?
        TODO - should query vars be set in the env?
     */
    if (indexQuery) {
        indexQuery = sclone(indexQuery);
        cp = stok(indexQuery, "+", &tok);
        while (cp) {
            argv[argind++] = mprEscapeCmd(mprUriDecode(cp), 0);
            cp = stok(NULL, "+", &tok);
        }
    }
    
    assure(argind <= argc);
    argv[argind] = 0;
    *argcp = argc;
    *argvp = (cchar**) argv;

    mprLog(5, "CGI: command:");
    for (i = 0; i < argind; i++) {
        mprLog(5, "   argv[%d] = %s", i, argv[i]);
    }
}


#if BIT_WIN_LIKE || VXWORKS
/*
    If the program has a UNIX style "#!/program" string at the start of the file that program will be selected 
    and the original program will be passed as the first arg to that program with argv[] appended after that. If 
    the program is not found, this routine supports a safe intelligent search for the command. If all else fails, 
    we just return in program the fileName we were passed in. script will be set if we are modifying the program 
    to run and we have extracted the name of the file to run as a script.
 */
static void findExecutable(HttpConn *conn, char **program, char **script, char **bangScript, char *fileName)
{
    HttpRx      *rx;
    HttpTx      *tx;
    HttpRoute   *route;
    MprKey      *kp;
    MprFile     *file;
    cchar       *actionProgram, *ext, *cmdShell, *cp, *start;
    char        *tok, buf[BIT_MAX_FNAME + 1], *path;

    rx = conn->rx;
    tx = conn->tx;
    route = rx->route;

    *bangScript = 0;
    *script = 0;
    *program = 0;
    path = 0;

    actionProgram = mprGetMimeProgram(rx->route->mimeTypes, rx->mimeType);
    ext = tx->ext;

    /*
        If not found, go looking for the fileName with the extensions defined in appweb.conf. 
        NOTE: we don't use PATH deliberately!!!
     */
    if (access(fileName, X_OK) < 0) {
        for (kp = 0; (kp = mprGetNextKey(route->extensions, kp)) != 0; ) {
            path = sjoin(fileName, ".", kp->key, NULL);
            if (access(path, X_OK) == 0) {
                break;
            }
            path = 0;
        }
        if (kp) {
            ext = kp->key;
        } else {
            path = fileName;
        }

    } else {
        path = fileName;
    }
    assure(path && *path);

#if BIT_WIN_LIKE
    if (ext && (strcmp(ext, ".bat") == 0 || strcmp(ext, ".cmd") == 0)) {
        /*
            Let a mime action override COMSPEC
         */
        if (actionProgram) {
            cmdShell = actionProgram;
        } else {
            cmdShell = getenv("COMSPEC");
        }
        if (cmdShell == 0) {
            cmdShell = "cmd.exe";
        }
        *script = sclone(path);
        *program = sclone(cmdShell);
        return;
    }
#endif

    if (actionProgram) {
        *program = sclone(actionProgram);

    } else if ((file = mprOpenFile(path, O_RDONLY, 0)) != 0) {
        if (mprReadFile(file, buf, BIT_MAX_FNAME) > 0) {
            mprCloseFile(file);
            buf[BIT_MAX_FNAME] = '\0';
            if (buf[0] == '#' && buf[1] == '!') {
                cp = start = &buf[2];
                cmdShell = stok(&buf[2], "\r\n", &tok);
                if (!mprIsPathAbs(cmdShell)) {
                    /*
                        If we can't access the command shell and the command is not an absolute path, 
                        look in the same directory as the script.
                     */
                    if (mprPathExists(cmdShell, X_OK)) {
                        cmdShell = mprJoinPath(mprGetPathDir(path), cmdShell);
                    }
                }
                *program = sclone(cmdShell);
                *bangScript = sclone(path);
                return;
            }
        } else {
            mprCloseFile(file);
        }
    }

    if (actionProgram) {
        *program = sclone(actionProgram);
        *bangScript = sclone(path);
    } else {
        *program = sclone(path);
    }
    return;
}
#endif
 

/*
    Get the next input token. The content buffer is advanced to the next token. This routine always returns a 
    non-zero token. The empty string means the delimiter was not found.
 */
static char *getCgiToken(MprBuf *buf, cchar *delim)
{
    char    *token, *nextToken;
    ssize   len;

    len = mprGetBufLength(buf);
    if (len == 0) {
        return "";
    }
    token = mprGetBufStart(buf);
    nextToken = sncontains(mprGetBufStart(buf), delim, len);
    if (nextToken) {
        *nextToken = '\0';
        len = (int) strlen(delim);
        nextToken += len;
        buf->start = nextToken;

    } else {
        buf->start = mprGetBufEnd(buf);
    }
    return token;
}


#if BIT_DEBUG
/*
    Trace output first part of output received from the cgi process
 */
static void traceCGIData(MprCmd *cmd, char *src, ssize size)
{
    char    dest[512];
    int     index, i;

    if (mprGetLogLevel() >= 5) {
        mprRawLog(5, "CGI: process wrote (leading %d bytes) => \n", min(sizeof(dest), size));
        for (index = 0; index < size; ) { 
            for (i = 0; i < (sizeof(dest) - 1) && index < size; i++) {
                dest[i] = src[index];
                index++;
            }
            dest[i] = '\0';
            mprRawLog(5, "%s", dest);
        }
        mprRawLog(5, "\n");
    }
}
#endif


static int copyVars(cchar **envv, int index, MprHash *vars, cchar *prefix)
{
    MprKey  *kp;
    char    *cp;

    for (ITERATE_KEYS(vars, kp)) {
        if (kp->data) {
            if (prefix) {
                cp = sjoin(prefix, kp->key, "=", (char*) kp->data, NULL);
            } else {
                cp = sjoin(kp->key, "=", (char*) kp->data, NULL);
            }
            envv[index] = cp;
            for (; *cp != '='; cp++) {
                if (*cp == '-') {
                    *cp = '_';
                } else {
                    *cp = toupper((uchar) *cp);
                }
            }
            index++;
        }
    }
    envv[index] = 0;
    return index;
}


static int actionDirective(MaState *state, cchar *key, cchar *value)
{
    char    *mimeType, *program;

    if (!maTokenize(state, value, "%S %S", &mimeType, &program)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    mprSetMimeProgram(state->route->mimeTypes, mimeType, program);
    return 0;
}


static int scriptAliasDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    char        *prefix, *path;

    if (!maTokenize(state, value, "%S %S", &prefix, &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    route = httpCreateAliasRoute(state->route, prefix, path, 0);
    httpSetRouteHandler(route, "cgiHandler");
    httpSetRoutePattern(route, sfmt("^%s(.*)$", prefix), 0);
    httpSetRouteTarget(route, "run", "$1");
    httpFinalizeRoute(route);
    mprLog(4, "ScriptAlias \"%s\" for \"%s\"", prefix, path);
    return 0;
}


/*  
    Loadable module initialization
 */
PUBLIC int maCgiHandlerInit(Http *http, MprModule *module)
{
    HttpStage   *handler, *connector;
    MaAppweb    *appweb;

    if ((handler = httpCreateHandler(http, "cgiHandler", module)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    http->cgiHandler = handler;
    handler->close = closeCgi; 
    handler->outgoingService = cgiToBrowserService;
    handler->incoming = browserToCgiData; 
    handler->open = openCgi; 
    handler->start = startCgi; 

    if ((connector = httpCreateConnector(http, "cgiConnector", module)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    http->cgiConnector = connector;
    connector->outgoingService = browserToCgiService;
    connector->incoming = cgiToBrowserData; 

    /*
        Add configuration file directives
     */
    appweb = httpGetContext(http);
    maAddDirective(appweb, "Action", actionDirective);
    maAddDirective(appweb, "ScriptAlias", scriptAliasDirective);
    return 0;
}

#endif /* BIT_PACK_CGI */

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
