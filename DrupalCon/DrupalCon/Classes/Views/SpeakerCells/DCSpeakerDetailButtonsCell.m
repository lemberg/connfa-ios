//
//  DCSpeakerDetailButtonsCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/18/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCSpeakerDetailButtonsCell.h"

@implementation DCSpeakerDetailButtonsCell


- (void) initData:(DCSpeaker*)speaker
{
    // hide unused buttons
    if (!speaker.webSite.length)
    {
        self.webButtonLeftPadding.constant = 8;
        self.webButtonWidth.constant = 0;
    }
    
    if (!speaker.twitterName.length)
    {
        self.twitterButton.hidden = YES;
    }
    
        // no buttons, self becomes invisible
    if (!speaker.webSite.length && !speaker.twitterName.length)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
        return;
    }
}

@end
