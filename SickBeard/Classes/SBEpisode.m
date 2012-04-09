//
//  SBEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisode.h"
#import "SBShow.h"
#import "NSDate+Utilities.h"

@implementation SBEpisode

@synthesize airDate;
@synthesize episodeDescription;
@synthesize location;
@synthesize name;
@synthesize status;
@synthesize season;
@synthesize number;
@synthesize show;

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		self.airDate = [NSDate dateWithString:[dict objectForKey:@"airdate"]];
		self.episodeDescription = [dict objectForKey:@"description"];
		self.location = [dict objectForKey:@"location"];
		self.name = [dict objectForKey:@"name"];
		
		NSString *statusString = [[dict objectForKey:@"status"] lowercaseString];
		if ([statusString isEqualToString:@"ignored"]) {
			self.status = EpisodeStatusIgnored;
		}
		else if ([statusString isEqualToString:@"skipped"]) {
			self.status = EpisodeStatusSkipped;
		}
		else if ([statusString isEqualToString:@"wanted"]) {
			self.status = EpisodeStatusWanted;
		}
		else if ([statusString isEqualToString:@"unaired"]) {
			self.status = EpisodeStatusUnaired;
		}
		else if ([statusString isEqualToString:@"archived"]) {
			self.status = EpisodeStatusArchived;
		}
		else if ([statusString isEqualToString:@"snatched"]) {
			self.status = EpisodeStatusSnatched;
		}
		else if ([statusString rangeOfString:@"downloaded"].location != NSNotFound) {
			self.status = EpisodeStatusDownloaded;
		}
		else {
			self.status = EpisodeStatusUnknown;
		}		
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (void)setEpisodeDescription:(NSString *)ed {
	if (ed.length == 0) {
		episodeDescription = NSLocalizedString(@"No episode description", @"No episode description");
	}
	else {
		episodeDescription = ed;
	}
}


- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | episode = S%dE%d>", [self class], self, name, season, number];
}

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status {
	switch (status) {
		case EpisodeStatusArchived:
			return NSLocalizedString(@"Archived", @"Archived");
			
		case EpisodeStatusDownloaded:
			return NSLocalizedString(@"Downloaded", @"Downloaded");
			
		case EpisodeStatusIgnored:
			return NSLocalizedString(@"Ignored", @"Ignored");
			
		case EpisodeStatusSkipped:
			return NSLocalizedString(@"Skipped", @"Skipped");
			
		case EpisodeStatusSnatched:
			return NSLocalizedString(@"Snatched", @"Snatched");
			
		case EpisodeStatusUnaired:
			return NSLocalizedString(@"Unaired", @"Unaired");
			
		case EpisodeStatusWanted:
			return NSLocalizedString(@"Wanted", @"Wanted");
			
		default:
			return NSLocalizedString(@"Unknown", @"Unknown");
	}
}


@end