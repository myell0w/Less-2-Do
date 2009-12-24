//
//  BaseSyncObject.h
//  Less2Do
//
//  Created by BlackandCold on 24.12.09.
//  Copyright 2009 TU Wien. All rights reserved.
//


/* Dieses Objekt dient den Grundlegenden Funktionalitäten der Synchronisation.
 *
 * (1) Aufruf der SyncAPI Funktionen mit angepassten Parametern
 * (1.1) Parameter der Aufrufenden Funktion sind Objecte aus db.entities
 *
 * (2) Fehlerentgegenahme und Weiterreichung an Fehlerfunktionen (Entscheidung GUI?)
 * (3) event. Synchronisationsvorgänge mit Threads
 *
 * (4) Zusatzfunktionen Toodledoo spezifisch 
 * (4.1) Speichern der Anmeldedaten
 * (4.2) Speichern der Einstellungen im Fehlerfall
 * (4.3) Informationsfluss die Verbindung betreffend (Requestcount etc.)
 */

@interface BaseSyncObject : NSObject 
{

}

@end
