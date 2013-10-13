//
//  GlobalSettings.m
//  Theseus
//
//  Created by Jason Fieldman on 9/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GlobalSettings.h"

BOOL sound_on = YES;

BOOL GlobalSoundOn() {
	return sound_on;
}

void SetGlobalSoundOn(BOOL s) {
	sound_on = s;
}



BOOL fast_minotaur = NO;

BOOL GlobalFastMinotaur() {
	return fast_minotaur;
}

void SetGlobalFastMinotaur(BOOL f) {
	fast_minotaur = f;
}