//
//  Game.h
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AHWord.h"
#import "Animal.h"
#import "Letter.h"
#import "AHSelectionPath.h"
#import "AHInstructionsLayer.h"
#import "AHScoreLayer.h"
#import "AHParticleExplosion.h"
#import "Mobclix.h"
#import "MobclixAds.h"
#import "AHNewGameLayer.h"
#import "AHPauseLayer.h"
#import "AlphaHunterIpad995AppDelegate.h"

@class AHWord;
@class Letter;
@class AHSelectionPath;
@class AHInstructionsLayer;
@class AHScoreLayer;
@class AHParticleExplosion;

#define kLetterParticleSpeed 1.0
#define kNumEsthers 13
#define kSpinWordDuration 1.0
#define kBoardNotMarked 2
#define kBoardEnclised 1
#define kBoardUnknown 0
#define kRibbonWidth 16

#define kWordZ 200
#define kSelectedLetterZ 100
#define kSelectionPathZ 80
#define kAnimalZ 25
#define kUnselectedLetterZ 50
#define kMenuZ 2
#define kAHInstructionsZ 1000
#define kAHSelectionPathZ -10

#define kAHTopFontComedownPixels 80

#define kAHGameClockTickTime 0.1f
#define kAHTimeLabelNormalSize 0.5f
#define kAHAdsDownPixels 55

#define kAHGreenR 145
#define kAHGreenG 193
#define kAHGreenB 84

#define kAHLetterLimboTime 25

#define kAHOFHighScoresLeaderboard @"610714"

@interface GameLayer : CCLayerColor <CCTargetedTouchDelegate, MobclixAdViewDelegate> {
	AHWord *word_;
	int lettersWide_;
	int lettersHigh_;
	
	int numTotalAnimals_;
	int numLiveAnimals_;
	
	double topHeight_;
	CCLabelBMFont *spinWord_;
	CCLabelBMFont *scoreLabel_;
	CCLabelBMFont *topWord_;
	
	float timeLeft_;
	CCLabelBMFont *timeLabel_;	
	
	AHSelectionPath *selectionPath_;
	
	NSMutableArray *animals_;
	
	int totalAnimalsCaught_;
	int allowLetterClicks_;
	int caughtAnimals_[10];

	int score_;
	Letter *letters_[32][48];
	CCParticleSystem	*emitter_;
	
	MobclixAdView* adView;
	
	int strobingTime_;
	int wordsUsed_;
	float elapsedTime_;
	
    float maxTimeLeft_;
	
	double minX;
	double maxX;
	double minY;
	double maxY;
}


@property(nonatomic,retain) MobclixAdView* adView;

+(id) scene;

-(void) wordSuccess;
-(void) wordFailure;

-(void) letterSelected:(Letter *)letter;
-(void) increaseScoreBy:(int)by;
-(void) wordChangedIsAWord:(int)isAWord;

-(void) letterAddedAt:(Letter *)letter;
-(void) removeLastLetter;
-(int) isLegalMoveFrom:(CGPoint)from to:(CGPoint) to;

-(void) scoreMainMenuClicked:(AHScoreLayer *) ahsco;
-(void) newGameRequest:(int) difficulty;
-(void) newGame;
-(void) showNewGame;

-(CGPoint) getAnimalPosition;
-(void) animalResurrected;
-(NSString *) pickCharacter;
-(void) readyNextWord;
-(void) letterCaught:(Letter *)gridLetter;
-(Letter *) getLetterForTouchPoint:(CGPoint) tp;
-(void) pause;
-(void) resume;

@end
