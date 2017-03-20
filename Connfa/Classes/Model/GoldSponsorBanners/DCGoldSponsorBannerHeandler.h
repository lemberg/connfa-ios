//
//  DCGoldSponsorBannerHeandler.h
//  DrupalCon
//
//  Created by Roman Malinovskyi on 1/23/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCGoldSponsorBannerHeandler : NSObject
+ (id)sharedManager;
- (void)makeRandomGoldenSponsor;
- (NSString *)getSponsorBannerName;
@end
