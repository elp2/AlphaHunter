//
//  About.h
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Mobclix.h"
#import "MobclixAds.h"

#define kScrollTime 15

@interface AboutLayer : CCLayerColor {
	CCSprite *bigMouth_;
	CCLayerColor *creditsLayer_;
}

+(id) scene;

@end
