//
//  SBEpisodesViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"

@class OrderedDictionary;

@interface SBEpisodesViewController : SBBaseTableViewController {
	OrderedDictionary *comingEpisodes;
}

@end