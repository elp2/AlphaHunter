//
//  About.m
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "About.h"
#import "AHMainMenu.h"
#import "AHWord.h"

@implementation AboutLayer


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AboutLayer *layer = [AboutLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(CCLabelBMFont *) getBitmapText:(NSString *) text fontSize:(int) fontSize
{
    NSString *fntFile;
    if(fontSize > 40) { fntFile = kAHBitmapFontNameBig; } else { fntFile = kAHBitmapFontName; };
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:text fntFile:fntFile];
    //label.scale = fontSize / 30;
    
    return label;
}

-(int) addCenteredNode:(CCNode *)node xPos:(int) xPos yPos:(int)yPos 
{
	node.position = ccp( xPos, yPos - node.contentSize.height / 2 );
	yPos -= node.contentSize.height;
	
	[creditsLayer_ addChild:node];
	
	return yPos;
}

// on "init" you need to initialize your instance
-(id) init
{
	int yPos;
	if( (self=[super initWithColor: ccc4( 0, 0, 0, 255)] )) {
		creditsLayer_ = [CCLayerColor layerWithColor: ccc4( 0, 0, 0, 255)];

		CGSize size = [[CCDirector sharedDirector] winSize];
		yPos = size.height - 30;

		// CREDITS
		CCLabelBMFont* label = [self getBitmapText:@"CREDITS"  fontSize:64];		
		label.position =  ccp( size.width /2 , yPos );	
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];


		// Programming.. Ed Palmer
		label = [self getBitmapText:@"Programming...      Edward Palmer"  fontSize:30];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];
		CCSprite *img = [CCSprite spriteWithFile:@"BdayCake.jpg"];
		yPos -= 10;
		yPos = [self addCenteredNode:img xPos:size.width / 2 yPos:yPos];
		yPos -= 40;
        
        // Muse
		yPos -= 40;
		label = [self getBitmapText:@"Muse... Everywhere Girl"  fontSize:30];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];
		yPos -= 10;
		img = [CCSprite spriteWithFile:@"Esther.JPG"];
		yPos = [self addCenteredNode:img xPos:size.width / 2 yPos:yPos];
		
		// Cocos2d
        yPos -= 40;
		label = [self getBitmapText:@"Game Engine... cocos2d for iPad"  fontSize:30];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];
		yPos -= 10;
		img = [CCSprite spriteWithFile:@"Official-cocos2d-Logo-Landscape-Angry.png"];
		yPos = [self addCenteredNode:img xPos:size.width / 2 yPos:yPos];
		
		// Font
		yPos -= 40;
		label = [self getBitmapText:@"Font... GoodDog Plain by ethan@fonthead.com"  fontSize:30];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	

		// Code Details
		yPos -= 40;
		label = [self getBitmapText:@"Code..."  fontSize:30];		
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	
		label = [self getBitmapText:@"3236 Lines of Objective-C code"  fontSize:20];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	
		label = [self getBitmapText:@"656 Lines of Objective-C headers"  fontSize:20];
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	
		
		// Twitter
		yPos -= 40;
		label = [self getBitmapText:@"Follow me on twitter @ohsnapninjas"  fontSize:30];		
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	
        
        yPos -= 40;
		label = [self getBitmapText:@"Look for my other apps on the Appstore!"  fontSize:30];		
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	

		// Thanks
		yPos -= 40;
		label = [self getBitmapText:@"Thanks for playing!  -Ed"  fontSize:30];		
		yPos = [self addCenteredNode:label xPos:size.width / 2 yPos:yPos];	
		
		// Now that we've added evertyhing to creditsLayer, scroll it
		[self addChild:creditsLayer_];
        creditsLayer_.position = ccp( 0, -1 * size.height/2 );
		[creditsLayer_ runAction:[CCMoveTo actionWithDuration:kScrollTime position:CGPointMake( 0, -1 * yPos )]];
		
		CCLabelBMFont *backLabel = [CCLabelBMFont labelWithString:@"Back" fntFile:kAHBitmapFontName];
		CCMenuItemLabel *backItem = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(menuTran:)];
		CCMenu *menu = [CCMenu menuWithItems: backItem, nil];
		[menu alignItemsVertically];
        [backItem setColor:ccGREEN];
		[self addChild: menu z:2];
		yPos -= backItem.contentSize.height/2;
		menu.position = ccp( size.width - backItem.contentSize.width / 2 - 10, 
							 20 );	
	}
	return self;
}

-(void) launchCCPage:(id) sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://chichai.com/AlphaHunter/CC.html"]];	
}
-(void) launchMineField:(id) sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=312962759&mt=8"]];
}

-(void) menuTran: (id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild: [MainMenuLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFadeBL transitionWithDuration:0.5 scene:scene]];	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
