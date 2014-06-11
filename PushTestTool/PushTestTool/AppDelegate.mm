//
//  AppDelegate.m
//  PushTestTool
//
//  Created by Fish on 14-5-16.
//  Copyright (c) 2014年 Fish. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize certTextField;
@synthesize keyTextField;
@synthesize pwdTextField;
@synthesize dtTextField;
@synthesize plTextField;
@synthesize certificatePath;
@synthesize keyPath;

-(id) init
{
    if (self = [super init])
    {
        certificatePath = NULL;
        keyPath         = NULL;
        
        ssl_socket = new SSLSocket();
    }
    
    return self;
}


-(void)dealloc
{
    ssl_socket->closeSSL();
    delete ssl_socket;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    pushserver = 0;

}

//点击关闭按钮以后点击dock可以重新打开程序
- (BOOL) applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	[[self window] makeKeyAndOrderFront:self];
	return NO;
}

//连接push服务
- (void)connect
{
    // Define result variable.
    //OSStatus result;
    
    if (pushserver == 0) servername = @"gateway.sandbox.push.apple.com";
    else                 servername = @"gateway.push.apple.com";
    
    int port = 2195;
    
    ssl_socket->closeSSL();
    ssl_socket->initSSL((char*)[self.certificatePath UTF8String],
                        (char*)[self.keyPath UTF8String],
                        (char*)[self.pwdTextField.stringValue UTF8String]);
    ssl_socket->connectSSL((char*)[servername UTF8String], port);
    
    //ssl_socket->initSSL((char*)[self.certificatePath UTF8String], "2", NULL);
    
    /*
    // Establish connection to server.
    PeerSpec peer;
    result = MakeServerConnection([servername UTF8String], 2195, &socket, &peer);
    NSLog(@"MakeServerConnection(): %d", result);
    // Create new SSL context.
    result = SSLNewContext(false, &context);
    NSLog(@"SSLNewContext(): %d", result);
    // Set callback functions for SSL context.
    result = SSLSetIOFuncs(context, SocketRead, SocketWrite);
    NSLog(@"SSLSetIOFuncs(): %d", result);
    // Set SSL context connection.
    result = SSLSetConnection(context, socket);
    NSLog(@"SSLSetConnection(): %d", result);
    // Set server domain name.
    result = SSLSetPeerDomainName(context, [servername UTF8String], 30);
    NSLog(@"SSLSetPeerDomainName(): %d", result);
    // Open keychain.
    result = SecKeychainCopyDefault(&keychain);
    NSLog(@"SecKeychainOpen(): %d", result);
    
    // Create certificate.
    NSData *certificateData = [NSData dataWithContentsOfFile:self.certificatePath];
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    if (certificate == NULL)
        NSLog (@"SecCertificateCreateWithData failled");
    
    // Create identity.
    result = SecIdentityCreateWithCertificate(keychain, certificate, &identity);
    NSLog(@"SecIdentityCreateWithCertificate(): %d", result);
    
    // Set client certificate.
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)&identity, 1, NULL);
    result = SSLSetCertificate(context, certificates);
    NSLog(@"SSLSetCertificate(): %d", result);
    CFRelease(certificates);
    
    // Perform SSL handshake.
    do {
        result = SSLHandshake(context);
        NSLog(@"SSLHandshake(): %d", result);
    } while(result == errSSLWouldBlock);
    */
	
}

-(void)disconnect
{
    ssl_socket->closeSSL();
    
    /*
	// Define result variable.
	OSStatus result;
	// Close SSL session.
	result = SSLClose(context);
	NSLog(@"SSLClose(): %d", result);
	// Release identity.
	CFRelease(identity);
	// Release certificate.
	CFRelease(certificate);
	// Release keychain.
	CFRelease(keychain);
	// Close connection to server.
	close((int)socket);
	// Delete SSL context.
	result = SSLDisposeContext(context);
	NSLog(@"SSLDisposeContext(): %d", result);
    */
}

