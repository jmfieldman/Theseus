//
//  MapView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "TileHelper.h"
#import "DataStructures.h"
#import "MapGenerator.h"
#import "SoundManager.h"

@implementation MapView
@synthesize map_model;
@synthesize gestureDelegate;
@synthesize still_animating_undo;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
						
		self.multipleTouchEnabled = YES;
		flourished_in = NO;
		still_animating_undo = NO;
		
		int x, y;
		for (x = 0; x < MAX_LEVEL_SIZE; x++) {
			for (y = 0; y < MAX_LEVEL_SIZE; y++) {
				floorTiles[x][y] = [[ConvertibleImageView alloc] initWithFrame:kTileRect];
				[floorTiles[x][y] setActiveImage:g_floorTiles[(x+y)%2]];
				floorTiles[x][y].userInteractionEnabled = NO;
				[self addSubview:floorTiles[x][y]];
			}
		}
		for (x = 0; x <= MAX_LEVEL_SIZE; x++) {
			for (y = 0; y <= MAX_LEVEL_SIZE; y++) {
				wallTiles[x][y] = [[ConvertibleImageView alloc] initWithFrame:kTileRect];
				wallTiles[x][y].userInteractionEnabled = NO;
				[self addSubview:wallTiles[x][y]];
			}
		}
		stairTile = [[ConvertibleImageView alloc] initWithFrame:kTileRect];
		[stairTile setActiveImage:g_stairsTile];
		stairTile.userInteractionEnabled = NO;
		[self addSubview:stairTile];
				
		theseusTile = [[UIImageView alloc] initWithImage:g_theseusTile];
		theseusTile.frame = kTileRect;
		theseusTile.userInteractionEnabled = NO;
		[self addSubview:theseusTile];
		
		minotaurTile = [[ConvertibleImageView alloc] initWithFrame:kTileRect];
		[minotaurTile setActiveImage:g_minotaurTile];
		minotaurTile.userInteractionEnabled = NO;
		[self addSubview:minotaurTile];
		
		[self guaranteeAllTilesHidden];
    }
    return self;
}


- (void)dealloc {
	[gestureDelegate release];
    [super dealloc];
}

- (void)guaranteeAllTilesHidden {
	int x, y;
	for (x = 0; x < MAX_LEVEL_SIZE; x++) {
		for (y = 0; y < MAX_LEVEL_SIZE; y++) {			
			floorTiles[x][y].center = kCenterHidden;
			//floorTiles[x][y].alpha = 0;
		}
	}
	for (x = 0; x <= MAX_LEVEL_SIZE; x++) {
		for (y = 0; y <= MAX_LEVEL_SIZE; y++) {
			wallTiles[x][y].center = kCenterHidden;
			//wallTiles[x][y].alpha = 0;
		}
	}
	stairTile.center = kCenterHidden;
	//stairTile.alpha = 0;
	theseusTile.center = kCenterHidden;
	theseusTile.alpha = 0;	
	minotaurTile.center = kCenterHidden;
	minotaurTile.alpha = 0;
}

- (void)_recalculateMapMetrics {
	if (map_model.size.w <= 8 && map_model.size.h <= 8) {
		tileSize = 40; tileSizeHalf = 20;
	} else if (map_model.size.w <= 10 && map_model.size.h <= 10) {
		tileSize = 30; tileSizeHalf = 15;
	} else if (map_model.size.w <= 12 && map_model.size.h <= 12) {
		tileSize = 24; tileSizeHalf = 12;
	} else {
		tileSize = 20; tileSizeHalf = 10;
	}
	
	int map_width = map_model.size.w * tileSize;
	int map_height = map_model.size.h * tileSize;
	
	offsetX = (self.frame.size.width  - map_width)  / 2;
	offsetY = (self.frame.size.height - map_height) / 2;
	
	if (map_model.maze_level == 0 || map_model.maze_level == 1) offsetY = 20;
	if (map_model.maze_level == 2 || map_model.maze_level == 3) offsetY = 0;
}

