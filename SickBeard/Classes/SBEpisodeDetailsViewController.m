//
//  SBEpisodeDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisodeDetailsViewController.h"
#import "SBEpisode.h"
#import "SBShow.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "ATMHud.h"

@interface SBEpisodeDetailsViewController ()
@property (nonatomic, retain) ATMHud *hud;
@end

@implementation SBEpisodeDetailsViewController

@synthesize titleLabel;
@synthesize airDateLabel;
@synthesize seasonLabel;
@synthesize descriptionLabel;
@synthesize episode;
@synthesize hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions
- (IBAction)episodeAction:(id)sender {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													 otherButtonTitles:@"Search", @"Set Status", nil] autorelease];
	actionSheet.tag = 998;
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)searchForEpisode {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];

	[hud setCaption:@"Searching for episode..."];
	[hud setActivity:YES];
	[hud show];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(id JSON) {
											  NSString *result = [[JSON objectForKey:@"result"] lowercaseString];
											  
											  [hud setActivity:NO];
											  
											  if ([result isEqualToString:@"failure"]) {
												  [hud setCaption:[JSON objectForKey:@"error"]];
												  [hud update];
												  [hud hideAfter:2];
											  }
											  else {
												  [hud setCaption:@"Episode found and is downloading."];
												  [hud setImage:[UIImage imageNamed:@"19-check"]];
												  [hud update];
												  [hud hideAfter:2];
											  }
										  }
										  failure:^(NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
										  }];
}

- (void)showEpisodeStatusActionSheet {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"" 
															  delegate:self 
													 cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Wanted", @"Skipped", @"Archived", @"Ignored", nil] autorelease];
	actionSheet.tag = 999;
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)performSetEpisodeStatus:(EpisodeStatus)status {
	NSString *statusString = [SBEpisode episodeStatusAsString:status];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode",
							statusString, @"status", nil];
	
	[hud setCaption:[NSString stringWithFormat:@"Setting episode status to %@", statusString]];
	[hud setActivity:YES];
	[hud show];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  NSString *error = [JSON objectForKey:@"error"];
																 
											  [hud setActivity:NO];
											  
											  if (result && !error) {
												  [hud setCaption:result];
												  [hud setImage:[UIImage imageNamed:@"19-check"]];
											  }
											  else {
												  [hud setCaption:error];
												  [hud setImage:[UIImage imageNamed:@"11-x"]];
											  }
												   
											  [hud update];
											  [hud hideAfter:2];
										  }
										  failure:^(NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
										  }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 998) {
		if (buttonIndex == 0) {
			[self searchForEpisode];
		}
		else if (buttonIndex == 1) {
			[self showEpisodeStatusActionSheet];
		}
	}
	else {
		if (buttonIndex < 4) {
			[self performSetEpisodeStatus:buttonIndex];
		}
	}
}	


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	self.title = @"Details";

	self.hud = [[[ATMHud alloc] init] autorelease];
	[self.view addSubview:self.hud.view];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisode 
									   parameters:params
										  success:^(id JSON) {
											  episode.episodeDescription = [JSON objectForKey:@"description"];
											  
											  self.titleLabel.text = episode.name;
											  self.airDateLabel.text = [NSString stringWithFormat:@"Aired on %@", episode.airDate];
											  self.seasonLabel.text = [NSString stringWithFormat:@"Season %d, episode %d", episode.season, episode.number];
											  self.descriptionLabel.text = episode.episodeDescription;
										  }
										  failure:^(NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
										  }];

	
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setAirDateLabel:nil];
    [self setSeasonLabel:nil];
    [self setDescriptionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [titleLabel release];
    [airDateLabel release];
    [seasonLabel release];
    [descriptionLabel release];
    [super dealloc];
}
@end
