//
//  DCMyScheduleInstructionViewController.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCMyScheduleInstructionViewController.h"

@interface DCMyScheduleInstructionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageVIew;

@end

@implementation DCMyScheduleInstructionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UITapGestureRecognizer *singleFingerTap =
  [[UITapGestureRecognizer alloc] initWithTarget:self
                                          action:@selector(dismissSelf)];
  [self.view addGestureRecognizer:singleFingerTap];
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self setNeedsStatusBarAppearanceUpdate];
}

-(void)dismissSelf{
  [self dismissViewControllerAnimated:true completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
