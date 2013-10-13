//
//  MapModel.m
//  Theseus
//
//  Created by Jason Fieldman on 8/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapModel.h"
#import "MapGenerator.h"

static volatile BOOL should_cancel_solve = NO;

@implementation MapModel
@synthesize maze_exit, start_theseus, start_minotaur, theseus, minotaur, size;
@synthesize history_max, history_cursor, best_move_pos, maze_level;
@synthesize author;

/* initialize map data with the supplied array.
 * [0] = w_size
 * [1] = h_size
 * [2...] = map data
 */
- (void) initMapData:(int*)map_data {
	size.w = map_data[0];
	size.h = map_data[1];
	
	solve_map = NULL;
	
	self.author = [NSString stringWithFormat:@"%s", authors[map_data[2]]];
	
	best_move_pos = map_data[3];
	
	int ind = 4;
	int m_ind = 0;
	maze = &map_data[4];
	for (int y = 0; y < size.h; y++) {
		for (int x = 0; x < size.w; x++) {
			/* error-correct missing walls */
			if (x > 0) { /* Check tile to west */
				if (maze[m_ind-1] & DIR_E) maze[m_ind] |= DIR_W;
				else if (maze[m_ind] & DIR_W) maze[m_ind-1] |= DIR_E;
			}
			if (x < (size.w-1)) { /* Check tile to east */
				if (maze[m_ind+1] & DIR_W) maze[m_ind] |= DIR_E;
				else if (maze[m_ind] & DIR_E) maze[m_ind+1] |= DIR_W;
			}
			if (y > 0) { /* Check tile to north */
				if (maze[m_ind-size.w] & DIR_S) maze[m_ind] |= DIR_N;
				else if (maze[m_ind] & DIR_N) maze[m_ind-size.w] |= DIR_S;
			}
			if (y < (size.h-1)) { /* Check tile to south */
				if (maze[m_ind+size.w] & DIR_N) maze[m_ind] |= DIR_S;
				else if (maze[m_ind] & DIR_S) maze[m_ind+size.w] |= DIR_N;
			}
			
			/* Fill out special squares */
			if (map_data[ind] & SPEC_THES) {
				theseus.x = x; theseus.y = y;
				start_theseus.x = x; start_theseus.y = y;
			}
			if (map_data[ind] & SPEC_MINO) {
				minotaur.x = x; minotaur.y = y;
				start_minotaur.x = x; start_minotaur.y = y;
			}
			if (map_data[ind] & SPEC_EXIT) {
				maze_exit.x = x; maze_exit.y = y;
			}
			ind++; m_ind++;
		}
	}
	
	/* Ok, now fill out wall post data */
	memset(wall_post, 0, sizeof(wall_post));
	for (int x = 0; x < size.w; x++) {
		for (int y = 0; y < size.h; y++) {
			int current_floor = [self getMazeSquareByX:x Y:y];
			if ((current_floor & DIR_N) || y == 0) {
				wall_post[x][y] |= DIR_E;
				wall_post[x+1][y] |= DIR_W;
			}
			if ((current_floor & DIR_S) || y == (size.h-1)) {
				wall_post[x][y+1] |= DIR_E;
				wall_post[x+1][y+1] |= DIR_W;
			}
			if ((current_floor & DIR_W) || x == 0) {
				wall_post[x][y] |= DIR_S;
				wall_post[x][y+1] |= DIR_N;
			}
			if ((current_floor & DIR_E) || x == (size.w-1)) {
				wall_post[x+1][y] |= DIR_S;
				wall_post[x+1][y+1] |= DIR_N;
			}
		}
	}
	
	history_cursor = 0;
	history_max = 0;
	move_history[0] = [self positionToHistory];
}

- (void) resetMap {
	theseus = start_theseus;
	minotaur = start_minotaur;
	history_cursor = 0;
	history_max = 0;
	move_history[0] = [self positionToHistory];
}

/* Converts the current thes/mino positions into a uint32_t for move history */
- (History_t) positionToHistory {
	return ( (theseus.x << 24) | (theseus.y << 16) | (minotaur.x << 8) | (minotaur.y) );
}

- (void) restorePositionFromHistory:(History_t)hist {
	theseus.x  = (hist >> 24) & 0xFF;
	theseus.y  = (hist >> 16) & 0xFF;
	minotaur.x = (hist >>  8) & 0xFF;
	minotaur.y = (hist >>  0) & 0xFF;
}

- (BOOL) canUndo {
	return (history_cursor > 0);
}

- (BOOL) canRedo {
	return (history_cursor < history_max);
}

