//
//  SyncManager.m
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"


@implementation SyncManager

@synthesize tdApi;
@synthesize isConnected;
@synthesize syncError;
@synthesize currentDate;

/* deprecated */
+(BOOL)syncWithPreferenceOld:(SyncPreference)preference error:(NSError**)error
{
	NSError *localError;
	BOOL requestSuccessful = NO;
	NSDate *currentDate = [NSDate date];
	//TDApi *tdApi = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&localError];
	TDApi *tdApi = [[TDApi alloc] initWithUsername:@"j.kurz@gmx.at" password:@"fubar100508529" error:&localError];
	//ALog(@"tdApi init error: %@", localError);

	
	// 1. commit unsaved changes - damit werden alle local modified dates gesetzt
	[BaseManagedObject commit];
	
	NSArray *testFuck = [Folder getUnsyncedFolders:&localError];
	NSLog(@"count: %d", [testFuck count]);
	
	for(Folder * f in testFuck)
	{
		NSLog(@"Name: %@ remoteId: %d", f.name,[f.remoteId integerValue]);
	}
	
	
	//AutoCommit disable
	[self stopAutocommit];
	
	// suche ältestes lokales Änderungsdatum
	// hole remote-Änderungsdatum der Folder
	// wenn das remote-Änderungsdatum neuer ist als die letzte lokale Änderung --> hole Folders, sonst nicht (spart traffic)
	NSDate *oldestLocalFolderDate = [Folder modificationDateOfType:@"Folder" dateType:((preference == SyncPreferRemote)?DateTypeOldest:DateTypeYoungest) error:&localError];
	NSDate *oldestLocalSyncDate = [Folder syncDateOfType:@"Folder" dateType:((preference == SyncPreferRemote)?DateTypeOldest:DateTypeYoungest) error:&localError];
	NSMutableDictionary *remoteDates = [tdApi getLastModificationsDates:&localError];
	NSString  *lastRemoteFolderEditString = [remoteDates valueForKey:@"lastFolderEdit"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	//[formatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *lastRemoteFolderEditDate = [formatter dateFromString:lastRemoteFolderEditString];
	lastRemoteFolderEditDate = [lastRemoteFolderEditDate addTimeInterval:21600]; // hardcodiert: server time difference
	[formatter release];
	
	BOOL fetchedRemote = NO;
	NSMutableArray *usedLocalEntityVersion = nil;
	if (oldestLocalFolderDate == nil // noch keine Folder vorhanden
		|| ([lastRemoteFolderEditDate compare:oldestLocalFolderDate] == NSOrderedDescending // Remote aktueller als Folder
			&& (oldestLocalSyncDate == nil // noch kein Sync stattgefunden
				|| [lastRemoteFolderEditDate compare:oldestLocalSyncDate] == NSOrderedDescending))) // Remote aktueller als letzter Sync
	{ 
		fetchedRemote = YES;
		NSArray *remoteFolders = [tdApi getFolders:&localError];
		NSArray *localFoldersWithRemoteIdArray = [Folder getRemoteStoredFolders:&localError];
		NSMutableArray *localFoldersWithRemoteId = [NSMutableArray array];
		[localFoldersWithRemoteId addObjectsFromArray:localFoldersWithRemoteIdArray];
		usedLocalEntityVersion = [[NSMutableArray alloc] init];
		
		for(GtdFolder *remoteFolder in remoteFolders)
		{
			BOOL foundLocalEntity = NO;
			// durchsuche lokale Folder, ob gleiche id existiert
			for(int i=0; i<[localFoldersWithRemoteId count]; i++)
			{
				Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
				ALog(@"%@ - %d", localFolder.name, [localFolder.deleted integerValue]);
				if([localFolder.remoteId integerValue] == remoteFolder.uid)
				{
					foundLocalEntity = YES;
					/*
					   HIER VERSCHIEDENE MÖGLICHKEITEN EINBAUEN
					   1. nach preference
					        a) preferRemote --> überschreibe jedenfalls lokale Entities
						    b) preferLocal --> überschreibe jedenfalls remote Entities
					   2. nach datum
					        geht nicht so recht für folder/contexts, weil dazu remote kein änderungsdatum gespeichert wird
					        bei tasks:
							  je nachdem, welches änderungsdatum neuer ist --> überschreibe ältere version
					*/
					if(preference == SyncPreferRemote)
					{
						localFolder.deleted = [NSNumber numberWithInteger:0]; // verhindere möglichen Löschvorgang
						// überschreibe lokale Felder
						localFolder.name = remoteFolder.title;
						localFolder.order = [NSNumber numberWithInteger:remoteFolder.order];
						// weiter unten: nsset tasks
						localFolder.lastSyncDate = currentDate;
					}
					else
					{
						[usedLocalEntityVersion addObject:localFolder];
					}

					[localFoldersWithRemoteId removeObject:localFolder];
					i--;
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
		
		if(preference == SyncPreferRemote)
		{
			for(int i=0;i<[localFoldersWithRemoteId count];i++)
			{
				Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
				localFolder.deleted = [NSNumber numberWithInteger:1];
			}
		}
		else
		{
			// toodledo add localFoldersWithRemoteId
			for(int i=0;i<[localFoldersWithRemoteId count];i++)
			{
				GtdFolder *remoteFolder = [[GtdFolder alloc] init];
				Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
				remoteFolder.title = localFolder.name;
				remoteFolder.order = [localFolder.order integerValue];
				//remoteFolder.uid = [localFolder.remoteId integerValue];
				requestSuccessful = YES;
				localError = nil;
				if([localFolder.deleted intValue] == 0)
				{
					localFolder.lastSyncDate = currentDate;
					localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:remoteFolder error:&localError]];
				}
				[remoteFolder release];
				if(localError != nil)
				{
					*error = localError;
					[BaseManagedObject rollback];
					[self startAutocommit];
					[tdApi release];
					return NO;
				}
			}
		}

	}
	
	// sync data to remote
	if(fetchedRemote) // mit der datenstruktur herumtun
	{
		for(Folder *localFolder in usedLocalEntityVersion)
		{
			// update toodledo
			GtdFolder *newFolder = [[GtdFolder alloc] init];
			newFolder.title = localFolder.name;
			newFolder.order = [localFolder.order integerValue];
			newFolder.uid = [localFolder.remoteId integerValue];
			
			// sende update request nur, wenn der folder nicht sowieso gelöscht wird
			requestSuccessful = YES;
			ALog(@"lastSync: %@, lastLocalMod: %@, deleted: %d", localFolder.lastSyncDate, localFolder.lastLocalModification, [localFolder.deleted integerValue]);
			if([localFolder.deleted intValue] == 0)
			{
				localFolder.lastSyncDate = currentDate;
				requestSuccessful = [tdApi editFolder:newFolder error:&localError];
			}
			
			[newFolder release];
			if(!requestSuccessful)
			{
				*error = localError;
				[BaseManagedObject rollback];
				[self startAutocommit];
				[tdApi release];
				return NO;
			}
		}
		[usedLocalEntityVersion release];
		
		// alle folder mit remoteId == nil && deleted == false ==> add toodledo
		NSArray *unsyncedFolders = [Folder getUnsyncedFolders:&localError];
		ALog(@"VOR DER SCHLEIFE %d", [unsyncedFolders count]);
		for(Folder *localFolder in unsyncedFolders)
		{
			GtdFolder *newFolder = [[GtdFolder alloc] init];
			newFolder.title = localFolder.name;
			newFolder.order = [localFolder.order integerValue];
			newFolder.private = NO;
			newFolder.uid = -1;
			NSLog(@"ENDLOS OBEN");
			
			localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&localError]];
			localFolder.lastSyncDate = currentDate;
			[newFolder release];
		}
		NSLog(@"NACH DER SCHLEIFE");
	}
	else // vergleiche sync date und mod date
	{
		NSArray *modifiedFolders = [Folder getModifiedFolders:&localError];
		
		// für alle folder:
			// wenn lastSyncDate < lastLocalModification
				// wenn remoteId == nil ==> add toodledo
				// else ==> update toodledo		
		for(Folder * localFolder in modifiedFolders)
		{
			if([localFolder.remoteId intValue] == -1)
			{
				GtdFolder *newFolder = [[GtdFolder alloc] init];
				newFolder.title = localFolder.name;
				newFolder.order = [localFolder.order integerValue];
				NSLog(@"ENDLOS UNTEN");
				localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&localError]];
				localFolder.lastSyncDate = currentDate;
				[newFolder release];
			}
			else 
			{
				GtdFolder *newFolder = [[GtdFolder alloc] init];
				newFolder.title = localFolder.name;
				newFolder.order = [localFolder.order integerValue];
				newFolder.uid = [localFolder.remoteId integerValue];
				localFolder.lastSyncDate =currentDate; 
				requestSuccessful = [tdApi editFolder:newFolder error:&localError];
				[newFolder release];
				if(!requestSuccessful)
				{
					*error = localError;
					[BaseManagedObject rollback];
					[self startAutocommit];
					[tdApi release];
					return NO;
				}
			}

		}
	}
	// alle folder mit remoteId != nil && deleted == true ==> delete toodledo
	localError = nil;
	NSArray *foldersToDeleteRemote = [Folder getRemoteStoredFoldersLocallyDeleted:&localError];
	if(localError != nil)
	ALog(@"Error ftdr: %@", localError);
	for(int i=0; i<[foldersToDeleteRemote count]; i++)
	{
		Folder * folderToDeleteRemote = [foldersToDeleteRemote objectAtIndex:i];
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.uid = [folderToDeleteRemote.remoteId integerValue];
		requestSuccessful = [tdApi deleteFolder:newFolder error:&localError];
		[newFolder release];
		if(!requestSuccessful)
		{
			*error = localError;
			[BaseManagedObject rollback];
			[self startAutocommit];
			[tdApi release];
			return NO;
		}
	}
	
	// alle folder mit deleted == true lokal löschen
	
	NSArray *foldersToDeleteLocally = [Folder getAllFoldersLocallyDeleted:&localError];
	for(int i=0; i<[foldersToDeleteLocally count]; i++)
	{
		Folder *folderToDeleteLocally = [foldersToDeleteLocally objectAtIndex:i];
		[Folder deleteObjectFromPersistentStore:folderToDeleteLocally error:&localError];
	}
	
	[BaseManagedObject commitWithoutLocalModification];
	[self startAutocommit];
	[tdApi release];
	return YES;
}

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
	//TDApi *tdApi = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&localError];
	tdApi = [[TDApi alloc] initWithUsername:@"j.kurz@gmx.at" password:@"fubar100508529" error:&syncError];
	
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
			wasSuccessful = [self syncFoldersPreferLocal];
			if(!wasSuccessful)
			{
				*error = syncError;
				[BaseManagedObject rollback];
				[self startAutocommit];
				[tdApi release];
				return NO;
			}
		}
		else
		{
			wasSuccessful = [self syncFoldersPreferRemote];
			if(!wasSuccessful)
			{
				*error = syncError;
				[BaseManagedObject rollback];
				[self startAutocommit];
				[tdApi release];
				return NO;
			}
		}
		
		[BaseManagedObject commitWithoutLocalModification];
		[self startAutocommit];
		[tdApi release];
		return YES;
	}
	
	return wasSuccessful;
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die lokale
 Version bevorzugt wird.
