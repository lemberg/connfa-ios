//
//  DCMenuImage.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMenuImage.h"

@implementation DCMenuImage

-(id) initWithMenuType: (DCMenuSection) menu {
    self = [super init];
    UIImage *image = nil;
    
    if (self) {
        if(menu == DCMENU_PROGRAM_ITEM)
            image = [UIImage imageNamed: @"ic_program"];
        if (menu == DCMENU_BOFS_ITEM)
            image = [UIImage imageNamed:@"ic_bofs"];
        if(menu == DCMENU_SPEAKERS_ITEM)
            image = [UIImage imageNamed: @"ic_speakers"];
        if(menu == DCMENU_LOCATION_ITEM)
            image = [UIImage imageNamed: @"ic_location"];
        if(menu == DCMENU_ABOUT_ITEM)
            image = [UIImage imageNamed: @"ic_about"];
        if(menu == DCMENU_MYSCHEDULE_ITEM)
            image = [UIImage imageNamed: @"ic_myschedule"];
    }
    
    self = (DCMenuImage*)[[UIImage alloc] initWithCGImage: image.CGImage];
    return self;
}

@end