- (void) undo {
	if (![self canUndo]) return;
	history_cursor--;
	[self restorePositionFromHistory:move_history[history_cursor]];
}

- (void) redo {
	if (![self canRedo]) return;
	history_cursor++;
	[self restorePositionFromHistory:move_history[history_cursor]];
}

- (BOOL) snapshotForHistory {
	/* New: Smart Undo */
	{
		int cur_pos_val = [self positionToHistory];
		for (int i = 0; i < history_cursor; i++) {
			if (move_history[i] == cur_pos_val) {
				history_cursor = i;
				return YES;
			}
		}
	}
	
	
	history_cursor++;
	history_max = history_cursor;
	move_history[history_cursor] = [self positionToHistory];
	
	if (history_cursor == MAX_MOVE_HISTORY)
		return NO;
	return YES;
}

- (History_t) getHistoryAtCursor:(int)c {
	return move_history[c];
}

- (void) setHistory:(History_t)h atCursor:(int)c {
	move_history[c] = h;
	if (c >= history_cursor) {
		[self restorePositionFromHistory:h];
		history_cursor = c;
	}
	if (history_cursor > history_max) history_max = history_cursor;
}

- (int)  minotaurMovesToNextHistory {
	int cur_pos = move_history[history_cursor];
	int nex_pos = move_history[history_cursor+1];
	
	int min_cur_x  = (cur_pos >> 8) & 0xFF;
	int min_cur_y  = (cur_pos >> 0) & 0xFF;
	int min_nex_x  = (nex_pos >> 8) & 0xFF;
	int min_nex_y  = (nex_pos >> 0) & 0xFF;
	
	return ( abs(min_cur_x - min_nex_x) + abs(min_cur_y - min_nex_y) );
}

- (THPoint) minotaurMidStepToNextHistory {
	int cur_hist = move_history[history_cursor];
	int nex_pos = move_history[history_cursor+1];
	
	theseus.x = (nex_pos >> 24) & 0xFF;
	theseus.y = (nex_pos >> 16) & 0xFF;
	
	[self moveMinotaur];
	THPoint p;
	p.x = minotaur.x;
	p.y = minotaur.y;
	
	[self restorePositionFromHistory:cur_hist];	
	
	return p;
}

/* Get the floor data of the maze location 'loc' */
- (int) getMazeSquare:(THPoint)loc {
	if (loc.x < 0 || loc.y < 0 || loc.x >= size.w || loc.y >= size.h)
		return -1;
	return (maze[(loc.y * size.w) + loc.x]);
}

/* Get the floor data of the maze location x,y */
- (int) getMazeSquareByX:(int)x Y:(int)y {
	if (x < 0 || y < 0 || x >= size.w || y >= size.h)
		return -1;
	return (maze[(y * size.w) + x]);
}

/* Returns the wall directions from this post (0,0) is upper left post */
- (int) getWallPost:(THPoint)loc {
	return [self getWallPostByX:loc.x Y:loc.y];
}

- (int) getWallPostByX:(int)x Y:(int)y {
	if (x > size.w || y > size.h) return 0;
	if (x < 0 || y < 0) return 0;
	return wall_post[x][y];
}

/* Can something move in the requested direction? */
- (BOOL) canMoveFromPoint:(THPoint)point inDirection:(Direction_t)dir {
	int cur = [self getMazeSquare:point];
	if (cur & dir) return NO;
	if (	(dir == DIR_N && point.y == 0) ||
			(dir == DIR_W && point.x == 0) ||
			(dir == DIR_S && point.y == (size.h - 1)) ||
			(dir == DIR_E && point.x == (size.w - 1)) ) {
		return NO;
	}
	return YES;
}

/* Can Theseus move in the direction? */
- (BOOL) canTheseusMove:(Direction_t)dir {
	if ([self isTheseusDead]) return NO;
	if (dir == DIR_WAIT) return YES;
	return [self canMoveFromPoint:theseus inDirection:dir];
}

/* Can the Minotaur move in the direction? */
- (BOOL) canMinotaurMove:(Direction_t)dir {
	return [self canMoveFromPoint:minotaur inDirection:dir];
}

/* Try to move Theseus.  Return YES if success, NO on failure */
- (BOOL) moveTheseus:(Direction_t)dir {
	if (![self canTheseusMove:dir]) return NO;
	switch (dir) {
		case DIR_N: theseus.y--; break;
		case DIR_W: theseus.x--; break;
		case DIR_S: theseus.y++; break;
		case DIR_E: theseus.x++; break;
	}
	return YES;
}

