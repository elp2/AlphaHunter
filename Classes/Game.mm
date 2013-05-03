//
//  Game.m
//  AlphaHunter
//
//  Created by Ed Palmer on 16/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//


#import "Game.h"
#import "AHMainMenu.h"
#import "Letter.h"
#import "GameCenterManager.h"

#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + arc4random() % ((__MAX__+1) - (__MIN__)))
@implementation GameLayer

int letterFrequencies[] = {
716,
965,
1244,
1669,
2939,
3162,
3363,
3973,
4669,
4685,
4762,
5164,
5405,
6080,
6831,
7024,
7033,
7632,
8264,
9170,
9346,
9450,
9600,
9780,
9840,
30000, // just in case it's way off in our funtion
};

@synthesize adView;

#pragma mark -
#pragma mark Animals

-(void) animalResurrected
{
	numLiveAnimals_++;
}

-(int) isOnBoard:(CGPoint)to
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	int offBoard = to.x >= size.width -kLetterWidth / 2 || to.x <= kLetterWidth / 2  || to.y >= size.height -kLetterWidth / 2 - topHeight_ || to.y <= kLetterWidth / 2;
	
	if( offBoard ) {
		return NO;
	} else {
		return YES;
	}
}

-(CGPoint) getAnimalPosition
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	int padding = 100;
	int toPixelsWide = size.width - padding;
	int toPixelsHigh = size.height - topHeight_ - padding;
	
	CGPoint point = ccp( -100, -100 );
	while( ![self isOnBoard:point] ) {
		point = ccp( RANDOM_INT( padding, (toPixelsWide) ), 
					RANDOM_INT( padding, toPixelsHigh ) );
	}
	
	return( point );		
}

-(void) updateAnimalSpeeds
{
	float newSpeed = (float)numTotalAnimals_ / (float)numLiveAnimals_;

	[Animal setGameSpeed: newSpeed];
}

-(int) isLegalMoveFrom:(CGPoint)from to:(CGPoint) to
{
	if( ![self isOnBoard:to] )
		return NO;
	
	return( [selectionPath_ sameSideOfLinePointA:from pointB:to] );	
}

#pragma mark -
#pragma mark Scores 

-(void) showScoreScreen
{
	allowLetterClicks_ = NO;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	AHScoreLayer *scores = [AHScoreLayer node];
	[scores prepareScoreWithNumAnimals:totalAnimalsCaught_ caughtNums:caughtAnimals_ score:score_ totalWords:wordsUsed_ elapsed:elapsedTime_];

	
	//[scores prepareScoreWithAnimals:animals_ score: score_];
	scores.position = ccp( size.width + scores.contentSize.width / 2, 0 );
	[scores runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0,0)]];
	[self addChild:scores z:1000];
}

-(void) scoreChanged
{
	[scoreLabel_ setString:[NSString stringWithFormat:@"%d", score_]];
}

-(void) increaseScoreBy:(int)by
{
	if( by > 1000 || by < 0 )
		by = 1;
	
	score_ += by;
	[self scoreChanged];
}


-(void) resetScore
{
	score_ = 0;
	[self scoreChanged];
}

#pragma mark -
#pragma mark Time

-(void)increaseTimeBy:(int)by
{
	timeLeft_ += by;
    timeLeft_ = MIN(maxTimeLeft_, timeLeft_);
}

-(void) redrawClock
{
	NSString *formattedTime = [NSString stringWithFormat:@"%2.1f", timeLeft_];	
	[timeLabel_ setString:formattedTime];
}

-(void) startClock
{
	[self redrawClock];
	[self schedule:@selector(tickClock) interval:kAHGameClockTickTime];
}

-(void) stopClock
{
	[self unschedule:@selector(tickClock)];
}

