/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI45_0_0RCTAppState.h"

#import <ABI45_0_0FBReactNativeSpec/ABI45_0_0FBReactNativeSpec.h>
#import <ABI45_0_0React/ABI45_0_0RCTAssert.h>
#import <ABI45_0_0React/ABI45_0_0RCTBridge.h>
#import <ABI45_0_0React/ABI45_0_0RCTEventDispatcherProtocol.h>
#import <ABI45_0_0React/ABI45_0_0RCTUtils.h>

#import "ABI45_0_0CoreModulesPlugins.h"

static NSString *ABI45_0_0RCTCurrentAppState()
{
  static NSDictionary *states;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    states = @{@(UIApplicationStateActive) : @"active", @(UIApplicationStateBackground) : @"background"};
  });

  if (ABI45_0_0RCTRunningInAppExtension()) {
    return @"extension";
  }

  return states[@(ABI45_0_0RCTSharedApplication().applicationState)] ?: @"unknown";
}

@interface ABI45_0_0RCTAppState () <ABI45_0_0NativeAppStateSpec>
@end

@implementation ABI45_0_0RCTAppState {
  NSString *_lastKnownState;
}

ABI45_0_0RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (ABI45_0_0facebook::ABI45_0_0React::ModuleConstants<JS::NativeAppState::Constants>)constantsToExport
{
  return (ABI45_0_0facebook::ABI45_0_0React::ModuleConstants<JS::NativeAppState::Constants>)[self getConstants];
}

- (ABI45_0_0facebook::ABI45_0_0React::ModuleConstants<JS::NativeAppState::Constants>)getConstants
{
  __block ABI45_0_0facebook::ABI45_0_0React::ModuleConstants<JS::NativeAppState::Constants> constants;
  ABI45_0_0RCTUnsafeExecuteOnMainQueueSync(^{
    constants = ABI45_0_0facebook::ABI45_0_0React::typedConstants<JS::NativeAppState::Constants>({
        .initialAppState = ABI45_0_0RCTCurrentAppState(),
    });
  });

  return constants;
}

#pragma mark - Lifecycle

- (NSArray<NSString *> *)supportedEvents
{
  return @[ @"appStateDidChange", @"memoryWarning" ];
}

- (void)startObserving
{
  for (NSString *name in @[
         UIApplicationDidBecomeActiveNotification,
         UIApplicationDidEnterBackgroundNotification,
         UIApplicationDidFinishLaunchingNotification,
         UIApplicationWillResignActiveNotification,
         UIApplicationWillEnterForegroundNotification
       ]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppStateDidChange:)
                                                 name:name
                                               object:nil];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleMemoryWarning)
                                               name:UIApplicationDidReceiveMemoryWarningNotification
                                             object:nil];
}

- (void)stopObserving
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - App Notification Methods

- (void)handleMemoryWarning
{
  if (self.bridge) {
    [self sendEventWithName:@"memoryWarning" body:nil];
  }
}

- (void)handleAppStateDidChange:(NSNotification *)notification
{
  NSString *newState;

  if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
    newState = @"inactive";
  } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    newState = @"background";
  } else {
    newState = ABI45_0_0RCTCurrentAppState();
  }

  if (![newState isEqualToString:_lastKnownState]) {
    _lastKnownState = newState;
    if (self.bridge) {
      [self sendEventWithName:@"appStateDidChange" body:@{@"app_state" : _lastKnownState}];
    }
  }
}

#pragma mark - Public API

/**
 * Get the current background/foreground state of the app
 */
ABI45_0_0RCT_EXPORT_METHOD(getCurrentAppState : (ABI45_0_0RCTResponseSenderBlock)callback error : (__unused ABI45_0_0RCTResponseSenderBlock)error)
{
  callback(@[ @{@"app_state" : ABI45_0_0RCTCurrentAppState()} ]);
}

- (std::shared_ptr<ABI45_0_0facebook::ABI45_0_0React::TurboModule>)getTurboModule:
    (const ABI45_0_0facebook::ABI45_0_0React::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<ABI45_0_0facebook::ABI45_0_0React::NativeAppStateSpecJSI>(params);
}

@end

Class ABI45_0_0RCTAppStateCls(void)
{
  return ABI45_0_0RCTAppState.class;
}
