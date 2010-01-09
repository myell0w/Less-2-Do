//
//  SyncManager.m
//  Less2Do
//
//  Created by Gerhard Schraml on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "TDApi.h"


@implementation SyncManager

/*
 Führt eine Synchronisation mit automatischer Wahl des aktuelleren Datensatzes durch.
*/
+(void)syncWithPreference:(SyncPreference)preference error:(NSError**)error
{
	NSError *localError;
	TDApi *tdApi = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&localError];
	//ALog(@"tdApi init error: %@", localError);
	// 1. commit unsaved changes - damit werden alle local modified dates gesetzt
	[BaseManagedObject commit];
	
	// suche ältestes lokales Änderungsdatum
	// hole remote-Änderungsdatum der Folder
	// wenn das remote-Änderungsdatum neuer ist als die letzte lokale Änderung --> hole Folders, sonst nicht (spart traffic)
	NSDate *oldestLocalFolderDate = [Folder oldestModificationDateOfType:@"Folder" error:&localError];
	NSDate *oldestLocalSyncDate = [Folder oldestSyncDateOfType:@"Folder" error:&localError];
	NSMutableDictionary *remoteDates = [tdApi getLastModificationsDates:&localError];
	NSString  *lastRemoteFolderEditString = [remoteDates valueForKey:@"lastFolderEdit"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	NSDate *lastRemoteFolderEditDate = [formatter dateFromString:lastRemoteFolderEditString];
	
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
		NSMutableArray *localFoldersWithRemoteId = [[NSMutableArray alloc] init];
		[localFoldersWithRemoteId addObjectsFromArray:localFoldersWithRemoteIdArray];
		usedLocalEntityVersion = [[NSMutableArray alloc] init];
		
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
					if(preference == SyncPreferRemote)
					{
						localFolder.deleted = NO; // verhindere möglichen Löschvorgang
						// überschreibe lokale Felder
						localFolder.name = remoteFolder.title;
						localFolder.order = [NSNumber numberWithInteger:remoteFolder.order];
						// weiter unten: nsset tasks
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
			}
		}
		
		if(preference == SyncPreferRemote)
		{
			for(int i=0;i<[localFoldersWithRemoteId count];i++)
			{
				Folder *localFolder = [localFoldersWithRemoteId objectAtIndex:i];
				localFolder.deleted = YES;
			}
		}
		else
		{
			// toodledo add localFoldersWithRemoteId
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
			BOOL successful = [tdApi editFolder:newFolder error:&localError];
		}
		
		// alle folder mit remoteId == nil && deleted == false ==> add toodledo
		NSArray *unsyncedFolders = [Folder getUnsyncedFolders:&localError];
		for(Folder *localFolder in unsyncedFolders)
		{
			GtdFolder *newFolder = [[GtdFolder alloc] init];
			newFolder.title = localFolder.name;
			newFolder.order = [localFolder.order integerValue];
			localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&localError]];
		}
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
			if(localFolder.remoteId == nil)
			{
				GtdFolder *newFolder = [[GtdFolder alloc] init];
				newFolder.title = localFolder.name;
				newFolder.order = [localFolder.order integerValue];
				localFolder.remoteId = [NSNumber numberWithInteger:[tdApi addFolder:newFolder error:&localError]];
			}
			else 
			{
				GtdFolder *newFolder = [[GtdFolder alloc] init];
				newFolder.title = localFolder.name;
				newFolder.order = [localFolder.order integerValue];
				newFolder.uid = [localFolder.remoteId integerValue];
				BOOL successful = [tdApi editFolder:newFolder error:&localError];
			}

		}

	}
	// alle folder mit remoteId != nil && deleted == true ==> delete toodledo
	
	NSArray *foldersToDeleteRemote = [Folder getRemoteStoredFoldersLocallyDeleted:&localError];
	
	for(Folder * folderToDeleteRemote in foldersToDeleteRemote)
	{
		GtdFolder *newFolder = [[GtdFolder alloc] init];
		newFolder.uid = [folderToDeleteRemote.remoteId integerValue];
		BOOL successful = [tdApi deleteFolder:newFolder error:&localError];
	}
	
	// alle folder mit deleted == true lokal löschen
	
	NSArray *foldersToDeleteLocally = [Folder getAllFoldersLocallyDeleted:&localError];
	for(int i=0; i<[foldersToDeleteLocally count]; i++)
	{
		Folder *folderToDeleteLocally = [foldersToDeleteLocally objectAtIndex:i];
		[Folder deleteObjectFromPersistentStore:folderToDeleteLocally error:&localError];
		
	}

	
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die lokale
 Version bevorzugt wird.
*/
+(void)overrideLocal:(NSError**)error
{
	
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die remote-
 Version bevorzugt wird.
*/
+(void)overrideRemote:(NSError**)error
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

+(void)stopAutocommit
{
	Less2DoAppDelegate *appDelegate;
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.timer invalidate];
	//ALog(@"Timer for Autocommit has been stopped! Fuck"); 
	
}

+(void)startAutocommit
{
	Less2DoAppDelegate *appDelegate;
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.timer = [NSTimer scheduledTimerWithTimeInterval:20.0
														 target:self
													   selector:@selector(commitDatabase:)
													   userInfo:nil
														repeats:YES];
	
	//ALog(@"Timer for Autocommit has been started!"); 
}

@end
