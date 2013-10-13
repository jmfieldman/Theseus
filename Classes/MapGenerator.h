//
//  MapGenerator.h
//  Theseus
//
//  Created by Jason Fieldman on 8/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"

#define NUM_LEVELS 97
#define NUM_AUTHORS 8

#define NUM_LEVEL_NAMES 97

extern char *authors[NUM_AUTHORS];
extern char *display_names[NUM_LEVEL_NAMES];

@interface MapGenerator : NSObject {

}

+ (void)initLevels;
+ (MapModel*)getMap:(int)level;
+ (int)numLevels;

+ (int)indexOfLevelNamed:(char*)name;
+ (char*)nameOfLevelIndexed:(int)index;

@end
