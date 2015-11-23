
#import "DCSideMenuViewController.h"
#import "DCSideMenuCell.h"
#import "DCBaseViewController.h"
#import "DCAppFacade.h"
#import "DCSideMenuType.h"
#import "DCMenuStoryboardHelper.h"
#import "DCProgramViewController.h"
#import "UIConstants.h"
#import "DCLimitedNavigationController.h"
#import "DCDayEventsController.h"
#import "DCAppConfiguration.h"
#import "UIImage+Extension.h"
#import "DCAppSignMenuCell.h"

@class DCEvent;

@interface DCSideMenuViewController ()

@property(nonatomic, weak) IBOutlet UITableView* tableView;
@property(nonatomic, weak) IBOutlet UIImageView* backgroundImageView;

@property(nonatomic, strong) NSArray* arrayOfCaptions;
@property(nonatomic, strong) NSIndexPath* activeCellPath;
@property(nonatomic, strong) DCEvent* event;

@end

@implementation DCSideMenuViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.arrayOfCaptions = [DCAppConfiguration appMenuItems];
  self.backgroundImageView.image = [UIImage imageNamed:@"menu_bg"];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(menuStateDidChange:)
             name:MFSideMenuStateNotificationEvent
           object:nil];

  // our first menu item is Program, this is actually the screen that we should
  // see right after the login page, thats why lets just add it on top as if the
  // user alerady selected it

  self.activeCellPath =
      [NSIndexPath indexPathForRow:DCMENU_PROGRAM_ITEM inSection:0];
  [self tableView:self.tableView didSelectRowAtIndexPath:self.activeCellPath];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.event) {
    NSDictionary* menuItem = self.arrayOfCaptions.firstObject;
    [self showViewControllerAssociatedWithMenuItem:menuItem];

    UINavigationController* navCon =
        self.sideMenuContainer.centerViewController;
    if ([navCon isKindOfClass:[UINavigationController class]]) {
      DCProgramViewController* programController =
          (DCProgramViewController*)navCon.topViewController;
      if ([programController
              respondsToSelector:@selector(openDetailScreenForEvent:)]) {
        [programController openDetailScreenForEvent:self.event];
        self.event = nil;
      }
    }
  }
}

#pragma mark - Private