-(void) timesUp
{
	allowLetterClicks_ = NO;
	[self stopClock];
	for( Animal *animal in animals_) {
		[animal runAction:[CCScaleTo actionWithDuration:2.0 scale:0]];
	}
	
	
	NSMutableArray *wordLetters = [word_ getWordLetters];
	for( Letter *letter in wordLetters) {
		[letter wasRemoved];
	}
	
	int x = 0, y = 0;
	for( x=0; x<32;x++){
		for( y=0; y<48; y++) {
			Letter *letter = letters_[x][y];
			[letter stopAllActions];
			[letter runAction:[CCScaleTo actionWithDuration:3.0 scale:0]];
		}
	}	
	
	[selectionPath_ done];
	[self reorderChild:selectionPath_ z:kAHSelectionPathZ];
	
	selectionPath_ = [[AHSelectionPath alloc] init];
	[self addChild:selectionPath_ z:kSelectionPathZ];
	
	[self readyNextWord];	
	
	[self showScoreScreen];	
}

-(void) stopStrobingClock
{
	NSLog( @"alertClock!" );
	[timeLabel_ setColor:ccc3( 255, 255, 255)];
	[timeLabel_ stopAllActions];
	strobingTime_ = NO;

	[timeLabel_ setScale:kAHTimeLabelNormalSize]; 
}

-(void) startStrobingClock
{
	NSLog( @"alertClock!" );
	[timeLabel_ setColor:ccc3( 255, 0, 0)];
	CCSequence *strobe = [CCSequence actions:[CCScaleTo actionWithDuration:0.5f scale:1.1f], [CCScaleTo actionWithDuration:0.5 scale:0.9f], nil];
	[timeLabel_ runAction:[CCRepeatForever actionWithAction: strobe]];
	strobingTime_ = YES;
}

-(void) tickClock
{
	timeLeft_ -= kAHGameClockTickTime;
	elapsedTime_ += kAHGameClockTickTime;
	
	if( timeLeft_ < 0 )
		timeLeft_ = 0;
	
	if( 6.05 > timeLeft_ && 5.95 < timeLeft_ )
		[self startStrobingClock];
	
	if( strobingTime_ && 6.1 < timeLeft_ )
		[self stopStrobingClock];
			
	[self redrawClock];
	
	if( 0 == timeLeft_ )
		[self timesUp];
	
	[self updateAnimalSpeeds];
}

#pragma mark -
#pragma mark Words 

-(void) stopStrobingWord
{
	[topWord_ stopAllActions];
	[topWord_ setScale:1.0]; 
}

-(void) startStrobingWord
{
	CCSequence *strobe = [CCSequence actions:[CCScaleTo actionWithDuration:0.5f scale:1.15f], [CCScaleTo actionWithDuration:0.5 scale:0.85f], nil];
	[topWord_ runAction:[CCRepeatForever actionWithAction: strobe]];
}

// Resets the displayed word
-(void) wordChangedIsAWord:(int)isAWord
{
	NSString *displayedWord = [word_ getWordString];
	[topWord_ setString:displayedWord];
	if( isAWord ) {
		[topWord_ setColor:ccc3( 205, 0, 0)];
        [self startStrobingWord];
	} else {
		[topWord_ setColor:ccc3( 105, 105, 105)];
        [self stopStrobingWord];
	}
}

-(void) removeLastLetter
{
	[selectionPath_ letterRemoved];
}

-(void) letterAddedAt:(Letter *)letter
{
	[self reorderChild:letter z:kSelectedLetterZ];
	[selectionPath_ letterAddedAt:letter.position];

}

-(void) letterSelected:(Letter *)letter
{
	if( allowLetterClicks_ )
		[word_ letterWasClicked:letter];
}

-(int) pointsForWord:(NSMutableString *)word numAnimalsCaught:(int)numAnimalsCaught numLettersCaught:(int) numLettersCaught
{

	int basePoints = ([word length] * [word length] * numAnimalsCaught * numAnimalsCaught );
	if( 0 == numAnimalsCaught )
		return basePoints;
	
	return basePoints / (sqrt(numLettersCaught)/2);	
}

-(double) getTimeDistance:(Letter *)gridLetter
{
	int selectedLettersHigh = (int)( ( maxY - minY ) / kLetterWidth );
	
	double timeDistance = ( ( gridLetter.position.x - minX ) / kLetterWidth ) * selectedLettersHigh
	+ ( gridLetter.position.y - minY ) / kLetterWidth;
	
	return timeDistance;
}

-(void) letterCaught:(Letter *)gridLetter
{
	[gridLetter wasCaughtDelay:[self getTimeDistance:gridLetter]* 0.01f limboTime:kAHLetterLimboTime withString:[self pickCharacter]];	
}

