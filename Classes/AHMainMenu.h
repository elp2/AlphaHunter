//
//  AHMainMenu.h
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "About.h"
#import "Game.h"
#import "AHWord.h"
#import "GameConfig.h"

@class AHOFDelegate;

@class AHMainMenu;


@interface MainMenuLayer : CCLayerColor {
	AHOFDelegate *ofDelegate;
}

+(id) scene;

@end
