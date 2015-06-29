//
//  RongCloudModule.m
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "RongCloudLibPlugin.h"
#import "RongCloudModel.h"
#import "RongCloudConstant.h"
#import "RongCloudHandler.h"

#import <objc/runtime.h>

#define BAD_PARAMETER_CODE -10002
#define BAD_PARAMETER_MSG @"Argument Exception"

#define NOT_INIT_CODE -10000
#define NOT_INIT_MSG @"Not Init"

#define NOT_CONNECT_CODE -10001
#define NOT_CONNECT_MSG @"Not Connected"

static BOOL isInited = NO;
static BOOL isConnected = NO;

@interface RongCloudLibPlugin ()

@property (nonatomic, strong) RCMessage *sendMessage;
@property (nonatomic, strong) CDVInvokedUrlCommand *transferUrlCommand;
@property (nonatomic, strong) CDVInvokedUrlCommand *receivedMessageCommand;

- (BOOL)_confirmIfInitedAndConnectedWithRongCloud:(CDVPluginResult*)pluginResult command:(CDVInvokedUrlCommand *)command;
- (void)_notInitCallbackEvent: (CDVPluginResult*) pluginResult command:(CDVInvokedUrlCommand *)command;
- (void)_argumentsBadCallbackEvent: (CDVPluginResult*) pluginResult command:(CDVInvokedUrlCommand *)command;
- (void)_sendMessage:(RCConversationType)conversationType withTargetId:(NSString *)targetId withContent:(RCMessageContent *)messageContent withPushContent:(NSString *)pushContent withCommand:(CDVInvokedUrlCommand *)command;

@end


@implementation RongCloudLibPlugin

