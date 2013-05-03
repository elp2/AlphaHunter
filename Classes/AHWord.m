//
//  AHWord.m
//  AlphaHunter
//
//  Created by Ed Palmer on 30/08/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "AHWord.h"
#import "AHDictionarySingleton.h"

@implementation AHWord

#pragma mark -
#pragma mark Letters maintainence

-(NSMutableString*) getWordString
{
	NSMutableString *wordString = [[NSMutableString alloc] initWithCapacity:[letters_ count] ];
	for( Letter *letter in letters_) {
		[wordString appendString:[letter getCharacter] ];
	}
	
	return( [wordString retain] );
}

-(void) resetWord
{
	[letters_ removeAllObjects];
	[game_ wordChangedIsAWord:0];
}

-(NSMutableArray*) getWordLetters
{
	return( letters_ );
}

#pragma mark -
#pragma mark Word checking

-(int) isTooLong
{
	return( [letters_ count] > kAHMaxWordLength );
}

-(int) isAWord
{
	return( [[AHDictionarySingleton sharedInstance] isAWord:[self getWordString]] 
           && [letters_ count] >= minWordLength_ );
}

-(void) checkForWordiness
{
	if( [self isAWord] )
	{
		NSLog( @"found something!" );
		[game_ wordSuccess];
	} else {
		[game_ wordFailure];
	}		
}


#pragma mark -
#pragma mark Letters being clicked

-(void) removeLastLetter
{
	Letter *lastLetter = [letters_ lastObject];
	[lastLetter.parent reorderChild:lastLetter z:kUnselectedLetterZ];
	[letters_ removeLastObject];
	[lastLetter wasRemoved];
	[game_ removeLastLetter];
	[game_ wordChangedIsAWord:[self isAWord]];
}

-(void) addLetter:(Letter *)letter
{
	if( [letter wasSelectedAndIsFirst:0==[letters_ count]] ) {
		if( 1 != [letters_ count] )
			[[letters_ lastObject] noLongerLast];
		[letters_ addObject:letter];
		[game_ letterAddedAt:letter];
		[game_ wordChangedIsAWord:[self isAWord]];
	}
}
	
-(void) letterWasClicked:(Letter *)letter
{
	if( [letters_ lastObject] == letter ) {
		[self removeLastLetter];
		if( 1 != [letters_ count] )
			[[letters_ lastObject] isLast];		
	} else if( [letters_ count] > 2 && [letters_ objectAtIndex:0] == letter ){
		[game_ letterAddedAt:letter];
		[self checkForWordiness];
	} else if( ![letters_ containsObject:letter] && ![self isTooLong] ) {
		[self addLetter:letter];
	}
}


#pragma mark -
#pragma mark Init

-(void) setMinWordLength:(int) minWordLength
{
    minWordLength_ = minWordLength;
}

-(id) initWithGame:(GameLayer *)game;
{
	if( (self=[super init]) ) {
		letters_ = [[NSMutableArray alloc] init];
		game_ = game;		
		

	}
	
	return self;
}

@end
