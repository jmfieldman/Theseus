//
//  MapPreviewView.m
//  Theseus
//
//  Created by Jason Fieldman on 8/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapPreviewView.h"

@implementation MapPreviewView

- (id)initWithFrame:(CGRect)frame withMap:(MapModel*)map withBorder:(int)brdr {
	if (self = [super initWithFrame:frame]) {
		preview_mode = YES;
		img_buffer = nil;
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
	
	CGRect newSize = CGRectMake(0, 0, frame.size.width, frame.size.height);
	UIGraphicsBeginImageContext(newSize.size);
	[self drawPreview:newSize];
	[img_buffer release];
	img_buffer = UIGraphicsGetImageFromCurrentImageContext();
	[img_buffer retain];
	UIGraphicsEndImageContext();
	
	
	//if (shadow_buffer) [shadow_buffer release];
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


- (void)drawRect:(CGRect)rect {
	if (preview_mode) {
		//[self drawPreview:rect];
		[img_buffer drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		return;
	}
	
}

- (void)dealloc {
	[super dealloc];
}


@end