- (Direction_t) minotaurWillMove {
	/* Horizontal */
	if (theseus.x < minotaur.x) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_W]) {			
			return DIR_W;
		}
	} else if (theseus.x > minotaur.x) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_E]) {
			return DIR_E;
		}
	}
	
	/* Vertical */
	if (theseus.y < minotaur.y) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_N]) {
			return DIR_N;
		}
	} else if (theseus.y > minotaur.y) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_S]) {
			return DIR_S;
		}
	}
	return DIR_WAIT;
}

/* Try to move Minotaur (based on his movement rules).  Return YES if success, NO on failure */
- (BOOL) moveMinotaur {
	/* Horizontal */
	if (theseus.x < minotaur.x) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_W]) {
			minotaur.x--;
			return YES;
		}
	} else if (theseus.x > minotaur.x) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_E]) {
			minotaur.x++;
			return YES;
		}
	}
	
	/* Vertical */
	if (theseus.y < minotaur.y) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_N]) {
			minotaur.y--;
			return YES;
		}
	} else if (theseus.y > minotaur.y) {
		if ([self canMoveFromPoint:minotaur inDirection:DIR_S]) {
			minotaur.y++;
			return YES;
		}
	}
	return NO;
}

/* Is theseus eaten by the minotaur? */
- (BOOL) isTheseusDead {
	return (theseus.x == minotaur.x && theseus.y == minotaur.y);
}

/* Has Theseus reached the exit? */
- (BOOL) hasTheseusExit {
	return (theseus.x == maze_exit.x && theseus.y == maze_exit.y);
}

#define TMCOORD_TO_MAP(_tx, _ty, _mx, _my) ( (_tx << 12) | (_ty << 8) | (_mx << 4) | _my )
#define MAP_TO_TX(_map) ((_map >> 12) & 0x0F)
#define MAP_TO_TY(_map) ((_map >> 8 ) & 0x0F)
#define MAP_TO_MX(_map) ((_map >> 4 ) & 0x0F)
#define MAP_TO_MY(_map) ((_map >> 0 ) & 0x0F)

#define SOLVER_UNKNOWN  (0xFFFF)
#define SOLVER_NOPATH   (0xFFFE)
#define SOLVER_NODATA   (-1)
#define SOLVER_DEAD     (-2)
#define SOLVER_FINISHED (0)

- (int) returnMapCoordAfter:(Direction_t)dir TP:(THPoint)tp MP:(THPoint)mp {
	if (dir != DIR_WAIT && ![self canMoveFromPoint:tp inDirection:dir]) return SOLVER_NOPATH;
	
	switch (dir) {
		case DIR_WAIT: {}; break;
		case DIR_N: tp.y--; break;
		case DIR_S: tp.y++; break;
		case DIR_W: tp.x--; break;
		case DIR_E: tp.x++; break;
	}
	
	/* Move Minotaur twice */
	for (int i = 0; i < 2; i++) {
		/* Horizontal */
		if (tp.x < mp.x) {
			if ([self canMoveFromPoint:mp inDirection:DIR_W]) {
				mp.x--;
				continue;
			}
		} else if (tp.x > mp.x) {
			if ([self canMoveFromPoint:mp inDirection:DIR_E]) {
				mp.x++;
				continue;
			}
		}
		
		/* Vertical */
		if (tp.y < mp.y) {
			if ([self canMoveFromPoint:mp inDirection:DIR_N]) {
				mp.y--;
				continue;
			}
		} else if (tp.y > mp.y) {
			if ([self canMoveFromPoint:mp inDirection:DIR_S]) {
				mp.y++;
				continue;
			}
		}		
	}
	
	return TMCOORD_TO_MAP(tp.x, tp.y, mp.x, mp.y);
}

- (void) cancelSolve {
	should_cancel_solve = YES;
}

