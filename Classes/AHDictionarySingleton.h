//
//  AHDictionarySingleton.h
//  AlphaHunterIpad
//
//  Created by Ed Palmer on 16/12/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AHDictionarySingleton : NSObject {
    BOOL seenInstructions_;
}

@property (nonatomic,assign) BOOL seenInstructions;

+(AHDictionarySingleton*)sharedInstance;
-(NSMutableArray *) getXRandomWords:(int) numWords;
-(int) isAWord:(NSString *) wordString;

@end
