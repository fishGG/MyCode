//
//  SSLSocket.h
//  PushTestTool
//
//  Created by Fish on 14-6-5.
//  Copyright (c) 2014年 Fish. All rights reserved.
//

#ifndef __PushTestTool__SSLSocket__
#define __PushTestTool__SSLSocket__

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

//SSL Socket
class SSLSocket
{
    
public:
    SSLSocket();
    ~SSLSocket();
    
    //初始化SSL
    void initSSL(char* cert, char* key,char* password);

    //建立SSL连接
    int connectSSL(char* server, int port);
    
    //关闭SSL连接
    void closeSSL();
    
    //发送数据
    int send(const char* data, int len);
    
public:
    SSL_CTX* ctx;
    SSL*     ssl;
    int      sockfd;

};


#endif /* defined(__PushTestTool__SSLSocket__) */
