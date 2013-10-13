//
//  MapView.m
//  Theseus
//
//  Created by Jason Fieldman on 8/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "Sound.h"

@implementation MapView
@synthesize draw_special_locations;
@synthesize navDelegate;

- (id)initWithFrame:(CGRect)frame withMap:(MapModel*)map withBorder:(int)brdr {
	if (self = [super initWithFrame:frame]) {
		navDelegate = nil;
		down_waiting = NO;
		down_point = CGPointZero;
		
		shadow_buffer = nil;

		[self updateWithFrame:frame withMap:map withBorder:brdr];
	}
	return self;
}

- (void)updateWithFrame:(CGRect)frame withMap:(MapModel*)map withBorder:(int)brdr {
	self.frame = frame;
	
	/* Assign the map */	
	map_model = map;	
	
	/* Pre-calculate values */
	border = brdr;
	tile_size.w = (int)(frame.size.width - brdr*2) / (int)map.size.w;
	tile_size.h = (int)(frame.size.height - brdr*2) / (int)map.size.h;
	
	/* Sprite sizing */
	sprite_size.w = tile_size.w * 2;
	sprite_size.h = tile_size.h * 2;
	
	sprite_offset.x = (tile_size.w / 2) * -1;
	sprite_offset.y = (tile_size.h / 2) * -1;
	
	/* Theseus sizing */
	thes_size.w = tile_size.w * 3 / 4;
	thes_size.h = tile_size.h * 3 / 4;
	thes_offset.x = (tile_size.w / 8);
	thes_offset.y = (tile_size.h / 8);
	
	/* Minotaur sizing */
	mino_size.w = tile_size.w * 5 / 4;
	mino_size.h = tile_size.h * 5 / 4;
	mino_offset.x = (tile_size.w * 1 / 8) * -1;
	mino_offset.y = (tile_size.h * 3 / 8) * -1;
	
	wall_half_width = tile_size.w / 16;
	wall_width = wall_half_width * 2;
	
	//if (shadow_buffer) [shadow_buffer release];
	[self initializeShadowBuffer:frame];
	[self setNeedsDisplay];
}

- (void)setPreviewMode:(BOOL)p_mode {
	preview_mode = p_mode;
	[self setNeedsDisplay];
}


