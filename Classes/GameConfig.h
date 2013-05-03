//
//  GameConfig.h
//  AlphaHunterIpad995
//
//  Created by Ed Palmer on 08/01/2011.
//  Copyright chichai.com 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
//#define GAME_AUTOROTATION kGameAutorotationUIViewController
#define GAME_AUTOROTATION kGameAutorotationNone
// kGameAutorotationUIViewController Mobclixxxx doesn't workkkk (clicking on it makes it disasppear)

#define kAHGameTag 456

#endif // __GAME_CONFIG_H