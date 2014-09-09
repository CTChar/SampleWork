//
//  GTSession_Private.c
//  GitTrack
//
//  Created by Cole Herzog on 6/3/14.
//  Copyright (c) 2014 Vintty. All rights reserved.
//

#ifndef Private_h
#include "Private.h"
#endif

#ifndef GTSession_Private_h
#include "GTSession_Private.h"
#endif

static const char * trackingDBName = "GTDB.db";
static const uint32_t sesVersion = 2;
static const int32_t repoNotFound = -1;
static const uint32_t sessionSignature = 0x5969;

#pragma mark - File Functions

char * removeNewLines(char * text) {
    char *index = strrchr(text, '\n');
    if(!index) {
        return text;
    }
    *index = '\0';
    return text;
}

//FETCH VERSION
uint32_t fetchVersionDB(const char *path) {
    uint32_t version = sesVersion;
    sqlite3 *dbhandle = openConnection(path);
    if(dbhandle) {
        char *query = "SELECT value FROM control WHERE key=\"version\";";
        sqlite3_stmt * statement = NULL;
        const char* tail;
        sqlite3_prepare_v2(dbhandle, query, -1, &statement, &tail);
        int sqlResult = sqlite3_step(statement);
        while(sqlResult == SQLITE_ROW) {
            version = sqlite3_column_int(statement, 0);
            sqlResult = sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    return version;
}

#pragma mark - Session Functions
//INITIALIZE SESSION
GTStatus initializeSession(const char *storage, GTSessionID * pSessionID)
{
    GTStatus status = GTSUCCESS;
    GTSession *pSession = NULL;
    unsigned char rootExists = 1;
    
    // Create the storage root folder if needed
    if(!dirExists(storage))
    {
        rootExists = 0;
        //should be mkdirs
        if(mkdir(storage, 0775)) {
            status = GTERROR_NOT_ACCESSIBLE_DIR;
            pSessionID = NULL;
            return status;
        }
    }
    
    char *fullStoragePath = filePathFromComponents(storage, trackingDBName);
    if(!fullStoragePath) {
       status = GTERROR_MEMORY_PROBLEM;
       pSessionID = NULL;
       return status;
    }
    
    // At last - allocate the Session and remember the storage root
    pSession = (GTSession *) calloc(sizeof(GTSession), 1);
    if(pSession) {
        size_t storageLength = strlen(storage) +1;
        pSession->storage = (char *) malloc(storageLength);
        if(pSession->storage) {
            strcpy(pSession->storage, storage);
        }
        else {
            free(pSession);
            free(fullStoragePath);
            status = GTERROR_MEMORY_PROBLEM;
            pSessionID = NULL;
            return status;
        }
        pSession->signature = sessionSignature;
        pSession->repoCount = 0;
    }
    else {
        status = GTERROR_MEMORY_PROBLEM;
    }
    
    if(!isValidDB(fullStoragePath)) {
        GTStatus DBStatus = buildDB(pSession);
        if (DBStatus) {
            free(fullStoragePath);
            status = GTERROR_FILEACCESS;
            pSessionID = NULL;
            return status;
        }
    }
    
    int desiredVersion = fetchVersionDB(fullStoragePath);
    if(desiredVersion == 1) {
        //This is where seperate version loading will happen
    }
    status = loadSessionDB(pSession);
    free(fullStoragePath);
    *pSessionID = (GTSessionID)pSession;
    return status;
}

GTStatus loadSessionDB(GTSession *pSession) {
    sqlite3 *dbhandle = NULL;
    char *dbPath = NULL;
    GTStatus status = GTSUCCESS;
    const unsigned char *name = NULL;
    const unsigned char *path = NULL;
    uint32_t repoDBID = 0;
    if(isValidSession(pSession)) {
        dbPath = createDBPath(pSession);
    }
    if(dbPath && isValidDB(dbPath)) {
        dbhandle = openConnection(dbPath);
    }
    if(dbhandle) {
        char *query = "SELECT repositoryID, name, path FROM repositories;";
        sqlite3_stmt * statement = NULL;
        const char* tail;
        status = sqlite3_prepare_v2(dbhandle, query, -1, &statement, &tail);
        int sqlResult = sqlite3_step(statement);
        while(sqlResult == SQLITE_ROW) {
            repoDBID = sqlite3_column_int(statement, 0);
            name = sqlite3_column_text(statement, 1);
            path = sqlite3_column_text(statement, 2);
            RepoTracker * pTracker = createRepoTracker(pSession, (const char *)path, (const char *)name, repoDBID); //NEED TO CHANGE CREATE REPO TRACKER
            if(!pTracker) {
                sqlite3_finalize(statement);
                free(dbPath);
                closeConnection(dbhandle);
                return status;
            }
            status = loadRepoTrackerToSessionDB(pTracker, pSession);
            sqlResult = sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    if(dbPath) {
        free(dbPath);
    }
    closeConnection(dbhandle);
    return status;
}

//TERMINATE SESSION
GTStatus terminateSession(GTSession * pSession)
{
    GTStatus status = GTSUCCESS;
    if(isValidSession(pSession)) {
        invalidateSession(pSession);
        for (int32_t repoIndex = pSession->repoCount - 1; repoIndex >= 0; repoIndex--) {
            RepoTracker *pTracker = pSession->linkedRepos[repoIndex];
            destroyRepository(pTracker);
        }
        free(pSession->storage);
        free(pSession);
    }
    return status;
}

//INVALIDATE SESSION
void invalidateSession(GTSession * pSession)
{
    if(isValidSession(pSession)) {
        if(pSession) {
            pSession->signature = 0;
        }
    }
}

int32_t repoIndexFromPath(GTSession *pSession, const char *path)
{
    RepoTracker * pTracker = NULL;
    if(path == NULL) {
        return GTERROR_NOT_REPO;
    }
    for (uint32_t repoIndex = 0; repoIndex < pSession->repoCount; repoIndex++) {
        pTracker = pSession->linkedRepos[repoIndex];
        if(!strcmp(pTracker->path, path))
        {
            return repoIndex;
        }
    }
    return repoNotFound;
}

GTStatus addRepoTrackerToSessionDB(RepoTracker *pTracker, GTSession *pSession) {
    GTStatus status = GTSUCCESS;
    if(!pTracker) {
        status = GTERROR_NOT_REPO;
    }
    if (pSession->repoCount >= reposPerSession) {
        status = GTERROR_MEMORY_PROBLEM;
    }
    if(repoIndexFromPath(pSession, pTracker->path) != -1) {
        return GTREPO_EXISTS;
    }
    pSession->linkedRepos[pSession->repoCount++] = pTracker;
    status = insertRepo(pTracker);
    return status;
}

GTStatus loadRepoTrackerToSessionDB(RepoTracker *pTracker, GTSession *pSession) {
    GTStatus status = GTSUCCESS;
    if(!pTracker) {
        status = GTERROR_NOT_REPO;
    }
    if (pSession->repoCount >= reposPerSession) {
        status = GTERROR_MEMORY_PROBLEM;
    }
    if(repoIndexFromPath(pSession, pTracker->path) != -1) {
        return GTREPO_EXISTS;
    }
    pSession->linkedRepos[pSession->repoCount++] = pTracker;
    return status;
}

GTStatus removeRepoTrackerFromSession(RepoTracker *pTracker, GTSession *pSession) {
    GTStatus status = GTSUCCESS;
    if(pSession->repoCount < 1) {
        status = GTERROR_NOT_REPO;
    }
    int32_t index = repoIndexFromPath(pSession, pTracker->path);
    if(index == repoNotFound) {
        status = GTERROR_NOT_REPO;
    }
    else {
        destroyRepository(pSession->linkedRepos[index]);
        pSession->repoCount--;
        if (pSession->repoCount) {
            pSession->linkedRepos[index] = pSession->linkedRepos[pSession->repoCount];
        }
        pSession->linkedRepos[pSession->repoCount] = NULL;
    }
    return status;
}