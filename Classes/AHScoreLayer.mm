//
//  AHScoreLayer.m
//  AlphaHerderZ
//
//  Created by Edward Palmer on 28/02/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import "AHScoreLayer.h"
#import "GameKit/GameKit.h"
#import "GameCenterManager.h"

@implementation AHScoreLayer

#pragma mark -
#pragma mark Callbacks

-(void) okButtonCB: (id) sender
{
    [(GameLayer *) self.parent showNewGame];
    [(GameLayer *) self.parent removeChild:self cleanup:YES];
}

-(void) scoreButtonCB: (id) sender
{
    [[GameCenterManager sharedInstance] showLeaderboard];
}

-(void) mmButtonCB: (id) sender
{
	[(GameLayer *) self.parent scoreMainMenuClicked:self];
}

-(void) setAcheivementsScore:(int)score animals:(int)numAnimals words:(int)numWords
{
	// High Score Leaderboard
	if( score > 0 ) {
        [[GameCenterManager sharedInstance] reportScore:score forCategory:@"ALPHAHUNTER_SCORES"];
    }
	// Animals
	if( numAnimals >= 1000 ){
        [[GameCenterManager sharedInstance] achievement:@"CATCH_1000"];
	}
	else if( numAnimals >= 250 ){
        [[GameCenterManager sharedInstance] achievement:@"CATCH_250"];
	}
    else if( numAnimals >= 100 ) {
        [[GameCenterManager sharedInstance] achievement:@"CATCH_100"];
    }
    else if( numAnimals >= 50 ) {
        [[GameCenterManager sharedInstance] achievement:@"CATCH_50"];
    }
}


#define kScoreFontHeaderSize 160
#define kScoreFontSize 80
#define kScoreNumberFontSize 40

-(void) prepareScoreWithNumAnimals:(int) numAnimals caughtNums:(int[]) caughtAnimals score:(int)score totalWords:(int)totalWords elapsed:(float)elapsed
{
	[self setAcheivementsScore:score animals:numAnimals words:totalWords];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"GAME OVER" fntFile:kAHBitmapFontNameBig];
	title.position = ccp( size.width/2, size.height - 200 );
	[title setColor:ccc3(255, 0, 0)];
	[self addChild:title];
	
	NSString *caughtString = [NSString stringWithFormat:@"Animals Caught: %d", numAnimals];
	CCLabelBMFont *line1 = [CCLabelBMFont labelWithString:caughtString fntFile:kAHBitmapFontName];
	line1.position = ccp( size.width/2, size.height - 310 );
	[self addChild:line1];	
	
	int animalY = size.height - 535;
	int animalI = 1;
	for( animalI = 1; animalI <= kAHMaxAnimalNum; animalI++ ){
		int secondsPerFadeIn = 0.1 * animalI;
		NSString *caughtString = [NSString stringWithFormat:@"%d", caughtAnimals[animalI-1]];
		CCLabelBMFont *animalLabel = [CCLabelBMFont labelWithString:caughtString fntFile:kAHBitmapFontName];

		int animalX = animalI * size.width / (kAHMaxAnimalNum + 1);
		animalLabel.position = ccp( animalX, animalY );
		animalLabel.opacity = 0.5;
		animalLabel.scale = 5;
		[self addChild:animalLabel];
		[animalLabel runAction:[CCFadeIn actionWithDuration:secondsPerFadeIn]];
		[animalLabel runAction:[CCScaleTo actionWithDuration:secondsPerFadeIn scale:1]];
		
		Animal *animal = [Animal animalWithType:animalI];
		animal.position = ccp( animalX, animalY + kScoreNumberFontSize * 2 + 5 );
		animal.scale = 5;

		[self addChild:animal];
		[animal runAction:[CCScaleTo actionWithDuration:secondsPerFadeIn scale:1.75]];
	}
	

	///////////
	int displayX = size.width / 4;
	int displayY = 160;
	int displayY2 = 115;
    
	line1 = [CCLabelBMFont labelWithString:@"Score" fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY );
	[self addChild:line1];	

	caughtString = [NSString stringWithFormat:@"%d", score];
	line1 = [CCLabelBMFont labelWithString:caughtString fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY2 );
	[self addChild:line1];	
	
	//////////
	displayX = 2 * size.width / 4;
	line1 = [CCLabelBMFont labelWithString:@"Words" fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY );
	[self addChild:line1];	
	
	caughtString = [NSString stringWithFormat:@"%d", totalWords];
	line1 = [CCLabelBMFont labelWithString:caughtString fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY2 );
	[self addChild:line1];	
	
	/////////
	displayX = 3 * size.width / 4;
	line1 = [CCLabelBMFont labelWithString:@"Time" fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY );
	[self addChild:line1];	
	
	caughtString = [NSString stringWithFormat:@"%.1f", elapsed];
	line1 = [CCLabelBMFont labelWithString:caughtString fntFile:kAHBitmapFontName];
	line1.position = ccp( displayX, displayY2 );
	[self addChild:line1];	
}

#pragma mark -
#pragma mark Init
-(id) init
{
	if( (self=[super initWithColor: ccc4( 50, 50, 50, 200)] )) {		
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelBMFont *newLabel = [CCLabelBMFont labelWithString:@"New Game" fntFile:kAHBitmapFontName];
        CCMenuItemLabel *newItem = [CCMenuItemLabel itemWithLabel:newLabel target:self selector:@selector(okButtonCB:)];
        CCLabelBMFont *mmLabel  = [CCLabelBMFont labelWithString:@"Main Menu" fntFile:kAHBitmapFontName];
        CCMenuItemLabel *mmItem = [CCMenuItemLabel itemWithLabel:mmLabel target:self selector:@selector(mmButtonCB:)];
        CCLabelBMFont *hsLabel  = [CCLabelBMFont labelWithString:@"High Scores" fntFile:kAHBitmapFontName];
        CCMenuItemLabel *hsItem = [CCMenuItemLabel itemWithLabel:hsLabel target:self selector:@selector(scoreButtonCB:)];
        CCMenu *menu = [CCMenu menuWithItems: newItem,
                        mmItem,
                        hsItem,
                        nil];
        newItem.position = ccp(0,0);
        [newLabel setColor:ccGREEN];
        
        mmItem.position = ccp( 200, 0 );
        mmItem.scale = 0.5;
        [mmLabel setColor:ccGREEN];
        
        hsItem.position = ccp( -200, 0 );
        hsItem.scale = 0.5;
        [hsLabel setColor:ccGREEN];
        
        menu.position = ccp( size.width/2, 50 );
        [self addChild:menu z:1];
	}
	
	return self;
}

#pragma mark -
#pragma mark Touch Functions
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	//	[self touchLetters: touch];
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// If it weren't for the TouchDispatcher, you would need to keep a reference
	// to the touch from touchBegan and check that the current touch is the same
	// as that one.
	// Actually, it would be even more complicated since in the Cocos dispatcher
	// you get NSSets instead of 1 UITouch, so you'd need to loop through the set
	// in each touchXXX method.
	//	[self touchLetters: touch];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	
}

@end
