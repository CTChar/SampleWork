//
//  RepositoryManager.m
//  gtrak
//
//  Created by Paul Herzog on 6/5/14.
//  Copyright (c) 2014 Vintty. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "RepositoryManager.h"
#import "Tracker.h"
#import "Identity.h"
#import <GitTrack.h>
#import <git2.h>

@interface RepositoryManager ()

@property (strong, nonatomic) NSMutableArray *internalTrackedRepos;
@property (strong, nonatomic) NSMutableArray *identities;
@property (assign, readwrite) GTSessionID sessionID;
@end

@implementation RepositoryManager

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        git_threads_init();
        self.internalTrackedRepos = NSMutableArray.new;
        self.identities = NSMutableArray.new;
        self.sessionID = [self setupSession:path];
        [self loadRepositories];
        [self loadIdentities];
    }
    return self;
}

- (void)dealloc {
    if (self.isReady) {
        GTSessionID gtSessionID = self.sessionID;
        terminateGTSession(gtSessionID);
        git_threads_shutdown();
    }
}

- (BOOL)isReady {
    return (self.sessionID != GTNULL);
}

- (GTSessionID)setupSession:(NSString *)path {
    GTSessionID gtSessionID = GTNULL;
    GTStatus gtStatus = initGTSession(path.UTF8String, &gtSessionID);
    self.sessionID = GTNULL;
    if (gtStatus != GTSUCCESS) {
        gtSessionID = GTNULL;
    }
    return gtSessionID;
}

- (NSArray *)trackedRepos {
    return [NSArray arrayWithArray:self.internalTrackedRepos];
}

- (NSArray *)identityList {
    return [NSArray arrayWithArray:self.identities];
}

// Private
- (Tracker *)trackRepoAtPath:(NSString *)repoPath withName:(NSString *)repoName {
    Tracker *gtRepo = nil;
    const char *path = NULL;
    const char *name = NULL;
    if (repoPath) {
        path = repoPath.UTF8String;
    }
    if (repoName) {
        name = repoName.UTF8String;
    }
    GTRepoID repoID = GTNULL;
    GTStatus gtStatus = addLocalRepository(self.sessionID, path, name, &repoID);
    if (gtStatus == GTSUCCESS) {
        gtRepo = [Tracker trackerWithID:(NSUInteger)repoID];
        [gtRepo trackAllRemotes];
        [self.internalTrackedRepos addObject:gtRepo];
    }
    return gtRepo;
}

//DOCUMENT THAT UI COMPLETION CAN GET A NIL
- (void)addRepositoryWithCompletion:(void (^)(Tracker *tracker))uiGuyCompletionBlock {
    __block RepositoryManager *repoManager = self;
    [self addRepositoryWithBlock:^ void (NSURL *url) {
        Tracker *tracker = nil;
        NSError *error = nil;
        git_repository *gitRepo = NULL;
        uint32_t result = git_repository_open(&gitRepo, url.path.UTF8String);
        if(result == 0) {
            tracker = [repoManager trackRepoAtPath:url.path withName:nil];
            NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
            addBookmark(tracker.repoID, (unsigned char *)bookmark.bytes, (uint32_t)bookmark.length);
            git_repository_free(gitRepo);
        }
        else {
            const git_error *e = giterr_last();
            printf("Error %d/%d: %s\n", result, e->klass, e->message);
        }
        uiGuyCompletionBlock(tracker);
    }];
}

- (void)addRepositoryWithBlock:(void (^)(NSURL *url))trackerCreation {
    NSOpenPanel *openPanel = NSOpenPanel.new;
    openPanel.allowedFileTypes = nil;
    openPanel.directoryURL = nil;
    openPanel.canCreateDirectories = NO;
    openPanel.treatsFilePackagesAsDirectories = NO;
    openPanel.prompt = @"Select";
    openPanel.title = @"Repository";
    openPanel.message = @"Select a Folder containing a Git Repository";
    openPanel.showsHiddenFiles = NO;
    openPanel.resolvesAliases = YES;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSUInteger urlCount = openPanel.URLs.count;
            if (urlCount > 0) {
                NSURL *requestedURL = openPanel.URLs[0];
                trackerCreation(requestedURL);
            }
        }
    }];
}

