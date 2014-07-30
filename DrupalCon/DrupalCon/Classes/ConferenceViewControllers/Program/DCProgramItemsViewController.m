//
//  DCProgramItemsViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCProgramItemsViewController.h"
#import "DCProgramsDataSourceMananger.h"
#import "DCSpeechCell.h"
#import "DCSpeechOfDayCell.h"
#import "DCCofeeCell.h"
#import "DCLunchCell.h"
#import "DCEvent.h"

@interface DCProgramItemsViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tablewView;
@end

@implementation DCProgramItemsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    NSString *cellIdCoffeBreak = @"ProgramCellIdentifierCoffeBreak";
    NSString *cellIdLunch = @"ProgramCellIdentifierLunch";
    
    
    DCEvent *event = [[DCProgramsDataSourceMananger shared] eventForSection:indexPath.section row: indexPath.row inDay: self.pageIndex];
    
    UITableViewCell *cell;
    switch (event.eventType) {
        case DC_EVENT_SPEACH: {
            NSLog(@"CelId: %@", cellIdSpeech);
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            _cell.speakerLabel.text = event.speaker;
            _cell.experienceLevelLabel.text = event.experienceLevel;
            _cell.trackLabel.text = event.track;
            _cell.nameLabel.text = event.name;
            cell = _cell;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            NSLog(@"CelId: %@", cellIdSpeechOfDay);
            DCSpeechOfDayCell *_cell = (DCSpeechOfDayCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeechOfDay];
            _cell.speakerLabel.text = event.speaker;
            _cell.experienceLevelLabel.text = event.experienceLevel;
            _cell.trackLabel.text = event.track;
            _cell.nameLabel.text = event.name;
            cell = _cell;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            NSLog(@"CelId: %@", cellIdCoffeBreak);
            DCCofeeCell *_cell = (DCCofeeCell*)[tableView dequeueReusableCellWithIdentifier: cellIdCoffeBreak];
            _cell.startLabel.text = event.time.from;
            _cell.startLabel.text = event.time.to;
            cell = _cell;
            break;
        }
        case DC_EVENT_LUNCH: {
              NSLog(@"CelId: %@", cellIdLunch);
            DCLunchCell *_cell = (DCLunchCell*)[tableView dequeueReusableCellWithIdentifier: cellIdLunch];
            _cell.startLabel.text = event.time.from;
            _cell.startLabel.text = event.time.to;
            cell = _cell;
            break;
        }
        default:
            break;
    }
    
    
    //Selection style
    /*
     UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
     selectedBackgroundView.backgroundColor = [UIColor colorWithRed: 52./255. green: 52./255. blue: 59./255. alpha: 1.0];
     cell.selectedBackgroundView = selectedBackgroundView;
     */
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sections = [[DCProgramsDataSourceMananger shared]  sectionsInDay: self.pageIndex];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = [[DCProgramsDataSourceMananger shared] itemsInDay: self.pageIndex inSection:section];
    return rows;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCEvent *event = [[DCProgramsDataSourceMananger shared] eventForSection:indexPath.section row: indexPath.row inDay: self.pageIndex];
    
    switch (event.eventType) {
        case DC_EVENT_SPEACH: {
            return 97;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            return 97;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            return 94;
            break;
        }
        case DC_EVENT_LUNCH: {
            return 94;
            break;
        }
    }
    
    return 94;
}

-(void) dealloc {
    
}

@end
