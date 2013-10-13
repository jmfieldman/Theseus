//
//  SoundManager.m
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

#define SOUND_DIRECTORY @"Resources"
#define WAV_TYPE @"wav"
#define AU_TYPE @"au"
#define AIFF_TYPE @"aif"

#define INIT_SOUND(vari, filename, filetype) do { \
NSString *s_file = [bundle pathForResource:filename ofType:filetype ]; \
NSURL *s_url = [NSURL fileURLWithPath:s_file]; \
AudioServicesCreateSystemSoundID( (CFURLRef) s_url, &soundIds[vari] ); \
} while (0);

SystemSoundID soundIds[NUM_SOUNDS];
BOOL globalSoundOn = YES;

@implementation SoundManager

+ (void)initialize {
	NSBundle *bundle = [NSBundle mainBundle];
	
	INIT_SOUND(SND_POP,       @"pop",        WAV_TYPE);
	INIT_SOUND(SND_STONE,     @"stone",      WAV_TYPE);
	INIT_SOUND(SND_ENTER,     @"enter",      WAV_TYPE);
	INIT_SOUND(SND_CANNOTNAV, @"cannot_nav", WAV_TYPE);
	INIT_SOUND(SND_SNAP,      @"snap",       WAV_TYPE);
	INIT_SOUND(SND_STOMP,     @"minotaur",   AU_TYPE);
	INIT_SOUND(SND_CAUGHT,    @"caught",     WAV_TYPE);
	INIT_SOUND(SND_UNDO,      @"undo",       WAV_TYPE);
	INIT_SOUND(SND_FLOUT,     @"flourish_out", WAV_TYPE);
	INIT_SOUND(SND_TADA,      @"tada",       WAV_TYPE);
	INIT_SOUND(SND_VAULT,     @"vault",      WAV_TYPE);	
	INIT_SOUND(SND_KICK,      @"kick",       WAV_TYPE);
	INIT_SOUND(SND_SELECT,    @"select",     WAV_TYPE);
	INIT_SOUND(SND_TOGGLE,    @"toggle",     WAV_TYPE);
	INIT_SOUND(SND_TONGUE,    @"tongue",     WAV_TYPE);

}

+ (void)playSound:(Sound_t)sound {
	if (!globalSoundOn) return;
	AudioServicesPlaySystemSound(soundIds[sound]);
}

+ (void)setGlobalSound:(BOOL)on {
	globalSoundOn = on;
}

+ (BOOL)getGlobalSound {
	return globalSoundOn;
}

@end
