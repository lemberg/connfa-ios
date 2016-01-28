
#import "DCCalendarManager.h"
#import <EventKit/EventKit.h>
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCEvent+DC.h"
#import "DCCoreDataStore.h"
#import "DCAlertsManager.h"

NSString* kCalendarIdKey = @"CalendarIdKey";

@interface DCCalendarManager ()
@property(nonatomic) EKEventStore* eventStore;
@property(nonatomic, strong) NSBlockOperation* blockOperation;
@property(nonatomic) BOOL isAccessGranted;

@end

@implementation DCCalendarManager

// static EKEventStore *eventStore;

- (instancetype)init {
  self = [super init];
  if (self) {
    self.eventStore = [EKEventStore new];
    self.blockOperation = [[NSBlockOperation alloc] init];
    [self checkEventStoreAccessForCalendar];
  }
  return self;
}

- (void)executeRequest:(void (^)())request {
  if (self.isAccessGranted) {
    request();
  } else {
    [self.blockOperation addExecutionBlock:^{
      request();
    }];
  }
}

+ (NSString*)calendarTitle {
  return [NSString
      stringWithFormat:@"%@ events", [DCAppConfiguration appDisplayName]];
}

- (EKCalendar*)defaultCalendar {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSString* calendarId = [defaults stringForKey:kCalendarIdKey];

  EKCalendar* calendar =
      [self findCalendar:calendarId title:[DCCalendarManager calendarTitle]];

  if (!calendarId && calendar) {
    [self removeCalendar:calendar];
    calendar = nil;
  }

  if (calendar == nil) {
    calendar = [self createNewCalendar];
  }

  return calendar;
}

- (EKCalendar*)findCalendar:(NSString*)calendarId
                      title:(NSString*)calendarTitle {
  // instead of getting calendar by identifier
  // get all calendars and check matching in the cycle
  // workaround caused by bug:
  // http://stackoverflow.com/questions/28258204/error-getting-shared-calendar-invitations-for-entity-types-3-xcode-6-1-1-ekcal

  NSArray* allCalendars =
      [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
  for (EKCalendar* calendar in allCalendars) {
    if ([calendar.calendarIdentifier isEqualToString:calendarId] ||
        [calendar.title isEqualToString:calendarTitle]) {
      return calendar;
    }
  }

  return nil;
}

#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
- (void)checkEventStoreAccessForCalendar {
  EKAuthorizationStatus status =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  switch (status) {
    // Update our UI if the user has granted access to their Calendar
    case EKAuthorizationStatusAuthorized:
      [self accessGrantedForCalendar];
      break;
    // Prompt the user for access to Calendar if there is no definitive answer
    case EKAuthorizationStatusNotDetermined:
      [self requestCalendarAccess];
      break;
    // Display a message if the user has denied or restricted access to Calendar
    case EKAuthorizationStatusDenied:
    case EKAuthorizationStatusRestricted: {
      [self showAlertWithTitle:@"Privacy Warning"
                       message:@"Permission was not granted for Calendar"];

    } break;
    default:
      break;
  }
}

// Prompt the user for access to their Calendar
- (void)requestCalendarAccess {
  __weak typeof(self) weakSelf = self;

  [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                  completion:^(BOOL granted, NSError* error) {
                                    if (granted) {
                                      weakSelf.isAccessGranted = YES;
                                      [weakSelf.blockOperation start];
                                    }
                                  }];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)msg {
  [DCAlertsManager showAlertWithTitle:title message:msg];
}

- (EKCalendar*)createNewCalendar {
  EKCalendar* calendar;
  EKSource* defaultSource =
      [self.eventStore defaultCalendarForNewEvents].source;

  // create new calendar in Default source
  calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent
                                    eventStore:self.eventStore];
  calendar.title = [DCCalendarManager calendarTitle];
  calendar.source = defaultSource;

  NSError* error = nil;
  [self.eventStore saveCalendar:calendar commit:YES error:&error];

  if (error && error.code == 17) {
    [self showAlertWithTitle:@"Attention"
                     message:@"DrupalCon calendar was not created because app "
                     @"does not have rights to access your calendar "
                     @"account. Go to "
                     @"Settings->Mail,Contacts,Calendars->Account and "
                     @"turn off Calendar switcher. Or use iCloud "
                     @"account for calendar."];
  }

  if (!error) {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:calendar.calendarIdentifier forKey:kCalendarIdKey];
    [userDefaults synchronize];
  }

  return calendar;
}

// This method is called when the user has granted permission to Calendar
- (void)accessGrantedForCalendar {
  // Let's get the default calendar associated with our event store
  self.isAccessGranted = YES;
  [self.blockOperation start];
}

- (void)removeCalendar:(EKCalendar*)calendar {
  NSError* error = nil;

  BOOL result =
      [self.eventStore removeCalendar:calendar commit:YES error:&error];
  if (!result) {
    NSLog(@"Deleting calendar failed: %@.", error);
  }
}

- (void)addEventWithItem:(DCEvent*)event interval:(int)minutesBefore {
  __weak typeof(self) weakSelf = self;

  [self executeRequest:^{
    EKEvent* calEvent = [EKEvent eventWithEventStore:self.eventStore];
    calEvent.title = event.name;
    calEvent.location = event.place;
    calEvent.startDate = [event startDate];
    calEvent.endDate = [event endDate];
    calEvent.calendar = [self defaultCalendar];

    NSTimeInterval interval = -(minutesBefore * 60.f);
    EKAlarm* alarm = [EKAlarm alarmWithRelativeOffset:interval];
    [calEvent addAlarm:alarm];

    NSError* err = nil;
    [weakSelf.eventStore saveEvent:calEvent span:EKSpanThisEvent error:&err];
    if (err)
      NSLog(@"Error during adding event to a calendar %@", err);
    dispatch_async(dispatch_get_main_queue(), ^{

      event.calendarId = calEvent.eventIdentifier;
      [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];

    });
  }];
}

- (void)removeEventOfItem:(DCEvent*)event {
  __weak typeof(self) weakSelf = self;

  [self executeRequest:^{
    EKEvent* calendarEvent =
        [self.eventStore eventWithIdentifier:event.calendarId];

    if (calendarEvent) {
      NSError* error;
      [weakSelf.eventStore removeEvent:calendarEvent
                                  span:EKSpanThisEvent
                                 error:&error];
      if (error)
        NSLog(@"Error during removing event from a calendar %@", error);
    }
  }];
}

@end
