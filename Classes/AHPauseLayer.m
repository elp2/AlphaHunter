//
//  AHPauseLayer.m
//  AlphaHunterIpad995
//
//  Created by Edward Palmer on 3/1/12.
//  Copyright 2012 chichai.com. All rights reserved.
//

#import "AHPauseLayer.h"

@implementation AHPauseLayer

#pragma mark -
#pragma mark Init
-(id) init
{
	if( (self=[super initWithColor: ccc4( 50, 50, 50, 200)] )) {	
		NSLog( @"GamePaused" );
        self.isTouchEnabled = YES;
        
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		
        CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"GAME PAUSED" fntFile:kAHBitmapFontNameBig];
		title.position = ccp( size.width/2, 500 );
        [title setColor:ccRED];
		[self addChild:title];
 
        CCLabelBMFont *text = [CCLabelBMFont labelWithString:@"Tap Anywhere to Continue" fntFile:kAHBitmapFontName];
		text.position = ccp( size.width/2, 300);
		[self addChild:text];      
	}
	
	return self;
}

#pragma mark -
#pragma mark EnterExit
-(void) onEnter
{
    NSLog( @"PL onEnter %d", [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused );
    if( ![AlphaHunterIpad995AppDelegate getDelegateSingleton].paused ) {
        NSLog(@"PauseLayer - adding touch del!!!");
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        [super onEnter];
    }
}

- (void)onExit
{
    NSLog(@"PL onExit %d", [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused );
    if( ![AlphaHunterIpad995AppDelegate getDelegateSingleton].paused ) {
        // Need to only call onExit/onEnter when we're not paused... this way onEnter gets called when we create the PL, and then onExit happens after we resume (1x each only)
        NSLog(@"onExit PauseLayer - removing touch disp");
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        [super onExit];
    }
}

#pragma mark -
#pragma mark Touch Functions

-(CGPoint) getPointForTouch:(UITouch *)touch
{
	CGPoint tp = [self convertTouchToNodeSpace:touch];	
	
	return( tp );
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog(@"Pause Touchbegan!");
    GameLayer * gl = (GameLayer *)self.parent;
    [self.parent removeChild:self cleanup:YES];
    [gl resume];

	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Nothing to do here
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog( @"PauseTouchEnded!" );
	CGPoint tp = [self getPointForTouch:touch];
    NSLog( @"Pause touch @ %@", NSStringFromCGPoint(tp));
};


- (void) dealloc
{
    [super dealloc];
}

@end
