//
//  DCMenuStoryboardHelper.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMenuStoryboardHelper.h"

@implementation DCMenuStoryboardHelper
+(NSString*) viewControllerStoryboardIDFromMenuType: (DCMenuSection) menu {
    
    NSString *storyboardControllerID = nil;
    
    if(menu == DCMENU_PROGRAM_ITEM)
        storyboardControllerID = @"ProgramViewController";
    
    if (menu == DCMENU_BOFS_ITEM)
        storyboardControllerID = @"ProgramViewController";
    
    if(menu == DCMENU_SPEAKERS_ITEM)
        storyboardControllerID = @"SpeakersViewController";
    
    
    if(menu == DCMENU_LOCATION_ITEM) {
        storyboardControllerID = @"LocationViewController";
    }
    if(menu == DCMENU_ABOUT_ITEM) {
        storyboardControllerID = @"AboutViewController";
        
    }
    if(menu == DCMENU_MYSCHEDULE_ITEM) {
        storyboardControllerID = @"FavoritesViewController";
    }
    
    return storyboardControllerID;
}

+(NSString*) titleForMenuType: (DCMenuSection) menu {
    NSString *title = nil;
    
    if(menu == DCMENU_PROGRAM_ITEM)
        title = @"Programs";
    
    if (menu == DCMENU_BOFS_ITEM)
        title = @"BoFs";
    
    if(menu == DCMENU_SPEAKERS_ITEM)
        title = @"Speakers";
    
    if(menu == DCMENU_LOCATION_ITEM)
        title = @"Locations";
    
    if(menu == DCMENU_ABOUT_ITEM)
        title = @"About";
    
    if(menu == DCMENU_MYSCHEDULE_ITEM)
        title = @"My Schedule";
    
    
    return title;
}

@end