#pragma mark private methods
- (BOOL)_confirmIfInitedAndConnectedWithRongCloud:(CDVPluginResult*)pluginResult command:(CDVInvokedUrlCommand *)command
{
    BOOL isContinue = YES;
    if (NO == isInited) {
        isContinue            = NO;
        [self _notInitCallbackEvent:pluginResult command:command];
    }else if (NO == isConnected)
    {
        NSDictionary *_error_result    = @{@"status": ERROR, @"code":@(NOT_CONNECT_CODE), @"msg": NOT_CONNECT_MSG};
        isContinue            = NO;
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_error_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    return isContinue;
}
- (void)_notInitCallbackEvent: (CDVPluginResult*) pluginResult command:(CDVInvokedUrlCommand *)command{
    NSDictionary *_error_result      =   @{@"status": ERROR, @"code":@(NOT_INIT_CODE), @"msg": NOT_INIT_MSG};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_error_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)_argumentsBadCallbackEvent: (CDVPluginResult*) pluginResult command:(CDVInvokedUrlCommand *)command{
    NSDictionary *_error_result    = @{@"status":ERROR, @"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_error_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)_sendMessage:(RCConversationType)conversationType withTargetId:(NSString *)targetId withContent:(RCMessageContent *)messageContent withPushContent:(NSString *)pushContent withCommand:(CDVInvokedUrlCommand *)command
{
    __block CDVPluginResult* pluginResult = nil;
    __weak RongCloudLibPlugin* weakSelf = self;
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient]sendMessage:conversationType
                                                            targetId:targetId
                                                             content:messageContent
                                                         pushContent:pushContent
                                                             success:^(long messageId) {
                                                                 NSLog(@"%s", __FUNCTION__);
                                                                 
                                                                 NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                 
                                                                 [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                 
                                                                 [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                                 
                                                                 NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
                                                                 [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                             }
                                                               error:^(RCErrorCode nErrorCode, long messageId) {
                                                                   
                                                                   NSLog(@"%s", __FUNCTION__);
                                                                   NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                   
                                                                   [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                   
                                                                   [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                                   
                                                                   NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}, @"code": @(nErrorCode), @"msg": @""};
                                                                   
                                                                   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
                                                                   [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                   
                                                               }];
    
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
    NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

# pragma mark Public methods
/**
 * initialize & connection
 */
- (void)init:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    NSString *_appkey = [command argumentAtIndex:0 withDefault:nil];
    NSString *_deviceToken = [command argumentAtIndex:1 withDefault:nil];
    NSLog(@"_appkey >> %@, %@", _appkey, _deviceToken);

    CDVPluginResult* pluginResult = nil;
    
   	if (![_appkey isKindOfClass:NSString.class] /*|| ![_deviceToken isKindOfClass:NSString.class]*/) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
   	}
    
   	[[RCIMClient sharedRCIMClient] init:_appkey deviceToken:_deviceToken];
   	isInited = YES;
   	
   	NSDictionary *_result = @{@"status":SUCCESS};
   	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connect:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (NO == isInited) {
        [self _notInitCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSString *token = [command argumentAtIndex:0 withDefault:nil];
    if (![token isKindOfClass:[NSString class]]) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]connectWithToken:token success:^(NSString *userId) {
        NSLog(@"%s", __FUNCTION__);

        isConnected           = YES;
        NSDictionary *_result = @{@"status": SUCCESS, @"result": @{@"userId":userId}};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCConnectErrorCode status) {
        NSLog(@"%s, errorCode> %ld", __FUNCTION__, status);
        
        isConnected           = NO;
        NSDictionary *_error_result    = @{@"status": ERROR,@"code":@(status), @"msg": @""};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_error_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } tokenIncorrect:^{
        isConnected           = NO;
        NSDictionary *_error_result    = @{@"status": ERROR,@"code":@(0), @"msg": @"Token is wrong"};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_error_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}




- (void)reconnect:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]reconnect:^(NSString *userId) {
        //success
        isConnected = YES;
        NSDictionary *_result   =   @{@"status": SUCCESS, @"result": @{@"userId":userId}};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCConnectErrorCode status) {
        //error
        isConnected           = NO;
        NSDictionary *_err    = @{@"status": ERROR, @"code":@(status), @"msg": @""};
        
       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_err];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

}

- (void)disconnect:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    NSNumber *isReceivePush = [command argumentAtIndex:0 withDefault:nil];
    if (NO == isInited) {
        [self _notInitCallbackEvent:pluginResult command:command];
        return;
    }
    
    if (![isReceivePush isKindOfClass:[NSNumber class]]) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    if (isReceivePush) {
        
        if (1 == isReceivePush.integerValue) {
            [[RCIMClient sharedRCIMClient]disconnect:YES];
        }
        else{
            [[RCIMClient sharedRCIMClient]disconnect:NO];
        }
    }
    else{
        [[RCIMClient sharedRCIMClient]disconnect:YES];
    }
    
    isConnected           = NO;
    NSDictionary *_result = @{@"status": SUCCESS};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setConnectionStatusListener:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    _transferUrlCommand = command;
    [[RCIMClient sharedRCIMClient]setRCConnectionStatusChangeDelegate:self];
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    if (_transferUrlCommand) {
        CDVPluginResult* pluginResult = nil;
        NSDictionary *_result = @{@"status": SUCCESS, @"result":@{@"code":@(status), @"connectionStatus":@""}};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_transferUrlCommand.callbackId];
        
    }
}

/**
 * message send & receive
 */
- (void)sendTextMessage:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
 
    NSLog(@"%s", __FUNCTION__);
    
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_content                 = [command argumentAtIndex:2 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:3 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_content isKindOfClass:[NSString class]] ||
        ![_extra isKindOfClass:[NSString class]]
        ) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    RCTextMessage *rcTextMessage         = [RCTextMessage messageWithContent:_content];
    rcTextMessage.extra                  = _extra;
    
    [self _sendMessage:_conversationType withTargetId:_targetId withContent:rcTextMessage withPushContent:nil withCommand:command];
    
}

