//
//  GTFile_Private.h
//  GitTrack
//
//  Created by Cole Herzog on 6/25/14.
//  Copyright (c) 2014 Vintty. All rights reserved.
//

#ifndef GitTrack_GTUtil_h
#define GitTrack_GTUtil_h

#ifndef _SYS__TYPES_H_
#include <sys/_types.h>
#endif

#ifndef GTStatus_h
#include "GTStatus.h"
#endif

#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlite3.h>

struct GTSession;
struct RepoTracker;

typedef struct RepoTracker {
    char *path;
    char *name;
    uint32_t signature;
    struct GTSession *session;
    uint32_t BookmarkID;
    uint32_t repositoryID;
} RepoTracker;

typedef struct GTSession {
    char *storage;
    RepoTracker *linkedRepos[reposPerSession];
    uint32_t repoCount;
    uint32_t signature;
} GTSession;

/**
 * Composes a full file path given the directory path and the file name
 *
 * @param path The path of the directory the file is in
 *
 * @param name The name of the file
 *
 * @return The pointer to the start of the full file name, or null if it failed
 */
char * filePathFromComponents(const char * path, const char * name);

/**
 * Generates a short name for a repository from the repository's path
 *
 * @param path The path the name will be generated from
 *
 * @return the short name
 */
const char *lastPathComponent(const char *path);

/**
 * Determines if the given file path exists
 *
 * @param path The full path of the file
 *
 * @return 1 if the file exists, 0 if the file does not exist
 */
unsigned char fileExists(const char *path);

unsigned char extendedDirExists(const char *path, const char *name);

/**
 * Determines if the given directory exists
 *
 * @param path The full path of the directory
 *
 * @return 1 if the directory exists, 0 if the directory does not exist
 */
unsigned char dirExists(const char *path);

/**
 * Determines if the given directory is a git repository
 *
 * @param path The full path of the directory
 *
 * @return 1 if the directory is a git repository, 0 if it is not
 */
unsigned char isGitDir(const char *path);

/**
 * checks to see if a repository is valid
 *
 * @param pTracker Pointer to the RepoTracker to be validated
 *
 * @return 1 if RepoTracker is valid, 0 if it's not
 */
unsigned char isValidRepoTracker(RepoTracker *pTracker);

/**
 * checks to see if a session is valid
 *
 * @param sessionID The GTSessionID of the session being checked
 *
 * @return 0 if session is not valid, 1 if session is valid
 */
unsigned char isValidSession(GTSession * pSession);

char * createDBPath(GTSession * pSession);

sqlite3* openConnection(const char *fileName);

int closeConnection(sqlite3 *connection);

#endif