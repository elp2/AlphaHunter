//
//  Letter.h
//  AlphaHunter
//
//  Created by Ed Palmer on 30/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AHWord.h"

#define kLetterWidth 72
#define kLetterHeight 85
#define kLetterUnselected 0
#define kLetterUnselectedR 0
#define kLetterUnselectedG 0
#define kLetterUnselectedB 0


#define kLetterSelectedFirst 1
#define kLetterSelectedFirstR 255
#define kLetterSelectedFirstG 255
#define kLetterSelectedFirstB 255

#define kLetterSelectedNotFirst 2
#define kLetterSelectedNotFirstR 255
#define kLetterSelectedNotFirstG 255
#define kLetterSelectedNotFirstB 255

#define kLetterDissappeared 3

#define kLetterResurrectShrinkTime 0.15

#define kAHBitmapFontName @"GoodDogPlain.fnt"
#define kAHBitmapFontNameBig @"GoodDogPlainBig.fnt"

#define kAHLetterStateAlive 1
#define kAHLetterStateDead 2

#define kAHFirstColor ccRED
#define kAHMiddleColor ccBLUE
#define kAHLastColor ccBLUE
#define kAHUnselectedColor ccWHITE

@class AHWord;

@interface Letter : CCLabelBMFont  {
 @private
	NSString *character_, *resurrectToCharacter_;
	AHWord *word_;
	int selectedState_;
	double dissappearAfter_;
	int state_;
}

-(id) initWithCharacter:(NSString *)character andWord:(AHWord *)word;
+(id) letterWithCharacter:(NSString *)character andWord:(AHWord *)word;

-(void) dissapearAfter:(double) stayTime;
-(int) wasSelectedAndIsFirst:(int)wasFirst;
-(void) wasRemoved;
-(NSString *) getCharacter;
-(void) noLongerLast;
-(void) isLast;
-(void) setCharacter:(NSString *) newCharacter;
-(void) resurrectTo:(NSString *)character;

-(void)wasCaughtDelay:(double)pDelay limboTime:(double)limboTime withString:(NSString *)newString;

@end