//Not quite confident which add works better, probably NOT this one
- (Identity *)addIdentityWithName:(NSString *)name username:(NSString *)refData authType:(uint32_t)authType {
    Identity *iden = nil;
    const char *charName = [name UTF8String];
    const char *charRef = [refData UTF8String];
    GTStatus status = addIdentity(self.sessionID, (char *)charName, authType, (char *)charRef);
    if(status == GTSUCCESS) {
        if(refData) {
            iden = [[Identity alloc] initWithName:name username:refData];
        }
        else {
            iden = [[Identity alloc] initWithName:name];
        }
    }
    return iden;
}

// TODO: stop tracking a repo
- (BOOL)untrackRepo:(Tracker *)gtRepo {
    BOOL didUntrack = NO;
    GTStatus status = removeLocalRepository(gtRepo.repoID);
    if(status == GTSUCCESS) {
        didUntrack = YES;
    }
    [self.internalTrackedRepos removeObject:gtRepo];
    return didUntrack;
}

- (void)loadRepositories {
    uint32_t number = 0;
    GTRepoID *reposJSON = listRepositories(self.sessionID, &number);
    for(int i = 0; i<number; i++) {
        Tracker *btracker = [[Tracker alloc] initWithID:reposJSON[i]];
        [self.internalTrackedRepos addObject:btracker];
        [btracker trackAllRemotes];
    }
}

- (Identity *)createNewIdentity:(NSString *)name userName:(NSString *)uname {
    GTStatus status = GTERROR_NO_NAME;
    if(name && uname) {
        status = addIdentity(self.sessionID, (char *)name.UTF8String, UNAME_PASSWORD, (char *)uname.UTF8String);
    }
    if (status == GTSUCCESS) {
        Identity *identity = [[Identity alloc] initWithName:name username:uname];
        [self.identities addObject:identity];
        return identity;
    }
    return nil;
}

- (Identity *)createNewIdentity:(NSString *)name pubKey:(NSString *)pubPath privKey:(NSString *)privPath {
    //GTStatus status = GTERROR_NO_NAME;
    //Need to learn more about SSH
    return nil;
}

- (BOOL)deleteIdentity:(Identity *)identity {
    SecKeychainItemRef itemRef = [identity keychainItemRef];
    GTStatus status = removeIdentity(self.sessionID, (char *)identity.name.UTF8String);
    if(status == GTSUCCESS) {
        SecKeychainItemDelete(itemRef);
        [self.identities removeObject:identity];
    }
    return (status == GTSUCCESS);
}

- (void)loadIdentities {
    char *list = createIdentityNamesList(self.sessionID);
    NSUInteger listLength = (NSUInteger)strlen(list);
    NSData *data = [NSData dataWithBytes:list length:listLength];
    NSError *error = nil;
    enum authenticationType type = 0;
    char *refData = (char *)malloc(300);
    NSArray *identityNamesList = (NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for (NSString *idName in identityNamesList) {
        type = getIdentityInfo(self.sessionID, idName.UTF8String, refData, 300);
        if(type == UNAME_PASSWORD) {
            NSString *uname = [NSString stringWithUTF8String:refData];
            Identity *identity = [[Identity alloc] initWithName:idName username:uname];
            [self.identities addObject:identity];
        }
        else if(type == KEYS) {
            //get key stuff and call new Identity with key stuff
        }
        else if(type == SSHCLIENT) {
            //do SSH-AGENT stuff
        }
    }
    if(refData) {
        refData = NULL;
        free(refData);
    }
}

@end