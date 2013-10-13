//
//  GameStateModel.m
//  Theseus
//
//  Created by Jason Fieldman on 9/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameStateModel.h"
#import "MapGenerator.h"
#import "NavigationHelperModel.h"
#import "DungeonViewController.h"
#import "GlobalSettings.h"
#import "GraphicsModel.h"

int has_completed[NUM_LEVELS];
int has_cheated[NUM_LEVELS];
int badge_earned[NUM_LEVELS];

static int saved_current_level = -1;
static int saved_history_cursor = 0;
static int saved_current_position = 0;
static History_t saved_move_history[MAX_MOVE_HISTORY];

#define GAME_STATE_FILE @"game_state"

@implementation GameStateModel

+ (void) CreateGameStateFileIfNecessary {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableFilePath = [documentsDirectory stringByAppendingPathComponent:GAME_STATE_FILE];
    if ([fileManager fileExistsAtPath:writableFilePath]) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:GAME_STATE_FILE];
    [fileManager copyItemAtPath:defaultFilePath toPath:writableFilePath error:NULL];	
}

+ (void) LoadGameState {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableFilePath = [documentsDirectory stringByAppendingPathComponent:GAME_STATE_FILE];
	
	memset(has_completed, 0, sizeof(has_completed));
	memset(has_cheated, 0, sizeof(has_cheated));
	memset(badge_earned, 0, sizeof(badge_earned));
	
	NSFileHandle *remfile = [NSFileHandle fileHandleForReadingAtPath:writableFilePath];
	if (remfile) {
		NSData *data = [remfile readDataToEndOfFile];
		NSString *dStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		//NSLog(@"\n%@",dStr);
		@try {
			NSDictionary *gamesdict = [dStr propertyListFromStringsFileFormat];
			if (gamesdict) {
				/* Get current level */
				saved_current_level = [MapGenerator indexOfLevelNamed:(char*)[[gamesdict objectForKey:@"current_puzzle"] UTF8String]];
				
				/* If current level >= 0, get more info */
				if (saved_current_level >= 0) {
					saved_history_cursor = [[gamesdict objectForKey:@"history_cursor"] intValue];
					saved_current_position = [[gamesdict objectForKey:@"current_position"] intValue];
					for (int i = 0; i <= saved_history_cursor; i++) {
						NSString *key_id = [NSString stringWithFormat:@"cursor_%d",i];
						saved_move_history[i] = [[gamesdict objectForKey:key_id] intValue];
					}
				}
				
				/* Load puzzle state */
				for (int j = 0; j < NUM_LEVELS; j++) {
					NSString *lev_id = [NSString stringWithFormat:@"%s",[MapGenerator nameOfLevelIndexed:j]];
					int has_comp = [[gamesdict objectForKey:lev_id] intValue];
					has_completed[j] = has_comp ? YES : NO;
				}
				
				SetGlobalSoundOn([[gamesdict objectForKey:@"global_sound"] intValue] ? YES : NO);
				SetGlobalFastMinotaur([[gamesdict objectForKey:@"global_mino"] intValue] ? YES : NO);
				SetCurrentTheseusImg([[gamesdict objectForKey:@"theseus_img"] intValue]);
				
				/* Load has_cheated */
				for (int j = 0; j < NUM_LEVELS; j++) {
					NSString *lev_id = [NSString stringWithFormat:@"%s_cheat",[MapGenerator nameOfLevelIndexed:j]];
					int has_cheat = [[gamesdict objectForKey:lev_id] intValue];
					has_cheated[j] = has_cheat ? YES : NO;
				}

				/* Load badge */
				for (int j = 0; j < NUM_LEVELS; j++) {
					NSString *lev_id = [NSString stringWithFormat:@"%s_badge",[MapGenerator nameOfLevelIndexed:j]];
					int has_badge = [[gamesdict objectForKey:lev_id] intValue];
					badge_earned[j] = has_badge;
				}
				
			}
		}
		@catch (NSException *ex) {			
		}
	}
	[remfile closeFile];
}

