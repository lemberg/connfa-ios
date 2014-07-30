//
//  DCMenuStoryboardHelper.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCMenuStoryboardHelper.h"

@implementation DCMenuStoryboardHelper
+(NSString*) viewControllerStoryboardIDFromMenuType: (DCMenuSection) menu {
    
    NSString *storyboardControllerID = @"";
    
    if(menu == DCMENU_PROGRAM_ITEM)
        storyboardControllerID = @"ProgramViewController";
    
    if(menu == DCMENU_SPEAKERS_ITEM)
        storyboardControllerID = @"SpeakersViewController";
    
    
    if(menu == DCMENU_LOCATION_ITEM) {
        
    }
    if(menu == DCMENU_ABOUT_ITEM) {
        
    }
    if(menu == DCMENU_MYSCHEDULE_ITEM) {
        
    }
    
    return storyboardControllerID;
}
@end
