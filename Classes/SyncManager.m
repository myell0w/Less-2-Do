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
+(void)sync:(NSError**)error
{
	TDApi *fuck2 = [[TDApi alloc] initWithUsername:@"g.schraml@gmx.at" password:@"vryehlgg" error:&error];
	NSError *error1;
	// 1. commit unsaved changes - damit werden alle local modified dates gesetzt
	[BaseManagedObject commit];
	
	// suche ältestes lokales Änderungsdatum
	// hole remote-Änderungsdatum der Folder
	// wenn das remote-Änderungsdatum neuer ist als die letzte lokale Änderung --> hole Folders, sonst nicht (spart traffic)
	NSDate *oldestLocalFolderDate = [Folder oldestModificationDateOfType:@"Folder" error:&error];
	
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die lokale
 Version bevorzugt wird.
*/
+(void)syncForceLocal:(NSError**)error
{
	
}

/*
 Führt eine Synchronisation durch, bei der im Falle gleicher Datensätze die remote-
 Version bevorzugt wird.
*/
+(void)syncForceRemote:(NSError**)error
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

@end
