//
//  AHNewGameLayer.m
//  AlphaHunterIpad995
//
//  Created by Edward Palmer on 15/12/11.
//  Copyright 2011 chichai.com. All rights reserved.
//

#import "AHNewGameLayer.h"
#import "Animal.h"

@implementation AHNewGameLayer

#pragma mark - 
#pragma mark External CB's 
-(void) instructionsOKClicked:(AHInstructionsLayer *) ahil
{
	[self removeChild:ahil cleanup:YES];
}

#pragma mark -
#pragma mark Callbacks

-(void) newGame:(AHGameDifficulty) difficulty
{
    if( [self.parent isKindOfClass:[GameLayer class]] ) {
        [(GameLayer *) self.parent newGameRequest:difficulty];
        [self.parent removeChild:self cleanup:YES];
    }
    else {
        [self.parent removeChild:self cleanup:YES];
        [self.parent.parent removeChild:self cleanup:YES];
        [(GameLayer *) self.parent newGameRequest:difficulty];
   }
}

-(void) easyCB: (id) sender
{
    NSLog(@"EASY!");
    [self newGame:kAHGameEasy];
}

-(void) medCB: (id) sender
{
    NSLog(@"MED!");
    [self newGame:kAHGameMedium];
}

-(void) hardCB: (id) sender
{
    NSLog(@"HARD!");
    [self newGame:kAHGameHard];
}

-(void) instructionsCB: (id) sender
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    AHInstructionsLayer *il = [AHInstructionsLayer node];
    [self addChild:il z:kAHInstructionsZ+1];
    il.position = ccp( size.width, 0 );
    [il runAction:[CCMoveTo actionWithDuration:0.25 position:ccp(0, 0)]];    
}

#pragma mark -
#pragma mark Helpers
-(CCMenu *) getGameButton:(NSString *) title andAnimal:(Animal *) animal desc1:(NSString *) desc1 desc2:(NSString *) desc2 selector:(SEL)selector
{
    CCNode *node = [[CCNode alloc] init];
    
    CCLabelBMFont *titleLabel = [CCLabelBMFont labelWithString:title fntFile:kAHBitmapFontName];
    CCLabelBMFont *desc1Label = [CCLabelBMFont labelWithString:desc1 fntFile:kAHBitmapFontName];
    CCLabelBMFont *desc2Label = [CCLabelBMFont labelWithString:desc2 fntFile:kAHBitmapFontName];
    
    [node addChild:titleLabel];
    titleLabel.position = ccp( 0, 0 );
    [node addChild:animal];
    animal.position = ccp( 0, -1 * [titleLabel boundingBox].size.height - [animal boundingBox].size.height );
    [node addChild:desc1Label];
    desc1Label.position = ccp( 0, animal.position.y - [animal boundingBox].size.height - [desc1Label boundingBox].size.height );
    desc1Label.scale = 0.5;

    [node addChild:desc2Label];
    desc2Label.position = ccp( 0, desc1Label.position.y - [desc1Label boundingBox].size.height );//ccp( 0, minimumLabel.position.y - [minimumLabel boundingBox].size.height );
    desc2Label.scale = 0.5;
    
    [node setContentSize:CGSizeMake([desc2Label contentSize].width/2, -1 * desc2Label.position.y )];
        
    CCMenuItem *item = [CCMenuItem itemWithTarget:self selector:selector];
    [item addChild:node];
    node.anchorPoint = ccp(-0.5f,-1.0f);
    [item setContentSize:[node contentSize]];
    
    CCMenu *menu = [CCMenu menuWithItems: item, nil];
    return menu;
}

#pragma mark -
#pragma mark Init
-(id) init
{
	if( (self=[super initWithColor: ccc4( 50, 50, 50, 200)] )) {		
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"NEW GAME" fntFile:kAHBitmapFontNameBig];
        title.position = ccp( size.width/2, size.height - 200 );
        [self addChild:title];

        float y = size.height/2-50;
        easyMenu_ = [self getGameButton:@"Easy" andAnimal:[Animal animalWithType:6] desc1:@"30 seconds" desc2:@"Min word 3 letters" 
                                       selector:@selector(easyCB:)];
        easyMenu_.position = CGPointMake(size.width/3-100, y);
        [self addChild:easyMenu_];
        medMenu_ = [self getGameButton:@"Medium" andAnimal:[Animal animalWithType:3] desc1:@"30 seconds" desc2:@"Min word 4 letters"
                                selector:@selector(medCB:)];
        medMenu_.position = ccp( size.width/2, y);
        [self addChild:medMenu_];
        hardMenu_ = [self getGameButton:@"Wild" andAnimal:[Animal animalWithType:2] desc1:@"30 seconds" desc2:@"Min word 5 letters"
                            selector:@selector(hardCB:)];
        hardMenu_.position = ccp( 2*size.width/3+100, y);
        [self addChild:hardMenu_];
        
        CCLabelBMFont *instructionsLabel = [CCLabelBMFont labelWithString:@"Instructions" fntFile:kAHBitmapFontName];
        [instructionsLabel setColor:ccGREEN];
        CCMenuItemLabel *instructionsItem = [CCMenuItemLabel itemWithLabel:instructionsLabel target:self selector:@selector(instructionsCB:)];        
        CCMenu *instructionsMenu = [CCMenu menuWithItems: instructionsItem,
                         nil];
        [self addChild:instructionsMenu];        
        instructionsMenu.position = ccp(size.width/2, 100);
        
        if( NO == [[AHDictionarySingleton sharedInstance] seenInstructions] ) {
            [AHDictionarySingleton sharedInstance].seenInstructions = YES;
            [self instructionsCB:self];
        }
    }
    
    return self;
}
@end
