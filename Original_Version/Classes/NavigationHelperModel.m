//
//  NavigationHelperModel.m
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NavigationHelperModel.h"

MainMenuViewController*	g_MainMenuViewController = nil;
MainMenuViewController*	GetMainMenuViewController() {
	if (!g_MainMenuViewController) {
		g_MainMenuViewController = [[MainMenuViewController alloc] init];
	}
	return g_MainMenuViewController;
}

DungeonViewController*	g_DungeonViewController = nil;
DungeonViewController*	GetDungeonViewController() {
	if (!g_DungeonViewController) {
		g_DungeonViewController = [[DungeonViewController alloc] init];
	}
	return g_DungeonViewController;
}

HowToPlayViewController*	g_HowToPlayViewController = nil;
HowToPlayViewController*	GetHowToPlayViewController() {
	if (!g_HowToPlayViewController) {
		g_HowToPlayViewController = [[HowToPlayViewController alloc] init];
	}
	return g_HowToPlayViewController;
}
