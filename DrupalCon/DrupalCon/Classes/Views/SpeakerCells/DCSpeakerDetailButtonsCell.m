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
        self.webButtonLeftPadding.constant = 3;
        self.webButtonWidth.constant = 0;
    }
    
    if (!speaker.twitterName.length)
    {
        self.twitterButton.hidden = YES;
    }
    
        // if there is no description below, remove bottom padding
    if (speaker.characteristic.length)
    {
        self.webButtonBottomPadding.constant = 0;
    }
}

@end