//发送
-(void)push:(NSString*)dt playload:(NSString*)pl
{
	// Convert string into device token data.
	
    NSString* deviceToken = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"device token : %@",deviceToken);
    
    if ([deviceToken length] % 2 != 0) return;
    
    //字符串转化为字节
    NSMutableData *deviceTokenData = [NSMutableData data];
    
    for(int i=0;i<[deviceToken length];i+=2)
    {
        NSString* subStr = [deviceToken substringWithRange:NSMakeRange(i, 2)];
        unsigned char value;
        sscanf([subStr UTF8String],"%x",&value);
        [deviceTokenData appendBytes:&value length:sizeof(unsigned char)];
    }
    
    NSLog(@"dev1: %@",[deviceTokenData description]);
    
    //<03adb9a8 242b0b99 efb6e91d add4e8ef 3fd9c085 c2159f5d 2ca70d8a 93f1b572>
    //<03adb9a8 242b0b99 efb6e91d add4e8ef 3fd9c085 c2159f5d 2ca70d8a 93f1b572>
    /*
    deviceTokenData = [NSMutableData data];

	unsigned value;
	NSScanner *scanner = [NSScanner scannerWithString:dt];
	while(![scanner isAtEnd]) {
		[scanner scanHexInt:&value];
		value = htonl(value);
		[deviceTokenData appendBytes:&value length:sizeof(value)];
    }
    
    NSLog(@"dev2: %@",[deviceTokenData description]);*/

	char *deviceTokenBinary = (char *)[deviceTokenData bytes];
	char *payloadBinary = (char *)[pl UTF8String];
	size_t payloadLength = strlen(payloadBinary);
	
	// Define some variables.
	uint8_t command = 0;
	char message[293];
	char *pointer = message;
	uint16_t networkTokenLength = htons(32);
	uint16_t networkPayloadLength = htons(payloadLength);
	
	// Compose message.
	memcpy(pointer, &command, sizeof(uint8_t));
	pointer += sizeof(uint8_t);
	memcpy(pointer, &networkTokenLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
	memcpy(pointer, deviceTokenBinary, 32);
	pointer += 32;
	memcpy(pointer, &networkPayloadLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
    
	memcpy(pointer, payloadBinary, payloadLength);
	pointer += payloadLength;
	
	// Send message over SSL.
    int ret = ssl_socket->send((char*)&message, (int)(pointer - message));

    NSLog(@"send ret: %d",ret);
    //1424ad6aebe87aae8243868852b4158ee339cf5cdbd95e39f677e100e7f9c9f6
    //ce4f2014149fa586727438c11e1e14849019f672eb5e7a658a6e020536e46316
    
    /*
	size_t processed = 0;
	OSStatus result = SSLWrite(context, &message, (pointer - message), &processed);
	NSLog(@"SSLWrite(): %d %zu", result, processed);
    */
}

//选择证书文件
-(IBAction)selectCertPath:(id)sender
{
    //文件对话框
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    //可以选中文件
    [panel setCanChooseFiles:YES];
    //不可以选择目录
    [panel setCanChooseDirectories:NO];
    //不允许多选
    [panel setAllowsMultipleSelection:NO];
    //点击按钮
    NSInteger clicked = [panel runModal];
    //如果点击是OK按钮
    if (clicked == NSFileHandlingPanelOKButton)
    {
        self.certificatePath = [[[panel URL] description] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [certTextField setStringValue:self.certificatePath];
    }
}

//选择密钥文件
-(IBAction)selectKeyPath:(id)sender
{
    //文件对话框
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    //可以选中文件
    [panel setCanChooseFiles:YES];
    //不可以选择目录
    [panel setCanChooseDirectories:NO];
    //不允许多选
    [panel setAllowsMultipleSelection:NO];
    //点击按钮
    NSInteger clicked = [panel runModal];
    //如果点击是OK按钮
    if (clicked == NSFileHandlingPanelOKButton)
    {
        self.keyPath = [[[panel URL] description] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [keyTextField setStringValue:self.keyPath];
    }
}

//发送push
-(IBAction)sendPushMessage:(id)sender
{
    //[self push:self.dtTextField.stringValue playload:self.plTextField.stringValue];
    
    //判断必要属性不为空
    if(self.certificatePath != nil &&
       self.keyPath != nil &&
       self.pwdTextField.stringValue.length > 0 &&
       self.dtTextField.stringValue.length > 0 &&
       self.plTextField.stringValue.length > 0)
    {
        [self connect];
        NSLog(@"sendPushMessage %@ %@",self.dtTextField.stringValue,self.plTextField.stringValue);
        [self push:self.dtTextField.stringValue playload:self.plTextField.stringValue];
        [self disconnect];
    }
}

//点击服务选择
-(IBAction)selectPushServer:(id)sender
{
    NSMatrix* radio = (NSMatrix*)sender;
    
    NSLog(@"radio: %ld %ld",radio.selectedRow, (long)radio.selectedColumn);

    if(radio.selectedRow == 0) pushserver = 0;
    else                       pushserver = 1;
}

@end
