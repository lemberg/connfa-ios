
#import "DCLoginViewController.h"
#import "DCSideMenuViewController.h"
#import "MFSideMenu.h"
#import "DCAppFacade.h"
#import "DCMainProxy.h"

#define isiPhone5 \
  ([[UIScreen mainScreen] bounds].size.height == 568) ? TRUE : FALSE

#define CONTENT_HEIGHT_568 800
#define CONTENT_HEIGHT 650

@interface DCLoginViewController ()
@property(nonatomic, weak) IBOutlet NSLayoutConstraint* contentHeightContraint;
@property(nonatomic, weak)
    IBOutlet NSLayoutConstraint* imageLockTopSpaceContraint;
@property(nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property(nonatomic, weak) IBOutlet UITextField* loginTextField;
@property(nonatomic, weak) IBOutlet UITextField* passwordTextField;

@property(nonatomic, weak) IBOutlet UIImageView* lockImageView;
@end

@implementation DCLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.scrollView setDelaysContentTouches:NO];

  [self registerForKeyboardNotifications];

  if (!isiPhone5)
    self.imageLockTopSpaceContraint.constant = 40;
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWasShown:)
             name:UIKeyboardDidShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillBeHidden:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)deregisterForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardDidShowNotification
              object:self];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillHideNotification
              object:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Login Screen is not actual for now!! But on this point we have a triger for
  // initial loading screen;

  if ([DCMainProxy sharedProxy].state == DCMainProxyStateInitDataLoading) {
    [self performSegueWithIdentifier:@"toFirstLoading" sender:self];
  } else {
    [[DCAppFacade shared].mainNavigationController goToSideMenuContainer:nil];
  }
  return;
}

- (IBAction)loginButtonCLicked:(id)sender {
  [[DCAppFacade shared].mainNavigationController goToSideMenuContainer:sender];
}

#pragma mark text fields delegate

- (BOOL)textFieldShouldClear:(UITextField*)textField {
  return YES;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
  if (isiPhone5)
    self.contentHeightContraint.constant = CONTENT_HEIGHT_568;
  else
    self.contentHeightContraint.constant = CONTENT_HEIGHT;
  [self.view layoutIfNeeded];

  if (isiPhone5)
    [self.scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
  else
    [self.scrollView setContentOffset:CGPointMake(0, 190) animated:YES];

  [self performSelector:@selector(hideLockImageView)
             withObject:self
             afterDelay:0.3];
}

- (void)hideLockImageView {
  [UIView animateWithDuration:0.3
      delay:0.0
      options:UIViewAnimationOptionCurveEaseIn
      animations:^{
        self.lockImageView.alpha = 0.0;

      }
      completion:^(BOOL finished){
      }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
  self.contentHeightContraint.constant =
      [[UIScreen mainScreen] bounds].size.height;
  [UIView animateWithDuration:0.3
      delay:0.0
      options:UIViewAnimationOptionCurveEaseIn
      animations:^{
        [self.view layoutIfNeeded];

      }
      completion:^(BOOL finished) {
        self.lockImageView.alpha = 1.0;
      }];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
  if (textField == self.loginTextField) {
    [self.passwordTextField becomeFirstResponder];
  }
  if (textField == self.passwordTextField) {
    [self.passwordTextField resignFirstResponder];
    [self loginButtonCLicked:nil];
  }

  return YES;
}

@end
