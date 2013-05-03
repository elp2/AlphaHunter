//
//  Animal.h
//  AlphaHunter
//
//  Created by Ed Palmer on 01/09/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"

//////////////
#define kAHMinAnimalNum 1
#define kAHBearType 1
#define kAHBearBox CGRectMake(0,0, 76,110)
#define kAHBearScore 1

#define kAHBeeType 2
#define kAHBeeBox CGRectMake( 97,9, 81, 82)
#define kAHBeeScore 2

#define kAHCowType 3
#define kAHCowBox CGRectMake( 244,16, 62,81);
#define kAHCowScore 3

#define kAHFoxType 4
#define kAHFoxBox CGRectMake(266,127,86,86)
#define kAHFoxScore 4

#define kAHLionType 5
#define kAHLionBox CGRectMake(166,117, 76, 67)
#define kAHLionScore 5

#define kAHTigerType 6
#define kAHTigerBox CGRectMake(17,114,113,73)
#define kAHTigerScore 6

#define kAHMaxAnimalNum 6
/////////



#define kUpdateInterval 0.1

#define kMaxSpeed 1
#define kSpeedScalar 0.1f

#define kAHFreeState 1
#define kAHCaughtState 2

@interface Animal : CCSpriteBatchNode  {
	int points_;
	int animalType_;
	
	CGPoint moveVector_;
	double turnyNess_;
	int maxTurnDegrees_;
	int ticksSinceTurn_;
	
	int state_;
	
	//static
	CCSpriteBatchNode *_animalSheet;
	CCSprite *reticle_;
}

-(id) initWithType:(int)pAnimalType;
+(id) animalWithType:(int)pAnimalType;
+(void) setGameSpeed:(float)newGameSpeed;
-(int) score;
-(void)wasCaughtDelay:(double)pDelay limboTime:(double)limboTime;
-(void) startMoving;
-(int) getType;

-(int) isFree;

@end