+ (void) SaveGameState {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableFilePath = [documentsDirectory stringByAppendingPathComponent:GAME_STATE_FILE];
	
	@try {
		NSMutableDictionary *gamesdict = [NSMutableDictionary dictionary];
		
		if (gamesdict) {
			
			/* Save current game and history */
			DungeonViewController* dvc = GetDungeonViewController();
			if ([dvc.map_model hasTheseusExit]) {
				[gamesdict setObject:@"NOLEVEL" forKey:@"current_puzzle"];
			} else {
				[gamesdict setObject:[NSString stringWithFormat:@"%s",[MapGenerator nameOfLevelIndexed:dvc.my_level]] forKey:@"current_puzzle"];
			}
						
			/* Save history if we're in a puzzle */
			if (dvc.my_level >= 0) {
				MapModel *model = [MapGenerator getMap:dvc.my_level];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",model.history_cursor] forKey:@"history_cursor"];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",[model positionToHistory]] forKey:@"current_position"];
				for (int j = 0; j <= model.history_cursor; j++) {
					[gamesdict setObject:[NSString stringWithFormat:@"%d",[model getHistoryAtCursor:j]] forKey:[NSString stringWithFormat:@"cursor_%d",j]];
				}
			}
			
			/* Save puzzle state */
			for (int i = 0; i < NUM_LEVELS; i++) {
				NSString *lev_id = [NSString stringWithFormat:@"%s",[MapGenerator nameOfLevelIndexed:i]];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",has_completed[i]] forKey:lev_id];
				
				NSString *cheat_id = [NSString stringWithFormat:@"%s_cheat",[MapGenerator nameOfLevelIndexed:i]];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",has_cheated[i]] forKey:cheat_id];
				
				NSString *badge_id = [NSString stringWithFormat:@"%s_badge",[MapGenerator nameOfLevelIndexed:i]];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",badge_earned[i]] forKey:badge_id];
			}
			
			/* Save globals settings */
			[gamesdict setObject:[NSString stringWithFormat:@"%d", (GlobalSoundOn()?1:0) ] forKey:@"global_sound"];
			[gamesdict setObject:[NSString stringWithFormat:@"%d", (GlobalFastMinotaur()?1:0) ] forKey:@"global_mino"];
			[gamesdict setObject:[NSString stringWithFormat:@"%d", GetCurrentTheseusImg() ] forKey:@"theseus_img"];
			
			/* Write to file */
			[gamesdict writeToFile:writableFilePath atomically:YES];
		}		
	}
	@catch (NSException *ex) {
	}
}


+ (void) setLevelCompleted:(int)level {
	has_completed[level] = YES;
}

+ (BOOL) getLevelCompleted:(int)level {
	return (has_completed[level] == 0) ? NO : YES;
}

+ (void) setLevelCheated:(int)level {
	has_cheated[level] = YES;
}

+ (BOOL) getLevelCheated:(int)level {
	return (has_cheated[level] == 0) ? NO : YES;
}

+ (void) setBadge:(int)badge forLevel:(int)level {
	/* Can only give a new badge if we're at none or silver.  Cannot replace bronze or gold */
	if (badge_earned[level] == 2 || badge_earned[level] == 0) {
		badge_earned[level] = badge;
	}
}

+ (BOOL) getLevelBadge:(int)level {
	return badge_earned[level];
}



+ (int) getNextIncompleteLevelAfter:(int)level {
	int l = (level + 1) % NUM_LEVELS;
	while ([GameStateModel getLevelCompleted:l]) {
		l = (l + 1) % NUM_LEVELS;
		if (l == level) return l;
	}
	return l;
}

+ (int) getCurrentLevel {
	return saved_current_level;
}

+ (void) fillHistory {
	if (saved_current_level == -1) return;
	
	MapModel *model = [MapGenerator getMap:saved_current_level];
	int i;
	for (i = 0; i <= saved_history_cursor; i++) {
		[model setHistory:saved_move_history[i] atCursor:i];
	}
	//[model restorePositionFromHistory:saved_current_position];
}


@end
