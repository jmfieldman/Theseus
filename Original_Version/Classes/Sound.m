//
//  Sound.m
//  Theseus
//
//  Created by Jason Fieldman on 9/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Sound.h"

SystemSoundID sound_stomp;
SystemSoundID sound_bwah;
SystemSoundID sound_snap;
SystemSoundID sound_caught;
SystemSoundID sound_crowd;
SystemSoundID sound_enter;

#define SOUND_DIRECTORY @"Resources"
#define WAV_TYPE @"wav"
#define AU_TYPE @"au"

#define INIT_SOUND(vari, filename, filetype) do { \
NSString *s_file = [bundle pathForResource:filename ofType:filetype ]; \
NSURL *s_url = [NSURL fileURLWithPath:s_file]; \
AudioServicesCreateSystemSoundID( (CFURLRef) s_url, &vari ); \
} while (0);

void InitSound() {
	NSBundle *bundle = [NSBundle mainBundle];

	INIT_SOUND(sound_stomp,  @"minotaur", AU_TYPE);
	INIT_SOUND(sound_bwah,   @"bwah",     WAV_TYPE);
	INIT_SOUND(sound_snap,   @"snap",     WAV_TYPE);
	INIT_SOUND(sound_caught, @"caught",   WAV_TYPE);
	INIT_SOUND(sound_crowd,  @"crowd",    WAV_TYPE);
	INIT_SOUND(sound_enter,  @"enter",    WAV_TYPE);
}

void PlayStomp() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_stomp);
}

void PlayBwah() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_bwah);
}

void PlaySnap() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_snap);
}

void PlayCaught() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_caught);
}

void PlayCrowd() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_crowd);
}

void PlayEnter() {
	if (!GlobalSoundOn()) return;
	AudioServicesPlaySystemSound(sound_enter);
}
