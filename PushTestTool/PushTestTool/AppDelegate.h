//
//  AppDelegate.h
//  PushTestTool
//
//  Created by Fish on 14-5-16.
//  Copyright (c) 2014年 Fish. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "ioSock.h"
#import "SSLSocket.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSString *certificatePath;
    
    /*
	otSocket          socket;
	SSLContextRef     context;
	SecKeychainRef    keychain;
	SecCertificateRef certificate;
	SecIdentityRef    identity;
    */
    
    SSLSocket*        ssl_socket;
     
    NSString*         servername;
    int               pushserver;
}

@property (assign) IBOutlet NSWindow*    window;
@property (assign) IBOutlet NSTextField* certTextField;
@property (assign) IBOutlet NSTextField* keyTextField;
@property (assign) IBOutlet NSTextField* pwdTextField;
@property (assign) IBOutlet NSTextField* dtTextField;
@property (assign) IBOutlet NSTextField* plTextField;
@property (strong) NSString*             certificatePath;
@property (strong) NSString*             keyPath;

//选择证书文件
-(IBAction)selectCertPath:(id)sender;

//选择密钥文件
-(IBAction)selectKeyPath:(id)sender;

//发送push
-(IBAction)sendPushMessage:(id)sender;

//点击服务选择
-(IBAction)selectPushServer:(id)sender;

@end