- (void)drawPreview:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* Draw background */
	CGContextSetRGBFillColor(c, MAZE_P_TILE_RGBA);
	CGContextFillRect(c, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	/* Draw Exit Square */
	CGContextSetRGBFillColor(c, MAZE_P_EXIT_RGBA);
	CGContextFillRect(c, CGRectMake(map_model.maze_exit.x * tile_size.w + 1, map_model.maze_exit.y * tile_size.h + 1, tile_size.w - 2, tile_size.h - 2));
	
	/* Draw Theseus */
	CGContextSetRGBFillColor(c, MAZE_P_THES_RGBA);
	CGContextFillEllipseInRect(c, CGRectMake(map_model.theseus.x * tile_size.w + wall_half_width + 2, map_model.theseus.y * tile_size.h + wall_half_width + 2, tile_size.w - wall_width - 4, tile_size.h - wall_width - 4));
	
	/* Draw Minotaur */
	CGContextSetRGBFillColor(c, MAZE_P_MINO_RGBA);
	CGContextFillEllipseInRect(c, CGRectMake(map_model.minotaur.x * tile_size.w + wall_half_width + 2, map_model.minotaur.y * tile_size.h + wall_half_width + 2, tile_size.w - wall_width - 4, tile_size.h - wall_width - 4));
	
	/* Draw grid */
#if 0
	CGContextSetRGBStrokeColor(c, MAZE_P_GRID_RGBA);
	CGContextSetLineCap(c, kCGLineCapButt);
	CGContextSetLineWidth(c, 1);
	int gx = tile_size.w;
	for (int gi = 0; gi < (map_model.size.w-1); gi++) {
		CGContextMoveToPoint(c, gx, 0);
		CGContextAddLineToPoint(c, gx, tile_size.h * (map_model.size.h + 1));
		CGContextStrokePath(c);		
		gx += tile_size.w;		
	}
	int gy = tile_size.h;
	for (int gyi = 0; gyi < (map_model.size.h-1); gyi++) {
		CGContextMoveToPoint(c, 0, gy);
		CGContextAddLineToPoint(c, tile_size.w * (map_model.size.w + 1), gy);
		CGContextStrokePath(c);		
		gy += tile_size.h;		
	}
#endif
	
	/* Draw Walls */
	CGContextSetRGBStrokeColor(c, MAZE_P_WALL_RGBA);
	CGContextSetLineWidth(c, 1);//wall_width);
	THPoint maze_loc;
	int x_left   = tile_size.w * (map_model.size.w - 1);
	int x_right  = tile_size.w * (map_model.size.w + 0);
	
	CGContextSetLineCap(c, kCGLineJoinRound);
	CGContextBeginPath(c);
	for (maze_loc.x = map_model.size.w - 1; maze_loc.x >= 0; maze_loc.x--) {
		int y_top    = tile_size.h * (map_model.size.h - 1);
		int y_bottom = tile_size.h * (map_model.size.h + 0);
		for (maze_loc.y = map_model.size.h - 1; maze_loc.y >= 0; maze_loc.y--) {
			int map_tile = [map_model getMazeSquare:maze_loc];
			if (map_tile & DIR_N) {
				CGContextMoveToPoint(c, x_left, y_top);
				CGContextAddLineToPoint(c, x_right, y_top);
				CGContextStrokePath(c);
			}
			if (map_tile & DIR_S) {
				CGContextMoveToPoint(c, x_left, y_bottom);
				CGContextAddLineToPoint(c, x_right, y_bottom);
				CGContextStrokePath(c);
			}
			if (map_tile & DIR_W) {
				CGContextMoveToPoint(c, x_left, y_top);
				CGContextAddLineToPoint(c, x_left, y_bottom);
				CGContextStrokePath(c);
			}
			if (map_tile & DIR_E) {
				CGContextMoveToPoint(c, x_right, y_top);
				CGContextAddLineToPoint(c, x_right, y_bottom);
				CGContextStrokePath(c);
			}
			y_top -= tile_size.h;
			y_bottom -= tile_size.h;
		}
		x_left -= tile_size.w;
		x_right -= tile_size.w;
	}
	
	/* Finish with border */
	CGContextSetLineWidth(c, wall_width + 1);
	CGContextStrokeRect(c, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
}

- (void) initializeShadowBuffer:(CGRect)frame {
	int x, y;
	THPoint tile_origin;
	int RIGHT = map_model.size.w - 1;
	int BOTTOM = map_model.size.h - 1;

	UIGraphicsBeginImageContext(frame.size);
	
	tile_origin.y = border;
	for (y = 0; y < map_model.size.h; y++) {
		tile_origin.x = border;
		for (x = 0; x < map_model.size.w; x++) {
			int map_tile = [map_model getMazeSquareByX:x Y:y];
			
			/* Calculate sprite rectangle */
			CGRect sprite_rect = CGRectMake(tile_origin.x + sprite_offset.x, tile_origin.y + sprite_offset.y,
											sprite_size.w, sprite_size.h);
			
			/* Draw shadows */
			if ((map_tile & DIR_N) || y == 0)      [img_shadow_top    drawInRect:sprite_rect];
			if ((map_tile & DIR_W) || x == 0)      [img_shadow_left   drawInRect:sprite_rect];
			if ((map_tile & DIR_E) || x == RIGHT)  [img_shadow_right  drawInRect:sprite_rect];
			if ((map_tile & DIR_S) || y == BOTTOM) [img_shadow_bottom drawInRect:sprite_rect];
			
			tile_origin.x += tile_size.w;
		}
		tile_origin.y += tile_size.h;
	}
	
	if (shadow_buffer) [shadow_buffer release];
	shadow_buffer = UIGraphicsGetImageFromCurrentImageContext();
	[shadow_buffer retain];
	UIGraphicsEndImageContext();
}

- (void)drawRect:(CGRect)rect {
	if (preview_mode) {
		[self drawPreview:rect];
		return;
	}
	
	int x, y;
	THPoint tile_origin;
	int RIGHT = map_model.size.w - 1;
	int BOTTOM = map_model.size.h - 1;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* Draw background */
	//CGContextSetRGBFillColor(c, MAZE_BACKGROUND_RGBA);
	//CGContextFillRect(c, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	for (x = 0; x < 4; x++) {
		float cc = 0.25 + 0.25*x;
		CGContextSetRGBFillColor(c, cc,cc,cc,1);
		CGContextFillRect(c, CGRectMake(0+x, 0+x, self.frame.size.width-(x*2), self.frame.size.height-(x*2)));	
	}
	
	/* Draw tile backgrounds */
	tile_origin.y = border;
	for (y = 0; y < map_model.size.h; y++) {
		tile_origin.x = border;
		for (x = 0; x < map_model.size.w; x++) {
			/* Draw tile background */
			if ( (x + y) & 1 ) {
				CGContextSetRGBFillColor(c, MAZE_TILE_ODD_RGBA);
			} else {
				CGContextSetRGBFillColor(c, MAZE_TILE_EVEN_RGBA);
			}
			CGContextFillRect(c, CGRectMake(tile_origin.x, tile_origin.y, tile_size.w, tile_size.h));
			tile_origin.x += tile_size.w;
		}
		tile_origin.y += tile_size.h;
	}
	
	/* Place the map exit */
	[img_exit drawInRect:CGRectMake(border + (tile_size.w * map_model.maze_exit.x), border + (tile_size.h * map_model.maze_exit.y), tile_size.w, tile_size.h)];
	
	/* Place down the shadows */
	[shadow_buffer drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.2];
	
	/* Ugh, we have to draw the top wall first for rendering reasons.. */
	tile_origin.y = border;
	tile_origin.x = border;
	for (x = 0; x < map_model.size.w; x++) {
		CGRect sprite_rect = CGRectMake(tile_origin.x + sprite_offset.x, tile_origin.y + sprite_offset.y,
										sprite_size.w, sprite_size.h);
		[img_wall_top    drawInRect:sprite_rect];
		tile_origin.x += tile_size.w;
	}
	
	/* Put down ball shadows */
	for (y = 0; y < map_model.size.h; y++) {
		tile_origin.x = border;
		for (x = 0; x < map_model.size.w; x++) {
			if (map_model.minotaur.x == x && map_model.minotaur.y == y) {
				CGRect mino_rect = CGRectMake(tile_origin.x + mino_offset.x, tile_origin.y + mino_offset.y,
											  mino_size.w, mino_size.h);

				[img_mino_shadow drawInRect:mino_rect];
				if ([map_model isTheseusDead]) {
					[img_mino_eating_drops drawInRect:mino_rect];					
				}				
				
			} else if (map_model.theseus.x == x && map_model.theseus.y == y) {
				CGRect thes_rect = CGRectMake(tile_origin.x + thes_offset.x, tile_origin.y + thes_offset.y,
											  thes_size.w, thes_size.h);
				[img_thes_shadow drawInRect:thes_rect];				
			}
			
			tile_origin.x += tile_size.w;
		}
		tile_origin.y += tile_size.h;
	}
	
	/* Paint tiles from top to bottom, left to right */
	tile_origin.y = border;
	for (y = 0; y < map_model.size.h; y++) {
		tile_origin.x = border;
		for (x = 0; x < map_model.size.w; x++) {
			/* --------- Begin per-tile paint code --------- */
			
			int map_tile = [map_model getMazeSquareByX:x Y:y];
						
			/* Calculate sprite rectangle */
			CGRect sprite_rect = CGRectMake(tile_origin.x + sprite_offset.x, tile_origin.y + sprite_offset.y,
											sprite_size.w, sprite_size.h);
			
			/*if (map_model.minotaur.x == x && map_model.minotaur.y == y && [map_model isTheseusDead]) {
				CGRect mino_rect = CGRectMake(tile_origin.x + mino_offset.x, tile_origin.y + mino_offset.y,
											  mino_size.w, mino_size.h);
				[img_mino_eating_drops drawInRect:mino_rect];
				if (x == 0 || [map_model getMazeSquareByX:(x-1) Y:y] & DIR_E) {
					[img_wall_left   drawInRect:sprite_rect];
				}
			}*/

			/* Draw walls (only left, right) */
			if (x == 0)                            [img_wall_left   drawInRect:sprite_rect];
			if ((map_tile & DIR_E) || x == RIGHT)  [img_wall_right  drawInRect:sprite_rect];
			
			/* Draw Theseus and Minotaur if they are here */
			if (map_model.theseus.x == x && map_model.theseus.y == y && ![map_model isTheseusDead]) {
				CGRect thes_rect = CGRectMake(tile_origin.x + thes_offset.x, tile_origin.y + thes_offset.y,
												thes_size.w, thes_size.h);
				[img_thes drawInRect:thes_rect];
			}
			if (map_model.minotaur.x == x && map_model.minotaur.y == y) {
				CGRect mino_rect = CGRectMake(tile_origin.x + mino_offset.x, tile_origin.y + mino_offset.y,
											  mino_size.w, mino_size.h);
				[([map_model isTheseusDead] ? img_mino_eating : img_mino) drawInRect:mino_rect];
			}
						
			
			/* Draw bottom wall */
			if ((map_tile & DIR_S) || y == BOTTOM) [img_wall_bottom drawInRect:sprite_rect];
			
			
			/* --------- End per-tile paint code ---------- */
			tile_origin.x += tile_size.w;
		}
		tile_origin.y += tile_size.h;
	}
}

