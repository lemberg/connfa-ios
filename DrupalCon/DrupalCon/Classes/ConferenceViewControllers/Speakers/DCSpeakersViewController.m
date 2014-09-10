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
    _speakers = [[DCMainProxy sharedProxy] speakerInstances];
    [_speakersTbl reloadData];
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
    UITableViewCell *cell;
    DCSpeakerCell *_cell = (DCSpeakerCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeaker];
    
    DCSpeaker * speaker = _speakers[indexPath.row];
    
    [_cell.nameLbl setText:speaker.name];
    [_cell.positionTitleLbl setText:speaker.jobTitle];
    [_cell.pictureImg sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
                        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [_cell setNeedsDisplay];
                                   });
                                   
                               }];
    cell = _cell;
    return _cell;
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
