/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@import CoreData;

/**
 *  DCCoreDataStore manages object contexts main and private which has parent
 * main context
 */

@interface DCCoreDataStore : NSObject

+ (instancetype)defaultStore;

/**
 *  Save value from all contexts on disk
 *
 *  @return BOOL if save is success
 */
- (void)saveWithCompletionBlock:(void (^)(BOOL isSuccess))callback;

/**
 *  Save main context on disk
 */

- (void)saveMainContextWithCompletionBlock:(void (^)(BOOL isSuccess))callback;

/**
 *  Context that works on main Queue
 *
 *  @return NSManagedObjectContext which works with NSFetchResultController
 */
+ (NSManagedObjectContext*)mainQueueContext;

/**
 *  Context that works on background Queue
 *
 *  @return  NSManagedObjectContext for backround working
 */
+ (NSManagedObjectContext*)privateQueueContext;

@end
