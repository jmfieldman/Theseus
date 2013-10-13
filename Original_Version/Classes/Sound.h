//
//  Sound.h
//  Theseus
//
//  Created by Jason Fieldman on 9/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalSettings.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

void InitSound();

void PlayStomp();
void PlayBwah();
void PlaySnap();
void PlayCaught();
void PlayCrowd();
void PlayEnter();