- (void)sendImageMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }


    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_imagepath                 = [command argumentAtIndex:2 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:3 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_imagepath isKindOfClass:[NSString class]] ||
        ![_extra isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSString *_truePath = _imagepath;//[self getPathWithUZSchemeURL:_imagepath];
    NSLog(@"_truePath > %@", _truePath);
    
    NSData *imageData   = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];
    UIImage* image      = [UIImage imageWithData:imageData];
    
    if (![image isKindOfClass:[UIImage class]]) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
    RCImageMessage *imageMessage         = [RCImageMessage messageWithImage:image];
    imageMessage.extra                   = _extra;
    imageMessage.thumbnailImage          = [UIImage imageWithData:[RongCloudModel compressedImageAndScalingSize:image targetSize:CGSizeMake(360.0f, 360.0f) percent:0.4f]];
    
   __weak RongCloudLibPlugin* weakSelf = self;
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient] sendImageMessage:_conversationType
                                                                  targetId:_targetId
                                                                   content:imageMessage
                                                               pushContent:nil
                                                                  progress:^(int progress, long messageId) {
                                                                      if (0 == progress) {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(0)}};
                                                                          
                                                                          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
                                                                          [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                      }else if (50 == progress)
                                                                      {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(50)}};
                                                                          
                                                                          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
                                                                          [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                      }else if (100 == progress)
                                                                      {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(100)}};
                                                                          
                                                                          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
                                                                          [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                      }
                                                                  } success:^(long messageId) {
                                                                      NSLog(@"%s", __FUNCTION__);
                                                                      
                                                                      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                                      
                                                                      
                                                                      NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
                                                                      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                      
                                                                  } error:^(RCErrorCode errorCode, long messageId) {
                                                                      NSLog(@"%s", __FUNCTION__);
                                                                      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                                      
                                                                      NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}, @"code": @(errorCode), @"msg": @""};
                                                                     
                                                                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
                                                                      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                                      
                                                                  }];
    
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
    NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)sendVoiceMessage:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
   

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_voicePath               = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_duration                = [command argumentAtIndex:3 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:4 withDefault:nil];
        
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_voicePath isKindOfClass:[NSString class]] ||
        ![_duration isKindOfClass:[NSNumber class]]||
        ![_extra isKindOfClass:[NSString class]]
        ) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSString *_truePath = _voicePath;//[self getPathWithUZSchemeURL:_voicePath];
    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
    NSData *amrData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];
    if (amrData == nil) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSData *wavData                = [[RCAMRDataConverter sharedAMRDataConverter]dcodeAMRToWAVE:amrData];
    RCVoiceMessage *rcVoiceMessage = [RCVoiceMessage messageWithAudio:wavData duration:_duration.intValue];
    rcVoiceMessage.extra           = _extra;
    [self _sendMessage:_conversationType withTargetId:_targetId withContent:rcVoiceMessage withPushContent:nil withCommand:command];
    
}

- (void)sendLocationMessage:(CDVInvokedUrlCommand *)command
{
    //need to confirm
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_latitude                = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_longitude               = [command argumentAtIndex:3 withDefault:nil];
    NSString *_locationName            = [command argumentAtIndex:4 withDefault:nil];
    NSString *_imagePath               = [command argumentAtIndex:5 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:6 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_latitude isKindOfClass:[NSNumber class]] ||
        ![_longitude isKindOfClass:[NSNumber class]] ||
        ![_locationName isKindOfClass:[NSString class]] ||
        ![_imagePath isKindOfClass:[NSString class]]||
        ![_extra isKindOfClass:[NSString class]]
        ) {
        
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSString *_truePath = _imagePath;//[self getPathWithUZSchemeURL:_imagePath];
    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    CLLocationCoordinate2D location;
    location.latitude                    = (CLLocationDegrees)[_latitude doubleValue];
    location.longitude                   = (CLLocationDegrees)[_longitude doubleValue];
    
    NSData *thumbnailData                = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];
    
    UIImage *thumbnailImage              = [UIImage imageWithData:thumbnailData];
    
    RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:thumbnailImage location:location locationName:_locationName];
    locationMessage.extra              = _extra;
    [self _sendMessage:_conversationType withTargetId:_targetId withContent:locationMessage withPushContent:nil withCommand:command];
    
}