- (CGPoint)_getOffScreenWaitCoordByX:(int)x Y:(int)y burst:(BOOL)burst {
	CGPoint rval;
	float rad = (self.frame.size.width);// / 2) + tileSize*2;
	
	float tx = (map_model.size.w / 2.0) - x;
	float ty = (map_model.size.h / 2.0) - y;
	
	if (burst) {
		tx = -tx;
		ty = -ty;
	}
	
	if (tx == 0.0) tx = 0.01;
	if (ty == 0.0) ty = 0.01;
	
	float atx = fabs(tx);
	float aty = fabs(ty);
	
	if (tx > 0 && atx > aty) {
		rval.x = rad;
		rval.y = rad * (ty / tx);
	} else if (tx < 0 && atx > aty) {
		rval.x = -rad;
		rval.y = rad * (ty / tx);
	} else if (ty > 0) {
		rval.y = rad;
		rval.x = rad * (tx / ty);
	} else {
		rval.y = -rad;
		rval.x = rad * (tx / ty);
	}
	
	rval.y *= 1.2;
	
	rval.x += (self.frame.size.width / 2);
	rval.y += (self.frame.size.height / 2);
	return rval;
}

- (CGPoint)_getScreenCenterCoordOfFloorByX:(int)x Y:(int)y {
	CGPoint p;
	p.x = (offsetX + (x*tileSize) + tileSizeHalf);
	p.y = (offsetY + (y*tileSize) + tileSizeHalf);
	return p;
}

- (CGPoint)_getScreenCenterCoordOfWallByX:(int)x Y:(int)y {
	CGPoint p;
	p.x = (offsetX + (x*tileSize));
	p.y = (offsetY + (y*tileSize));
	return p;	
}

- (void)setMapModel:(MapModel*)model {
	map_model = model;
	[self _recalculateMapMetrics];
}

- (void)updateDudePosition:(BOOL)isTheseus {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudeSlideDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	if (isTheseus) {
		theseusTile.center  = [self _getScreenCenterCoordOfFloorByX:map_model.theseus.x Y:map_model.theseus.y];
	} else {
		minotaurTile.center  = [self _getScreenCenterCoordOfFloorByX:map_model.minotaur.x Y:map_model.minotaur.y];		
	}
	[UIView commitAnimations];
	
	if (!isTheseus && [map_model isTheseusDead]) {
		[minotaurTile replaceNewImageOver:g_minotaurEatingTile delay:kDudeSlideDuration/2];
	}
}

- (void)_handleUndoFinalize:(NSTimer*)timer {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudeSlideDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	theseusTile.center  = [self _getScreenCenterCoordOfFloorByX:map_model.theseus.x Y:map_model.theseus.y];
	minotaurTile.center = [self _getScreenCenterCoordOfFloorByX:map_model.minotaur.x Y:map_model.minotaur.y];
	[UIView commitAnimations];
	//[SoundManager playSound:SND_UNDO];
	still_animating_undo = NO;
}