/* ------------- TOUCHES -------------- */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];

	UITouch *t = [myTouches objectAtIndex:0];
	CGPoint p = [t locationInView:self];
	down_point = p;
	
	if (num_touches == 2) {
		down_waiting = YES;
	}
}

#define SWIPE_TOLERANCE 30

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!navDelegate) return;
	
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	//int num_touches = [myTouches count];
	
	if (down_waiting) {
		[navDelegate acceptNavigation:DNAV_WAIT];
		down_point = CGPointZero;
		down_waiting = NO;
		return;		
	} else {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p  = [t locationInView:self];
		
		if ( abs(p.x - down_point.x) > SWIPE_TOLERANCE || abs(p.y - down_point.y) > SWIPE_TOLERANCE ) {
			if (abs(p.x - down_point.x) > abs(p.y - down_point.y)) {
				if (p.x > down_point.x) {
					[navDelegate acceptNavigation:DNAV_MOVE_E];
				} else {
					[navDelegate acceptNavigation:DNAV_MOVE_W];
				}
			} else {
				if (p.y > down_point.y) {
					[navDelegate acceptNavigation:DNAV_MOVE_S];
				} else {
					[navDelegate acceptNavigation:DNAV_MOVE_N];
				}
			}
			PlaySnap();
			down_waiting = NO;
			down_point = CGPointZero;
		}		
	}			
}





- (void)dealloc {
	if (shadow_buffer) [shadow_buffer release];
	[super dealloc];
}


@end
