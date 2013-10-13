//
//  MapView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"
#import "ConvertibleImageView.h"

/* Interval between steps of the flourish in */
#define kFlourishInAdvanceInterval 0.03

/* The duration for each flourish visual effect */
#define kFlourishInEffectDuration 0.5

/* The duration for each flourish visual effect */
#define kDudePopInEffectDuration 0.15

/* The distance per direction movement for the gesture pad */
#define kGestureMinDragDistance 40.0

/* A place to store things way off board */
#define kCenterHidden CGPointMake(-1000,-1000)

/* Slide duration for moving T/M */
#define kDudeSlideDuration 0.20

@interface MapView : UIView {
	/* map model */
	MapModel *map_model;
	int offsetX, offsetY;
	int tileSize, tileSizeHalf;
		
	/* Flourish mode: YES=displaying normally NO=waiting for flourish */
	BOOL flourished_in;
	
	/* Floor tiles */
	ConvertibleImageView *floorTiles[MAX_LEVEL_SIZE][MAX_LEVEL_SIZE];
	
	/* Wall tiles */
	ConvertibleImageView *wallTiles[MAX_LEVEL_SIZE+1][MAX_LEVEL_SIZE+1];
	
	/* Stair tile */
	ConvertibleImageView *stairTile;
	
	/* Theseus and the Minotaur */
	UIImageView *theseusTile;
	ConvertibleImageView *minotaurTile;
	
	/* The MapView is also a gesture pad */
	id<DungeonNavigationDelegate> gestureDelegate;
	CGPoint initial_touch_point;
	BOOL has_dragged;
	BOOL went_two;
	
	/* This indicates that we are still animating an undo */
	BOOL still_animating_undo;
}

@property (retain)   id<DungeonNavigationDelegate> gestureDelegate;
@property (readonly) MapModel *map_model;
@property (readonly) BOOL still_animating_undo;

- (void)setMapModel:(MapModel*)model;
- (void)guaranteeAllTilesHidden;
- (void)flourishIn:(MapModel*)new_map;
- (float)flourishOut;
- (void)flourishToMap:(MapModel*)new_map;

- (void)updateDudePosition:(BOOL)isTheseus;

- (void)suckDownTheseus;

- (void)handleUndo;
- (void)handleReset;

@end