- (void)handleUndo {
	float final_move_del = 0;
	[SoundManager playSound:SND_UNDO];
	[minotaurTile replaceNewImageOver:g_minotaurTile delay:kDudeSlideDuration/2];
	
	if ([map_model minotaurMovesToNextHistory] == 2) {
		still_animating_undo = YES;
		final_move_del += kDudeSlideDuration;
		THPoint p = [map_model minotaurMidStepToNextHistory];
		[UIView beginAnimations:@"boo" context:NULL];
		[UIView setAnimationDuration:kDudeSlideDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		minotaurTile.center = [self _getScreenCenterCoordOfFloorByX:p.x Y:p.y];
		[UIView commitAnimations];
		//[SoundManager playSound:SND_UNDO];
		START_TIMER(final_move_del, _handleUndoFinalize:, NO);
	}
	START_TIMER(final_move_del, _handleUndoFinalize:, NO);
}

- (void)handleReset {
	/* Pop out dudes */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	theseusTile.alpha = 0;
	minotaurTile.alpha = 0;
	[UIView commitAnimations];

	[minotaurTile replaceNewImageOver:g_minotaurTile delay:kDudePopInEffectDuration];
	
	START_TIMER(kDudePopInEffectDuration, _handleTimerPopInDudes:, NO);
}

- (void)_handleResetTimer:(NSTimer*)timer {
	[self handleReset];
}

- (void)suckDownTheseus {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	theseusTile.alpha = 0;
	[UIView commitAnimations];
	[SoundManager playSound:SND_TADA];
}

- (void)_playDudePopSound:(NSString*)strId context:(void*)context {
	[SoundManager playSound:SND_POP];
	NSLog(@"popsound");
}

- (void)_playDudePopSoundTimer:(NSTimer*)timer {
	[SoundManager playSound:SND_POP];
	NSLog(@"popsound_timer");
}

- (void)_handleTimerPopInDudes:(NSTimer*)timer {
	theseusTile.center  = [self _getScreenCenterCoordOfFloorByX:map_model.theseus.x Y:map_model.theseus.y];
	minotaurTile.center = [self _getScreenCenterCoordOfFloorByX:map_model.minotaur.x Y:map_model.minotaur.y];
	
	CGRect initBounds = CGRectMake(tileSize/2,tileSize/2, 0, 0);
	CGRect largeBounds = CGRectMake(-tileSize/4.0, -tileSize/4.0, tileSize*3.0/2, tileSize*3.0/2);
	CGRect finalBounds = CGRectMake(0, 0, tileSize, tileSize);
	
	theseusTile.bounds = initBounds;
	minotaurTile.bounds = initBounds;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelay:0.1];
	theseusTile.alpha = 1;
	theseusTile.bounds = largeBounds;
	[UIView commitAnimations];
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelay:kDudePopInEffectDuration+0.1];
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationWillStartSelector:@selector(_playDudePopSound:)];	
	theseusTile.bounds = finalBounds;
	[UIView commitAnimations];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];	
	minotaurTile.alpha = 1;
	minotaurTile.bounds = largeBounds;
	[UIView commitAnimations];  
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelay:(kDudePopInEffectDuration)];
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationWillStartSelector:@selector(_playDudePopSound:)];
	minotaurTile.bounds = finalBounds;
	[UIView commitAnimations];

	START_TIMER(kDudePopInEffectDuration-0.1, _playDudePopSoundTimer:, NO);
	START_TIMER(kDudePopInEffectDuration+0.1, _playDudePopSoundTimer:, NO);
}

- (void)_flourishToMapOfDiffSize:(MapModel*)new_map {
	MapModel *old_map = map_model;
	map_model = new_map;
	[self _recalculateMapMetrics];
	
	int w = MAX_LEVEL_SIZE;
	int h = MAX_LEVEL_SIZE;
	int x, y;
	
	/* Resize all tiles */
	CGPoint cen;
	for (x = 0; x < w; x++) { for (y = 0; y < h; y++) {
		cen = floorTiles[x][y].center;
		[floorTiles[x][y] resizeTo:tileSize];
		floorTiles[x][y].center = cen;
	}}
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
		cen = wallTiles[x][y].center;
		[wallTiles[x][y] resizeTo:tileSize];
		wallTiles[x][y].center = cen;
	}}
	[stairTile resizeTo:tileSize];
	CGRect nr = CGRectMake(0, 0, tileSize, tileSize);
	theseusTile.frame = nr;
	minotaurTile.frame = nr;
	
	for (x = 0; x < w; x++) { for (y = 0; y < h; y++) {
		if (x < map_model.size.w && y < map_model.size.h) {
			/* Move the tile into the new map */
			if (x < old_map.size.w && y < old_map.size.h) {
				/* Then we're just moving it from one map to another */
			} else {
				/* Otherwise we have to bring it in */
				floorTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
			}
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFlourishInEffectDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelay:(0.02 * (rand()%24))];
			floorTiles[x][y].center = [self _getScreenCenterCoordOfFloorByX:x Y:y];
			[UIView commitAnimations];
		} else if (x < old_map.size.w && y < old_map.size.h) {
			/* Otherwise move it off the board */
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFlourishInEffectDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelay:(0.02 * (rand()%24))];
			floorTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];			
			[UIView commitAnimations];
		}
	}}
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
		if (x <= map_model.size.w && y <= map_model.size.h) {
			/* Move tile to the new map */
			if (x > old_map.size.w || y > old_map.size.h) {
				/* We have to move it in */
				[wallTiles[x][y] setActiveImage:g_wallTiles[[map_model getWallPostByX:x Y:y]]];
				wallTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
			} else {
				/* we have to move it from an existing wall tile */
				int new_wall = [new_map getWallPostByX:x Y:y];
				if (new_wall != [old_map getWallPostByX:x Y:y])
					[wallTiles[x][y] gearsToNewImage:g_wallTiles[ new_wall ] duration:0.6 delay:(0.02*(rand()%12))];
			}
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFlourishInEffectDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelay:(0.02 * (rand()%24))];
			wallTiles[x][y].center = [self _getScreenCenterCoordOfWallByX:x Y:y];
			[UIView commitAnimations];
		} else if (x <= old_map.size.w && y <= old_map.size.h) {
			/* Otherwise move it off the board */
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFlourishInEffectDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelay:(0.02 * (rand()%24))];
			wallTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
			[UIView commitAnimations];
		}
	}}
}

