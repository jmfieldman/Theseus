//
//  GraphicsModel.m
//  Theseus
//
//  Created by Jason Fieldman on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GraphicsModel.h"
#import "DataStructures.h"
#import "GameStateModel.h"

UIFont *sys12;
UIFont *sys14;
UIFont *sys16;
UIFont *sys18;

UIFont *Bsys12;
UIFont *Bsys14;
UIFont *Bsys16;
UIFont *Bsys18;

UIImage *img_thes;
UIImage *img_mino;
UIImage *img_mino_eating;
UIImage *img_mino_eating_drops;
UIImage *img_thes_shadow;
UIImage *img_mino_shadow;

UIImage *img_exit;

UIImage *img_shadow_top;
UIImage *img_shadow_bottom;
UIImage *img_shadow_right;
UIImage *img_shadow_left;

UIImage *img_wall_top;
UIImage *img_wall_bottom;
UIImage *img_wall_right;
UIImage *img_wall_left;

UIImage *img_dpad[2][2][9];

UIImage *img_nav_bk;
UIImage *img_dun_bk;
UIImage *img_howto_bk;
UIImage *img_howto_con;
UIImage *img_game_menu_bk;
UIImage *img_main_menu_bk;

UIImage *img_button_wait;
UIImage *img_button_wait_dn;

UIImage *img_undo_enabled;
UIImage *img_undo_enabled_dn;
UIImage *img_undo_disabled;
UIImage *img_redo_enabled;
UIImage *img_redo_enabled_dn;
UIImage *img_redo_disabled;

UIImage *img_close_button;
UIImage *img_close_button_dn;
UIImage *img_reload;

UIImage *img_badges[3];

UIImage *img_theseus_options[NUM_THESEUS_IMGS];
int current_theseus_img = 0;

int imgs_need_init = 1;

