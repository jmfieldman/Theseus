//
//  MapModel.h
//  Theseus
//
//  Created by Jason Fieldman on 8/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"

/* Maximum level size */
#define MAX_LEVEL_SIZE 16
#define MAX_MOVE_HISTORY 2048

typedef struct MoveSolverNode {
	uint16_t left;
	uint16_t right;
	uint16_t up;
	uint16_t down;
	uint16_t wait;
	int16_t steps_away;
} MoveSolverNode_t;


@interface MapModel : NSObject {
	/* Maze size */
	THSize size;

	/* Author */
	NSString *author;
	
	/* Maze data */
	int *maze;
	int maze_level;
	
	/* wall post data */
	int wall_post[MAX_LEVEL_SIZE+1][MAX_LEVEL_SIZE+1];
	
	/* Our characters */
	THPoint theseus;
	THPoint minotaur;
	
	/* Special Locations */
	THPoint start_theseus;
	THPoint start_minotaur;
	THPoint maze_exit;
	
	/* Move history */
	History_t move_history[MAX_MOVE_HISTORY];
	int history_cursor;
	int history_max;
	
	/* Solving the level */
	int best_move_pos;
	MoveSolverNode_t *solve_map;
}

- (int) getMazeSquare:(THPoint)loc;
- (int) getMazeSquareByX:(int)x Y:(int)y;
- (int) getWallPost:(THPoint)loc;
- (int) getWallPostByX:(int)x Y:(int)y;
- (Direction_t) minotaurWillMove;
- (BOOL) moveMinotaur;
- (BOOL) moveTheseus:(Direction_t)dir;
- (BOOL) isTheseusDead;
- (void) initMapData:(int*)map_data;
- (BOOL) canTheseusMove:(Direction_t)dir;
- (BOOL) hasTheseusExit;
- (BOOL) canUndo;
- (BOOL) canRedo;
- (void) undo;
- (void) redo;
- (History_t) positionToHistory;
- (void) restorePositionFromHistory:(History_t)hist;
- (BOOL) snapshotForHistory;
- (int)  minotaurMovesToNextHistory;
- (THPoint) minotaurMidStepToNextHistory;
- (void) resetMap;

- (void) createSolveMap;
- (void) cleanSolveMap;
- (int)  getCurrentPosSolve;
- (void) cancelSolve;

- (History_t) getHistoryAtCursor:(int)c;
- (void) setHistory:(History_t)h atCursor:(int)c;

@property (readonly) THSize  size;
@property (readonly) THPoint theseus;
@property (readonly) THPoint minotaur;
@property (readonly) THPoint start_minotaur;
@property (readonly) THPoint start_theseus;
@property (readonly) THPoint maze_exit;
@property (assign)   int maze_level;
@property (readonly) int history_max;
@property (readonly) int history_cursor;
@property (readonly) int best_move_pos;
@property (retain) NSString *author;

@end
