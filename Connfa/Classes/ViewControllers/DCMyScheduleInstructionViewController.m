//
//  DCMyScheduleInstructionViewController.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCMyScheduleInstructionViewController.h"
#import "DCDeviceType.h"

@interface DCMyScheduleInstructionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *moreActionsImage;

@end

@implementation DCMyScheduleInstructionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UITapGestureRecognizer *singleFingerTap =
  [[UITapGestureRecognizer alloc] initWithTarget:self
                                          action:@selector(dismissSelf)];
  [self.view addGestureRecognizer:singleFingerTap];
  [self setTutorialImage];
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
}

-(void)dismissSelf{
  [self dismissViewControllerAnimated:true completion:nil];
}

-(void)setTutorialImage{
  self.moreActionsImage.image = [[UIImage imageNamed:@"More Actions Button_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.moreActionsImage.tintColor = [DCAppConfiguration navigationBarColor];
  if([DCDeviceType isIphone5]){
    [self setTutorialImageNamed:@"tutorial_iphone_5"];
  }else if([DCDeviceType isIphone7]){
    [self setTutorialImageNamed:@"tutorial_iphone_7"];
  }else if ([DCDeviceType isIphone7plus]){
    [self setTutorialImageNamed:@"tutorial_iphone_7_plus"];
  }
}

-(void)setTutorialImageNamed:(NSString *)name{
  //TODO: change image rendering mode
  UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tutorialImageVIew.image = image;
  self.tutorialImageVIew.tintColor = [DCAppConfiguration navigationBarColor];
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
