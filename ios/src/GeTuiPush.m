//
//  GeTuiPush.m
//  GeTuiPush
//
//  Created by X on 14-4-3.
//  Copyright (c) 2014年 io.dcloud. All rights reserved.
//

#import "GeTuiPush.h"
#import <UIKit/UIKit.h>
#import "PDRCore.h"
#import "PDRCommonString.h"
#import "PDRToolSystemEx.h"
#import "DC_JSON.h"
#import "PGPush.h"

@implementation PGGetuiPush

- (void) onAppStarted:(NSDictionary*)options {
    [super onAppStarted:options];
     _gexinPusher = [[GeTuiPush alloc] init];
    [_gexinPusher startEngine];
}

- (void) onRegRemoteNotificationsError:(NSError *)error {
    [_gexinPusher registerDeviceToken:nil];
}

- (void) onRevDeviceToken:(NSString *)deviceToken {
    [_gexinPusher registerDeviceToken:deviceToken];
}

- (void) onAppEnterBackground {
    [_gexinPusher stopEngine];
}

- (void) onAppEnterForeground {
    [_gexinPusher startEngine];
}

- (NSMutableDictionary*)getClientInfoJSObjcet {
    NSMutableDictionary *clientInfo = [super getClientInfoJSObjcet];
    NSString *appID = nil, *appKey = nil, *clientId = nil;
    if ( _gexinPusher ) {
        appID = _gexinPusher.appID;
        appKey = _gexinPusher.appKey;
        clientId = _gexinPusher.clientId;
    }
    [clientInfo setObject:appID ? appID : @"" forKey:g_pdr_string_appid];
    [clientInfo setObject:appKey ? appKey: @"" forKey:g_pdr_string_appkey];
    [clientInfo setObject:clientId ? clientId : @"" forKey:@"clientid"];
    return clientInfo;
}
@end

@implementation GeTuiPush

@synthesize appKey;
@synthesize appSecret;
@synthesize appID;
@synthesize clientId;

- (id)init {
    if ( self = [super init] ) {
        NSDictionary *dhDict = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"getui"];
        if ( [dhDict isKindOfClass:[NSDictionary class]] ) {
            self.appKey = [dhDict objectForKey:@"appkey"];
            self.appSecret = [dhDict objectForKey:@"appsecret"];
            self.appID = [dhDict objectForKey:@"appid"];
//            [[PDRCore Instance] regPluginWithName:@"Push" impClassName:@"PGGetuiPush" type:PDRExendPluginTypeFrame javaScript:nil];
//            //  UIApplication *sharedApplication = [UIApplication sharedApplication];
//            if ( [PTDeviceOSInfo systemVersion] >= PTSystemVersion8Series ) {
//                [[UIApplication sharedApplication] registerForRemoteNotifications];
//                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
//                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//            } else {
//                UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
//                // if ( apn_type != [sharedApplication enabledRemoteNotificationTypes] ) {
//                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
//                // }
//            }
        }
    }
    return self;
}

- (void)startEngine {
    if ( !_gexinPusher ) {
        _sdkStatus = SdkStatusStoped;
        
        self.appID = appID;
        self.appKey = appKey;
        self.appSecret = appSecret;
        
        NSError *err = nil;
        _gexinPusher = [GexinSdk createSdkWithAppId:self.appID
                                             appKey:self.appKey
                                          appSecret:self.appSecret
                                         appVersion:@"0.0.0"
                                           delegate:self
                                              error:&err];
        if (!_gexinPusher) {
        } else {
            _sdkStatus = SdkStatusStarting;
        }
    }
}

- (void)stopEngine {
    if ( _gexinPusher ) {
        [_gexinPusher destroy];
        [_gexinPusher release];
        _gexinPusher = nil;
        _sdkStatus = SdkStatusStoped;
    }
}

- (void)registerDeviceToken:(NSString *)deviceToken {
    if ( deviceToken ) {
      //  NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
      //  NSString *deviceTokenStringV = [[token stringByReplacingOccurrencesOfString:@" " withString:@""] retain];
        [_gexinPusher registerDeviceToken:deviceToken];
    } else {
        [_gexinPusher registerDeviceToken:@""];
    }
}

- (void)dealloc {
    [self stopEngine];
    self.appSecret = nil;
    self.appID = nil;
    self.appKey = nil;
    [super dealloc];
}

#pragma mark - GexinSdkDelegate
- (void)GexinSdkDidRegisterClient:(NSString *)cId
{
    self.clientId = cId;
    _sdkStatus = SdkStatusStarted;
}
    
- (void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId
{
    NSData *payload = [_gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding] autorelease];
        
      //  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
      //  NSMutableDictionary *userInfo = [payloadMsg objectFromJSONString];
       // if ( ![userInfo isKindOfClass:[NSDictionary class]] ) {
           // userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:payloadMsg, g_pdr_string_payload, nil];
       // } else {
           // userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:userInfo, @"payload", nil];
       // }
        //[dict setObject:userInfo forKey:g_pdr_string_aps];
        //[dict setObject:g_pdr_string_receive forKey:g_pdr_string_type];
        [[PDRCore Instance] handleSysEvent:PDRCoreSysEventRevRemoteNotification withObject:payloadMsg];
    }
}
    
- (void)GexinSdkDidOccurError:(NSError *)error
{
}
@end
