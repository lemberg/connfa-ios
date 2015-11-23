
#import "DCSpeakersViewController.h"
#import "DCAppFacade.h"
#import "DCSpeakersDetailViewController.h"
#import "DCSpeakerCell.h"
#import "DCMainProxy+Additions.h"
#import "DCSpeaker+DC.h"
#import "UIImageView+WebCache.h"
#import "DCLimitedNavigationController.h"
#import "UIConstants.h"

@interface DCSpeakersViewController ()

@property(nonatomic, weak) IBOutlet UITableView* speakersTbl;
@property(nonatomic, weak) IBOutlet UILabel* noItemsLabel;

@property(nonatomic, strong) IBOutlet UISearchBar* searchBar;
@property(nonatomic, strong)
    NSFetchedResultsController* fetchedResultsController;

@end

@implementation DCSpeakersViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [[UITableView appearance]
      setSectionIndexBackgroundColor:[UIColor clearColor]];
  [[UITableView appearance]
      setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
  [[UITableView appearance]
      setSectionIndexColor:[DCAppConfiguration navigationBarColor]];

  [self.searchBar setTintColor:[UIColor whiteColor]];
  self.searchBar.barTintColor = [DCAppConfiguration navigationBarColor];
  self.searchBar.layer.borderWidth = 1;
  self.searchBar.layer.borderColor =
      [[DCAppConfiguration navigationBarColor] CGColor];
  [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
      setTintColor:[UIColor darkGrayColor]];

  [self reload];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar {
  [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar*)searchBar {
  [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
  [self reload];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar {
  [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar {
  [searchBar resignFirstResponder];
}

#pragma mark - UITableView delegate/datasourse methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return [self.fetchedResultsController sectionIndexTitles];
}

- (void)tableView:(UITableView*)tableView
    willDisplayHeaderView:(UIView*)view
               forSection:(NSInteger)section {
  view.tintColor = [UIColor colorWithRed:247.0 / 255.0
                                   green:247.0 / 255.0
                                    blue:247.0 / 255.0
                                   alpha:1.0];
}

- (NSInteger)tableView:(UITableView*)tableView
    sectionForSectionIndexTitle:(NSString*)title
                        atIndex:(NSInteger)index {
  return [self.fetchedResultsController sectionForSectionIndexTitle:title
                                                            atIndex:index];
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo =
      [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

- (NSString*)tableView:(UITableView*)tableView
    titleForHeaderInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo =
      [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo name];
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  static NSString* cellIdSpeaker = @"DetailCellIdentifierSpeaker";
  DCSpeakerCell* _cell = (DCSpeakerCell*)
      [tableView dequeueReusableCellWithIdentifier:cellIdSpeaker];

  DCSpeaker* speaker =
      [self.fetchedResultsController objectAtIndexPath:indexPath];

  [_cell.nameLbl setText:speaker.name];

  [_cell.positionTitleLbl setText:[self positionTitleForSpeaker:speaker]];
  [_cell.pictureImg
      sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
               completed:^(UIImage* image, NSError* error,
                           SDImageCacheType cacheType, NSURL* imageURL) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                   [_cell setNeedsDisplay];
                 });
               }];
  _cell.separator.hidden =
      (indexPath.row ==
       [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1);
  return _cell;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return [DCSpeakerCell cellHeight];
}

- (NSString*)positionTitleForSpeaker:(DCSpeaker*)speaker {
  NSString* organisationName = speaker.organizationName;
  NSString* jobTitle = speaker.jobTitle;
  if ([jobTitle length] && [organisationName length]) {
    return [NSString stringWithFormat:@"%@ / %@", organisationName, jobTitle];
  }
  if (![jobTitle length]) {
    return organisationName;
  }

  return jobTitle;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  DCSpeakersDetailViewController* detailController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
  detailController.speaker =
      [self.fetchedResultsController objectAtIndexPath:indexPath];

  DCLimitedNavigationController* navContainer =
      [[DCLimitedNavigationController alloc]
          initWithRootViewController:detailController
                          completion:^{
                            [self setNeedsStatusBarAppearanceUpdate];
                            [self.speakersTbl reloadData];
                          }];

  [[DCAppFacade shared]
          .mainNavigationController presentViewController:navContainer
                                                 animated:YES
                                               completion:nil];
}

- (NSSortDescriptor*)sortDescriptor {
  NSSortDescriptor* sortLastName = [NSSortDescriptor
      sortDescriptorWithKey:@"firstName"
                  ascending:YES
                 comparator:^NSComparisonResult(id obj1, id obj2) {
                   NSString* lastName1 = (NSString*)obj1;
                   NSString* lastName2 = (NSString*)obj2;
                   if ([lastName1 length] == 0 && [lastName2 length] == 0) {
                     return NSOrderedSame;
                   }
                   if ([lastName1 length] == 0) {
                     return NSOrderedDescending;
                   }
                   if ([lastName2 length] == 0) {
                     return NSOrderedAscending;
                   }

                   return [lastName1 compare:lastName2
                                     options:NSCaseInsensitiveSearch];
                 }];
  return sortLastName;
}

- (void)reload {
  NSFetchRequest* request =
      [NSFetchRequest fetchRequestWithEntityName:@"DCSpeaker"];
  NSSortDescriptor* sectionKeyDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES];
  NSSortDescriptor* firstNameDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
  NSSortDescriptor* lastNameDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];

  request.sortDescriptors =
      @[ sectionKeyDescriptor, firstNameDescriptor, lastNameDescriptor ];

  NSPredicate* predicate = nil;
  if (self.searchBar.text.length)
    predicate = [NSPredicate
        predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text];

  request.predicate = predicate;

  _fetchedResultsController = [[NSFetchedResultsController alloc]
      initWithFetchRequest:request
      managedObjectContext:[DCMainProxy sharedProxy].workContext
        sectionNameKeyPath:@"sectionKey"
                 cacheName:nil];
  //    _fetchedResultsController.delegate = self;

  NSError* error = nil;
  [self.fetchedResultsController performFetch:&error];

  if (error)
    NSLog(@"%@", error);

  BOOL itemsEnabled = self.fetchedResultsController.fetchedObjects.count;

  self.noItemsLabel.hidden = itemsEnabled;
  self.speakersTbl.hidden = !itemsEnabled;

  if (itemsEnabled)
    [self.speakersTbl reloadData];
}

@end
