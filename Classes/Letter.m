//
//  Letter.m
//  AlphaHunter
//
//  Created by Ed Palmer on 30/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "Letter.h"


@implementation Letter


#pragma mark -
#pragma mark Selection / Deselection

-(void)letterResurrected
{
	state_ = kAHLetterStateAlive;
}

-(void)letterResurrecting
{
    [self setColor:kAHUnselectedColor];
	[self setCharacter:resurrectToCharacter_];
}


-(void)wasCaughtDelay:(double)pDelay limboTime:(double)limboTime withString:(NSString *)newString
{
	if( state_ == kAHLetterStateDead )
		return;
	
	state_ = kAHLetterStateDead;
	resurrectToCharacter_ = newString;

	NSLog( @"letter wasCaught! %f %f", pDelay, limboTime );
	
	[self stopAllActions];	
	CCSequence *deathAndRebirth = [CCSequence actions:[CCScaleTo actionWithDuration:pDelay scale:0.0f], 
								   [CCDelayTime actionWithDuration:limboTime],
								   [CCCallFunc actionWithTarget:self selector:@selector(letterResurrecting)],
								   [CCScaleTo actionWithDuration:1.0f scale:1.0f],
								   [CCCallFunc actionWithTarget:self selector:@selector(letterResurrected)],
								   nil];
	
	[self runAction:deathAndRebirth];
}

-(int) wasSelectedAndIsFirst:(int)wasFirst
{
	if( kAHLetterStateDead == state_ )
		return NO;
	
	if( kLetterDissappeared == selectedState_ )
		return NO;

	[self stopAllActions];	
	
	if( wasFirst ) {
		selectedState_ = kLetterSelectedFirst;
        [self setColor:kAHFirstColor];
	} else {
		[self isLast];
		selectedState_ = kLetterSelectedNotFirst;
        [self setColor:kAHLastColor];
	}
	return YES;
}

-(void) wasRemoved
{
    [self setColor:kAHUnselectedColor];
	
	NSLog( @"removed: %@", character_ );
	[self stopAllActions];
	selectedState_ = kLetterUnselected;
}

-(void) noLongerLast
{
    [self setColor:kAHMiddleColor];
}

-(void) isLast
{
    [self setColor:kAHLastColor];
}

#pragma mark -
#pragma mark Misc

-(void) pResurrect;
{
    [self setColor:kAHUnselectedColor];
	selectedState_ = kLetterUnselected;
	
	[self unschedule:@selector(pResurrect)];
	[self setCharacter:resurrectToCharacter_];

	self.scale = 1;
}

-(void) resurrectTo:(NSString *)character
{
	[self stopAllActions];
	resurrectToCharacter_ = character;

	[self letterResurrecting];
	[self letterResurrected];
	
	[self pResurrect];
	[self stopAllActions];	
}


-(void) setCharacter:(NSString *) newCharacter
{
	character_ = newCharacter;
	[self setString:character_];
}

-(NSString *) getCharacter
{
	return character_;
}
	
-(void) dissapearAfter:(double) stayTime
{
	selectedState_ = kLetterDissappeared;

	[self runAction:[CCScaleTo actionWithDuration:1.1 + stayTime scale:0.00]];
}


#pragma mark -
#pragma mark Init

-(id) initWithCharacter:(NSString *)character andWord:(AHWord *)word
{
	if( (self=[super initWithString:character fntFile:kAHBitmapFontName ]) ) {
		[self setCharacter:character];
		word_ = word;
		selectedState_ = kLetterUnselected;
		state_ = kAHLetterStateAlive;
	}
	return self;
}


+(id) letterWithCharacter:(NSString *)character andWord:(AHWord *)word
{
	return [[self alloc] initWithCharacter:character andWord:word];
}

@end
