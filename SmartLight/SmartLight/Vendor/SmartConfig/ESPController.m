//
//  ESPViewController.m
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "ESPController.h"
#import "ESPTouchTask.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result {
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
}

@end

@interface ESPController ()

// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// the state of the confirm/cancel button
@property (nonatomic, assign) BOOL _isConfirmState;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;
@property (nonatomic, weak) id<ESPControllerDelegate> delegate;
@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;

@end

@implementation ESPController

- (instancetype)init {
    self = [super init];
    if (self) {
        self._isConfirmState = YES;
        self._condition = [[NSCondition alloc] init];
        self._esptouchDelegate = [[EspTouchDelegateImpl alloc] init];
    }
    return self;
}

- (instancetype)initWithDelegate: (id<ESPControllerDelegate> ) delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self._isConfirmState = YES;
        self._condition = [[NSCondition alloc] init];
        self._esptouchDelegate = [[EspTouchDelegateImpl alloc] init];
    }
    return self;
}

- (void) tapConfirmForResults
{
    // do confirm
    if (self._isConfirmState) {
        NSString *apSsid = [self fetchSsid];
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"wifiPWD"];
        NSString *apPwd = [dict objectForKey:apSsid];
        NSString *apBssid = [self fetchBssid];
        int taskCount = 1;
        BOOL broadcast = YES;
        
        self._isConfirmState = NO;
        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            // execute the task
            NSArray *esptouchResultArray = [self executeForResultsWithSsid:apSsid bssid:apBssid password:apPwd taskCount:taskCount broadcast:broadcast];
            // show the result to the user in UI Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
                // check whether the task is cancelled and no results received
                if (!firstResult.isCancelled) {
                    NSMutableString *mutableStr = [[NSMutableString alloc]init];
                    NSUInteger count = 0;
                    // max results to be displayed, if it is more than maxDisplayCount,
                    // just show the count of redundant ones
                    const int maxDisplayCount = 5;
                    if ([firstResult isSuc]) {
                        for (int i = 0; i < [esptouchResultArray count]; ++i) {
                            ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                            [mutableStr appendString:[resultInArray description]];
                            [mutableStr appendString:@"\n"];
                            count++;
                            if (count >= maxDisplayCount) {
                                break;
                            }
                        }
                        
                        if (count < [esptouchResultArray count]) {
                            [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                        }
                        NSLog(@"Esptouch %@", mutableStr);
                        [self.delegate scanWIFI: esptouchResultArray];
                    } else {
                        NSLog(@"Esptouch fail");
                        [self.delegate scanWIFI:nil];
                    }
                }
                
            });
        });
    }
    // do cancel
    else {
        self._isConfirmState = YES;
        [self cancel];
    }
}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil) {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast {
    [self._condition lock];
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._esptouchTask setPackageBroadcast:broadcast];
    [self._condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

- (NSString *)fetchSsid {
    NSDictionary *ssidInfo = [self fetchNetInfo];
    return [ssidInfo objectForKey:@"SSID"];
}

- (NSString *)fetchBssid {
    NSDictionary *bssidInfo = [self fetchNetInfo];
    return [bssidInfo objectForKey:@"BSSID"];
}

// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end

