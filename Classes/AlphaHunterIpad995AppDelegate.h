//
//  AlphaHunterIpad995AppDelegate.h
//  AlphaHunterIpad995
//
//  Created by Ed Palmer on 08/01/2011.
//  Copyright chichai.com 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AHGameScene.h"
#import "GameKit/GameKit.h"

@class RootViewController;
@class AHOFDelegate;

@interface AlphaHunterIpad995AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    BOOL paused_;
}

@property (nonatomic, retain) RootViewController	*viewController;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) BOOL paused;

+(AlphaHunterIpad995AppDelegate *) getDelegateSingleton;
@end
