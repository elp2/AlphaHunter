//
//  AHMainMenu.m
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "AHMainMenu.h"
#import "AHDictionarySingleton.h"
#import "GameCenterManager.h"

#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

#define kAHNumWordColors 7
static ccColor3B AHWordColors[kAHNumWordColors] = { 
    { 90, 193, 83}, 
    { 83, 193, 130 }, 
    { 83, 193, 185 }, 
    { 83, 145, 193 }, 
	{ 83, 90, 193 }, 
    { 193, 83, 90 }, 
    { 130, 83, 193 }, 
};

@implementation MainMenuLayer

static int alreadyLaunched = NO;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) placeWords
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    NSArray *words = [[NSArray alloc]initWithObjects:
                      @"awesome",
                      @"centaur",
                      @"chetah",
                      @"hidden",
                      @"message",
                      @"kangaroo",
                      @"lorikeet",
                      @"koala",
                      @"lion",
                      @"tiger",
                      @"bear",
                      @"penguin",
                      @"cow",
                      @"pig",
                      @"dog",
                      @"cat",
                      @"robot",
                      @"elephant",
                      @"zebra",
                      @"giraffe",
                      @"ostrich",
                      @"platypus",
                      @"emu",
                      @"dingo",
                      @"wombat",
                      @"leopard",
                      @"lemur",
                      @"monkey",
                      @"mouse",
                      @"snake",
                      @"crocodile",
                      @"octopus",
                      @"parrot",
                      @"sloth",
                      @"snake",
                      @"gorilla",
                      nil
];
    int wi;
    int randomSpacing = RANDOM_INT(0,15);
    for(wi=0; wi<[words count]; wi++) {
        NSString *useWord = [words objectAtIndex:(wi+randomSpacing)%[words count]];
        NSLog(@"StartingWord %@", useWord);
        CCLabelBMFont *word = [CCLabelBMFont labelWithString:[useWord uppercaseString] fntFile:kAHBitmapFontName];
        
        [word setColor:AHWordColors[ RANDOM_INT( 0, kAHNumWordColors-1 ) ]];
        
        int scaleUpPercent = RANDOM_INT(-50,50);
        word.scale = 1.00f + scaleUpPercent/100.0f;

        int usableHeight = size.height - 100;
        int yPos = 50 + wi * usableHeight / [words count] + RANDOM_INT(-10, 10);

        CGPoint rightPos   = ccp( size.width + word.contentSize.width, yPos );
        CGPoint leftPos    = ccp( -1 * word.contentSize.width, yPos );
        int midXMin, midXMax;
        if(wi%2==0) { midXMin = 1; midXMax = 500; } else { midXMin = 501; midXMax = 1000; }
        int midX = leftPos.x + RANDOM_INT(midXMin, midXMax) * (rightPos.x - leftPos.x) / 1000;
        CGPoint midPos     = ccp( midX, yPos);
        word.position = midPos;

        float runTime = 10.0f;//(float)RANDOM_INT(10,15);
        float pixelsPerSecond = (rightPos.x - leftPos.x) / runTime;

        id midRight = [CCMoveTo actionWithDuration:(rightPos.x - midPos.x)/pixelsPerSecond position:rightPos];
        id upperRight = [CCMoveTo actionWithDuration:0.05 position:CGPointMake(rightPos.x, -200)];
        id upperLeft = [CCMoveTo actionWithDuration:0.05 position:CGPointMake(leftPos.x, -200)];
        id left = [CCMoveTo actionWithDuration:0.05 position:leftPos];
        id leftMid = [CCMoveTo actionWithDuration:(midPos.x - leftPos.x)/pixelsPerSecond position:midPos];
        id loopForever = [CCRepeatForever actionWithAction:[CCSequence actions:midRight, upperRight, upperLeft, left, leftMid, nil]];
        [word runAction:loopForever];

        [self addChild:word z:0];
        NSLog(@"Moving %@ from %.2f -> %.2f -> %.2f at %.2f", useWord, midPos.x, rightPos.x, leftPos.x, pixelsPerSecond);
    }
}

-(id) init
{
	if( (self=[super initWithColor: ccc4( kAHGreenR, kAHGreenG, kAHGreenB, 255)] )) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *top = [CCSprite spriteWithFile:@"Background.png" rect:CGRectMake(0, 0, 1024, 287)];
        [self addChild:top];
        top.position = CGPointMake(size.width/2, size.height - [top boundingBoxInPixels].size.height/2);
        
        CCSprite *bottom = [CCSprite spriteWithFile:@"Background.png" rect:CGRectMake(0, 287, 1024, 435-287)];
        [self addChild:bottom];
        bottom.position = CGPointMake(size.width/2, [bottom boundingBoxInPixels].size.height/2);
        
		[AHDictionarySingleton sharedInstance];

		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"ALPHA HUNTER" fntFile:kAHBitmapFontNameBig];
		label.position =  ccp( size.width /2 , size.height/2 + 50 );
		[self addChild:label z:1];
		
        CCLabelBMFont *item1Label = [CCLabelBMFont labelWithString:@"START GAME" fntFile:kAHBitmapFontNameBig];
        CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:item1Label target:self selector:@selector(gameTran:)];

		[item1 setColor:ccBLACK];
		CCMenu *menu = [CCMenu menuWithItems: item1, nil];
        item1.scale = 0.75;
		menu.position =  ccp( size.width /2 , size.height/4 );
		[self addChild: menu z:1];

        CCLabelBMFont *aboutLabel = [CCLabelBMFont labelWithString:@"About" fntFile:kAHBitmapFontName];
        CCMenuItemLabel *aboutItem = [CCMenuItemLabel itemWithLabel:aboutLabel target:self selector:@selector(aboutTran:)];
        CCLabelBMFont *highScoresLabel = [CCLabelBMFont labelWithString:@"High Scores" fntFile:kAHBitmapFontName];
        CCMenuItemLabel *highScoresItem = [CCMenuItemLabel itemWithLabel: highScoresLabel  target:self selector:@selector(highScores:)];
        
		CCMenu *menu2 = [CCMenu menuWithItems: aboutItem,
                                               highScoresItem,
                                                nil];
		aboutItem.position = ccp( -300, 0 );
        aboutItem.scale = 0.75;
		highScoresItem.position = ccp( 300, 0 );
        highScoresItem.scale = 0.75;
	
		menu2.position =  ccp( size.width/2, 40);			
		[self addChild: menu2 z:1];
					
		if( !alreadyLaunched ) {
			CCSprite *defaultImg = [CCSprite spriteWithFile:@"Default.png"];
			[defaultImg setRotation:270];
			
			defaultImg.position = ccp( size.width / 2, size.height / 2 );
			id scaleAction = [CCScaleBy actionWithDuration:1 scale:2];
			id fadeAction = [CCFadeOut actionWithDuration:1];
			[defaultImg runAction:scaleAction];
			[defaultImg runAction:fadeAction];
			[self addChild:defaultImg z:2];
			alreadyLaunched = YES;
		}
		RANDOM_SEED();
		
        [self placeWords];
	}
	
	return self;
}

-(void) highScores: (id) sender
{
    [[GameCenterManager sharedInstance] showLeaderboard];
}

-(void) gameTran: (id) sender
{
	AHGameScene *scene = [AHGameScene node]; // We use a AHGameScene to easier detect that we're in game mode and should pause in the Delegate
	[scene addChild: [GameLayer node] z:0 tag:kAHGameTag];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:0.1 scene:scene]];
}

-(void) aboutTran: (id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild: [AboutLayer node] z:0];
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