-(void) wordAcheivements:(NSString *)wordString
{
	switch ([wordString length]) {
		case 5:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_5"];
			break;
			
		case 6:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_6"];
            break;
			
		case 7:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_7"];
			break;
	
		case 8:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_8"];
            break;
	
		case 9:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_9"];
            break;

		case 10:
            [[GameCenterManager sharedInstance] achievement:@"WORD_LENGTH_10"];
            break;

		default:
			break;
	}

}

-(void) wordFoundSuccessfully:(NSMutableArray *)letters
{
	wordsUsed_++;

	NSMutableString *useWord = [word_ getWordString];
	[self wordAcheivements:useWord];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	int avgX = 0;
	int avgY = 0;
	
	minX = size.width;
	maxX = 0;
	minY = size.height;
	maxY = 0;
	
	int lettersScore = 1;
	for( Letter *letter in letters) {
		lettersScore *=2;
		minX = MIN( minX, letter.position.x);
		minY = MIN( minY, letter.position.y);
		maxX = MAX( maxX, letter.position.x);
		maxY = MAX( maxY, letter.position.y);
		
		avgX += letter.position.x;
		avgY += letter.position.y;
	}
	

	int numLettersCaught = 0;
	int x, y;
	for ( x=0; x<lettersWide_; x++) {
		for( y=0; y< lettersHigh_; y++ ) {
			Letter *gridLetter = letters_[x][y];
			if( nil == gridLetter )
				continue;
			
			if( [selectionPath_ containsPoint:gridLetter.position] )
			{
				numLettersCaught++;
				[self letterCaught:gridLetter];				
			}			
		}
	}
	[selectionPath_ catchLettersOnPath:self];
	
	int selectedLettersHigh = (int)( ( maxY - minY ) / kLetterWidth );
	int numAnimalsCaught = 0;
	for( Animal *animal in animals_ ) {
		if( [selectionPath_ containsPoint:animal.position] && [animal isFree] )
		{
			double timeDistance = ( ( animal.position.x - minX ) / kLetterWidth ) * selectedLettersHigh
			+ ( animal.position.y - minY ) / kLetterWidth;
			
			caughtAnimals_[ [animal getType ]-1 ]++;
			[animal wasCaughtDelay:timeDistance * 0.02f limboTime:1.0f];
			numAnimalsCaught++;
			totalAnimalsCaught_++;
			numLiveAnimals_--;
		}	
	}
	
	int scoreIncrease = [self pointsForWord:useWord numAnimalsCaught:numAnimalsCaught numLettersCaught:numLettersCaught];
	[self increaseScoreBy:scoreIncrease];
	[self increaseTimeBy:((numAnimalsCaught+1)*(numAnimalsCaught+1))/2];
	
	[selectionPath_ done];
	[self reorderChild:selectionPath_ z:kAHSelectionPathZ];
	
	selectionPath_ = [[AHSelectionPath alloc] init];
	[self addChild:selectionPath_ z:kSelectionPathZ];
	
	[spinWord_ setString:useWord];
	[spinWord_ setOpacity:0];
	spinWord_.position = ccp( avgX / [letters count], avgY / [letters count] );
	NSLog( @"Using word: %@ at %f %f", useWord, spinWord_.position.x, spinWord_.position.y );

	int spinStartAngle = (360 + RANDOM_INT( 0, 100 ) - 50 ) % 360;
	int spinDeltaAngle = RANDOM_INT( 0, 50 ) - 100;
	[spinWord_ setRotation:spinStartAngle];
	id spinSequence = [CCSequence actions: [CCRotateBy actionWithDuration:kSpinWordDuration angle:spinDeltaAngle],
									     [CCMoveTo actionWithDuration:0 position:ccp( -500, -500 )],
										 nil];
	[spinWord_ runAction:spinSequence];

	id fadeSequence = [CCSequence actions: [CCFadeOut actionWithDuration:kSpinWordDuration+0.3],
										 [CCFadeIn  actionWithDuration:0],
										 nil];
	[spinWord_ runAction:fadeSequence];
	
	id sizeSequence = [CCSequence actions: [CCScaleBy actionWithDuration:kSpinWordDuration scale:4.0], 
										 [CCScaleTo actionWithDuration:0 scale:1.0], 
										 nil];
	[spinWord_ runAction:sizeSequence];
}


