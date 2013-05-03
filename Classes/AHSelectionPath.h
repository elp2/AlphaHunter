//
//  AHSelectionPath.h
//  AlphaHunter
//
//  Created by Edward Palmer on 27/12/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Animal;
@class GameLayer;

#import "cocos2d.h"
#import "Animal.h"
#define kDashedLineLength 30
#define kDashedLineEmptyLength 5
#define kLineWidthLive 6
#define kLineWidthDone 3

#define kAHSelectionPathLive 0
#define kAHSelectionPathDone 1

@interface AHSelectionPath : CCNode {
	CGPoint points_[ 20 ];
	int numVert_;
	int state_;
}



-(void) done;
-(void) letterAddedAt:(CGPoint)letterPoint;
-(void) letterRemoved;
-(void) clearSelections;
-(void) isFinishedAfter:(double)dissappearAfter;

-(int) containsPoint:(CGPoint) point;
-(int) containsAnimal:(Animal *)animal;

-(int) sameSideOfLinePointA:(CGPoint) a pointB:(CGPoint) b;
-(void) catchLettersOnPath:(GameLayer * )game;

@end
