//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
