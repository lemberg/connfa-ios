/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/





#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

/**
 * Does ARC support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 *
 * @see
 *http://opensource.apple.com/source/libdispatch/libdispatch-228.18/os/object.h
 **/
#if OS_OBJECT_USE_OBJC
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or
 *OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) \
  enum _name : _type _name;   \
  enum _name : _type
#endif

extern NSString* const kReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NetworkStatus) {
  // Apple NetworkStatus Compatible Names.
  NotReachable = 0,
  ReachableViaWiFi = 2,
  ReachableViaWWAN = 1
};

@class Reachability;

typedef void (^NetworkReachable)(Reachability* reachability);
typedef void (^NetworkUnreachable)(Reachability* reachability);

@interface Reachability : NSObject

@property(nonatomic, copy) NetworkReachable reachableBlock;
@property(nonatomic, copy) NetworkUnreachable unreachableBlock;

@property(nonatomic, assign) BOOL reachableOnWWAN;

+ (Reachability*)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
// compatibility with Apples original code. (see .m)
+ (Reachability*)reachabilityWithHostName:(NSString*)hostname;
+ (Reachability*)reachabilityForInternetConnection;
+ (Reachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+ (Reachability*)reachabilityForLocalWiFi;

- (Reachability*)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been
// established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired;  // Identical DDG variant.
- (BOOL)connectionRequired;    // Apple's routine.
// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand;
// Is user intervention required?
- (BOOL)isInterventionRequired;

- (NetworkStatus)currentReachabilityStatus;
- (SCNetworkReachabilityFlags)reachabilityFlags;
- (NSString*)currentReachabilityString;
- (NSString*)currentReachabilityFlags;

@end
