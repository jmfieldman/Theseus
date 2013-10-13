//
//  GameStateModel.h
//  Theseus
//
//  Created by Jason Fieldman on 9/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"

@interface GameStateModel : NSObject {

}

+ (void) CreateGameStateFileIfNecessary;
+ (void) SaveGameState;
+ (void) LoadGameState;

+ (void) setLevelCompleted:(int)level;
+ (BOOL) getLevelCompleted:(int)level;

+ (void) setLevelCheated:(int)level;
+ (BOOL) getLevelCheated:(int)level;

+ (void) setBadge:(int)badge forLevel:(int)level;
+ (BOOL) getLevelBadge:(int)level;

+ (int) getCurrentLevel;
+ (void) fillHistory;

+ (int) getNextIncompleteLevelAfter:(int)level;

@end
