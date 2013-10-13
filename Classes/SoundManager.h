//
//  SoundManager.h
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

typedef enum {
	SND_POP = 0,
	SND_STONE,
	SND_ENTER,
	SND_CANNOTNAV,
	SND_SNAP,
	SND_STOMP,
	SND_CAUGHT,
	SND_UNDO,
	SND_FLOUT,
	SND_TADA,
	SND_VAULT,
	SND_KICK,
	SND_SELECT,
	SND_TOGGLE,
	SND_TONGUE,
	NUM_SOUNDS,
} Sound_t;

@interface SoundManager : NSObject {
	
}

+ (void)initialize;
+ (void)playSound:(Sound_t)sound;
+ (void)setGlobalSound:(BOOL)on;
+ (BOOL)getGlobalSound;

@end
