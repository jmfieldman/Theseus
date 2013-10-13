//
//  MainMenuViewController.m
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MapGenerator.h"
#import "MapModel.h"
#import "LevelSelectTableCell.h"
#import "GameStateModel.h"
#import "FlourishController.h"
#import "SoundManager.h"

static MainMenuViewController* shared_instance = nil;

@implementation MainMenuViewController

+ (MainMenuViewController*) sharedInstance {
	if (!shared_instance) {
		shared_instance = [[MainMenuViewController alloc] init];
	}
	return shared_instance;
}

- (id) init {
	if (self = [super init]) {
		flourished_in = NO;
		
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].applicationFrame.size.height)];
		contentView.backgroundColor = [UIColor whiteColor];
		self.view = contentView;
		[contentView release];
		
		/* Table stuff */
		
		table_levels = [[UITableView alloc] initWithFrame:CGRectMake(0,kMenuHeaderHeight-10,320,contentView.frame.size.height - (kMenuHeaderHeight-10))];
		table_levels.delegate = self;
		table_levels.dataSource = self;
		table_levels.backgroundColor = [UIColor clearColor];
		table_levels.separatorStyle = UITableViewCellSeparatorStyleNone;
		table_levels.showsVerticalScrollIndicator = NO;
		table_levels.userInteractionEnabled = NO;
		table_levels.contentOffset = CGPointMake(0,[GameStateModel getLevelTableOffset]);
		[contentView addSubview:table_levels];
		[table_levels release];
				
		array_levels = [[NSMutableArray alloc] initWithCapacity:(NUM_LEVELS+10)];
		for (int lev = 0; lev < NUM_LEVELS; lev++) {
			LevelSelectTableCell *cell = [[LevelSelectTableCell alloc] initWithLevel:lev];
			[array_levels insertObject:cell atIndex:lev];
			[cell release];
		}		
		[table_levels reloadData];
		
		/* Make the header view */
		
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -(kMenuHeaderHeight+20), contentView.frame.size.width, kMenuHeaderHeight)];
		[contentView addSubview:headerView];
		[headerView release];
		
		UIImageView *header_img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_header.png"]];
		header_img.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
		[headerView addSubview:header_img];
		[header_img release];
		
		UILabel *label_table = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 20)];
		UILabel *label_subtx = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 250, 20)];
		label_table.text = JFLocalizedString(@"TitleText", @"Theseus and the Minotaur");
		label_subtx.text = JFLocalizedString(@"LevelSelection", @"Level Selection");
		label_table.textAlignment = label_subtx.textAlignment = UITextAlignmentRight;		
		label_table.backgroundColor = label_subtx.backgroundColor = [UIColor clearColor];
		label_table.font = label_subtx.font = [UIFont fontWithName:@"Trebuchet MS" size:14];
		[headerView addSubview:label_table]; [label_table release];
		[headerView addSubview:label_subtx]; [label_subtx release];
		
		info_button = [UIButton buttonWithType:UIButtonTypeCustom];
		info_button.frame = CGRectMake(256, 5, 50, 50);
		[info_button setImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateNormal];
		info_button.adjustsImageWhenHighlighted = NO;
		[info_button addTarget:self action:@selector(_handleInfoButton:) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:info_button];
		
		/* Done making the header */
	
		/* Credits */
		cred_view = [[CreditsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		cred_view.hidden = YES;
		[contentView addSubview:cred_view];
		[cred_view release];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	/* Deselect the table */
	NSIndexPath *p = [table_levels indexPathForSelectedRow];
	if (p) {
		[table_levels deselectRowAtIndexPath:p animated:NO];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[array_levels release];
    [super dealloc];
}

- (void)_handleInfoButton:(id)sender {
	[cred_view appear:YES];
}

- (void)handleFlourishInTimer:(NSTimer*)timer {
	table_levels.userInteractionEnabled = YES;
}

- (void)handleFlourishOutTimer:(NSTimer*)timer {
	NSIndexPath *p = [table_levels indexPathForSelectedRow];
	[[FlourishController sharedInstance] transitionToDungeon:[p row]];
}

- (void)flourishIn {
	if (flourished_in) return;
	flourished_in = YES;
	
	/* Bring in the header */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kHeaderPopDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGPoint p = headerView.center;
	p.y += (kMenuHeaderHeight+20);
	headerView.center = p;
	[UIView commitAnimations];
	
	/* Make sure all cells are visible */
	for (int i = ([array_levels count] - 1); i >= 0; i--) {
		UITableViewCell *c = [array_levels objectAtIndex:i];
		c.alpha = 1;
	}
	
	/* Fade in the level options */
	NSArray *visCel = [table_levels visibleCells];
	float cur_del = 0;
	for (int i = ([visCel count] - 1); i >= 0; i--) {
		UITableViewCell *cell = [visCel objectAtIndex:i];
		cell.alpha = 0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCellAlphaDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelay:cur_del];
		cell.alpha = 1;
		[UIView commitAnimations];
		cur_del += kCellAlphaStagger;		
	}

	START_TIMER( cur_del, handleFlourishInTimer:, NO);
}

- (void)flourishOut {
	if (!flourished_in) return;
	flourished_in = NO;
	
	table_levels.userInteractionEnabled = NO;
	
	/* Push out the header */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kHeaderPopDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGPoint p = headerView.center;
	p.y -= (kMenuHeaderHeight+20);
	headerView.center = p;
	[UIView commitAnimations];
	
	/* Fade out the level options */
	NSArray *visCel = [table_levels visibleCells];
	float cur_del = 0;
	for (int i = 0; i < [visCel count]; i++) {
		UITableViewCell *cell = [visCel objectAtIndex:i];		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCellAlphaDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelay:cur_del];
		cell.alpha = 0;
		[UIView commitAnimations];
		cur_del += kCellAlphaStagger;		
	}
	
	START_TIMER( (cur_del+kCellAlphaDuration) , handleFlourishOutTimer:, NO);
}

- (void)updateCellForLevel:(int)level {
	LevelSelectTableCell *c = [array_levels objectAtIndex:level];
	[c updateDisplay];
}

/* Updates the global position of the table */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[GameStateModel setLevelTableOffset:scrollView.contentOffset.y];
}

/* -------------------------- TABLE DELEGATE METHODS ----------------------- */

// decide what kind of accesory view (to the far right) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}

// Push the details view controller when a contract is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSInteger row = [indexPath row];
	//DungeonViewController *dvc = GetDungeonViewController();
	
	//[[self navigationController] pushViewController:dvc animated:YES];
	//[dvc initializeForLevel:row];
	[SoundManager playSound:SND_VAULT];
	[self flourishOut];
}

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [array_levels count];
}

// utility routine leveraged by 'cellForRowAtIndexPath' to determine which UITableViewCell to be used on a given row
//
- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row
{
	UITableViewCell *cell = [array_levels objectAtIndex:row];
	
	return cell;	
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	UITableViewCell *sourceCell = [self obtainTableCellForRow:row];
    return sourceCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kLevelSelectTableCellHeight;
}



@end
