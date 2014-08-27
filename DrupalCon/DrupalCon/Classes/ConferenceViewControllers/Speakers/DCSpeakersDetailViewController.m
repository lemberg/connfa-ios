//
//  DCSpeakersDetailViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakersDetailViewController.h"
#import "DCSpeaker+DC.h"

#import "DCSpeakerBottomCell.h"
#import "DCSpeakerHeaderCell.h"

@interface DCSpeakersDetailViewController ()

@property (nonatomic, strong) NSArray * events;
@property (nonatomic, weak) IBOutlet UITableView * speakerDetailTbl;

@end

@implementation DCSpeakersDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleTransparrent;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.navigationController)
    {
        
    }
    else
    {
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 60, 64)];
        [backButton setExclusiveTouch:YES];
//        [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [backButton setTitle:@"⟨ Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:backButton];
        
        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        [titleLbl setTextAlignment:NSTextAlignmentCenter];
        [titleLbl setTextColor:[UIColor whiteColor]];
        [titleLbl setText:@"Profile"];
        [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]];
        [self.view addSubview:titleLbl];
        
        [_speakerDetailTbl setFrame:CGRectMake(0, 44, 320, self.view.bounds.size.height-44)];
    }    
}

-(void)onBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate/DataSourse methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _events.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return [DCSpeakerHeaderCell cellHeight];
    
    else if ([self isLastRow:indexPath.row])
        return [DCSpeakerBottomCell cellHeightForText:_speaker.characteristic];
    
    else
        return 0.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdHeader = @"SpeakerCellIdHeader";
    NSString *cellIdBottom = @"SpeakerCellIdBottom";
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        DCSpeakerHeaderCell *_cell = (DCSpeakerHeaderCell*)[tableView dequeueReusableCellWithIdentifier: cellIdHeader];
        [_cell.pictureImg setImage:[UIImage imageNamed:@"avatar_test_image"]];
        [_cell.nameLbl setText:_speaker.name];
        [_cell.organizationLbl setText:_speaker.organizationName];
        [_cell.jobTitleLbl setText:_speaker.jobTitle];
        cell = _cell;
    }
    
    else if ([self isLastRow:indexPath.row])
    {
        DCSpeakerBottomCell * _cell = (DCSpeakerBottomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdBottom];
        [_cell.characteristicTxt setText:_speaker.characteristic];
        cell = _cell;
    }
    
    else
    {
        cell = nil;
    }

    return cell;
}

#pragma mark - 

- (BOOL)isLastRow:(NSInteger)row
{
    return (row == _events.count + 1);
}

@end