- (void)_flourishToMapOfSameSize:(MapModel*)new_map {
	int w = map_model.size.w;
	int h = map_model.size.h;
	int x, y;	
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
		int new_wall = [new_map getWallPostByX:x Y:y];
		if (new_wall != [map_model getWallPostByX:x Y:y])
			[wallTiles[x][y] gearsToNewImage:g_wallTiles[ new_wall ] duration:0.75 delay:(0.02*(rand()%36))];		
	}}
	map_model = new_map;
}

- (void)flourishToMap:(MapModel*)new_map {
	int diff = NO;
	[SoundManager playSound:SND_STONE];
	if (new_map.size.w == map_model.size.w && new_map.size.h == map_model.size.h) {
		[self _flourishToMapOfSameSize:new_map];
	} else {
		[self _flourishToMapOfDiffSize:new_map];
		diff = YES;
	}
	
	/* Move stairs */
	int mex = map_model.maze_exit.x;
	int mey = map_model.maze_exit.y;
	float mdel = (0.02 * (rand()%24));
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kFlourishInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:mdel];
	stairTile.center = [self _getScreenCenterCoordOfFloorByX:mex Y:mey];
	[UIView commitAnimations];
	[stairTile rotateIntoNewImage:g_stairsTile duration:kFlourishInEffectDuration delay:mdel withAlpha:YES];
	
	/* Pop out dudes */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	theseusTile.alpha = 0;
	minotaurTile.alpha = 0;
	[UIView commitAnimations];
	
	//START_TIMER((kFlourishInEffectDuration+(diff?0.5:0.5)), _handleTimerPopInDudes:, NO);
	START_TIMER((kFlourishInEffectDuration+(diff?0.5:0.5)), _handleResetTimer:, NO);
}

