
@protocol ManagedObjectUpdateProtocol<NSObject>

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context;

@optional
+ (NSString*)idKey;

@end

static NSString* kDCParseObjectDeleted = @"deleted";
static NSString* kDCParseObjectOrderKey = @"order";

@interface ManagedObjectUpdateProtocol : NSObject;

@end
