//
//  GameStateModel.m
//  Theseus
//
//  Created by Jason Fieldman on 9/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameStateModel.h"
#import "MapGenerator.h"
#import "DungeonViewController.h"
#import "SoundManager.h"

int has_completed[NUM_LEVELS];
int has_cheated[NUM_LEVELS];
int badge_earned[NUM_LEVELS];
int best_moves_taken[NUM_LEVELS];

static int saved_current_level = -1;
static int saved_history_cursor = 0;
static int saved_current_position = 0;
static int level_table_offset = 0;
static History_t saved_move_history[MAX_MOVE_HISTORY];

static int hints_active = 0;
static int right_handed = 1;
static int idle_timer = 1;

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
	memset(best_moves_taken, 0, sizeof(best_moves_taken));
	
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
				
				id v = [gamesdict objectForKey:@"global_sound"];
				if (v) [SoundManager setGlobalSound:([v intValue] ? YES : NO)];
				//!!SetGlobalSoundOn([[gamesdict objectForKey:@"global_sound"] intValue] ? YES : NO);
				//!!SetGlobalFastMinotaur([[gamesdict objectForKey:@"global_mino"] intValue] ? YES : NO);
				//!!SetCurrentTheseusImg([[gamesdict objectForKey:@"theseus_img"] intValue]);
				
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
				
				/* Load moves taken */
				for (int j = 0; j < NUM_LEVELS; j++) {
					NSString *lev_id = [NSString stringWithFormat:@"%s_movestaken",[MapGenerator nameOfLevelIndexed:j]];
					int num_moves = [[gamesdict objectForKey:lev_id] intValue];
					best_moves_taken[j] = num_moves;
				}
				
				level_table_offset = [[gamesdict objectForKey:@"level_table_offset"] intValue];
				
				/* Load others */
				v = [gamesdict objectForKey:@"hints_active"];
				if (v) hints_active = [v intValue];
				
				v = [gamesdict objectForKey:@"right_handed"];
				if (v) right_handed = [v intValue];
				
				v = [gamesdict objectForKey:@"idle_timer"];
				if (v) idle_timer = [v intValue];
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
			DungeonViewController* dvc = [DungeonViewController sharedInstance];
			if (!(dvc.playing_level) || [dvc.map_model hasTheseusExit]) {
				[gamesdict setObject:@"NOLEVEL" forKey:@"current_puzzle"];
			} else {
				[gamesdict setObject:[NSString stringWithFormat:@"%s",[MapGenerator nameOfLevelIndexed:dvc.map_model.maze_level]] forKey:@"current_puzzle"];
			}
						
			/* Save history if we're in a puzzle */
			if (dvc.playing_level) {
				MapModel *model = dvc.map_model;
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
				
				NSString *moves_id = [NSString stringWithFormat:@"%s_movestaken",[MapGenerator nameOfLevelIndexed:i]];
				[gamesdict setObject:[NSString stringWithFormat:@"%d",best_moves_taken[i]] forKey:moves_id];
			}
			
			/* Save globals settings */
			[gamesdict setObject:[NSString stringWithFormat:@"%d", ([SoundManager getGlobalSound]?1:0) ] forKey:@"global_sound"];
			//!![gamesdict setObject:[NSString stringWithFormat:@"%d", (GlobalFastMinotaur()?1:0) ] forKey:@"global_mino"];
			//!![gamesdict setObject:[NSString stringWithFormat:@"%d", GetCurrentTheseusImg() ] forKey:@"theseus_img"];
			
			[gamesdict setObject:[NSString stringWithFormat:@"%d", level_table_offset] forKey:@"level_table_offset"];
			[gamesdict setObject:[NSString stringWithFormat:@"%d", hints_active] forKey:@"hints_active"];
			[gamesdict setObject:[NSString stringWithFormat:@"%d", right_handed] forKey:@"right_handed"];
			[gamesdict setObject:[NSString stringWithFormat:@"%d", idle_timer] forKey:@"idle_timer"];
			
			
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

+ (int)  getBestNumMoves:(int)level {
	return best_moves_taken[level];
}

+ (void) setBestNumMoves:(int)level moves:(int)moves {
	if (best_moves_taken[level] <= 0 || best_moves_taken[level] > moves)
		best_moves_taken[level] = moves;
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
		if (l == level) return ((l + 1) % NUM_LEVELS);
	}
	return l;
}

+ (int) getCurrentLevel {
	return saved_current_level;
}

+ (void) setLevelTableOffset:(int)offset {
	level_table_offset = offset;
}

+ (int)  getLevelTableOffset {
	return level_table_offset;
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

+ (void) setHintsActive:(int)active {
	hints_active = active;
}

+ (int)  getHintsActive {
	return hints_active;
}

+ (void) setRightHanded:(int)handed {
	right_handed = handed;
}

+ (int)  getRightHanded {
	return right_handed;
}

+ (void) setIdleTimer:(int)timer {
	idle_timer = timer;
}

+ (int)  getIdleTimer {
	return idle_timer;
}


@end