- (void)menuStateDidChange:(NSNotification*)notification {
  NSDictionary* dict = [notification userInfo];
  MFSideMenuStateEvent eventType =
      (MFSideMenuStateEvent)[dict[@"eventType"] integerValue];

  if (eventType == MFSideMenuStateEventMenuDidClose)
    [self.sideMenuContainer
            .leftMenuViewController setNeedsStatusBarAppearanceUpdate];
  else if (eventType == MFSideMenuStateEventMenuDidOpen)
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)showViewControllerAssociatedWithMenuItem:(NSDictionary*)menuItemInfo {
  DCMenuSection menuSection = [menuItemInfo[kMenuType] intValue];
  NSString* viewControllerId = menuItemInfo[kMenuItemControllerId];

  NSAssert(viewControllerId.length,
           @"No Storyboard ID for Menu item view controller");

  DCBaseViewController* rootMenuVC =
      [self viewControllerFromMenuItem:menuSection
                       andControllerId:viewControllerId];
  UINavigationController* navigationController =
      [[UINavigationController alloc] initWithRootViewController:rootMenuVC];

  // disable swipe-to-Back gesture
  if ([navigationController
          respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    navigationController.interactivePopGestureRecognizer.enabled = NO;
  }

  [self arrangeNavigationBarForController:rootMenuVC
                                 menuItem:menuSection
                                 andTitle:menuItemInfo[kMenuItemTitle]];

  self.sideMenuContainer.centerViewController = navigationController;
  [self.sideMenuContainer setMenuState:MFSideMenuStateClosed completion:nil];
}

- (void)arrangeNavigationBarForController:(DCBaseViewController*)aController
                                 menuItem:(DCMenuSection)menuItem
                                 andTitle:(NSString*)title {
  // add proper Title

  aController.navigationItem.title = title;

  // add left Menu button to all Controllers
  UIImage* image = (menuItem == DCMENU_INFO_ITEM)
                       ? [UIImage imageNamedFromBundle:@"menu-icon-dark"]
                       : [UIImage imageNamedFromBundle:@"menu-icon"];
  UIButton* button = [[UIButton alloc]
      initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
  [button setBackgroundImage:image forState:UIControlStateNormal];
  [button addTarget:self
                action:@selector(leftSideMenuButtonPressed:)
      forControlEvents:UIControlEventTouchUpInside];
  aController.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)openEventFromFavorite:(DCEvent*)event {
  self.event = event;
}

#pragma mark - User actions

- (void)leftSideMenuButtonPressed:(id)sender {
  [self.sideMenuContainer toggleLeftSideMenuCompletion:nil];
}

- (DCBaseViewController*)viewControllerFromMenuItem:(DCMenuSection)menuItem
                                    andControllerId:(NSString*)controllerId {
  NSString* storyboardName = [self storyboardNameForMenuItem:menuItem];
  UIStoryboard* storyboard =
      [UIStoryboard storyboardWithName:storyboardName bundle:nil];

  DCBaseViewController* viewController =
      [storyboard instantiateViewControllerWithIdentifier:controllerId];

  if ([viewController isKindOfClass:[DCProgramViewController class]]) {
    [(DCProgramViewController*)viewController
        setEventsStrategy:[DCMenuStoryboardHelper
                              strategyForEventMenuType:menuItem]];
  }

  return viewController;
}
- (NSString*)storyboardNameForMenuItem:(DCMenuSection)menuSection {
  //   This functionlity return storyboard for appropriate menu items
  NSString* defaultStoryboardName = @"Main";

  switch (menuSection) {
    case DCMENU_MYSCHEDULE_ITEM:
    case DCMENU_SOCIAL_EVENTS_ITEM:
    case DCMENU_BOFS_ITEM:
    case DCMENU_PROGRAM_ITEM:
      defaultStoryboardName = @"Events";
      break;

    case DCMENU_SPEAKERS_ITEM:
      defaultStoryboardName = @"Speakers";
      break;

    case DCMENU_INFO_ITEM:
      defaultStoryboardName = @"Info";
      break;

    default:
      break;
  }
  return defaultStoryboardName;
}

- (BOOL)isLastMenuItemAtIndexPath:(NSIndexPath*)indexPath {
  return [self.arrayOfCaptions count] - 1 == indexPath.row;
}

#pragma mark - UITableView delegate

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  NSString* cellIdentifier = @"SideMenuCellIdentifier";
  if ([self isLastMenuItemAtIndexPath:indexPath]) {
    DCAppSignMenuCell* cell =
        [tableView dequeueReusableCellWithIdentifier:@"DCAppSignMenuCell"];
    cell.dateLabel.text = [DCAppConfiguration eventTime];
    cell.placeLabel.text = [DCAppConfiguration eventPlace];
    return cell;
  }
  DCSideMenuCell* cell = (DCSideMenuCell*)
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  NSDictionary* itemDict = self.arrayOfCaptions[indexPath.row];
  cell.captionLabel.text = itemDict[kMenuItemTitle];

  BOOL isActiveCell = indexPath.row == self.activeCellPath.row;
  cell.leftImageView.image = [UIImage
      imageNamedFromBundle:itemDict[isActiveCell ? kMenuItemSelectedIcon
                                                 : kMenuItemIcon]];

  UIFontDescriptor* fontDescriptor = [cell.captionLabel.font.fontDescriptor
      fontDescriptorWithSymbolicTraits:isActiveCell ? UIFontDescriptorTraitBold
                                                    : 0];
  cell.captionLabel.font = [UIFont fontWithDescriptor:fontDescriptor size:0];

  return cell;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  // Change cells view to display Selection
  DCSideMenuCell* lastSelected =
      (DCSideMenuCell*)[tableView cellForRowAtIndexPath:self.activeCellPath];
  DCSideMenuCell* newSelected =
      (DCSideMenuCell*)[tableView cellForRowAtIndexPath:indexPath];

  lastSelected.leftImageView.image =
      [UIImage imageNamedFromBundle:[self.arrayOfCaptions
                                        objectAtIndex:self.activeCellPath
                                                          .row][kMenuItemIcon]];

  UIFontDescriptor* regularFontDescriptor =
      [lastSelected.captionLabel.font.fontDescriptor
          fontDescriptorWithSymbolicTraits:0];
  lastSelected.captionLabel.font =
      [UIFont fontWithDescriptor:regularFontDescriptor size:0];

  newSelected.leftImageView.image = [UIImage
      imageNamedFromBundle:[self.arrayOfCaptions objectAtIndex:indexPath.row]
                               [kMenuItemSelectedIcon]];

  UIFontDescriptor* boldFontDescriptor =
      [newSelected.captionLabel.font.fontDescriptor
          fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
  newSelected.captionLabel.font =
      [UIFont fontWithDescriptor:boldFontDescriptor size:0];

  self.activeCellPath = indexPath;

  NSDictionary* menuItem = self.arrayOfCaptions[indexPath.row];
  [self showViewControllerAssociatedWithMenuItem:menuItem];
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.arrayOfCaptions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return 1;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  if ([self isLastMenuItemAtIndexPath:indexPath])
    return [self heightForLastItem];
  return (indexPath.row % 3 == 2) ? 65 : 50;
}

#define IS_OS_8_OR_LATER \
  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5                                                       \
  (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) &&  \
   ((IS_OS_8_OR_LATER &&                                                  \
     [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || \
    !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6                                           \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && \
   IS_OS_8_OR_LATER &&                                                 \
   [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

- (CGFloat)heightForLastItem {
  int offsetHeight = 0;
  // Always show in bottom
  if (self.arrayOfCaptions.count < DCMENU_SIZE) {
    offsetHeight = (int)(DCMENU_SIZE - self.arrayOfCaptions.count + 1) * 65;
  }
  // Is iphone 5,6
  if (IS_IPHONE_5) {
    return 135 + offsetHeight;
  } else if (IS_STANDARD_IPHONE_6)
    return 240 + offsetHeight;
  else if (IS_STANDARD_IPHONE_6_PLUS)
    return 300 + offsetHeight;
  else
    return 80 + offsetHeight;
}

@end
