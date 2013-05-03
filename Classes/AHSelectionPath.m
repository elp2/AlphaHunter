//
//  AHSelectionPath.m
//  AlphaHunter
//
//  Created by Edward Palmer on 27/12/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "AHSelectionPath.h"


@implementation AHSelectionPath

#pragma mark -
#pragma mark Lifecycle
-(void) done
{
	state_ = kAHSelectionPathDone;	
}

#pragma mark -
#pragma mark Segment Management

-(void) letterAddedAt:(CGPoint)letterPoint
{
	NSLog( @"Letter added at: %f, %f", letterPoint.x, letterPoint.y );
	points_[ numVert_ ] = letterPoint;
	numVert_++;
	
	
}

-(void) letterRemoved
{
	NSLog( @"letterRemoved %d", numVert_ -- );
}


-(void) harakiri
{
	[self unschedule:@selector(harakiri)];
	[self.parent removeChild:self cleanup:YES];
}

-(void) isFinishedAfter:(double)dissappearAfter
{
	[self schedule:@selector(harakiri) interval:dissappearAfter];
}



-(void) clearSelections
{
	numVert_ = 0;
}

/*
 http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
 
 int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy)
 {
 int i, j, c = 0;
 for (i = 0, j = nvert-1; i < nvert; j = i++) {
 if ( ((verty[i]>testy) != (verty[j]>testy)) &&
 (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
 c = !c;
 }
 return c;
 }
 */

#define kAHPointBumpRadius 4
-(int) containsPoint:(CGPoint) point 
{
	float testx = point.x;
	float testy = point.y;
	
	int xBump, yBump;
	for( xBump = -1 * kAHPointBumpRadius; xBump < kAHPointBumpRadius+1; xBump += kAHPointBumpRadius ) {
		for( yBump = -1 * kAHPointBumpRadius; yBump < kAHPointBumpRadius +1; yBump += kAHPointBumpRadius ) {
			int i, j, c = 0;

			for (i = 0, j = numVert_-1; i < numVert_; j = i++) {
				CGPoint icp = points_[ i ];
				CGPoint jcp = points_[ j ];
				float vertxi = icp.x;
				float vertyi = icp.y;
				float vertxj = jcp.x;
				float vertyj = jcp.y;
				if ( ((vertyi>testy) != (vertyj>testy)) &&
					(testx < (vertxj-vertxi) * (testy-vertyi) / (vertyj-vertyi) + vertxi) )
					c = !c;
			}
			
			if( c )
				return c;
		}
	}
	
	return 0;
}

-(int) containsAnimal:(Animal *)animal
{
	int delta = 5;
	
	return( [self containsPoint:CGPointMake( animal.position.x - delta, animal.position.y - delta)]
		   || [self containsPoint:CGPointMake( animal.position.x - delta, animal.position.y + delta)]
		   || [self containsPoint:CGPointMake( animal.position.x + delta, animal.position.y - delta)]
		   || [self containsPoint:CGPointMake( animal.position.x + delta, animal.position.y + delta)]
		   || [self containsPoint:animal.position]
		   );
}


/* Taken from Robert Sedgewick, Algorithms in C++ */

/*  returns whether, in traveling from the first to the second
 to the third point, we turn counterclockwise (+1) or not (-1) 

 enhancement to work with non-infinite lines ELP 2010
 */

-(int) ccwP0:(CGPoint) p0 p1:(CGPoint) p1 p2:(CGPoint) p2
{
	int dx1, dx2, dy1, dy2;
	
	dx1 = p1.x - p0.x; dy1 = p1.y - p0.y;
	dx2 = p2.x - p0.x; dy2 = p2.y - p0.y;
	
	if (dx1*dy2 > dy1*dx2)
		return +1;
	if (dx1*dy2 < dy1*dx2)
		return -1;
	if ((dx1*dx2 < 0) || (dy1*dy2 < 0))
		return -1;
	if ((dx1*dx1 + dy1*dy1) < (dx2*dx2 + dy2*dy2))
		return +1;
	return 0;
}


#define IN_P1_P2_BOX(__P__) ( minX <= __P__.x && maxX >= __P__.x && minY <= __P__.y && maxY >= __P__.y )