- (void)flourishIn:(MapModel*)new_map {
	if (flourished_in) return;
	flourished_in = YES;
	
	map_model = new_map;
	
	/* Some housekeeping */
	[self _recalculateMapMetrics];
		
	/* Get generic values */
	int w = map_model.size.w;
	int h = map_model.size.h;
	int x, y;
	CGRect nr = CGRectMake(0, 0, tileSize, tileSize);
	
	/* Resize all tiles */
	for (x = 0; x < w; x++) { for (y = 0; y < h; y++) {
			[floorTiles[x][y] resizeTo:tileSize];
	}}
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
			[wallTiles[x][y] resizeTo:tileSize];
	}}
	[stairTile resizeTo:tileSize];
	theseusTile.frame = nr;
	minotaurTile.frame = nr;
	
	/* Move them all off-screen */
	[self guaranteeAllTilesHidden];
	
	/* Now get all tiles into the screen */
	for (x = 0; x < w; x++) { for (y = 0; y < h; y++) {
		int dx = w/2 - x; int dy = h/2 - y;
		float d = sqrt(dx*dx + dy*dy);
		
		floorTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kFlourishInEffectDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];		
		[UIView setAnimationDelay:(0.10 * (d))];
		floorTiles[x][y].center = [self _getScreenCenterCoordOfFloorByX:x Y:y];
		[UIView commitAnimations];
	}}
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
		float dx = w/2.0 - x; float dy = h/2.0 - y;
		float d = sqrt(dx*dx + dy*dy);
		
		[wallTiles[x][y] setActiveImage:g_wallTiles[[map_model getWallPostByX:x Y:y]]];
		wallTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kFlourishInEffectDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelay:(0.10 * (d))];
		wallTiles[x][y].center = [self _getScreenCenterCoordOfWallByX:x Y:y];
		[UIView commitAnimations];
	}}
	
	/* Move stairs */
	int mex = map_model.maze_exit.x;
	int mey = map_model.maze_exit.y;
	float sdx = w/2.0 - mex; float sdy = h/2.0 - mey;
	float sd = sqrt(sdx*sdx + sdy*sdy);
	float sdel = (0.10 * (sd));
	stairTile.center = [self _getOffScreenWaitCoordByX:mex Y:mey burst:YES];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kFlourishInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:sdel];
	stairTile.center = [self _getScreenCenterCoordOfFloorByX:mex Y:mey];
	[UIView commitAnimations];
	[stairTile rotateIntoNewImage:g_stairsTile duration:kFlourishInEffectDuration delay:sdel withAlpha:YES];
	
	
	/* Deal with dudes. */
	[minotaurTile replaceNewImageOver:([map_model isTheseusDead] ? g_minotaurEatingTile : g_minotaurTile) delay:0];
	START_TIMER((sdel+kFlourishInEffectDuration), _handleTimerPopInDudes:, NO);
	[SoundManager playSound:SND_ENTER];
}

- (float)flourishOut {
	if (!flourished_in) return 0;
	flourished_in = NO;
	
	int w = map_model.size.w;
	int h = map_model.size.h;
	int x, y;

	float rval = 0;
	
	/* Get all tiles out of the screen */
	for (x = 0; x < w; x++) { for (y = 0; y < h; y++) {
		int dx = w/2 - x; int dy = h/2 - y;
		float d = sqrt(dx*dx + dy*dy);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kFlourishInEffectDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelay:(0.10 * d)];
		floorTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
		//floorTiles[x][y].alpha = 0;
		[UIView commitAnimations];
	}}
	for (x = 0; x <= w; x++) { for (y = 0; y <= h; y++) {
		float dx = w/2.0 - x; float dy = h/2.0 - y;
		float d = sqrt(dx*dx + dy*dy);
		if (d > rval) rval = d;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kFlourishInEffectDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelay:(0.10 * d)];
		wallTiles[x][y].center = [self _getOffScreenWaitCoordByX:x Y:y burst:YES];
		//wallTiles[x][y].alpha = 0;
		[UIView commitAnimations];
	}}

	/* Move stairs */
	int mex = map_model.maze_exit.x;
	int mey = map_model.maze_exit.y;
	float sdx = w/2.0 - mex; float sdy = h/2.0 - mey;
	float sd = sqrt(sdx*sdx + sdy*sdy);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kFlourishInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:(0.10 * (sd))];
	stairTile.center = [self _getOffScreenWaitCoordByX:mex Y:mey burst:YES];
	[UIView commitAnimations];
	[stairTile rotateIntoNewImage:g_stairsTile duration:kFlourishInEffectDuration delay:(0.10 * (sd)) withAlpha:YES];
	
	/* Pop out dudes */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kDudePopInEffectDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	theseusTile.alpha = 0;
	minotaurTile.alpha = 0;
	[UIView commitAnimations];
	
	return ((0.1 * rval) + kFlourishInEffectDuration);
}