-(void) readyNextWord
{
	[selectionPath_ clearSelections];
	
	[word_ resetWord];
    [self stopStrobingWord];
}

-(void) wordSuccess
{
	NSLog( @"wordSuccess!" );
	for (Animal *esther in animals_) {
		if ([selectionPath_ containsAnimal:esther] &&[esther isFree]) {
			NSLog( @"animal!!!!" );
			[esther stopAllActions];
		}
	}
	
	NSMutableArray *wordLetters = [word_ getWordLetters];
	[self wordFoundSuccessfully:wordLetters];
	
	[self readyNextWord];
	
	emitter_ = [AHParticleExplosion node];
	[self addChild:emitter_ z:10];
	emitter_.position = topWord_.position;
}


-(void) wordFailure
{
	NSLog( @"wordFailure :(" );
	
	[spinWord_ setString:@"???"];
	[spinWord_ setOpacity:0];
	[spinWord_ setScale:1];
	CGSize size = [[CCDirector sharedDirector] winSize];

	spinWord_.position = ccp( size.width / 2, size.height / 2 );
	
	id fadeSequence = [CCSequence actions: [CCFadeOut actionWithDuration:kSpinWordDuration+0.3],
										 [CCMoveTo actionWithDuration:0 position:ccp( -500, -500 )],
										 nil];
	[spinWord_ runAction:fadeSequence];
	
	id sizeSequence = [CCSequence actions: [CCScaleBy actionWithDuration:kSpinWordDuration scale:4.0], 
										 nil];
	[spinWord_ runAction:sizeSequence];

	NSMutableArray *wordLetters = [word_ getWordLetters];
	for( Letter *letter in wordLetters) {
		[letter wasRemoved];
	}
	
	[self readyNextWord];	
}



- (BOOL) letterOnBoardX:(int) x y:(int) y 
{
	return( x >= 0 && y >= 0 && x < lettersWide_ && y < lettersHigh_ );	
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
	NSLog(@"touchBegan!");
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
}

-(Letter *) getLetterForTouchPoint:(CGPoint) tp
{
	int letterX = tp.x / kLetterWidth;
	int letterY = tp.y / kLetterHeight;
	
	if( ![self letterOnBoardX:letterX y:letterY] ) 
		return nil;
	
	Letter *l = letters_[letterX][letterY];
	return l;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog( @"TouchEnded!" );
	CGPoint tp = [self getPointForTouch:touch];

	if( CGRectContainsPoint([topWord_ boundingBox], tp) && [word_ isAWord]) {
		if( allowLetterClicks_ )
			[word_ checkForWordiness];
	}
	else {
		Letter *touchedLetter = [self getLetterForTouchPoint:tp];
		
		if( nil != touchedLetter )
		{
			NSLog( @"touchletter %.2f %.2f %@", tp.x, tp.y, [touchedLetter getCharacter] );
			[self letterSelected:touchedLetter];
		} else {
			NSLog( @"Nil touchletter %.2f, %.2f", tp.x, tp.y );
		}
	}
}



