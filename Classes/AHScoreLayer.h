//
//  AHScoreLayer.h
//  AlphaHerderZ
//
//  Created by Edward Palmer on 28/02/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"
#import "AHWord.h"

#define kScoreFont @"Marker Felt"

@interface AHScoreLayer : CCLayerColor <CCTargetedTouchDelegate> {
	
}

-(void) prepareScoreWithNumAnimals:(int) numAnimals caughtNums:(int[]) caughtAnimals score:(int)score totalWords:(int)totalWords elapsed:(float)elapsed;

@end
