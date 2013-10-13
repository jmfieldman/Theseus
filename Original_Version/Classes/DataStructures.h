//
//  DataStructures.h
//  Theseus
//
//  Created by Jason Fieldman on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* ---------- STRUCTS ------------- */

/* Integer coordinate structs */
struct THPoint {
	int x;
	int y;
};
typedef struct THPoint THPoint;

struct THSize {
	int w;
	int h;
};
typedef struct THSize THSize;

/* ---------- ENUMERATIONS ------------ */

/* Bits for the wall definitions */
typedef enum {
	DIR_WAIT = 0,
	DIR_N = 1,
	DIR_W = 2,
	DIR_S = 4,
	DIR_E = 8
} Direction_t;

typedef enum {
	SPEC_THES = 16,
	SPEC_MINO = 32,
	SPEC_EXIT = 64
} SpecialSquares_t;

/* ------------ DEFINES ------------ */

#define DPAD_SEL    1
#define DPAD_UNSEL  0
#define DPAD_CAN    1
#define DPAD_CANNOT 0


/* ------------ PROTOCOLS ---------------- */

typedef enum {
	DNAV_WAIT   = 0,
	DNAV_MOVE_N = 1,
	DNAV_MOVE_W = 2,
	DNAV_MOVE_S = 4,
	DNAV_MOVE_E = 8,
	DNAV_RESET_LEVEL,
	DNAV_GAME_MENU,
	DNAV_UNDO,
	DNAV_REDO,
	DNAV_EXIT_TO_MAIN
} DungeonNavigationOptions_t;

@protocol DungeonNavigationDelegate <NSObject>
@required
- (void)acceptNavigation:(DungeonNavigationOptions_t)option;
@end

/* --------- History ------------ */

typedef uint32_t History_t;