#pragma mark -
#pragma mark Startup/Shutdown

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) resume
{
    if( ![AlphaHunterIpad995AppDelegate getDelegateSingleton].paused ) {
        return;
    }
    NSLog(@"RESUMING!  paused = NO now");
    [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused = NO;
    [self onEnter];
}

- (void)onEnter
{
    NSLog(@"onEnter Game %d", [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused);

    if( ![AlphaHunterIpad995AppDelegate getDelegateSingleton].paused) {
        NSLog(@"onEnter Game - appD is not paused");

        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        self.adView = [[[MobclixAdViewiPad_728x90 alloc] initWithFrame:CGRectMake(120.0f, 100.0f, 330.0f, 160.0f)] autorelease];
        UIViewController *controller = [UIViewController new];
        [controller.view addSubview:adView];
        [[[CCDirector sharedDirector] openGLView] addSubview: controller.view];
        [self.adView resumeAdAutoRefresh];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
         
        [self.adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
        [self.adView setCenter:CGPointMake(winSize.height-kAHAdsDownPixels, winSize.width/2)];
         
        [super onEnter];
    }
}

// http://www.packtpub.com/article/cocos2d-iphone-adding-layers-and-making-simple-pause-screen <- pause method reference
-(void) pause
{
    AHPauseLayer *pl = [AHPauseLayer node];
    [self addChild:pl z:100];
    pl.position = ccp(0,0);
    
    [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused = YES;
    [self onExit];
}

- (void)onExit
{
    NSLog(@"onExit Game %d", [AlphaHunterIpad995AppDelegate getDelegateSingleton].paused);

//    if( ![AlphaHunterIpad995AppDelegate getDelegateSingleton].paused ) {
        NSLog(@"onExit Game - appD is not paused");
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        [super onExit];
//    }
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

#pragma mark -
#pragma mark Callbacks

-(void) scoreMainMenuClicked:(AHScoreLayer *) ahsco
{
	[self removeChild:ahsco cleanup:YES];
	allowLetterClicks_ = YES;
	CCScene *scene = [CCScene node];
	[scene addChild: [MainMenuLayer node] z:0];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1.5 scene:scene]];
}

-(void) showNewGame 
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    AHNewGameLayer *ngl = [AHNewGameLayer node];
    [self addChild:ngl z:kAHInstructionsZ];
    ngl.position = ccp( size.width, 0 );
    [ngl runAction:[CCMoveTo actionWithDuration:0.25 position:ccp(0, 0)]];
}
-(void) newGameRequest:(int) difficulty
{
	[self newGame];
	[self resetScore];
    
    float times = 30.0f;
    switch (difficulty) {
        case kAHGameEasy:
            maxTimeLeft_ = times;
            [word_ setMinWordLength:3];
            break;
        case kAHGameMedium:
            maxTimeLeft_ = times;
            [word_ setMinWordLength:4];
            break;
        case kAHGameHard:
            maxTimeLeft_ = times;
            [word_ setMinWordLength:5];
            break;            
        default:
            break;
    }
    
	timeLeft_ = maxTimeLeft_;
	[self startClock];
	allowLetterClicks_ = YES;
}

#pragma mark -
#pragma mark Initialization

-(NSString *) pickCharacter
{
	int percentage = RANDOM_INT( 0, 10000 ); 
	int i;
	char c ='A';
	for( i=0; i<26; i++ ) {
		if( letterFrequencies[i] >= percentage ) {
			c = 'A' + i;
			break;
		};
	};
	
	NSString *ret = [[NSString alloc] initWithFormat:@"%c", c];
	
	return ret;
}


-(void) newGame
{
	[self resetScore];	
	
	totalAnimalsCaught_ = 0;
	wordsUsed_ = 0;
	elapsedTime_ = 0;
	
	int i;
	for( i=0; i< kAHMaxAnimalNum; i++ )
		caughtAnimals_[i] = 0;

	for( Animal *animal in animals_ ) {
		[self removeChild:animal cleanup:YES];
	}		
	
	animals_ = [[NSMutableArray alloc] init];

	int numEsthers = numLiveAnimals_ = numTotalAnimals_ = kNumEsthers;
	
	while( numEsthers-- ) {
		Animal *esther = [Animal animalWithType:RANDOM_INT(kAHMinAnimalNum,kAHMaxAnimalNum)];
		
		esther.position = [self getAnimalPosition];
		
		[self addChild:esther z:kAnimalZ];
		
		[animals_ addObject:esther];
		[esther startMoving];
	}
	NSLog( @"end animals" );
	
	int x,y;
	for( x=0; x < lettersWide_; x++ ){
		for( y = 0; y < lettersHigh_; y++ ) {
			Letter *letter = letters_[x][y];
			
			NSString *character = [self pickCharacter];
			
#ifdef AH_MANUAL_CHARACTERS
            if( 4 == x && 6 == y ) character = @"C";
            if( 7 == x && 6 == y ) character = @"A";
            if( 6 == x && 4 == y ) character = @"T";
            if( 5 == x && 4 == y ) character = @"C";
            if( 4 == x && 4 == y ) character = @"H";
#endif
            
			[letter resurrectTo:character];
			[self reorderChild:letter z:kUnselectedLetterZ];
		}
	}
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super initWithColor: ccc4( kAHGreenR, kAHGreenG, kAHGreenB, 255)] )) {
		NSLog( @"startinit" );

		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *top = [CCSprite spriteWithFile:@"Background.png" rect:CGRectMake(0, 0, 1024, 287)];
        [self addChild:top];
        top.position = CGPointMake(size.width/2, size.height - [top boundingBoxInPixels].size.height/2);
        
        CCSprite *bottom = [CCSprite spriteWithFile:@"Background.png" rect:CGRectMake(0, 287, 1024, 435-287)];
        [self addChild:bottom];
        bottom.position = CGPointMake(size.width/2, [bottom boundingBoxInPixels].size.height/2);
        
		[CCMenuItemFont setFontSize: 20];

		allowLetterClicks_ = NO;
		int x, y=0;
		word_ = [[AHWord alloc] initWithGame:self];
		RANDOM_SEED();
		
		topHeight_ = 120;
		lettersWide_ = size.width / kLetterWidth;
		lettersHigh_ = ( size.height - topHeight_ ) / kLetterHeight;
		
		for( x=0; x < lettersWide_; x++ ) {
			for( y = 0; y < lettersHigh_; y++ ) {
				Letter *l = [Letter letterWithCharacter:[self pickCharacter] andWord:word_];

				l.position = ccp( x * kLetterWidth  + kLetterWidth / 2, 
								  y * kLetterHeight + kLetterHeight / 2 );
				letters_[x][y]=l;
			}
		}		
		NSLog( @"end letters" );
		
		spinWord_   = [CCLabelBMFont labelWithString:@"" fntFile:kAHBitmapFontName];
		[spinWord_ setColor:ccc3( 0, 0, 0 )];
		
		CCLabelBMFont *bfa = [CCLabelBMFont labelWithString:@"SCORE" fntFile:kAHBitmapFontName];
		bfa.scaleX = bfa.scaleY = 0.60;
		bfa.position = ccp( 70, size.height - 40 );
		[self addChild:bfa z: kWordZ];	
		scoreLabel_ = [CCLabelBMFont labelWithString:@"" fntFile:kAHBitmapFontName];
		scoreLabel_.scaleX = scoreLabel_.scaleY = 0.5;
		scoreLabel_.position = ccp( 70, size.height - kAHTopFontComedownPixels );
		
		topWord_    = [CCLabelBMFont labelWithString:@"" fntFile:kAHBitmapFontName];
		[topWord_ setColor:ccc3(0, 0, 0 )];
		topWord_.scaleX = topWord_.scaleY = 0.5;
		[self addChild:spinWord_ z: kWordZ];
		[self addChild:topWord_ z: kMenuZ];

		[self resetScore];
		[self addChild:scoreLabel_ z:kMenuZ];
		
		bfa = [CCLabelBMFont labelWithString:@"TIME" fntFile:kAHBitmapFontName];
		bfa.scaleX = bfa.scaleY = 0.60;
		bfa.position = ccp( size.width - 80, size.height - 40 );
		[self addChild:bfa z: kWordZ];		
		timeLeft_ = maxTimeLeft_;		
		timeLabel_ = [CCLabelBMFont labelWithString:@"" fntFile:kAHBitmapFontName];		
		[self addChild:timeLabel_];
		timeLabel_.position = ccp( size.width - 80, size.height - kAHTopFontComedownPixels );
		timeLabel_.scaleX = timeLabel_.scaleY = kAHTimeLabelNormalSize;
		
		topWord_.position = ccp( size.width/2, size.height - kAHAdsDownPixels - 80 );

		NSLog( @"words" );
		selectionPath_ = [[AHSelectionPath alloc] init];
		[self addChild:selectionPath_ z:kSelectionPathZ];
		NSLog( @"selpath'd" );
		
		strobingTime_ = NO;
		
		totalAnimalsCaught_ = 0;
					
		[self newGame];
        [self showNewGame];
	}
	
	return self;
}

#pragma mark -
#pragma mark Mobclix

-(void) adViewWillTouchThrough:(MobclixAdView *)adView {
	NSLog( @"MobClix WTT" );
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void)adViewDidFinishTouchThrough:(MobclixAdView*)adView {
	NSLog( @"MobClix DFF WTT" );

	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

@end