void InitImgs() {
	sys12 = [UIFont systemFontOfSize:12];
	sys14 = [UIFont systemFontOfSize:14];
	sys16 = [UIFont systemFontOfSize:16];
	sys18 = [UIFont systemFontOfSize:18];

	Bsys12 = [UIFont boldSystemFontOfSize:12];
	Bsys14 = [UIFont boldSystemFontOfSize:14];
	Bsys16 = [UIFont boldSystemFontOfSize:16];
	Bsys18 = [UIFont boldSystemFontOfSize:18];
	
	img_theseus_options[0] = [UIImage imageNamed:@"theseus_armed.png"];
	img_theseus_options[1] = [UIImage imageNamed:@"theseus_satchel.png"];
	img_theseus_options[2] = [UIImage imageNamed:@"theseus_pirate.png"];
	img_theseus_options[3] = [UIImage imageNamed:@"theseus_robin.png"];
	
	img_thes = img_theseus_options[current_theseus_img];
	img_mino = [UIImage imageNamed:@"minotaur.png"];
	img_mino_eating = [UIImage imageNamed:@"minotaur_eating.png"];
	img_mino_eating_drops = [UIImage imageNamed:@"minotaur_eating_drops.png"];
	img_thes_shadow = [UIImage imageNamed:@"ball_shadow.png"];
	img_mino_shadow = [UIImage imageNamed:@"ball_shadow.png"];
	
	img_exit = [UIImage imageNamed:@"stairs.png"];
	
	img_shadow_top    = [UIImage imageNamed:@"shadow_top.png"];
	img_shadow_bottom = [UIImage imageNamed:@"shadow_bottom.png"];
	img_shadow_left   = [UIImage imageNamed:@"shadow_left.png"];
	img_shadow_right  = [UIImage imageNamed:@"shadow_right.png"];
	
	img_wall_top    = [UIImage imageNamed:@"wall_top.png"];
	img_wall_bottom = [UIImage imageNamed:@"wall_bottom.png"];
	img_wall_left   = [UIImage imageNamed:@"wall_left.png"];
	img_wall_right  = [UIImage imageNamed:@"wall_right.png"];
	
	img_dpad[DPAD_CAN][DPAD_SEL][DIR_N] = [UIImage imageNamed:@"dpad_o_d_up.png"];
	img_dpad[DPAD_CAN][DPAD_SEL][DIR_W] = [UIImage imageNamed:@"dpad_o_d_left.png"];
	img_dpad[DPAD_CAN][DPAD_SEL][DIR_E] = [UIImage imageNamed:@"dpad_o_d_right.png"];
	img_dpad[DPAD_CAN][DPAD_SEL][DIR_S] = [UIImage imageNamed:@"dpad_o_d_down.png"];

	img_dpad[DPAD_CAN][DPAD_UNSEL][DIR_N] = [UIImage imageNamed:@"dpad_o_u_up.png"];
	img_dpad[DPAD_CAN][DPAD_UNSEL][DIR_W] = [UIImage imageNamed:@"dpad_o_u_left.png"];
	img_dpad[DPAD_CAN][DPAD_UNSEL][DIR_E] = [UIImage imageNamed:@"dpad_o_u_right.png"];
	img_dpad[DPAD_CAN][DPAD_UNSEL][DIR_S] = [UIImage imageNamed:@"dpad_o_u_down.png"];
	
	img_dpad[DPAD_CANNOT][DPAD_SEL][DIR_N] = [UIImage imageNamed:@"dpad_x_d_up.png"];
	img_dpad[DPAD_CANNOT][DPAD_SEL][DIR_W] = [UIImage imageNamed:@"dpad_x_d_left.png"];
	img_dpad[DPAD_CANNOT][DPAD_SEL][DIR_E] = [UIImage imageNamed:@"dpad_x_d_right.png"];
	img_dpad[DPAD_CANNOT][DPAD_SEL][DIR_S] = [UIImage imageNamed:@"dpad_x_d_down.png"];
	
	img_dpad[DPAD_CANNOT][DPAD_UNSEL][DIR_N] = [UIImage imageNamed:@"dpad_x_u_up.png"];
	img_dpad[DPAD_CANNOT][DPAD_UNSEL][DIR_W] = [UIImage imageNamed:@"dpad_x_u_left.png"];
	img_dpad[DPAD_CANNOT][DPAD_UNSEL][DIR_E] = [UIImage imageNamed:@"dpad_x_u_right.png"];
	img_dpad[DPAD_CANNOT][DPAD_UNSEL][DIR_S] = [UIImage imageNamed:@"dpad_x_u_down.png"];
		
	img_nav_bk = [UIImage imageNamed:@"nav_bkgnd.png"];
	img_dun_bk = [UIImage imageNamed:@"dungeon_back.png"];
	img_howto_bk = [UIImage imageNamed:@"howto_back.png"];
	img_howto_con = [UIImage imageNamed:@"howto_content_en.png"];
	img_game_menu_bk = [UIImage imageNamed:@"game_menu.png"];
	img_main_menu_bk = [UIImage imageNamed:@"main_menu_back.png"];
	
	img_button_wait = [UIImage imageNamed:@"big_button.png"];
	img_button_wait_dn = [UIImage imageNamed:@"big_button_dn.png"];
	
	img_undo_enabled      = [UIImage imageNamed:@"undo_enabled.png"];
	img_undo_enabled_dn   = [UIImage imageNamed:@"undo_enabled_dn.png"];
	img_undo_disabled     = [UIImage imageNamed:@"undo_disabled.png"];
	img_redo_enabled      = [UIImage imageNamed:@"redo_enabled.png"];
	img_redo_enabled_dn   = [UIImage imageNamed:@"redo_enabled_dn.png"];
	img_redo_disabled     = [UIImage imageNamed:@"redo_disabled.png"];
	
	img_close_button    = [UIImage imageNamed:@"close_button.png"];
	img_close_button_dn = [UIImage imageNamed:@"close_button_dn.png"];
	img_reload          = [UIImage imageNamed:@"reload_map.png"];
	
	img_badges[0] = [UIImage imageNamed:@"awardbronze.png"];
	img_badges[1] = [UIImage imageNamed:@"awardsilver.png"];
	img_badges[2] = [UIImage imageNamed:@"awardgold.png"];
	
	imgs_need_init = 0;
}

void CycleTheseusImg() {
	current_theseus_img++;
	current_theseus_img %= NUM_THESEUS_IMGS;
	
	img_thes = img_theseus_options[current_theseus_img];
	[GameStateModel SaveGameState];
}

void SetCurrentTheseusImg(int t) {
	if (t < 0 || t >= NUM_THESEUS_IMGS) return;
	
	current_theseus_img = t;
	img_thes = img_theseus_options[current_theseus_img];
}

int GetCurrentTheseusImg() {
	return current_theseus_img;
}