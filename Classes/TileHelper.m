//
//  TileHelper.m
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileHelper.h"
#import "DataStructures.h"

UIImage *g_floorTiles[2];
UIImage *g_wallTiles[16];
UIImage *g_stairsTile;
UIImage *g_theseusTile;
UIImage *g_minotaurTile;
UIImage *g_minotaurEatingTile;

UIImage *g_goldaward;
UIImage *g_silvaward;

CATransform3D g_rotateIdentity;
CATransform3D g_rotateQuarter;
CATransform3D g_rotateHalf;
CATransform3D g_rotateThreeQuarters;


void InitializeFloorTiles() {
	g_floorTiles[0] = [[UIImage imageNamed:@"tileAa.png"] retain];
	g_floorTiles[1] = [[UIImage imageNamed:@"tileB.png"] retain];
	g_stairsTile    = [[UIImage imageNamed:@"stairs.png"] retain];
	g_theseusTile   = [[UIImage imageNamed:@"theseus.png"] retain];
	g_minotaurTile  = [[UIImage imageNamed:@"minotaur.png"] retain];
	g_minotaurEatingTile  = [[UIImage imageNamed:@"minotaur_eating.png"] retain];
}

void InitializeWallTiles() {
	for (int i = 0; i < 16; i++) {
		CGRect imgsize = CGRectMake(0, 0, kTileSize, kTileSize);
		UIGraphicsBeginImageContext(imgsize.size);
		CGContextRef c = UIGraphicsGetCurrentContext();
	
		CGContextSetRGBFillColor(c, kWallColor);
		
		CGContextSetShadow(c, CGSizeMake(2,-2), kWallBlur);
		
		if (i) for (int r = 0; r < kWallRepaint; r++) {
			CGContextSetAlpha(c, (r == (kWallRepaint-1)) ? 1.0 : kWallAlphaForAllButLast);
			CGContextBeginPath(c);
			/* Move to inner upper-left */
			CGContextMoveToPoint(c, kTileHalf - kWallRadius, kTileHalf - kWallRadius);
			
			if (i & DIR_N) {
				CGContextAddLineToPoint(c, kTileHalf - kWallRadius, -kTileHalf);
				CGContextAddLineToPoint(c, kTileHalf + kWallRadius, -kTileHalf);				
			}	CGContextAddLineToPoint(c, kTileHalf + kWallRadius, kTileHalf - kWallRadius);
			if (i & DIR_E) {
				CGContextAddLineToPoint(c, kTileSize + kTileHalf, kTileHalf - kWallRadius);
				CGContextAddLineToPoint(c, kTileSize + kTileHalf, kTileHalf + kWallRadius);				
			}	CGContextAddLineToPoint(c, kTileHalf + kWallRadius, kTileHalf + kWallRadius);
			if (i & DIR_S) {
				CGContextAddLineToPoint(c, kTileHalf + kWallRadius, kTileSize + kTileHalf);
				CGContextAddLineToPoint(c, kTileHalf - kWallRadius, kTileSize + kTileHalf);				
			}	CGContextAddLineToPoint(c, kTileHalf - kWallRadius, kTileHalf + kWallRadius);
			if (i & DIR_W) {
				CGContextAddLineToPoint(c, -kTileHalf, kTileHalf + kWallRadius);
				CGContextAddLineToPoint(c, -kTileHalf, kTileHalf - kWallRadius);				
			}	CGContextAddLineToPoint(c, kTileHalf - kWallRadius, kTileHalf - kWallRadius);
			
			CGContextEOFillPath(c);
		}
		
		g_wallTiles[i] = UIGraphicsGetImageFromCurrentImageContext();
		[g_wallTiles[i] retain];
		UIGraphicsEndImageContext();
	}
}

bool tiles_initialized = NO;
void InitializeTiles() {
	if (tiles_initialized) return;
	tiles_initialized = YES;

	InitializeFloorTiles();
	InitializeWallTiles();
	
	g_goldaward = [[UIImage imageNamed:@"awardgold.png"] retain];
	g_silvaward = [[UIImage imageNamed:@"awardsilver.png"] retain];
	
	g_rotateIdentity = CATransform3DIdentity;
	g_rotateQuarter = CATransform3DIdentity;
	g_rotateQuarter = CATransform3DRotate(g_rotateQuarter, M_PI_2, 0, 0, 1);
	g_rotateHalf = CATransform3DIdentity;
	g_rotateHalf = CATransform3DRotate(g_rotateHalf, M_PI, 0, 0, 1);
	g_rotateThreeQuarters = CATransform3DIdentity;
	g_rotateThreeQuarters = CATransform3DRotate(g_rotateThreeQuarters, 3*M_PI_2, 0, 0, 1);

}