/* Create the solve map */
- (void) createSolveMap {
	if (solve_map) return;

	should_cancel_solve = NO;
	
	/* iterators */
	int tx, ty, mx, my;
	
	/* map size */
	//int map_area = size.w * size.h;
	//int map_area_2 = map_area * map_area;
	int map_area_2 = 65536; /* Hard code max map size to 16x16 */
	
	/* Allocate map */
	solve_map = malloc(map_area_2 * sizeof(MoveSolverNode_t));
	if (!solve_map) return;
	
	/* Clear to 0xFFFF/-1 */
	memset(solve_map, 0xFF, map_area_2 * sizeof(MoveSolverNode_t));
	
	/* Create winners */
	for (mx = 0; mx < size.w; mx++) {
		for (my = 0; my < size.h; my++) {
			solve_map[TMCOORD_TO_MAP(maze_exit.x, maze_exit.y, mx, my)].steps_away = SOLVER_FINISHED;
		}
	}
	
	/* Create obvious failures */
	for (tx = 0; tx < size.w; tx++) {
		for (ty = 0; ty < size.h; ty++) {
			solve_map[TMCOORD_TO_MAP(tx, ty, tx, ty)].steps_away = SOLVER_DEAD;
		}
	}
	
	/* Create step links */
	THPoint tp, mp;
	for (tp.x = 0; tp.x < size.w; tp.x++) {
		for (tp.y = 0; tp.y < size.h; tp.y++) {
			for (mp.x = 0; mp.x < size.w; mp.x++) {
				for (mp.y = 0; mp.y < size.h; mp.y++) {
					int mapcoord = TMCOORD_TO_MAP(tp.x, tp.y, mp.x, mp.y);
					MoveSolverNode_t *n = &solve_map[mapcoord];
					n->left  = [self returnMapCoordAfter:DIR_W TP:tp MP:mp];
					n->right = [self returnMapCoordAfter:DIR_E TP:tp MP:mp];
					n->up    = [self returnMapCoordAfter:DIR_N TP:tp MP:mp];
					n->down  = [self returnMapCoordAfter:DIR_S TP:tp MP:mp];
					n->wait  = [self returnMapCoordAfter:DIR_WAIT TP:tp MP:mp];
				}
			}
		}
	}
	
	/* We have our move map!  Let's plot the path */
	int unknown_square_remains = 1;
	int best_path = 0;
	while (unknown_square_remains) {
		if (should_cancel_solve) return;
		unknown_square_remains = 0;
		for (tp.x = 0; tp.x < size.w; tp.x++) {
			for (tp.y = 0; tp.y < size.h; tp.y++) {
				for (mp.x = 0; mp.x < size.w; mp.x++) {
					for (mp.y = 0; mp.y < size.h; mp.y++) {
						int mapcoord = TMCOORD_TO_MAP(tp.x, tp.y, mp.x, mp.y);
						MoveSolverNode_t *n = &solve_map[mapcoord];
						if (n->steps_away != SOLVER_NODATA) continue;
						
						/* We don't know what the result of this square is yet.. */
						int any_non_dead = 0; /* Set to 1 if we have a (possible) escape */
						int any_unknown_paths = 0; /* Set to 1 if we see an unknown path */
						int cur_best_path = 0xFF; /* best route we can see */
						int cur_best_dir = DIR_WAIT; /* the path that goes to the best number */
						
						MoveSolverNode_t *neighbor;
						
#define HANDLE_NEIGHBOR(_dir, _eng) \
						do {													\
							if (n->_eng == SOLVER_NOPATH) break;					\
							neighbor = &solve_map[n->_eng];						\
							if (n == neighbor) break; \
							if (neighbor->steps_away == SOLVER_DEAD) break;		\
							if (neighbor->steps_away == SOLVER_NODATA) { any_unknown_paths = 1; any_non_dead = 1; break; }\
							{\
								any_non_dead = 1;		\
								if ((neighbor->steps_away & 0xFF) < cur_best_path) { \
									cur_best_path = (neighbor->steps_away & 0xFF);   \
									cur_best_dir = _dir;                    \
								} \
							} \
						} while (0);
						
						HANDLE_NEIGHBOR(DIR_N, up);
						HANDLE_NEIGHBOR(DIR_S, down);
						HANDLE_NEIGHBOR(DIR_W, left);
						HANDLE_NEIGHBOR(DIR_E, right);
						HANDLE_NEIGHBOR(DIR_WAIT, wait);
						
						if (!any_non_dead) {
							n->steps_away = SOLVER_DEAD;
							continue;
						}
						
						if (!any_unknown_paths || (cur_best_path <= best_path)) {
							n->steps_away = (cur_best_path+1) | (cur_best_dir << 8);							
							continue;
						}
						
						if (best_path == 200) {
							n->steps_away = SOLVER_DEAD;
							continue;
						}
						
						unknown_square_remains = 1;
					}
				}
			}
		}
		best_path++;
	}
}

- (int)  getCurrentPosSolve {
	if (!solve_map) return -1;
	return solve_map[TMCOORD_TO_MAP(theseus.x, theseus.y, minotaur.x, minotaur.y)].steps_away;
}

- (void) cleanSolveMap {
	if (solve_map) {
		free(solve_map);
		solve_map = NULL;
	}
}

@end
