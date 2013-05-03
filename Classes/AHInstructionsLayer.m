//
//  AHInstructionsLayer.m
//  AlphaHerderZ
//
//  Created by Edward Palmer on 28/02/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import "AHInstructionsLayer.h"


@implementation AHInstructionsLayer


#pragma mark -
#pragma mark Callbacks

-(void) okButtonCB: (id) sender
{
	[(AHNewGameLayer *) self.parent instructionsOKClicked:self];
}

#define ADD_LEFT_JUSTIFIED(pLine) {pLine.anchorPoint = ccp( 0, 0 ); pLine.position = ccp( 60, spacing);}

#pragma mark -
#pragma mark Init
-(id) init
{
	if( (self=[super initWithColor: ccc4( 25, 25, 25, 240)] )) {
		NSLog( @"Instructions" );

		CGSize size = [[CCDirector sharedDirector] winSize];
		
		int spacing = size.height - 200;
        CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"INSTRUCTIONS" fntFile:kAHBitmapFontNameBig];
		title.position = ccp( size.width/2, spacing );
		[self addChild:title];
		
		spacing -= 130;
        CCLabelBMFont *line = [CCLabelBMFont labelWithString:@"Create words to trap the animals" fntFile:kAHBitmapFontName];    
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];

		spacing -= 60;
		line = [CCLabelBMFont labelWithString:@"Tap on the letters to create a word like C-A-T-C-H" fntFile:kAHBitmapFontName];		
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];

        spacing -= 50;
        line = [CCLabelBMFont labelWithString:@"Current word at top turns red when in the dictionary" fntFile:kAHBitmapFontName];	
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];
		
		spacing -= 50;
        line = [CCLabelBMFont labelWithString:@"Touch the first letter or top letters to complete the word" fntFile:kAHBitmapFontName];	
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];

		spacing -= 50;
        line = [CCLabelBMFont labelWithString:@"Make long words with lots of animals for more points" fntFile:kAHBitmapFontName];	
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];

        spacing -= 50;
        line = [CCLabelBMFont labelWithString:@"Letters in the area dissappear so make smaller words" fntFile:kAHBitmapFontName];	
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];
        
        spacing -= 50;
        line = [CCLabelBMFont labelWithString:@"Catch as many animals as possible before time runs out" fntFile:kAHBitmapFontName];	
        line.scale = 0.5f;
		ADD_LEFT_JUSTIFIED(line);
		[self addChild:line];

        CCSprite *img = [CCSprite spriteWithFile:@"Instructions.png"];
        img.anchorPoint = ccp(0,0);
        img.position = ccp(650,100);
        [self addChild:img];
        
        CCLabelBMFont *instructionsLabel = [CCLabelBMFont labelWithString:@"OK" fntFile:kAHBitmapFontNameBig];
        [instructionsLabel setColor:ccGREEN];
        CCMenuItemLabel *instructionsItem = [CCMenuItemLabel itemWithLabel:instructionsLabel target:self selector:@selector(okButtonCB:)];        
		CCMenu *menu2 = [CCMenu menuWithItems: instructionsItem,
                         nil];
        [self addChild:menu2];
        menu2.position = ccp( size.width / 2, 75 );        
	}
	
	return self;
}
@end
