//
//  TileHelper.h
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"

#define kTileSize 40.0
#define kTileHalf 20.0
#define kTileRect CGRectMake(0, 0, kTileSize, kTileSize)

#define kWallWidth 4.0
#define kWallRadius 2.0

#define kWallRepaint 2
#define kWallAlphaForAllButLast 0.5
#define kWallBlur 8

//#define kWallColor 124.0/255.0, 124.0/255.0, 124.0/255.0, 1
#define kWallColor 100.0/255.0, 100.0/255.0, 100.0/255.0, 1

extern UIImage *g_floorTiles[2];
extern UIImage *g_wallTiles[16];
extern UIImage *g_stairsTile;
extern UIImage *g_theseusTile;
extern UIImage *g_minotaurTile;
extern UIImage *g_minotaurEatingTile;

extern UIImage *g_goldaward;
extern UIImage *g_silvaward;

extern CATransform3D g_rotateIdentity;
extern CATransform3D g_rotateQuarter;
extern CATransform3D g_rotateHalf;
extern CATransform3D g_rotateThreeQuarters;


void InitializeTiles();