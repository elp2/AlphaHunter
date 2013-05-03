//
//  AHNewGameLayer.h
//  AlphaHunterIpad995
//
//  Created by Edward Palmer on 15/12/11.
//  Copyright 2011 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AHWord.h"
#import "AHInstructionsLayer.h"
@class GameLayer;

typedef enum {
	kAHGameEasy = 1,
    kAHGameMedium,
    kAHGameHard,
} AHGameDifficulty;

@class AHInstructionsLayer;

@interface AHNewGameLayer : CCLayerColor {
    GameLayer *gameLayer_;
    CCMenu *easyMenu_, *medMenu_, *hardMenu_;
}
-(void) instructionsOKClicked:(AHInstructionsLayer *) ahil;

@end