-(int) sameSideOfLinePointA:(CGPoint) a pointB:(CGPoint) b
{
	int i;
		
	for ( i = 0; i < numVert_ - 1; i++ ) {
		CGPoint p1 = points_[ i ];
		CGPoint p2 = points_[ i+1 ];
		
		// The original algo assumes an infinite line but we only want this to apply if you're in the bounding box of the line
		double maxX = MAX( p1.x, p2.x ) + kMaxSpeed; // also include speed since we want to catch things that go across horizontal/vert lines
		double minX = MIN( p1.x, p2.x ) - kMaxSpeed;
		double maxY = MAX( p1.y, p2.y ) + kMaxSpeed;
		double minY = MIN( p1.y, p2.y ) - kMaxSpeed;
		
		if( !IN_P1_P2_BOX( a ) && !IN_P1_P2_BOX( b ) )
			continue;
				
		int aSide = [self ccwP0: a p1: p1 p2: p2];
		int bSide = [self ccwP0: b p1: p1 p2: p2];
		if( aSide != bSide || aSide == 0 || bSide == 0 )
			return 0;
	}

	return 1;
}


-(void) catchLettersOnPath:(GameLayer * )game
{
	int i;
	
	for ( i = 0; i < numVert_; i++ ) {
		CGPoint p1 = points_[ i % numVert_ ];
		CGPoint p2 = points_[ (i+1) % numVert_ ];
	
		float x = ( p2.x - p1.x );
		float y = ( p2.y - p1.y );
		float length = sqrt( x * x + y * y );
		float iterations = 3 * length / MIN( kLetterWidth, kLetterHeight );
		NSLog( @"len %.2f: from %.2f, %.2f to %.2f, %.2f in %.2f via %.2f,%.2f", length, p1.x, p1.y, p2.x, p2.y, iterations, x, y );
			
		float j;
		Letter *lastLetter = nil;
		for( j = 0.1; j<iterations;j = j +1.0 ) {
			Letter *letter = [game getLetterForTouchPoint:ccp( p1.x + x*j/iterations, p1.y + y*j/iterations )];
			if( nil != letter && lastLetter != letter ) {
				[game letterCaught:letter ];			
				lastLetter = letter;
			}
		}
	
	}
}


#pragma mark -
#pragma mark Drawing

-(void) drawLive
{
	glLineWidth(kLineWidthLive);
	
	glColor4ub(0,0,0,255);
	
	int i;
	for( i = 1; i < numVert_; i++ ) {
		CGPoint prev = points_[ i - 1]; 
		CGPoint next = points_[ i ];
		
		ccDrawLine( prev, next );
	};
	
	if( numVert_ > 2 ) {
		glLineWidth(1);
		glColor4ub(100,100,100,255);
		ccDrawLine(points_[numVert_-1], points_[0]);
	}
	
	// Restore original values
	//glDisable(GL_LINE_SMOOTH);
	glColor4ub(255,255,255,255);	
}

-(void) drawDone
{
	glLineWidth(kLineWidthDone);
	
	glColor4ub(100,100,100,255);
	
	int i;
	for( i = 1; i < numVert_; i++ ) {
		CGPoint prev = points_[ i - 1]; 
		CGPoint next = points_[ i ];
		
		ccDrawLine( prev, next );
	};
	ccDrawLine(points_[numVert_-1], points_[0]);
		
	// Restore original values
	//glDisable(GL_LINE_SMOOTH);
	glColor4ub(255,255,255,255);	
}

-(void) draw
{
	// line: color, width, aliased
	// glLineWidth > 1 and GL_LINE_SMOOTH are not compatible
	// GL_SMOOTH_LINE_WIDTH_RANGE = (1,1) on iPhone
	//	glEnable(GL_LINE_SMOOTH);
	
	switch (state_) {
		case kAHSelectionPathLive:
			[self drawLive];
			break;
		case kAHSelectionPathDone:
			[self drawDone];
			break;

		default:
			break;
	}

}

#pragma mark -
#pragma mark Init

-(id) init
{
	self = [super init];
	if( self ) {
		numVert_ = 0;
		state_ = kAHSelectionPathLive;
	}

	return self;
}
@end
