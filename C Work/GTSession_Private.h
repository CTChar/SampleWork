//
//  GTSession_Private.h
//  GitTrack
//
//  Created by Cole Herzog on 6/3/14.
//  Copyright (c) 2014 Vintty. All rights reserved.
//

#ifndef GTSession_Private_h
#define GTSession_Private_h

#define SESSION_PTR(x) ((GTSession *)x)
#define TRACKER_PTR(x) ((RepoTracker *)x)

uint32_t fetchVersionDB(const char *path);

unsigned char extendedFileExists(const char *path, const char *name);

/**
 * initializes and allocates the entire session
 * @param storage character Pointer to the name of the storage directory
 *
 * @param pSessionID Pointer that the session ID of the created Session will be placed
 *
 * @return GTSUCCESS if everything worked, GTERROR if failed
 */
GTStatus initializeSession(const char *storage, GTSessionID * pSessionID);

/**
 * Loads the Session based on the previously tracked and saved repositories
 *
 * @param pSession GTSession pointer to be loaded
 *
 * @param trackedRepoFile The full path of the storage file
 *
 * @return returns 0 if everything worked well, returns GTERRORs if things went wrong
 */
GTStatus loadSession(GTSession *pSession, const char *trackedRepoFile);

GTStatus loadSessionDB(GTSession *pSession);

/**
 * Saves the indicated session
 *
 * @param pSession GTSession pointer to be saved
 *
 * @param trackedRepoFile Full path of storage file where repositories will be saved
 *
 * @return GTSUCCESS if it worked, GTERROR if it did not
 */
GTStatus saveSession(GTSession *pSession, const char *trackedRepoFile);

/**
 * Destroys the given Session
 *
 * @param pSession Pointer to the Session to be destroyed
 *
 * @return GTSUCCESS if successful, GTERROR if not
 */
GTStatus terminateSession(GTSession * pSession);

/**
 * invalidates a Session
 *
 * @param sessionID the GTSessionID for the session being invalidated
 *
 * @return void
 */
void invalidateSession(GTSession * pSession);

GTStatus addRepoTrackerToSessionDB(RepoTracker *pTracker, GTSession *pSession);

GTStatus loadRepoTrackerToSessionDB(RepoTracker *pTracker, GTSession *pSession);

GTStatus removeRepoTrackerFromSession(RepoTracker *pTracker, GTSession *pSession);

#endif