- (void)sendRichContentMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }

    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_tiltle                  = [command argumentAtIndex:2 withDefault:nil];
    NSString *_content                 = [command argumentAtIndex:3 withDefault:nil];
    NSString *_imageUrl                = [command argumentAtIndex:4 withDefault:nil];
    NSString *_extra                   = [command argumentAtIndex:5 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_tiltle isKindOfClass:[NSString class]] ||
        ![_content isKindOfClass:[NSString class]] ||
        ![_imageUrl isKindOfClass:[NSString class]] ||
        ![_extra isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
    if (nil == _extra) {
        _extra = @"";
    }
    RCRichContentMessage  * rcRichMessage = [RCRichContentMessage messageWithTitle:_tiltle
                                                                            digest:_content
                                                                          imageURL:_imageUrl
                                                                             extra:_extra];
    
    [self _sendMessage:_conversationType withTargetId:_targetId withContent:rcRichMessage withPushContent:nil withCommand:command];
    
}
-(void)sendCommandNotificationMessage : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSString *_name                    = [command argumentAtIndex:2 withDefault:nil];
    NSString *_data                    = [command argumentAtIndex:3 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_name isKindOfClass:[NSString class]] ||
        ![_data isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    RCCommandNotificationMessage *msg    = [RCCommandNotificationMessage notificationWithName:_name data:_data];
    [self _sendMessage:_conversationType withTargetId:_targetId withContent:msg withPushContent:nil withCommand:command];
    
}

- (void)setOnReceiveMessageListener:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    _receivedMessageCommand = command;
    
    [[RCIMClient sharedRCIMClient]setReceiveMessageDelegate:self object:nil];
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
{
    NSLog(@"%s, isMainThread > %d", __FUNCTION__, [NSThread isMainThread]);
    CDVPluginResult* pluginResult = nil;
    if (_receivedMessageCommand) {
        NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:message];
        NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"message":_message, @"left":@(nLeft)}};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_receivedMessageCommand.callbackId];
    }
    
    /**
     *  Add Local Notification Event
     */
    NSNumber *nAppbackgroundMode = [[NSUserDefaults standardUserDefaults]objectForKey:kAppBackgroundMode];
    BOOL _bAppBackgroundMode = [nAppbackgroundMode boolValue];
    if (YES == _bAppBackgroundMode && 0 == nLeft) {
        //post local notification
        [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:message.conversationType targetId:message.targetId success:^(RCConversationNotificationStatus nStatus) {
            if (NOTIFY == nStatus) {
                NSString *_notificationMessae = @"您收到了一条新消息";
                
                [RongCloudModel postLocalNotification:_notificationMessae];
                
            }
        } error:^(RCErrorCode status) {
            NSLog(@"notification error code= %d",(int)status);
        }];
    }
}

/**
 * conversation
 */
- (void)getConversationList:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSArray *typeList                       = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:ConversationType_PRIVATE],
                                               [NSNumber numberWithInt:ConversationType_DISCUSSION],
                                               [NSNumber numberWithInt:ConversationType_GROUP],
                                               [NSNumber numberWithInt:ConversationType_SYSTEM],nil];
    
    NSArray *_conversationList              = [[RCIMClient sharedRCIMClient]getConversationList:typeList];
    
    NSMutableArray * _conversationListModel = nil;
    _conversationListModel                  = [RongCloudModel RCGenerateConversationListModel:_conversationList];
    
    NSDictionary *_result                   = @{@"status":SUCCESS, @"result": _conversationListModel};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getConversation:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    RCConversation *_rcConversion        = [[RCIMClient sharedRCIMClient]getConversation:_conversationType targetId:_targetId];
    NSDictionary *_ret                   = nil;
    _ret                                 = [RongCloudModel RCGenerateConversationModel:_rcConversion];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _ret};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)removeConversation:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
    BOOL isRemoved = [[RCIMClient sharedRCIMClient] removeConversation:_conversationType targetId:_targetId];
    if(isRemoved)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

