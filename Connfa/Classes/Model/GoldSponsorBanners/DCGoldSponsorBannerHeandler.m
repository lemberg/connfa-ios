//
//  DCGoldSponsorBannerHeandler.m
//  DrupalCon
//
//  Created by Roman Malinovskyi on 1/23/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCGoldSponsorBannerHeandler.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

static NSString* goldenSponsorKey = @"GoldSponsorHeaders";

@interface DCGoldSponsorBannerHeandler()
@property (copy, nonatomic) NSString *sponsorBannerName;
@end

@implementation DCGoldSponsorBannerHeandler


+ (id)sharedManager {
  static DCGoldSponsorBannerHeandler *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (void)makeRandomGoldenSponsor {
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistFileDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSArray *headerNames = [plistFileDictionary objectForKey:goldenSponsorKey];
    int randomIndex = arc4random_uniform((int)headerNames.count);
    NSString *headerName = [headerNames objectAtIndex:randomIndex];
    self.sponsorBannerName = headerName;
}

- (NSString *)getSponsorBannerName {
  return self.sponsorBannerName;
}

@end
