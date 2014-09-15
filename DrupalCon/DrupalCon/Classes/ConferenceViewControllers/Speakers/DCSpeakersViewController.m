//
//  DCSpeakersViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakersViewController.h"
#import "AppDelegate.h"
#import "DCSpeakersDetailViewController.h"
#import "DCSpeakerCell.h"
#import "DCMainProxy+Additions.h"
#import "DCSpeaker+DC.h"
#import "UIImageView+WebCache.h"

@interface DCSpeakersViewController ()

@property (nonatomic, weak) IBOutlet UITableView * speakersTbl;

@end

@implementation DCSpeakersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _speakers = [self orderByLastName:[[DCMainProxy sharedProxy] speakerInstances]];
    [_speakersTbl reloadData];
}

- (NSArray *)orderByLastName:(NSArray *)array
{
     NSSortDescriptor *sortLastName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
         NSString *lastName1 = (NSString *)obj1;
         NSString *lastName2 = (NSString *)obj2;
         if ([lastName1 length] == 0 && [lastName2 length] == 0) {
             return NSOrderedSame;
         }
         if ([lastName1 length] == 0) {
             return NSOrderedDescending;
         }
         if ([lastName2 length] == 0) {
             return NSOrderedAscending;
         }

         
         return [lastName1 compare:lastName2 options:NSCaseInsensitiveSearch];
     }];
    return [array sortedArrayUsingDescriptors:@[sortLastName]];
}

#pragma mark - UITableView delegate/datasourse methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DCSpeakerCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _speakers.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdSpeaker = @"DetailCellIdentifierSpeaker";
    DCSpeakerCell *_cell = (DCSpeakerCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeaker];
    
    DCSpeaker * speaker = _speakers[indexPath.row];
    
    [_cell.nameLbl setText:speaker.name];
    
    [_cell.positionTitleLbl setText: [self positionTitleForSpeaker:speaker]];
    [_cell.pictureImg sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
                        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [_cell setNeedsDisplay];
                                   });
                               }];
    return _cell;
}

- (NSString *)positionTitleForSpeaker:(DCSpeaker *)speaker
{
    NSString *organisationName = speaker.organizationName;
    NSString *jobTitle = speaker.jobTitle;
    if ([jobTitle length] && [organisationName length]) {
        return [NSString stringWithFormat:@"%@ / %@", organisationName, jobTitle];
    }
    if (![jobTitle length]) {
        return organisationName;
    }
    
    return jobTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.speakersTbl reloadData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DCSpeakersDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
    [detailController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    detailController.speaker = _speakers[indexPath.row];
    [detailController didCloseWithCallback:^{
        [self.speakersTbl reloadData];
    }];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:detailController animated:YES completion:nil];

}


@end