*/
-(void)overrideLocal:(NSError**)error
{
	
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die remote-
 Version bevorzugt wird.
*/
-(void)overrideRemote:(NSError**)error
{
	/*
	 --- remote -> local ---
	 0. hole remote-modification-dates (syncapi.getmodificationdates)
	 1. erzeuge backup-moc fürs reinschreiben (wird erst mit dem programm-moc gemerged, wenn alles erfolgreich war)
	 2. z.b.: folders (das selbe für tasks und contexts)
		    hole jüngstes lokales modification-date, vergleiche mit folder-remote-moddate
			wenn remote-moddate > local moddate
			-->
			hole alle toodledo-folders
			vergleiche uids && moddates, wenn lokal vorhanden (remoteId != nil) --> überschreibe lokale felder
							 wenn nicht vorhanden --> lege lokal an
	 3. alle lokalen folders, die noch nicht verglichen wurden (muss mitgezählt werden), wurden in der zwischenzeit
	    aus dem remote-speicher gelöscht --> delete them locally
	 4. ersetze programm-moc durch backup-moc
	 Jetzt sollten alle lokalen Task zumindest auf dem Stand von Toodledo sein, dh man kann jetzt alles zurückschreiben.
	 
	 --- local -> remote ---
	 5. z.b.: folders (das selbe für tasks und contexts)
			gehe alle lokalen folders durch
			wenn isDeleted --> delete remote
			für den rest:
			vergleiche uids && moddates, wenn lokal nicht vorhanden (remoteId != nil) --> add remote
										 wenn vorhanden, aber moddates verschieden --> edit remote
										
	 */
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