- (void)clearConversations: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSArray *__conversationTypes = [command argumentAtIndex:0 withDefault:nil];
    if (![__conversationTypes isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    if (nil != __conversationTypes && [__conversationTypes count] > 0) {
        
        NSUInteger _count      = [__conversationTypes count];
        NSMutableArray *argums = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i< _count; i++) {
            RCConversationType _type = [RongCloudModel RCTransferConversationType:[__conversationTypes objectAtIndex:i]];
            [argums addObject:@(_type)];
        }
        
        BOOL __ret =[[RCIMClient sharedRCIMClient]clearConversations:argums];
        
        if(__ret)
        {
            NSDictionary *_result = @{@"status":SUCCESS};
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            NSDictionary *_result = @{@"status":ERROR};
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        
    }
    
}

- (void)setConversationToTop:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber * _isTop                  = [command argumentAtIndex:2 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_isTop isKindOfClass:[NSNumber class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL isSetted = [[RCIMClient sharedRCIMClient] setConversationToTop:_conversationType targetId:_targetId isTop:[_isTop boolValue]];
    if(isSetted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 * conversation notification
 */
- (void)getConversationNotificationStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block  CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
   __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:_conversationType targetId:_targetId success:^(RCConversationNotificationStatus nStatus) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": @""}};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCErrorCode status) {
        NSLog(@"notification error code= %d",(int)status);
        NSDictionary *_err = @{@"status":ERROR, @"code": @(status), @"msg": @""};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_err];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];
    
}
- (void)setConversationNotificationStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString        = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId                       = [command argumentAtIndex:1 withDefault:nil];
    NSString *_conversationnotificationStatus = [command argumentAtIndex:2 withDefault:nil];
    
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_conversationnotificationStatus isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL _isBlocked = NO;
    if ([_conversationnotificationStatus isEqualToString:@"DO_NOT_DISTURB"]) {
        _isBlocked = YES;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]setConversationNotificationStatus:_conversationType targetId:_targetId isBlocked:_isBlocked success:^(RCConversationNotificationStatus nStatus) {
        
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": @""}};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_err = @{@"status":ERROR, @"code": @(status), @"status": @""};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_err];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

/**
 * read message & delete
 */
- (void)getLatestMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_count isKindOfClass:[NSNumber class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType     = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    NSArray *_latestMessages                 = [[RCIMClient sharedRCIMClient]getLatestMessages:_conversationType targetId:_targetId count:[_count intValue]];
    NSMutableArray * _latestMessageListModel = nil;
    
    _latestMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_latestMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _latestMessageListModel};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getHistoryMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_oldestMessageId         = [command argumentAtIndex:3 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_count isKindOfClass:[NSNumber class]] ||
        ![_oldestMessageId isKindOfClass:[NSNumber class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    NSArray *_historyMessages                 = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType targetId:_targetId oldestMessageId:[_oldestMessageId longValue] count:[_count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)getHistoryMessagesByObjectName:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    //need to confirm
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId                = [command argumentAtIndex:1 withDefault:nil];
    NSNumber *_count                   = [command argumentAtIndex:2 withDefault:nil];
    NSNumber *_oldestMessageId         = [command argumentAtIndex:3 withDefault:nil];
    NSString *_objectName              = [command argumentAtIndex:4 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_count isKindOfClass:[NSNumber class]] ||
        ![_oldestMessageId isKindOfClass:[NSNumber class]] ||
        ![_objectName isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    
    NSArray *_historyMessages = [[RCIMClient sharedRCIMClient]getHistoryMessages:_conversationType targetId:_targetId oldestMessageId:[_oldestMessageId longValue] count:[_count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) deleteMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSArray *_messageIds = [command argumentAtIndex:0 withDefault:nil];
    
    if (![_messageIds isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    BOOL isDeleted = [[RCIMClient sharedRCIMClient]deleteMessages:_messageIds];
    if(isDeleted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
- (void) clearMessages:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL isCleared = [[RCIMClient sharedRCIMClient]clearMessages:_conversationType targetId:_targetId];
    if(isCleared)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 * unread message count
 */
- (void) getTotalUnreadCount:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    int totalUnReadCount = (int)[[RCIMClient sharedRCIMClient]getTotalUnreadCount];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(totalUnReadCount)};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getUnreadCount:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    NSInteger unReadCount = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationType targetId:_targetId];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(unReadCount)};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
-(void)getUnreadCountByConversationTypes:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSArray *nsstring_conversationTypes = [command argumentAtIndex:0 withDefault:nil];
    
    if (![nsstring_conversationTypes isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSMutableArray * _conversationTypes = [NSMutableArray new];
    for(int i=0; i< [nsstring_conversationTypes count]; i++)
    {
        RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:nsstring_conversationTypes[i]];
        [_conversationTypes addObject:@(_conversationType)];
    }
    
    NSInteger _unread_count = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationTypes];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(_unread_count)};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * message status
 */
-(void) setMessageReceivedStatus: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSNumber *__messageId = [command argumentAtIndex:0 withDefault:nil];
    NSNumber *__receivedStatus = [command argumentAtIndex:1 withDefault:nil];
    
    if (![__messageId isKindOfClass:[NSNumber class]] ||
        ![__receivedStatus isKindOfClass:[NSNumber class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageReceivedStatus:__messageId.intValue
                                                         receivedStatus:__receivedStatus.intValue];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) clearMessagesUnreadStatus: (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient]clearMessagesUnreadStatus:_conversationType targetId:_targetId];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
-(void) setMessageExtra : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSNumber *__messageId =[command argumentAtIndex:0 withDefault:nil];
    NSString *__value = [command argumentAtIndex:1 withDefault:nil];
    
    if (![__messageId isKindOfClass:[NSNumber class]] ||
        ![__value isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageExtra:__messageId.longValue value:__value];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 * message draft
 */
-(void) getTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    NSString *__draft = [[RCIMClient sharedRCIMClient]getTextMessageDraft:_conversationType targetId:_targetId];
    if (nil == __draft) {
        __draft = @"";
    }
    NSDictionary *_result = @{@"status":SUCCESS, @"result": __draft};
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
-(void) saveTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    NSString *_content =  [command argumentAtIndex:2 withDefault:nil];
    
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]] ||
        ![_content isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:_conversationType
                                                            targetId:_targetId
                                                             content:_content];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
-(void)clearTextMessageDraft : (CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString * _conversationTypeString = [command argumentAtIndex:0 withDefault:nil];
    
    NSString *_targetId = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_conversationTypeString isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
       [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:_conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient] clearTextMessageDraft:_conversationType targetId:_targetId];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }else{
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }
}

/**
 * discussion
 */
- (void) createDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_name = [command argumentAtIndex:0 withDefault:nil];
    NSArray *_userIds = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_name isKindOfClass:[NSString class]] ||
        ![_userIds isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    __weak RongCloudLibPlugin* weakSelf = self;
    
    [[RCIMClient sharedRCIMClient]createDiscussion:_name userIdList:_userIds success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"discussionId": discussion.discussionId}};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCErrorCode status) {
        NSDictionary *_result =  @{@"status":ERROR, @"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)getDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *__discussionId = [command argumentAtIndex:0 withDefault:nil];
    if (![__discussionId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]getDiscussion:__discussionId success:^(RCDiscussion *discussion) {
        NSDictionary *_dic = [RongCloudModel RCGenerateDiscussionModel:discussion];
        NSDictionary *_result = @{@"status":SUCCESS, @"result": _dic};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCErrorCode status) {
        NSDictionary *_result =  @{@"status":ERROR, @"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)setDiscussionName :(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *__discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSString *__name = [command argumentAtIndex:1 withDefault:nil];
    if (![__discussionId isKindOfClass:[NSString class]] ||
        ![__name isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    __weak RongCloudLibPlugin* weakSelf = self;
    
    [[RCIMClient sharedRCIMClient]setDiscussionName:__discussionId name:__name success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) addMemberToDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSArray *_userIds = [command argumentAtIndex:1 withDefault:nil];
    if (![_discussionId isKindOfClass:[NSString class]] ||
        ![_userIds isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient] addMemberToDiscussion:_discussionId userIdList:_userIds success:^(RCDiscussion *discussion){
        
        NSDictionary *_result = @{@"status":SUCCESS};
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void) removeMemberFromDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_discussionId = [command argumentAtIndex:0 withDefault:nil];
    NSString *_userIds = [command argumentAtIndex:1 withDefault:nil];
    if (![_discussionId isKindOfClass:[NSString class]] ||
        ![_userIds isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:_discussionId userId:_userIds success:^(RCDiscussion *discussion) {
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void) quitDiscussion:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_discussionId = [command argumentAtIndex:0 withDefault:nil];
    if (![_discussionId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient] quitGroup:_discussionId success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void) setDiscussionInviteStatus:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_targetId = [command argumentAtIndex:0 withDefault:nil];
    NSString *_discussionInviteStatus = [command argumentAtIndex:1 withDefault:nil];
    
    if (![_discussionInviteStatus isKindOfClass:[NSString class]] ||
        ![_targetId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    BOOL _isOpen = YES;
    
    if ([_discussionInviteStatus isEqualToString:@"CLOSED"]) {
        _isOpen = NO;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    
    [[RCIMClient sharedRCIMClient]setDiscussionInviteStatus:_targetId isOpen:_isOpen success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

/**
 * group
 */
- (void) syncGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSArray *_groups = [command argumentAtIndex:0 withDefault:nil];
    
    if (![_groups isKindOfClass:[NSArray class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    NSMutableArray *_groupList = [RongCloudModel RCGenerateGroupList:_groups];
    
    if (nil == _groupList) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]syncGroups:_groupList success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void) joinGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_groupId      = [command argumentAtIndex:0 withDefault:nil];
    NSString *_groupName    = [command argumentAtIndex:1 withDefault:nil];
    if (![_groupId isKindOfClass:[NSString class]] ||
        ![_groupName isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]joinGroup:_groupId groupName:_groupName success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void) quitGroup:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_groupId = [command argumentAtIndex:0 withDefault:nil];
    if (![_groupId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    
    [[RCIMClient sharedRCIMClient]quitGroup:_groupId success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

/**
 * chatRoom
 */
- (void)joinChatRoom:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }
    NSString *_chatRoomId       = [command argumentAtIndex:0 withDefault:nil];
    NSNumber *_defMessageCount  = [command argumentAtIndex:1 withDefault:nil];
    if (![_chatRoomId isKindOfClass:[NSString class]] ||
        ![_defMessageCount isKindOfClass:[NSNumber class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    [[RCIMClient sharedRCIMClient]joinChatRoom:_chatRoomId messageCount:[_defMessageCount intValue] success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}
- (void)quitChatRoom:(CDVInvokedUrlCommand *)command
{
    NSLog(@"%s", __FUNCTION__);
    __block CDVPluginResult* pluginResult = nil;
    
    if (![self _confirmIfInitedAndConnectedWithRongCloud:pluginResult command:command]) {
        return;
    }

    NSString *_chatRoomId = [command argumentAtIndex:0 withDefault:nil];
    if (![_chatRoomId isKindOfClass:[NSString class]]
        ) {
        [self _argumentsBadCallbackEvent:pluginResult command:command];
        return;
    }
    __weak RongCloudLibPlugin* weakSelf = self;
    
    [[RCIMClient sharedRCIMClient]quitChatRoom:_chatRoomId success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR,@"code":@(status), @"msg": @""};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:_result];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
@end
