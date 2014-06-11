//
//  SSLSocket.cpp
//  PushTestTool
//
//  Created by Fish on 14-6-5.
//  Copyright (c) 2014年 Fish. All rights reserved.
//

#include "SSLSocket.h"


SSLSocket::SSLSocket():ctx(NULL),ssl(NULL),sockfd(0)
{
    
}

SSLSocket::~SSLSocket()
{
    
}

//初始化SSL
void SSLSocket::initSSL(char* cert, char* key,char* password)
{
    // 算法初始化
    SSL_library_init();
    // 加载SSL错误信息
    SSL_load_error_strings();
    // 添加SSL的加密/HASH算法
    SSLeay_add_ssl_algorithms();
    // 建立新的SSL上下文
    ctx = SSL_CTX_new(SSLv23_client_method());
    if(!ctx) return;
    // 设置证书文件的口令
    SSL_CTX_set_default_passwd_cb_userdata(ctx, password);
    //加载本地证书文件
    int status = SSL_CTX_use_certificate_file(ctx, cert, SSL_FILETYPE_PEM);
    
    if (status <= 0) {
        printf("Use cert fail, status=%d\n", status);
        goto error;
    }
    // 加载私钥文件
    if (SSL_CTX_use_PrivateKey_file(ctx, key, SSL_FILETYPE_PEM) <= 0) {
        printf("Use private key fail\n");
        goto error;
    }
    // 检查证书和私钥是否匹配
    if (!SSL_CTX_check_private_key(ctx)) {
        printf("Private key does not match the certificate public key");
        goto error;
    }
    
    printf("Cert and key OK\n");
    return;
    
error:
    SSL_CTX_free (ctx);
    ctx = NULL;
}

//建立SSL连接
int SSLSocket::connectSSL(char* server, int port)
{
    if (!ctx) return 9; //SSL上下文为空
    
    //连接服务器
    struct sockaddr_in    servaddr;
    struct hostent*       host;
    
    if((host = gethostbyname(server)) == NULL)
    {
        printf("Host not found");
        return 8;
    }

    //创建一个 socket 用于 tcp 通信s
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("Socket error");
        return 1; //socket错误
    }
    
    printf("socket created\n");
    
    //初始化服务器端（对方）的地址和端口信息
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port   = htons(port);
    servaddr.sin_addr   = *((struct in_addr *)host->h_addr);
    
    /*
    struct sockaddr_in dest;
    bzero(&dest, sizeof(dest));
    dest.sin_family = AF_INET;
    dest.sin_port = htons(port);
    if (inet_aton(server, (struct in_addr *) &dest.sin_addr.s_addr) == 0)
    {
        printf("Address error");
        return 2; //转换地址错误
    }
    
    printf("address created\n");
    */
    
    /* 连接服务器 */
    if(connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) < 0)
    {
        printf("Connect error");
        return 3; //
    }
    
    printf("server connected\n\n");
    
    //基于 ctx 产生一个新的 SSL
    ssl = SSL_new(ctx);
    //设置socket
    SSL_set_fd(ssl, sockfd);
    
    //建立 SSL 连接
    if (SSL_connect(ssl) == -1)
    {
        printf("SSL Connect error");
        return 4; //ssl connect error
    }
    else
    {  
        printf("Connected with %s encryption\n", SSL_get_cipher(ssl));
    }
    
    return 0;
}

//关闭SSL连接
void SSLSocket::closeSSL()
{
    if (sockfd) close(sockfd);
    sockfd = 0;
    
    if (ssl) SSL_free(ssl);
    ssl = NULL;
    
    if (ctx) SSL_CTX_free (ctx);
    ctx = NULL;
}


//发送数据
int SSLSocket::send(const char* data,int len)
{
    if (!ssl) return -1;
    
    int ret = SSL_write(ssl, data, len);
    
    return ret; //-1 代表错误
}







