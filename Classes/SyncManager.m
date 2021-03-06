//
//  SyncManager.m
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "Setting.h"
#import "SFHFKeychainUtils.h"

@implementation SyncManager

@synthesize tdApi;
@synthesize isConnected;
@synthesize syncError;
@synthesize currentDate;

/*
 Führt eine Synchronisation mit automatischer Wahl des aktuelleren Datensatzes durch.
 Die automatische Wahl funktioniert jedoch nur für Tasks, nicht für Folder und Contexts,
 weil bei letzteren auf Seiten von Toodledo keine Modified-Dates gespeichert werden.
 Die Preference (SyncPreferLocal/SyncPreferRemote) bezieht sich also nur auf Folder und Contexts.
 */
-(BOOL)syncWithPreference:(SyncPreference)preference error:(NSError**)error
{
	// 1. init members
	BOOL wasSuccessful = YES;
	isConnected = NO;
	currentDate = [NSDate date];
	syncError = nil;
	*error = nil;
	Setting *settings = (Setting *)[Setting getSettings:&syncError];
	if(settings == nil)
	{
		*error = syncError;
		return NO;
	}
	ALog(@"settings: %@", settings);
	NSString *tdPassword = [SFHFKeychainUtils getPasswordForUsername:settings.tdEmail error:&syncError];
	if(syncError != nil)
	{
		*error = syncError;
		return NO;
	}
	tdApi = [[TDApi alloc] initWithUsername:settings.tdEmail password:tdPassword error:&syncError];
	
	if(syncError != nil) // error establishing connection
	{
		*error = syncError;
		wasSuccessful = NO;
	}
	else // successfully connected
	{
		[BaseManagedObject commit];
		[self stopAutocommit];
		
		if(preference == SyncPreferLocal)
		{
			// 1. Folders
			wasSuccessful = [self syncFoldersPreferLocal];
			if(!wasSuccessful)
				return [self exitFailure:error];
			// 2. Contexts
			wasSuccessful = [self syncContextsPreferLocal];
			if(!wasSuccessful)
				return [self exitFailure:error];
			// 3. Tasks
			wasSuccessful = [self syncTasksMatchDates];
			if(!wasSuccessful)
				return [self exitFailure:error];
		}
		else
		{
			// 1. Folders
			wasSuccessful = [self syncFoldersPreferRemote];
			if(!wasSuccessful)
				return [self exitFailure:error];
			// 2. Contexts
			wasSuccessful = [self syncContextsPreferRemote];
			if(!wasSuccessful)
				return [self exitFailure:error];
			// 3. Tasks
			wasSuccessful = [self syncTasksMatchDates];
			if(!wasSuccessful)
				return [self exitFailure:error];
		}
		
		[BaseManagedObject commitWithoutLocalModification];
		[self startAutocommit];
		[tdApi release];
		return YES;
	}
	
	return wasSuccessful;
}

/*
 Der komplette lokale Stand wird gelöscht und mit dem aktuellen Remote-Stand überschrieben.
 */
-(BOOL)overwriteLocal:(NSError**)error
{
	// 1. init members
	BOOL wasSuccessful = YES;
	isConnected = NO;
	currentDate = [NSDate date];
	syncError = nil;
	*error = nil;
	Setting *settings = [Setting getSettings:&syncError];
	if(settings == nil)
	{
		*error = syncError;
		return NO;
	}
	NSString *tdPassword = [SFHFKeychainUtils getPasswordForUsername:settings.tdEmail error:&syncError];
	if(syncError != nil)
	{
		*error = syncError;
		return NO;
	}
	tdApi = [[TDApi alloc] initWithUsername:settings.tdEmail password:tdPassword error:&syncError];
	
	if(syncError != nil) // error establishing connection
	{
		*error = syncError;
		wasSuccessful = NO;
	}
	else // successfully connected
	{
		[self stopAutocommit];
		
		// ------ FIRST: DELETE ALL LOCAL DATA ------
		
		// delete Folders
		wasSuccessful = [self deleteAllLocalFolders];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// delete Contexts
		wasSuccessful = [self deleteAllLocalContexts];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// delete Tags
		wasSuccessful = [self deleteAllLocalTags];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// delete Tasks
		wasSuccessful = [self deleteAllLocalTasks];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// später: deleteAllExtendedInfos
		
		// ------ SECOND: GET DATA FROM REMOTE STORE
		
		// 1. get Folders
		wasSuccessful = [self syncFoldersPreferRemote];
		if(!wasSuccessful)
			return [self exitFailure:error];
		// 2. get Contexts
		wasSuccessful = [self syncContextsPreferRemote];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// 3. write Tasks
		wasSuccessful = [self syncTasksPreferRemote];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		[BaseManagedObject commitWithoutLocalModification];
		[self startAutocommit];
		[tdApi release];
		return YES;
	}
	
	return wasSuccessful;
}

/*
 Der komplette Remote-Stand wird gelöscht und mit dem aktuellen lokalen Stand überschrieben.
 */
-(BOOL)overwriteRemote:(NSError**)error
{
	// 1. init members
	BOOL wasSuccessful = YES;
	isConnected = NO;
	currentDate = [NSDate date];
	syncError = nil;
	*error = nil;
	Setting *settings = [Setting getSettings:&syncError];
	if(settings == nil)
	{
		*error = syncError;
		return NO;
	}
	NSString *tdPassword = [SFHFKeychainUtils getPasswordForUsername:settings.tdEmail error:&syncError];
	if(syncError != nil)
	{
		*error = syncError;
		return NO;
	}
	tdApi = [[TDApi alloc] initWithUsername:settings.tdEmail password:tdPassword error:&syncError];
	
	if(syncError != nil) // error establishing connection
	{
		*error = syncError;
		wasSuccessful = NO;
	}
	else // successfully connected
	{
		[self stopAutocommit];
		
		// ------ FIRST: DELETE ALL REMOTE DATA ------
		
		// delete Folders
		wasSuccessful = [self deleteAllRemoteFolders];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// delete Contexts
		wasSuccessful = [self deleteAllRemoteContexts];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// delete Tasks
		wasSuccessful = [self deleteAllRemoteTasks];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// ------ SECOND: WRITE LOCAL DATA TO REMOTE STORE
		
		// 1. write Folders
		wasSuccessful = [self syncFoldersPreferLocal];
		if(!wasSuccessful)
			return [self exitFailure:error];
		// 2. write Contexts
		wasSuccessful = [self syncContextsPreferLocal];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		// 3. write Tasks
		wasSuccessful = [self syncTasksPreferLocal];
		if(!wasSuccessful)
			return [self exitFailure:error];
		
		[BaseManagedObject commitWithoutLocalModification];
		[self startAutocommit];
		[tdApi release];
		return YES;
	}
	
	return wasSuccessful;
}

+(NSString *)gtdErrorMessage:(NSInteger)errorCode
{
	/*GtdApiNoConnectionError = 10,
	 GtdApiNotReachableError = 20,
	 GtdApiDataError = 30,
	 GtdApiMissingParameters = 40,
	 GtdApiMissingCredentialsError = 110,
	 GtdApiWrongCredentialsError = 120,
	 GtdApiFolderNotAddedError = 210,
	 GtdApiFolderNotDeletedError = 310,
	 GtdApiFolderNotEditedError = 410,
	 GtdApiContextNotAddedError = 510,
	 GtdApiContextNotDeletedError = 520,
	 GtdApiContextNotEditedError = 530*/
	switch (errorCode) {
		case GtdApiNoConnectionError:
			return @"Toodledo API no connection";
		case GtdApiNotReachableError:
			return @"Toodledo API not reachable";
		case GtdApiDataError:
			return @"Toodledo API data error";
		case GtdApiMissingParameters:
			return @"Toodledo API missing parameters";
		case GtdApiMissingCredentialsError:
			return @"Toodledo API missing credentials";
		case GtdApiWrongCredentialsError:
			return @"Toodledo API wrong credentials";
		case GtdApiFolderNotAddedError:
			return @"Toodledo API Folder not added";
		case GtdApiFolderNotDeletedError:
			return @"Toodledo API Folder not deleted";
		case GtdApiFolderNotEditedError:
			return @"Toodledo API Folder not edited";
		case GtdApiContextNotAddedError:
			return @"Toodledo API Context not added";
		case GtdApiContextNotDeletedError:
			return @"Toodledo API Context not deleted";
		case GtdApiContextNotEditedError:
			return @"Toodledo API Context not edited";
		default:
			return @"Toodledo API unknown error";
	}
}

