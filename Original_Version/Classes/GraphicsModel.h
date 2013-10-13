//
//  GraphicsModel.h
//  Theseus
//
//  Created by Jason Fieldman on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUM_THESEUS_IMGS 4

extern UIFont *sys12;
extern UIFont *sys14;
extern UIFont *sys16;
extern UIFont *sys18;

extern UIFont *Bsys12;
extern UIFont *Bsys14;
extern UIFont *Bsys16;
extern UIFont *Bsys18;

extern UIImage *img_thes;
extern UIImage *img_mino;
extern UIImage *img_mino_eating;
extern UIImage *img_mino_eating_drops;
extern UIImage *img_thes_shadow;
extern UIImage *img_mino_shadow;

extern UIImage *img_exit;

extern UIImage *img_shadow_top;
extern UIImage *img_shadow_bottom;
extern UIImage *img_shadow_right;
extern UIImage *img_shadow_left;

extern UIImage *img_wall_top;
extern UIImage *img_wall_bottom;
extern UIImage *img_wall_right;
extern UIImage *img_wall_left;

extern UIImage *img_dpad[2][2][9];

extern UIImage *img_nav_bk;
extern UIImage *img_dun_bk;
extern UIImage *img_howto_bk;
extern UIImage *img_howto_con;
extern UIImage *img_game_menu_bk;
extern UIImage *img_main_menu_bk;

extern UIImage *img_button_wait;
extern UIImage *img_button_wait_dn;

extern UIImage *img_undo_enabled;
extern UIImage *img_undo_enabled_dn;
extern UIImage *img_undo_disabled;
extern UIImage *img_redo_enabled;
extern UIImage *img_redo_enabled_dn;
extern UIImage *img_redo_disabled;

extern UIImage *img_close_button;
extern UIImage *img_close_button_dn;
extern UIImage *img_reload;

extern UIImage *img_badges[3];

void InitImgs();
void CycleTheseusImg();
int GetCurrentTheseusImg();
void SetCurrentTheseusImg(int t);
