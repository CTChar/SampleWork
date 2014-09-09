//
//  RepositoryManager.h
//  gtrak
//
//  Created by Paul Herzog on 6/5/14.
//  Copyright (c) 2014 Vintty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Identity.h"

@class Tracker;

@interface RepositoryManager : NSObject

@property (readonly, nonatomic) NSArray *trackedRepos;
@property (readonly, nonatomic) NSArray *identityList;
@property (readonly) BOOL isReady;

- (instancetype)initWithPath:(NSString *)path;

- (BOOL)untrackRepo:(Tracker *)gtRepo;

- (void)addRepositoryWithCompletion:(void (^)(Tracker *tracker))uiGuyCompletionBlock;

- (Identity *)createNewIdentity:(NSString *)name userName:(NSString *)uname;

- (BOOL)deleteIdentity:(Identity *)identity;

//- (Tracker *)addRepository;

- (Tracker *)trackRepoAtPath:(NSString *)repoPath withName:(NSString *)repoName;
@end
