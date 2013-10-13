//
//  MapView.h
//  Theseus
//
//  Created by Jason Fieldman on 8/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"
#import "GraphicsModel.h"

/* Preview colors */
#define MAZE_P_TILE_RGBA 245/255.0, 245/255.0, 245/255.0, 1
#define MAZE_P_EXIT_RGBA 0/255.0,   192/255.0, 0/255.0,   1
#define MAZE_P_MINO_RGBA 255/255.0,   0/255.0,   0/255.0,   1
#define MAZE_P_THES_RGBA 0/255.0,   64/255.0,   192/255.0, 1
#define MAZE_P_WALL_RGBA 0/255.0,   0/255.0,   0/255.0,   1
#define MAZE_P_GRID_RGBA 0/255.0, 245/255.0, 245/255.0,   1

/* Real colors */
#define MAZE_BACKGROUND_RGBA  245/255.0, 245/255.0, 245/255.0, 1

// Yellowish
//#define MAZE_TILE_ODD_RGBA    238/255.0, 230/255.0, 210/255.0, 1
//#define MAZE_TILE_EVEN_RGBA   246/255.0, 241/255.0, 231/255.0, 1

// Blue/white
#define MAZE_TILE_ODD_RGBA    255/255.0, 255/255.0, 255/255.0, 1
#define MAZE_TILE_EVEN_RGBA   210/255.0, 238/255.0, 255/255.0, 1

@interface MapView : UIView {
	/* Underlying map model */
	MapModel *map_model;
	
	/* Should we draw the special locations? */
	BOOL draw_special_locations;
	
	/* Preview mode flag */
	BOOL preview_mode;
	
	/* pre-calculated information */
	THSize tile_size;
	int border;
	int wall_width;
	int wall_half_width;
	
	/* pre-calculated wall coordinates */
	THPoint sprite_offset;
	THSize sprite_size;
	
	/* pre-calculated thes/mino sizes */
	THPoint thes_offset;
	THSize thes_size;
	THPoint mino_offset;
	THSize mino_size;
	
	/* Shadow buffer */
	UIImage *shadow_buffer;
	
	/* touch points */
	CGPoint down_point;
	BOOL down_waiting;
	
	/* Navigation Delegate */
	id<DungeonNavigationDelegate> navDelegate;
}

- (id)initWithFrame:(CGRect)frame withMap:(MapModel*)map withBorder:(int)brdr;
- (void)updateWithFrame:(CGRect)frame withMap:(MapModel*)map withBorder:(int)brdr;
- (void)setPreviewMode:(BOOL)p_mode;
- (void)initializeShadowBuffer:(CGRect)frame;

@property (assign) BOOL draw_special_locations;
@property (assign) id<DungeonNavigationDelegate> navDelegate;

@end
