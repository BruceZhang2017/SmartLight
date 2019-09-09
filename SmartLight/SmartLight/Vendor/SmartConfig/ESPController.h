//
//  ESPViewController.h
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPTouchResult.h"

@protocol ESPControllerDelegate <NSObject>

- (void)scanWIFI: (NSArray<ESPTouchResult*> *)result;

@end

@interface ESPController : NSObject

- (void) tapConfirmForResults;

- (NSString *)fetchSsid;
- (NSString *)fetchBssid;

- (void) cancel;

- (instancetype)initWithDelegate: (id<ESPControllerDelegate> ) delegate;

@end


