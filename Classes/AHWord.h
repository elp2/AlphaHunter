//
//  AHWord.h
//  AlphaHunter
//
//  Created by Ed Palmer on 30/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Letter.h"
#import "Game.h"
#import "AHDictionarySingleton.h"

#define kAHMaxWordLength 10

@class Letter;
@class GameLayer;

@interface AHWord : NSObject {
	@private
	 NSMutableArray *letters_;
	 Letter *lastLetterClicked_;
	 GameLayer *game_;
     int minWordLength_;	
}

-(void) letterWasClicked:(Letter *)letter;
-(void) checkForWordiness;
-(id) initWithGame:(GameLayer *)game;
-(void) resetWord;
-(int) isAWord;
-(int) isTooLong;
-(void) setMinWordLength:(int) minWordLength;

-(NSMutableString*) getWordString;
-(NSMutableArray*) getWordLetters;

@end