-(BOOL)syncFoldersPreferLocal
{
	NSArray *remoteFolders = [tdApi getFolders:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localFoldersWithRemoteIdArray = [Folder getRemoteStoredFolders:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Foldern
	// sobald ein remote-pendant gefunden wurde, entferne folder aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen aber aufgrund der
	// höheren priorität der lokalen version remote wieder geadded werden
	NSMutableArray *localFoldersWithRemoteId = [NSMutableArray array];
	[localFoldersWithRemoteId addObjectsFromArray:localFoldersWithRemoteIdArray];
	NSMutableArray *usedLocalEntityVersion = [[[NSMutableArray alloc] init] autorelease];
	
	for(GtdFolder *remoteFolder in remoteFolders)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Folder, ob gleiche id existiert
		for(int i=0; i<[localFoldersWithRemoteId count]; i++)
		{
			Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
			if([localFolder.remoteId integerValue] == remoteFolder.uid)
			{
				foundLocalEntity = YES;
				[usedLocalEntityVersion addObject:localFolder];
				[localFoldersWithRemoteId removeObject:localFolder];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
			newFolder.name = remoteFolder.title;
			newFolder.order = [NSNumber numberWithInteger:remoteFolder.order];
			newFolder.remoteId = [NSNumber numberWithInteger:remoteFolder.uid];
			newFolder.lastSyncDate = currentDate;
		}
	}
	
	// füge nun remote gelöschte folder wieder hinzu, aber nur wenn sie nicht
	// auch zufällig lokal als gekennzeichnet wurden
	for(int i=0;i<[localFoldersWithRemoteId count];i++)
	{
		GtdFolder *remoteFolder = [[GtdFolder alloc] init];
		Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
		remoteFolder.title = localFolder.name;
		remoteFolder.order = [localFolder.order integerValue];
		if([localFolder.deleted intValue] == 0)
		{
			localFolder.lastSyncDate = currentDate;
			localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:remoteFolder error:&syncError]];
		}
		[remoteFolder release];
		if(syncError != nil)
			return NO;
	}
	
	// update die toodledo folder, bei allen foldern, die schon mal gesynct wurden
	for(Folder *localFolder in usedLocalEntityVersion)
	{
		// update toodledo
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.title = localFolder.name;
		newFolder.order = [localFolder.order integerValue];
		newFolder.uid = [localFolder.remoteId integerValue];
		
		// sende update request nur, wenn der folder nicht sowieso gelöscht wird
		BOOL requestSuccessful = YES;
		if([localFolder.deleted intValue] == 0)
		{
			localFolder.lastSyncDate = currentDate;
			requestSuccessful = [tdApi editFolder:newFolder error:&syncError];
		}
		
		[newFolder release];
		if(!requestSuccessful)
			return NO;
	}
	
	// jetzt fehlen nur noch die noch nie gesyncten lokalen Folder
	// --> toodledo-add
	NSArray *unsyncedFolders = [Folder getUnsyncedFolders:&syncError];
	if(syncError != nil)
		return NO;
	for(Folder *localFolder in unsyncedFolders)
	{
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.title = localFolder.name;
		newFolder.order = [localFolder.order integerValue];
		newFolder.private = NO;
		newFolder.uid = -1;
		
		localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&syncError]];
		localFolder.lastSyncDate = currentDate;
		[newFolder release];
		if(syncError != nil)
			return NO;
	}
	
	// alle folder mit remoteId != nil && deleted == true ==> delete toodledo
	NSArray *foldersToDeleteRemote = [Folder getRemoteStoredFoldersLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[foldersToDeleteRemote count]; i++)
	{
		Folder * folderToDeleteRemote = [foldersToDeleteRemote objectAtIndex:i];
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.uid = [folderToDeleteRemote.remoteId integerValue];
		BOOL requestSuccessful = YES;
		requestSuccessful = [tdApi deleteFolder:newFolder error:&syncError];
		[newFolder release];
		if(!requestSuccessful)
		{
			// ignoriere Fehler, dann wurde der Folder eben schon von einem
			// anderen in der Zwischenzeit gelöscht
			if(![syncError code] == GtdApiFolderNotDeletedError)
				return NO;
			syncError = nil;
		}
	}
	
	// alle folder mit deleted == true lokal löschen
	NSArray *foldersToDeleteLocally = [Folder getAllFoldersLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[foldersToDeleteLocally count]; i++)
	{
		Folder *folderToDeleteLocally = [foldersToDeleteLocally objectAtIndex:i];
		[Folder deleteObjectFromPersistentStore:folderToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
}

-(BOOL)syncFoldersPreferRemote
{
	NSArray *remoteFolders = [tdApi getFolders:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localFoldersWithRemoteIdArray = [Folder getRemoteStoredFolders:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Foldern
	// sobald ein remote-pendant gefunden wurde, entferne folder aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen daher aufgrund
	// der höheren Priorität der remote Version lokal gelöscht werden
	NSMutableArray *localFoldersWithRemoteId = [NSMutableArray array];
	[localFoldersWithRemoteId addObjectsFromArray:localFoldersWithRemoteIdArray];
	
	for(GtdFolder *remoteFolder in remoteFolders)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Folder, ob gleiche id existiert
		for(int i=0; i<[localFoldersWithRemoteId count]; i++)
		{
			Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
			if([localFolder.remoteId integerValue] == remoteFolder.uid)
			{
				foundLocalEntity = YES;
				
				localFolder.deleted = [NSNumber numberWithInteger:0]; // verhindere möglichen Löschvorgang
				// überschreibe lokale Felder
				localFolder.name = remoteFolder.title;
				localFolder.order = [NSNumber numberWithInteger:remoteFolder.order];
				// weiter unten: nsset tasks
				localFolder.lastSyncDate = currentDate;
				
				[localFoldersWithRemoteId removeObject:localFolder];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Folder *newFolder = (Folder*)[Folder objectOfType:@"Folder"];
			newFolder.name = remoteFolder.title;
			newFolder.order = [NSNumber numberWithInteger:remoteFolder.order];
			newFolder.remoteId = [NSNumber numberWithInteger:remoteFolder.uid];
			newFolder.lastSyncDate = currentDate;
		}
	}
	
	// merke alle lokalen Folder, zu denen kein remote-Pendant gefunden wurde
	// zum löschen vor
	for(int i=0;i<[localFoldersWithRemoteId count];i++)
	{
		Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
		localFolder.deleted = [NSNumber numberWithInteger:1];
	}
	
	// alle folder mit remoteId == nil && deleted == false ==> add toodledo
	NSArray *unsyncedFolders = [Folder getUnsyncedFolders:&syncError];
	if(syncError != nil)
		return NO;
	for(Folder *localFolder in unsyncedFolders)
	{
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.title = localFolder.name;
		newFolder.order = [localFolder.order integerValue];
		newFolder.private = NO;
		newFolder.uid = -1;
		
		localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&syncError]];
		localFolder.lastSyncDate = currentDate;
		[newFolder release];
		if(syncError != nil)
			return NO;
	}
	
	// alle folder mit deleted == true lokal löschen
	NSArray *foldersToDeleteLocally = [Folder getAllFoldersLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[foldersToDeleteLocally count]; i++)
	{
		Folder *folderToDeleteLocally = [foldersToDeleteLocally objectAtIndex:i];
		[Folder deleteObjectFromPersistentStore:folderToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
}

-(BOOL)syncContextsPreferLocal
{
	NSArray *remoteContexts = [tdApi getContexts:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localContextsWithRemoteIdArray = [Context getRemoteStoredContexts:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Kontexten
	// sobald ein remote-pendant gefunden wurde, entferne context aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen aber aufgrund der
	// höheren priorität der lokalen version remote wieder geadded werden
	NSMutableArray *localContextsWithRemoteId = [NSMutableArray array];
	[localContextsWithRemoteId addObjectsFromArray:localContextsWithRemoteIdArray];
	NSMutableArray *usedLocalEntityVersion = [[[NSMutableArray alloc] init] autorelease];
	
	for(GtdContext *remoteContext in remoteContexts)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Contexte, ob gleiche id existiert
		for(int i=0; i<[localContextsWithRemoteId count]; i++)
		{
			Context *localContext = [localContextsWithRemoteId objectAtIndex:i];
			if([localContext.remoteId integerValue] == remoteContext.uid)
			{
				foundLocalEntity = YES;
				[usedLocalEntityVersion addObject:localContext];
				[localContextsWithRemoteId removeObject:localContext];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Context *newContext = (Context*)[Context objectOfType:@"Context"];
			newContext.name = remoteContext.title;
			newContext.remoteId = [NSNumber numberWithInteger:remoteContext.uid];
			newContext.lastSyncDate = currentDate;
		}
	}
	
	// füge nun remote gelöschte contexts wieder hinzu, aber nur wenn sie nicht
	// auch zufällig lokal als gekennzeichnet wurden
	for(int i=0;i<[localContextsWithRemoteId count];i++)
	{
		GtdContext *remoteContext = [[GtdContext alloc] init];
		Context *localContext = [localContextsWithRemoteId objectAtIndex:i];
		remoteContext.title = localContext.name;
		if([localContext.deleted intValue] == 0)
		{
			localContext.lastSyncDate = currentDate;
			localContext.remoteId = [NSNumber numberWithInteger:[tdApi addContext:remoteContext error:&syncError]];
		}
		[remoteContext release];
		if(syncError != nil)
			return NO;
	}
	
	// update die toodledo context, bei allen contexten, die schon mal gesynct wurden
	for(Context *localContext in usedLocalEntityVersion)
	{
		// update toodledo
		GtdContext *newContext = [[GtdContext alloc] init];
		newContext.title = localContext.name;
		newContext.uid = [localContext.remoteId integerValue];
		
		// sende update request nur, wenn der context nicht sowieso gelöscht wird
		BOOL requestSuccessful = YES;
		if([localContext.deleted intValue] == 0)
		{
			localContext.lastSyncDate = currentDate;
			requestSuccessful = [tdApi editContext:newContext error:&syncError];
		}
		
		[newContext release];
		if(!requestSuccessful)
			return NO;
	}
	
	// jetzt fehlen nur noch die noch nie gesyncten lokalen Contexte
	// --> toodledo-add
	NSArray *unsyncedContexts = [Context getUnsyncedContexts:&syncError];
	if(syncError != nil)
		return NO;
	for(Context *localContext in unsyncedContexts)
	{
		GtdContext *newContext = [[GtdContext alloc] init];
		newContext.title = localContext.name;
		newContext.uid = -1;
		
		localContext.remoteId = [NSNumber numberWithInteger:[tdApi addContext:newContext error:&syncError]];
		localContext.lastSyncDate = currentDate;
		[newContext release];
		if(syncError != nil)
			return NO;
	}
	
	// alle contexte mit remoteId != nil && deleted == true ==> delete toodledo
	NSArray *contextsToDeleteRemote = [Context getRemoteStoredContextsLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[contextsToDeleteRemote count]; i++)
	{
		Context * contextToDeleteRemote = [contextsToDeleteRemote objectAtIndex:i];
		GtdContext *newContext = [[GtdContext alloc] init];
		newContext.uid = [contextToDeleteRemote.remoteId integerValue];
		BOOL requestSuccessful = YES;
		requestSuccessful = [tdApi deleteContext:newContext error:&syncError];
		[newContext release];
		if(!requestSuccessful)
		{
			// ignoriere Fehler, dann wurde der Context eben schon von einem
			// anderen in der Zwischenzeit gelöscht
			if(![syncError code] == GtdApiContextNotDeletedError)
				return NO;
			syncError = nil;
		}
	}
	
	// alle contexte mit deleted == true lokal löschen
	NSArray *contextsToDeleteLocally = [Context getAllContextsLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[contextsToDeleteLocally count]; i++)
	{
		Context *contextToDeleteLocally = [contextsToDeleteLocally objectAtIndex:i];
		[Context deleteObjectFromPersistentStore:contextToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
}

-(BOOL)syncContextsPreferRemote
{
	NSArray *remoteContexts = [tdApi getContexts:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localContextsWithRemoteIdArray = [Context getRemoteStoredContexts:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Contextn
	// sobald ein remote-pendant gefunden wurde, entferne context aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen daher aufgrund
	// der höheren Priorität der remote Version lokal gelöscht werden
	NSMutableArray *localContextsWithRemoteId = [NSMutableArray array];
	[localContextsWithRemoteId addObjectsFromArray:localContextsWithRemoteIdArray];
	
	for(GtdContext *remoteContext in remoteContexts)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Context, ob gleiche id existiert
		for(int i=0; i<[localContextsWithRemoteId count]; i++)
		{
			Context *localContext = [localContextsWithRemoteId objectAtIndex:i];
			if([localContext.remoteId integerValue] == remoteContext.uid)
			{
				foundLocalEntity = YES;
				
				localContext.deleted = [NSNumber numberWithInteger:0]; // verhindere möglichen Löschvorgang
				// überschreibe lokale Felder
				localContext.name = remoteContext.title;
				// weiter unten: nsset tasks
				localContext.lastSyncDate = currentDate;
				
				[localContextsWithRemoteId removeObject:localContext];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Context *newContext = (Context*)[Context objectOfType:@"Context"];
			newContext.name = remoteContext.title;
			newContext.remoteId = [NSNumber numberWithInteger:remoteContext.uid];
			newContext.lastSyncDate = currentDate;
		}
	}
	
	// merke alle lokalen Context, zu denen kein remote-Pendant gefunden wurde
	// zum löschen vor
	for(int i=0;i<[localContextsWithRemoteId count];i++)
	{
		Context *localContext = [localContextsWithRemoteId objectAtIndex:i];
		localContext.deleted = [NSNumber numberWithInteger:1];
	}
	
	// alle context mit remoteId == nil && deleted == false ==> add toodledo
	NSArray *unsyncedContexts = [Context getUnsyncedContexts:&syncError];
	if(syncError != nil)
		return NO;
	for(Context *localContext in unsyncedContexts)
	{
		GtdContext *newContext = [[GtdContext alloc] init];
		newContext.title = localContext.name;
		newContext.uid = -1;
		
		localContext.remoteId = [NSNumber numberWithInteger:[tdApi addContext:newContext error:&syncError]];
		localContext.lastSyncDate = currentDate;
		[newContext release];
		if(syncError != nil)
			return NO;
	}
	
	// alle context mit deleted == true lokal löschen
	NSArray *contextsToDeleteLocally = [Context getAllContextsLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[contextsToDeleteLocally count]; i++)
	{
		Context *contextToDeleteLocally = [contextsToDeleteLocally objectAtIndex:i];
		[Context deleteObjectFromPersistentStore:contextToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
}

-(BOOL)syncTasksMatchDates
{	
	NSArray *remoteTasks = [tdApi getTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localTasksWithRemoteIdArray = [Task getRemoteStoredTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Tasks
	// sobald ein remote-pendant gefunden wurde, entferne task aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen aber aufgrund der
	// höheren priorität der lokalen version remote wieder geadded werden
	NSMutableArray *localTasksWithRemoteId = [NSMutableArray array];
	
	[localTasksWithRemoteId addObjectsFromArray:localTasksWithRemoteIdArray];
	
	NSMutableArray *usedLocalEntityVersion = [[[NSMutableArray alloc] init] autorelease];
	
	for(GtdTask *remoteTask in remoteTasks)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Task, ob gleiche id existiert
		for(int i=0; i<[localTasksWithRemoteId count]; i++)
		{
			Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
			
			if([localTask.remoteId integerValue] == remoteTask.uid)
			{
				ALog(@"Das remoteDate: %@ das localDate: %@",remoteTask.date_modified,localTask.lastLocalModification); 
				
				if([remoteTask.date_modified compare:localTask.lastLocalModification] == NSOrderedDescending || localTask.lastLocalModification == nil) // Remote aktueller als Folder
				{
					localTask.deleted = [NSNumber numberWithInteger:0]; // verhindere möglichen Löschvorgang
					// überschreibe lokale Felder
					localTask.lastSyncDate = currentDate;
					localTask.name = remoteTask.title;
					localTask.creationDate = remoteTask.date_created;
					//localTask.lastLocalModification = remoteTask.date_modified;
					localTask.startDateAnnoy = remoteTask.date_start; // ???
					
					if(remoteTask.hasDueDate)
						localTask.dueDate = remoteTask.date_due;
					else
						localTask.dueDate = nil;
					if(remoteTask.hasDueTime)
						localTask.dueTime = remoteTask.date_due;
					else
						localTask.dueTime = nil;
					
					NSMutableArray *tagsToRemove = [NSMutableArray array];
					for(Tag *tag in localTask.tags)
					{
						[tagsToRemove addObject:tag];
					}
					for(Tag *tag in tagsToRemove)
					{
						[tag removeTasksObject:localTask];
					}
					[localTask removeTags:localTask.tags];
					for(NSString *remoteTag in remoteTask.tags)
					{
						if(![remoteTag isEqualToString:@""])
						{
							Tag* tag = [Tag getTagWithName:remoteTag error:&syncError];
							if(syncError != nil)
								return NO;
							if(tag == nil)
							{
								tag = (Tag*)[Tag objectOfType:@"Tag"];
								tag.name = remoteTag;
							}
							if(![[tag tasks] containsObject:localTask])
								[tag addTasksObject:localTask];
							if(![[localTask tags] containsObject:tag])
								[localTask addTagsObject:tag];
						}
					}
					
					if(localTask.folder != nil)
					{
						[localTask.folder removeTasksObject:localTask];
						localTask.folder = nil;
					}
					Folder *folder = [Folder getFolderWithRemoteId:[NSNumber numberWithInteger:remoteTask.folder] error:&syncError];
					if(syncError != nil)
						return NO;
					if(folder != nil)
					{
						[folder addTasksObject:localTask];
						[localTask setFolder:folder];
					}
					
					if(localTask.context != nil)
					{
						[localTask.context removeTasksObject:localTask];
						localTask.context = nil;
					}
					Context *context = [Context getContextWithRemoteId:[NSNumber numberWithInteger:remoteTask.context] error:&syncError];
					if(syncError != nil)
						return NO;
					if(context != nil)
					{
						[context addTasksObject:localTask];
						[localTask setContext:context];
					}
					localTask.priority = [NSNumber numberWithInteger:remoteTask.priority];
					localTask.isCompleted = (remoteTask.completed != nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
					localTask.duration = [NSNumber numberWithInteger:remoteTask.length]; // number of minutes to complete???
					localTask.note = remoteTask.note;
					localTask.star = [NSNumber numberWithBool:remoteTask.star];
					localTask.repeat = [NSNumber numberWithInteger:remoteTask.repeat];
					//newTask.whatever = remoteTask.status; // wird bei uns nicht verwendet
					localTask.reminder = [NSNumber numberWithInteger:remoteTask.reminder];
					//newTask.parentId = remoteTask.parentId; // wird bei uns nicht verwendet
					localTask.remoteId = [NSNumber numberWithInteger:remoteTask.uid];
					localTask.lastSyncDate = currentDate;
					
				}
				else
				{
					[usedLocalEntityVersion addObject:localTask];
					
				}
				[localTasksWithRemoteId removeObject:localTask];
				foundLocalEntity = YES;
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Task *newTask = (Task*)[Task objectOfType:@"Task"];
			newTask.name = remoteTask.title;
			newTask.creationDate = remoteTask.date_created;
			newTask.modificationDate = remoteTask.date_modified;
			newTask.startDateAnnoy = remoteTask.date_start; // ???
			if(remoteTask.hasDueDate)
				newTask.dueDate = remoteTask.date_due;
			else
				newTask.dueDate = nil;
			if(remoteTask.hasDueTime)
				newTask.dueTime = remoteTask.date_due;
			else
				newTask.dueTime = nil;
			
			for(NSString *remoteTag in remoteTask.tags)
			{
				if(![remoteTag isEqualToString:@""])
				{
					Tag* tag = [Tag getTagWithName:remoteTag error:&syncError];
					if(syncError != nil)
						return NO;
					if(tag == nil)
					{
						tag = (Tag*)[Tag objectOfType:@"Tag"];
						tag.name = remoteTag;
					}
					if(![[tag tasks] containsObject:newTask])
						[tag addTasksObject:newTask];
					if(![[newTask tags] containsObject:tag])
						[newTask addTagsObject:tag];
				}
			}
			Folder *folder = [Folder getFolderWithRemoteId:[NSNumber numberWithInteger:remoteTask.folder] error:&syncError];
			if(syncError != nil)
				return NO;
			if(folder != nil)
			{
				[folder addTasksObject:newTask];
				[newTask setFolder:folder];
			}
			Context *context = [Context getContextWithRemoteId:[NSNumber numberWithInteger:remoteTask.context] error:&syncError];
			if(syncError != nil)
				return NO;
			if(context != nil)
			{
				[context addTasksObject:newTask];
				[newTask setContext:context];
			}
			newTask.priority = [NSNumber numberWithInteger:remoteTask.priority];
			newTask.isCompleted = (remoteTask.completed != nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
			newTask.duration = [NSNumber numberWithInteger:remoteTask.length]; // number of minutes to complete???
			newTask.note = remoteTask.note;
			newTask.star = [NSNumber numberWithBool:remoteTask.star];
			newTask.repeat = [NSNumber numberWithInteger:remoteTask.repeat];
			//newTask.whatever = remoteTask.status; // wird bei uns nicht verwendet
			newTask.reminder = [NSNumber numberWithInteger:remoteTask.reminder];
			//newTask.parentId = remoteTask.parentId; // wird bei uns nicht verwendet
			newTask.remoteId = [NSNumber numberWithInteger:remoteTask.uid];
			newTask.lastSyncDate = currentDate;
		}
	}
	
	// lösche alle remote gelöschten tasks, die nach der letzten lokalen änderung gelöscht wurden
	NSArray *deletedTasks = [tdApi getDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(GtdTask *deletedTask in deletedTasks)
	{
		for(int i=0;i<[localTasksWithRemoteId count];i++)
		{
			Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
			ALog(@"local task: %@ - date local %@ - date deleted %@", localTask, localTask.lastLocalModification, deletedTask.date_deleted);
			if(deletedTask.uid == [localTask.remoteId integerValue] && ([deletedTask.date_deleted compare:localTask.lastLocalModification] == NSOrderedDescending || localTask.lastLocalModification == nil))
			{
				localTask.deleted = [NSNumber numberWithBool:YES];
				[localTasksWithRemoteId removeObject:localTask];
			}
		}
	}
	
	// füge nun remote gelöschte task wieder hinzu, aber nur wenn sie nicht
	// auch zufällig lokal als deleted gekennzeichnet wurden
	for(int i=0;i<[localTasksWithRemoteId count];i++)
	{
		GtdTask *remoteTask = [[GtdTask alloc] init];
		Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
		if([localTask.deleted intValue] == 0)
		{
			remoteTask.title = localTask.name;
			remoteTask.date_created = localTask.creationDate;
			remoteTask.date_modified = localTask.lastLocalModification;
			remoteTask.date_start = localTask.startDateAnnoy;
			remoteTask.date_due = localTask.dueDate;
			if(localTask.dueTime == nil)
				remoteTask.hasDueTime = NO;
			else
				remoteTask.hasDueTime = YES;

			
			NSMutableArray *mutableTags = [NSMutableArray array];
			for(Tag *tag in localTask.tags)
			{
				[mutableTags addObject:tag.name];
			}
			remoteTask.tags = [NSArray arrayWithArray:mutableTags];
			remoteTask.folder = [localTask.folder.remoteId integerValue];
			remoteTask.context = [localTask.context.remoteId integerValue];
			remoteTask.priority = [localTask.priority integerValue];
			remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
			remoteTask.length = [localTask.duration integerValue];
			remoteTask.note = localTask.note;
			remoteTask.star = [localTask.star boolValue];
			remoteTask.repeat = [localTask.repeat integerValue];
			remoteTask.reminder = [localTask.reminder integerValue];
			
			localTask.lastSyncDate = currentDate;
			localTask.remoteId = [NSNumber numberWithInteger:[tdApi addTask:remoteTask error:&syncError]];
		}
		[remoteTask release];
		if(syncError != nil)
			return NO;
	}
	
	// update die toodledo task, bei allen taskn, die schon mal gesynct wurden
	for(Task *localTask in usedLocalEntityVersion)
	{
		// update toodledo
		GtdTask *remoteTask = [[GtdTask alloc] init];
		
		// sende update request nur, wenn der task nicht sowieso gelöscht wird
		BOOL requestSuccessful = YES;
		
		if([localTask.deleted intValue] == 0)
		{
			remoteTask.uid = [localTask.remoteId integerValue];
			remoteTask.title = localTask.name;
			remoteTask.date_created = localTask.creationDate;
			remoteTask.date_modified = localTask.lastLocalModification;
			remoteTask.date_start = localTask.startDateAnnoy;
			remoteTask.date_due = localTask.dueDate;
			if(localTask.dueTime == nil)
				remoteTask.hasDueTime = NO;
			else
				remoteTask.hasDueTime = YES;
			ALog(@"remoteTask.date_due: %@, localTask.dueDate: %@, localTask.dueTime: %@", remoteTask.date_due, localTask.dueDate, localTask.dueTime);
			NSMutableArray *mutableTags = [NSMutableArray array];
			for(Tag *tag in localTask.tags)
			{
				[mutableTags addObject:tag.name];
			}
			remoteTask.tags = [NSArray arrayWithArray:mutableTags];
			remoteTask.folder = [localTask.folder.remoteId integerValue];
			remoteTask.context = [localTask.context.remoteId integerValue];
			remoteTask.priority = [localTask.priority integerValue];
			remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
			remoteTask.length = [localTask.duration integerValue];
			remoteTask.note = localTask.note;
			remoteTask.star = [localTask.star boolValue];
			remoteTask.repeat = [localTask.repeat integerValue];
			remoteTask.reminder = [localTask.reminder integerValue];
			
			localTask.lastSyncDate = currentDate;
			requestSuccessful = [tdApi editTask:remoteTask error:&syncError];
		}
		
		[remoteTask release];
		if(!requestSuccessful)
			return NO;
	}
	
	// jetzt fehlen nur noch die noch nie gesyncten lokalen Task
	// --> toodledo-add
	NSArray *unsyncedTasks = [Task getUnsyncedTasks:&syncError];
	if(syncError != nil)
		return NO;
	for(Task *localTask in unsyncedTasks)
	{
		GtdTask *remoteTask = [[GtdTask alloc] init];
		remoteTask.uid = -1;
		remoteTask.title = localTask.name;
		remoteTask.date_created = localTask.creationDate;
		remoteTask.date_modified = localTask.lastLocalModification;
		remoteTask.date_start = localTask.startDateAnnoy;
		remoteTask.date_due = localTask.dueDate;
		if(localTask.dueTime == nil)
			remoteTask.hasDueTime = NO;
		else
			remoteTask.hasDueTime = YES;
		NSMutableArray *mutableTags = [NSMutableArray array];
		for(Tag *tag in localTask.tags)
		{
			[mutableTags addObject:tag.name];
		}
		remoteTask.tags = [NSArray arrayWithArray:mutableTags];
		remoteTask.folder = [localTask.folder.remoteId integerValue];
		remoteTask.context = [localTask.context.remoteId integerValue];
		remoteTask.priority = [localTask.priority integerValue];
		remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
		remoteTask.length = [localTask.duration integerValue];
		remoteTask.note = localTask.note;
		remoteTask.star = [localTask.star boolValue];
		remoteTask.repeat = [localTask.repeat integerValue];
		remoteTask.reminder = [localTask.reminder integerValue];
		
		localTask.remoteId = [NSNumber numberWithInteger:[tdApi addTask:remoteTask error:&syncError]];
		localTask.lastSyncDate = currentDate;
		[remoteTask release];
		if(syncError != nil)
			return NO;
	}
	
	// alle task mit remoteId != nil && deleted == true ==> delete toodledo
	NSArray *tasksToDeleteRemote = [Task getRemoteStoredTasksLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[tasksToDeleteRemote count]; i++)
	{
		Task * taskToDeleteRemote = [tasksToDeleteRemote objectAtIndex:i];
		GtdTask *newTask = [[GtdTask alloc] init];
		newTask.uid = [taskToDeleteRemote.remoteId integerValue];
		BOOL requestSuccessful = YES;
		requestSuccessful = [tdApi deleteTask:newTask error:&syncError];
		[newTask release];
		if(!requestSuccessful)
		{
			// ignoriere Fehler, dann wurde der Task eben schon von einem
			// anderen in der Zwischenzeit gelöscht
			if(![syncError code] == GtdApiDataError)
				return NO;
			syncError = nil;
		}
	}
	
	// alle task mit deleted == true lokal löschen
	NSArray *tasksToDeleteLocally = [Task getAllTasksLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[tasksToDeleteLocally count]; i++)
	{
		Task *taskToDeleteLocally = [tasksToDeleteLocally objectAtIndex:i];
		[Task deleteObjectFromPersistentStore:taskToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
	
}

-(BOOL)syncTasksPreferLocal
{	
	NSArray *remoteTasks = [tdApi getTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localTasksWithRemoteIdArray = [Task getRemoteStoredTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Tasks
	// sobald ein remote-pendant gefunden wurde, entferne task aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen aber aufgrund der
	// höheren priorität der lokalen version remote wieder geadded werden
	NSMutableArray *localTasksWithRemoteId = [NSMutableArray array];
	[localTasksWithRemoteId addObjectsFromArray:localTasksWithRemoteIdArray];
	NSMutableArray *usedLocalEntityVersion = [[[NSMutableArray alloc] init] autorelease];
	
	for(GtdTask *remoteTask in remoteTasks)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Task, ob gleiche id existiert
		for(int i=0; i<[localTasksWithRemoteId count]; i++)
		{
			Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
			if([localTask.remoteId integerValue] == remoteTask.uid)
			{
				foundLocalEntity = YES;
				[usedLocalEntityVersion addObject:localTask];
				[localTasksWithRemoteId removeObject:localTask];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Task *newTask = (Task*)[Task objectOfType:@"Task"];
			newTask.name = remoteTask.title;
			newTask.creationDate = remoteTask.date_created;
			newTask.modificationDate = remoteTask.date_modified;
			newTask.startDateAnnoy = remoteTask.date_start; // ???
			if(remoteTask.hasDueDate)
				newTask.dueDate = remoteTask.date_due;
			else
				newTask.dueDate = nil;
			if(remoteTask.hasDueTime)
				newTask.dueTime = remoteTask.date_due;
			else
				newTask.dueTime = nil;
			
			for(NSString *remoteTag in remoteTask.tags)
			{
				if(![remoteTag isEqualToString:@""])
				{
					Tag* tag = [Tag getTagWithName:remoteTag error:&syncError];
					if(syncError != nil)
						return NO;
					if(tag == nil)
					{
						tag = (Tag*)[Tag objectOfType:@"Tag"];
						tag.name = remoteTag;
					}
					if(![[tag tasks] containsObject:newTask])
						[tag addTasksObject:newTask];
					if(![[newTask tags] containsObject:tag])
						[newTask addTagsObject:tag];
				}
			}
			Folder *folder = [Folder getFolderWithRemoteId:[NSNumber numberWithInteger:remoteTask.folder] error:&syncError];
			if(syncError != nil)
				return NO;
			if(folder != nil)
			{
				[folder addTasksObject:newTask];
				[newTask setFolder:folder];
			}
			Context *context = [Context getContextWithRemoteId:[NSNumber numberWithInteger:remoteTask.context] error:&syncError];
			if(syncError != nil)
				return NO;
			if(context != nil)
			{
				[context addTasksObject:newTask];
				[newTask setContext:context];
			}
			newTask.priority = [NSNumber numberWithInteger:remoteTask.priority];
			newTask.isCompleted = (remoteTask.completed != nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
			newTask.duration = [NSNumber numberWithInteger:remoteTask.length]; // number of minutes to complete???
			newTask.note = remoteTask.note;
			newTask.star = [NSNumber numberWithBool:remoteTask.star];
			newTask.repeat = [NSNumber numberWithInteger:remoteTask.repeat];
			//newTask.whatever = remoteTask.status; // wird bei uns nicht verwendet
			newTask.reminder = [NSNumber numberWithInteger:remoteTask.reminder];
			//newTask.parentId = remoteTask.parentId; // wird bei uns nicht verwendet
			newTask.remoteId = [NSNumber numberWithInteger:remoteTask.uid];
			newTask.lastSyncDate = currentDate;
		}
	}
	
	// füge nun remote gelöschte task wieder hinzu, aber nur wenn sie nicht
	// auch zufällig lokal als deleted gekennzeichnet wurden
	for(int i=0;i<[localTasksWithRemoteId count];i++)
	{
		GtdTask *remoteTask = [[GtdTask alloc] init];
		Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
		if([localTask.deleted intValue] == 0)
		{
			remoteTask.title = localTask.name;
			remoteTask.date_created = localTask.creationDate;
			remoteTask.date_modified = localTask.lastLocalModification;
			remoteTask.date_start = localTask.startDateAnnoy;
			remoteTask.date_due = localTask.dueDate;
			if(localTask.dueTime == nil)
				remoteTask.hasDueTime = NO;
			else
				remoteTask.hasDueTime = YES;
			NSMutableArray *mutableTags = [NSMutableArray array];
			for(Tag *tag in localTask.tags)
			{
				[mutableTags addObject:tag.name];
			}
			remoteTask.tags = [NSArray arrayWithArray:mutableTags];
			remoteTask.folder = [localTask.folder.remoteId integerValue];
			remoteTask.context = [localTask.context.remoteId integerValue];
			remoteTask.priority = [localTask.priority integerValue];
			remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
			remoteTask.length = [localTask.duration integerValue];
			remoteTask.note = localTask.note;
			remoteTask.star = [localTask.star boolValue];
			remoteTask.repeat = [localTask.repeat integerValue];
			remoteTask.reminder = [localTask.reminder integerValue];
			
			localTask.lastSyncDate = currentDate;
			localTask.remoteId = [NSNumber numberWithInteger:[tdApi addTask:remoteTask error:&syncError]];
		}
		[remoteTask release];
		if(syncError != nil)
			return NO;
	}
	
	// update die toodledo task, bei allen taskn, die schon mal gesynct wurden
	for(Task *localTask in usedLocalEntityVersion)
	{
		// update toodledo
		GtdTask *remoteTask = [[GtdTask alloc] init];
		
		// sende update request nur, wenn der task nicht sowieso gelöscht wird
		BOOL requestSuccessful = YES;
		
		if([localTask.deleted intValue] == 0)
		{
			remoteTask.uid = [localTask.remoteId integerValue];
			remoteTask.title = localTask.name;
			remoteTask.date_created = localTask.creationDate;
			remoteTask.date_modified = localTask.lastLocalModification;
			remoteTask.date_start = localTask.startDateAnnoy;
			remoteTask.date_due = localTask.dueDate;
			if(localTask.dueTime == nil)
				remoteTask.hasDueTime = NO;
			else
				remoteTask.hasDueTime = YES;
			ALog(@"remoteTask.date_due: %@, localTask.dueDate: %@, localTask.dueTime: %@", remoteTask.date_due, localTask.dueDate, localTask.dueTime);
			NSMutableArray *mutableTags = [NSMutableArray array];
			for(Tag *tag in localTask.tags)
			{
				[mutableTags addObject:tag.name];
			}
			remoteTask.tags = [NSArray arrayWithArray:mutableTags];
			remoteTask.folder = [localTask.folder.remoteId integerValue];
			remoteTask.context = [localTask.context.remoteId integerValue];
			remoteTask.priority = [localTask.priority integerValue];
			remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
			remoteTask.length = [localTask.duration integerValue];
			remoteTask.note = localTask.note;
			remoteTask.star = [localTask.star boolValue];
			remoteTask.repeat = [localTask.repeat integerValue];
			remoteTask.reminder = [localTask.reminder integerValue];
			
			localTask.lastSyncDate = currentDate;
			requestSuccessful = [tdApi editTask:remoteTask error:&syncError];
		}
		
		[remoteTask release];
		if(!requestSuccessful)
			return NO;
	}
	
	// jetzt fehlen nur noch die noch nie gesyncten lokalen Task
	// --> toodledo-add
	NSArray *unsyncedTasks = [Task getUnsyncedTasks:&syncError];
	if(syncError != nil)
		return NO;
	for(Task *localTask in unsyncedTasks)
	{
		GtdTask *remoteTask = [[GtdTask alloc] init];
		remoteTask.uid = -1;
		remoteTask.title = localTask.name;
		remoteTask.date_created = localTask.creationDate;
		remoteTask.date_modified = localTask.lastLocalModification;
		remoteTask.date_start = localTask.startDateAnnoy;
		remoteTask.date_due = localTask.dueDate;
		if(localTask.dueTime == nil)
			remoteTask.hasDueTime = NO;
		else
			remoteTask.hasDueTime = YES;
		NSMutableArray *mutableTags = [NSMutableArray array];
		for(Tag *tag in localTask.tags)
		{
			[mutableTags addObject:tag.name];
		}
		remoteTask.tags = [NSArray arrayWithArray:mutableTags];
		remoteTask.folder = [localTask.folder.remoteId integerValue];
		remoteTask.context = [localTask.context.remoteId integerValue];
		remoteTask.priority = [localTask.priority integerValue];
		remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
		remoteTask.length = [localTask.duration integerValue];
		remoteTask.note = localTask.note;
		remoteTask.star = [localTask.star boolValue];
		remoteTask.repeat = [localTask.repeat integerValue];
		remoteTask.reminder = [localTask.reminder integerValue];
		
		localTask.remoteId = [NSNumber numberWithInteger:[tdApi addTask:remoteTask error:&syncError]];
		localTask.lastSyncDate = currentDate;
		[remoteTask release];
		if(syncError != nil)
			return NO;
	}
	
	// alle task mit remoteId != nil && deleted == true ==> delete toodledo
	NSArray *tasksToDeleteRemote = [Task getRemoteStoredTasksLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[tasksToDeleteRemote count]; i++)
	{
		Task * taskToDeleteRemote = [tasksToDeleteRemote objectAtIndex:i];
		GtdTask *newTask = [[GtdTask alloc] init];
		newTask.uid = [taskToDeleteRemote.remoteId integerValue];
		BOOL requestSuccessful = YES;
		requestSuccessful = [tdApi deleteTask:newTask error:&syncError];
		[newTask release];
		if(!requestSuccessful)
		{
			// ignoriere Fehler, dann wurde der Task eben schon von einem
			// anderen in der Zwischenzeit gelöscht
			if(![syncError code] == GtdApiDataError)
				return NO;
			syncError = nil;
		}
	}
	
	// alle task mit deleted == true lokal löschen
	NSArray *tasksToDeleteLocally = [Task getAllTasksLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[tasksToDeleteLocally count]; i++)
	{
		Task *taskToDeleteLocally = [tasksToDeleteLocally objectAtIndex:i];
		[Task deleteObjectFromPersistentStore:taskToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
	
}

-(BOOL)syncTasksPreferRemote
{
	NSArray *remoteTasks = [tdApi getTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	NSArray *localTasksWithRemoteIdArray = [Task getRemoteStoredTasks:&syncError];
	if(syncError != nil)
		return NO;
	
	// initialisiere zunächst mit allen bereits gesyncten Taskn
	// sobald ein remote-pendant gefunden wurde, entferne task aus dieser collection
	// die übrig gebliebenen wurden remote entfernt, müssen daher aufgrund
	// der höheren Priorität der remote Version lokal gelöscht werden
	NSMutableArray *localTasksWithRemoteId = [NSMutableArray array];
	[localTasksWithRemoteId addObjectsFromArray:localTasksWithRemoteIdArray];
	
	for(GtdTask *remoteTask in remoteTasks)
	{
		BOOL foundLocalEntity = NO;
		// durchsuche lokale Task, ob gleiche id existiert
		for(int i=0; i<[localTasksWithRemoteId count]; i++)
		{
			Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
			if([localTask.remoteId integerValue] == remoteTask.uid)
			{
				foundLocalEntity = YES;
				
				localTask.deleted = [NSNumber numberWithInteger:0]; // verhindere möglichen Löschvorgang
				// überschreibe lokale Felder
				localTask.lastSyncDate = currentDate;
				localTask.name = remoteTask.title;
				localTask.creationDate = remoteTask.date_created;
				//localTask.lastLocalModification = remoteTask.date_modified;
				localTask.startDateAnnoy = remoteTask.date_start; // ???
				if(remoteTask.hasDueDate)
					localTask.dueDate = remoteTask.date_due;
				else
					localTask.dueDate = nil;
				if(remoteTask.hasDueTime)
					localTask.dueTime = remoteTask.date_due;
				else
					localTask.dueTime = nil;
				
				NSMutableArray *tagsToRemove = [NSMutableArray array];
				for(Tag *tag in localTask.tags)
				{
					[tagsToRemove addObject:tag];
				}
				for(Tag *tag in tagsToRemove)
				{
					[tag removeTasksObject:localTask];
				}
				[localTask removeTags:localTask.tags];
				for(NSString *remoteTag in remoteTask.tags)
				{
					if(![remoteTag isEqualToString:@""])
					{
						Tag* tag = [Tag getTagWithName:remoteTag error:&syncError];
						if(syncError != nil)
							return NO;
						if(tag == nil)
						{
							tag = (Tag*)[Tag objectOfType:@"Tag"];
							tag.name = remoteTag;
						}
						if(![[tag tasks] containsObject:localTask])
							[tag addTasksObject:localTask];
						if(![[localTask tags] containsObject:tag])
							[localTask addTagsObject:tag];
					}
				}
				
				if(localTask.folder != nil)
				{
					[localTask.folder removeTasksObject:localTask];
					localTask.folder = nil;
				}
				Folder *folder = [Folder getFolderWithRemoteId:[NSNumber numberWithInteger:remoteTask.folder] error:&syncError];
				if(syncError != nil)
					return NO;
				if(folder != nil)
				{
					[folder addTasksObject:localTask];
					[localTask setFolder:folder];
				}
				
				if(localTask.context != nil)
				{
					[localTask.context removeTasksObject:localTask];
					localTask.context = nil;
				}
				Context *context = [Context getContextWithRemoteId:[NSNumber numberWithInteger:remoteTask.context] error:&syncError];
				if(syncError != nil)
					return NO;
				if(context != nil)
				{
					[context addTasksObject:localTask];
					[localTask setContext:context];
				}
				localTask.priority = [NSNumber numberWithInteger:remoteTask.priority];
				localTask.isCompleted = (remoteTask.completed != nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
				localTask.duration = [NSNumber numberWithInteger:remoteTask.length]; // number of minutes to complete???
				localTask.note = remoteTask.note;
				localTask.star = [NSNumber numberWithBool:remoteTask.star];
				localTask.repeat = [NSNumber numberWithInteger:remoteTask.repeat];
				//newTask.whatever = remoteTask.status; // wird bei uns nicht verwendet
				localTask.reminder = [NSNumber numberWithInteger:remoteTask.reminder];
				//newTask.parentId = remoteTask.parentId; // wird bei uns nicht verwendet
				localTask.remoteId = [NSNumber numberWithInteger:remoteTask.uid];
				localTask.lastSyncDate = currentDate;
				
				[localTasksWithRemoteId removeObject:localTask];
				break;
			}
		}
		if(!foundLocalEntity)
		{
			// add local
			Task *newTask = (Task*)[Task objectOfType:@"Task"];
			newTask.name = remoteTask.title;
			newTask.creationDate = remoteTask.date_created;
			newTask.modificationDate = remoteTask.date_modified;
			newTask.startDateAnnoy = remoteTask.date_start; // ???
			if(remoteTask.hasDueDate)
				newTask.dueDate = remoteTask.date_due;
			else
				newTask.dueDate = nil;
			if(remoteTask.hasDueTime)
				newTask.dueTime = remoteTask.date_due;
			else
				newTask.dueTime = nil;
			
			for(NSString *remoteTag in remoteTask.tags)
			{
				if(![remoteTag isEqualToString:@""])
				{
					Tag* tag = [Tag getTagWithName:remoteTag error:&syncError];
					if(syncError != nil)
						return NO;
					if(tag == nil)
					{
						tag = (Tag*)[Tag objectOfType:@"Tag"];
						tag.name = remoteTag;
					}
					if(![[tag tasks] containsObject:newTask])
						[tag addTasksObject:newTask];
					if(![[newTask tags] containsObject:tag])
						[newTask addTagsObject:tag];
				}
			}
			Folder *folder = [Folder getFolderWithRemoteId:[NSNumber numberWithInteger:remoteTask.folder] error:&syncError];
			if(syncError != nil)
				return NO;
			if(folder != nil)
			{
				[folder addTasksObject:newTask];
				[newTask setFolder:folder];
			}
			Context *context = [Context getContextWithRemoteId:[NSNumber numberWithInteger:remoteTask.context] error:&syncError];
			if(syncError != nil)
				return NO;
			if(context != nil)
			{
				[context addTasksObject:newTask];
				[newTask setContext:context];
			}
			newTask.priority = [NSNumber numberWithInteger:remoteTask.priority];
			newTask.isCompleted = (remoteTask.completed != nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
			newTask.duration = [NSNumber numberWithInteger:remoteTask.length]; // number of minutes to complete???
			newTask.note = remoteTask.note;
			newTask.star = [NSNumber numberWithBool:remoteTask.star];
			newTask.repeat = [NSNumber numberWithInteger:remoteTask.repeat];
			//newTask.whatever = remoteTask.status; // wird bei uns nicht verwendet
			newTask.reminder = [NSNumber numberWithInteger:remoteTask.reminder];
			//newTask.parentId = remoteTask.parentId; // wird bei uns nicht verwendet
			newTask.remoteId = [NSNumber numberWithInteger:remoteTask.uid];
			newTask.lastSyncDate = currentDate;
		}
	}
	
	// merke alle lokalen Task, zu denen kein remote-Pendant gefunden wurde
	// zum löschen vor
	for(int i=0;i<[localTasksWithRemoteId count];i++)
	{
		Task *localTask = [localTasksWithRemoteId objectAtIndex:i];
		localTask.deleted = [NSNumber numberWithInteger:1];
	}
	
	// jetzt fehlen nur noch die noch nie gesyncten lokalen Task
	// --> toodledo-add
	NSArray *unsyncedTasks = [Task getUnsyncedTasks:&syncError];
	if(syncError != nil)
		return NO;
	for(Task *localTask in unsyncedTasks)
	{
		GtdTask *remoteTask = [[GtdTask alloc] init];
		remoteTask.uid = -1;
		remoteTask.title = localTask.name;
		remoteTask.date_created = localTask.creationDate;
		remoteTask.date_modified = localTask.lastLocalModification;
		remoteTask.date_start = localTask.startDateAnnoy;
		remoteTask.date_due = localTask.dueDate;
		if(localTask.dueTime == nil)
			remoteTask.hasDueTime = NO;
		else
			remoteTask.hasDueTime = YES;
		NSMutableArray *mutableTags = [NSMutableArray array];
		for(Tag *tag in localTask.tags)
		{
			[mutableTags addObject:tag.name];
		}
		remoteTask.tags = [NSArray arrayWithArray:mutableTags];
		remoteTask.folder = [localTask.folder.remoteId integerValue];
		remoteTask.context = [localTask.context.remoteId integerValue];
		remoteTask.priority = [localTask.priority integerValue];
		remoteTask.completed = ([localTask.isCompleted boolValue] ? [NSDate dateWithTimeIntervalSince1970:0] : nil);
		remoteTask.length = [localTask.duration integerValue];
		remoteTask.note = localTask.note;
		remoteTask.star = [localTask.star boolValue];
		remoteTask.repeat = [localTask.repeat integerValue];
		remoteTask.reminder = [localTask.reminder integerValue];
		
		localTask.remoteId = [NSNumber numberWithInteger:[tdApi addTask:remoteTask error:&syncError]];
		localTask.lastSyncDate = currentDate;
		[remoteTask release];
		if(syncError != nil)
			return NO;
	}	
	
	// alle task mit deleted == true lokal löschen
	NSArray *tasksToDeleteLocally = [Task getAllTasksLocallyDeleted:&syncError];
	if(syncError != nil)
		return NO;
	for(int i=0; i<[tasksToDeleteLocally count]; i++)
	{
		Task *taskToDeleteLocally = [tasksToDeleteLocally objectAtIndex:i];
		[Task deleteObjectFromPersistentStore:taskToDeleteLocally error:&syncError];
		if(syncError != nil)
			return NO;
	}
	
	return YES;
}

-(BOOL)deleteAllLocalFolders
{
	NSArray *allFolders = [Folder getAllFoldersInStore:&syncError];
	if(syncError != nil)
		return NO;
	for(Folder *folder in allFolders)
	{
		[Folder deleteObjectFromPersistentStore:folder error:&syncError];
		if(syncError != nil)
			return NO;
	}
	return YES;
}

-(BOOL)deleteAllLocalContexts
{
	NSArray *allContexts = [Context getAllContextsInStore:&syncError];
	if(syncError != nil)
		return NO;
	for(Context *context in allContexts)
	{
		[Context deleteObjectFromPersistentStore:context error:&syncError];
		if(syncError != nil)
			return NO;
	}
	return YES;
}

-(BOOL)deleteAllLocalTags
{
	NSArray *allTags = [Tag getAllTagsInStore:&syncError];
	if(syncError != nil)
		return NO;
	for(Tag *tag in allTags)
	{
		[Tag deleteObjectFromPersistentStore:tag error:&syncError];
		if(syncError != nil)
			return NO;
	}
	return YES;
}

-(BOOL)deleteAllLocalTasks
{
	NSArray *allTasks = [Task getAllTasksInStore:&syncError];
	if(syncError != nil)
		return NO;
	for(Task *task in allTasks)
	{
		[Task deleteObjectFromPersistentStore:task error:&syncError];
		if(syncError != nil)
			return NO;
	}
	return YES;
}

-(BOOL)deleteAllRemoteFolders
{
	NSArray *allFolders = [tdApi getFolders:&syncError];
	if(syncError != nil)
		return NO;
	for(GtdFolder *folder in allFolders)
	{
		BOOL successful = [tdApi deleteFolder:folder error:&syncError];
		if(!successful)
			ALog(@"Error deleting folder... continued to prevent inconsistency");
	}
	return YES;
}

-(BOOL)deleteAllRemoteContexts
{
	NSArray *allContexts = [tdApi getContexts:&syncError];
	if(syncError != nil)
		return NO;
	for(GtdContext *context in allContexts)
	{
		BOOL successful = [tdApi deleteContext:context error:&syncError];
		if(!successful)
			ALog(@"Error deleting context... continued to prevent inconsistency");
	}
	return YES;
}

-(BOOL)deleteAllRemoteTasks
{
	NSArray *allTasks = [tdApi getTasks:&syncError];
	ALog(@"Received %d tasks to delete", [allTasks count]);
	if(syncError != nil)
		return NO;
	for(GtdTask *task in allTasks)
	{
		ALog(@"Trying to delete tasks with id %d and title %a", [task uid], [task title]);
		BOOL successful = [tdApi deleteTask:task error:&syncError];
		if(!successful)
			ALog(@"Error deleting task... continued to prevent inconsistency");
	}
	return YES;
}


-(BOOL)exitFailure:(NSError **)error
{
	*error = syncError;
	[BaseManagedObject rollback];
	[self startAutocommit];
	[tdApi release];
	return NO;
}

-(void)stopAutocommit {
	Less2DoAppDelegate *appDelegate;
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate stopTimer];
	//ALog(@"Timer for Autocommit has been stopped!"); 
	
}

-(void)startAutocommit {
	Less2DoAppDelegate *appDelegate;
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate startTimer];
	
	//ALog(@"Timer for Autocommit has been started!"); 
}

@end
