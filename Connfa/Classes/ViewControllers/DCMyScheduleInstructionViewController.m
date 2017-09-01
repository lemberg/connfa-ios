//
//  DCMyScheduleInstructionViewController.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCMyScheduleInstructionViewController.h"
#import "UIImage+Extension.h"

@interface DCMyScheduleInstructionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageVIew;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation DCMyScheduleInstructionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupUI];
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
}

-(void)dismissSelf{
  [self dismissViewControllerAnimated:true completion:nil];
}

-(void)setTutorialImageNamed:(NSString *)name{
  UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.tutorialImageVIew.image = image;
  self.tutorialImageVIew.tintColor = [DCAppConfiguration navigationBarColor];
}

-(void)setupUI{
  self.okButton.layer.cornerRadius = 6.;
  self.okButton.layer.borderWidth = 1.;
  self.okButton.layer.borderColor = [UIColor whiteColor].CGColor;
  self.backgroundView.backgroundColor = [DCAppConfiguration navigationBarColor];
  UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
  [self.backgroundView addGestureRecognizer:gestureRecognizer];
}
- (IBAction)onOkButton:(id)sender {
  [self dismissSelf];
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
