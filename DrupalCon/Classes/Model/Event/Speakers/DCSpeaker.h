
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCSpeaker : NSManagedObject

@property(nonatomic, retain) NSString* avatarPath;
@property(nonatomic, retain) NSString* characteristic;
@property(nonatomic, retain) NSString* firstName;
@property(nonatomic, retain) NSString* jobTitle;
@property(nonatomic, retain) NSString* lastName;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* organizationName;
@property(nonatomic, retain) NSNumber* speakerId;
@property(nonatomic, retain) NSString* twitterName;
@property(nonatomic, retain) NSString* webSite;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) NSSet* events;
@property(nonatomic, retain) NSString* sectionKey;

@end

@interface DCSpeaker (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent*)value;
- (void)removeEventsObject:(DCEvent*)value;
- (void)addEvents:(NSSet*)values;
- (void)removeEvents:(NSSet*)values;

@end