/* PURELY DEBUG RIGHT NOW */

int n_lev = 0;
- (void)test {
	//[self flourishToMap:[MapGenerator getMap:(rand()%87)]];	
	[self flourishToMap:[MapGenerator getMap:n_lev]];
	n_lev ++;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches) {
		UITouch *t = [myTouches objectAtIndex:0];
		initial_touch_point = [t locationInView:self];
		has_dragged = NO;
	}
	
	if (num_touches == 2) went_two = YES;
	if (num_touches == 1) went_two = NO;
	
#ifdef TESTING_FLOURISHES
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		
		NSLog(@"touch point %f %f", p.x, p.y);
		if (p.y > 160) {
			[self flourishOut];
		} else if (p.x < 160) {
			[self flourishIn];
		} else if (p.x > 160) {
			[self test];
		}
	}
#endif	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];

	/* Here we're just looking for movement so that we can send a directional nav */
	if (num_touches == 1 && !went_two) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		if (fabs(p.x - initial_touch_point.x) > kGestureMinDragDistance) {
			if (p.x > initial_touch_point.x) {
				[gestureDelegate acceptNavigation:DNAV_MOVE_E]; initial_touch_point.x += kGestureMinDragDistance;
			} else {
				[gestureDelegate acceptNavigation:DNAV_MOVE_W]; initial_touch_point.x -= kGestureMinDragDistance;
			}
			has_dragged = YES;
		}
		if (fabs(p.y - initial_touch_point.y) > kGestureMinDragDistance) {
			if (p.y > initial_touch_point.y) {
				[gestureDelegate acceptNavigation:DNAV_MOVE_S]; initial_touch_point.y += kGestureMinDragDistance;
			} else {
				[gestureDelegate acceptNavigation:DNAV_MOVE_N]; initial_touch_point.y -= kGestureMinDragDistance;
			}
			has_dragged = YES;
		}
	}
	
	if (num_touches == 2) went_two = YES;
}

/* A double-touch ending is either a wait or an undo */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches == 2) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		if (fabs(p.x - initial_touch_point.x) > kGestureMinDragDistance) {
			[gestureDelegate acceptNavigation:DNAV_UNDO];
		} else {
			[gestureDelegate acceptNavigation:DNAV_WAIT];
		}
		has_dragged = YES;
	} else if (num_touches == 1 && !has_dragged && !went_two) {
		/* Here we process directional tapping */
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		CGPoint th = theseusTile.center;
		
		if (fabs(p.x - th.x) > fabs(p.y - th.y)) {
			/* Moving horizontal first */
			if (p.x > th.x && [map_model canTheseusMove:DIR_E]) { [gestureDelegate acceptNavigation:DNAV_MOVE_E]; return; }
			else if (p.x < th.x && [map_model canTheseusMove:DIR_W]) { [gestureDelegate acceptNavigation:DNAV_MOVE_W]; return; }
			if (p.y > th.y && [map_model canTheseusMove:DIR_S]) { [gestureDelegate acceptNavigation:DNAV_MOVE_S]; return; }
			else if (p.y < th.y && [map_model canTheseusMove:DIR_N]) { [gestureDelegate acceptNavigation:DNAV_MOVE_N]; return; }
		} else {
			if (p.y > th.y && [map_model canTheseusMove:DIR_S]) { [gestureDelegate acceptNavigation:DNAV_MOVE_S]; return; }
			else if (p.y < th.y && [map_model canTheseusMove:DIR_N]) { [gestureDelegate acceptNavigation:DNAV_MOVE_N]; return; }
			if (p.x > th.x && [map_model canTheseusMove:DIR_E]) { [gestureDelegate acceptNavigation:DNAV_MOVE_E]; return; }
			else if (p.x < th.x && [map_model canTheseusMove:DIR_W]) { [gestureDelegate acceptNavigation:DNAV_MOVE_W]; return; }
		}
	}
}


@end
