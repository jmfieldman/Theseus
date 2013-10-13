//
//  Globals.m
//  Workout Heroes
//
//  Created by Jason Fieldman on 5/24/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "Globals.h"

static BOOL s_screenSize35;
static BOOL s_screenRetina;

@implementation Globals

+ (void) initGlobals {
	s_screenRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00);
	s_screenSize35 = ([[UIScreen mainScreen] applicationFrame].size.height <= 480);
	
}

+ (BOOL) isRetina {
	return s_screenRetina;
}

+ (BOOL) isScreen35 {
	return s_screenSize35;
}

@end
