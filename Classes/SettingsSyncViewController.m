//
//  SettingsSyncViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 03.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import "SettingsSyncViewController.h"
#import "SFHFKeychainUtils.h"
#import "SyncManager.h"
#import "Less2DoAppDelegate.h"

@implementation SettingsSyncViewController

@synthesize eMail;
@synthesize password;
@synthesize settings;
@synthesize preferToodleDo;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSError *error;
	self.settings = [Setting getSettings:&error];
	if(self.settings == nil) {
		self.settings = (Setting*)[BaseManagedObject objectOfType:@"Setting"];
		self.settings.tdEmail = @"";
		self.settings.useTDSync = [NSNumber numberWithInt:0];
		self.settings.preferToodleDo = [NSNumber numberWithInt:0];
	}
	else {
		self.eMail.text = self.settings.tdEmail;
		self.preferToodleDo.on = [self.settings.preferToodleDo intValue] == 1;
		NSError *error;
		self.password.text = [SFHFKeychainUtils getPasswordForUsername:self.eMail.text andServiceName:@"Less2DoToodleDoAccount" error:&error];
	}
	
	UIBarButtonItem *leftButton = self.navigationItem.leftBarButtonItem;
	leftButton.action = @selector(saveSettings);
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.settings = nil;
}


- (void)dealloc {
	[settings release];
    [super dealloc];
}

- (void)saveSettings {
	NSError *error=nil;
	if([self.settings.useTDSync intValue] == 1) {
		[SFHFKeychainUtils deleteItemForUsername:self.settings.tdEmail andServiceName:@"Less2DoToodleDoAccount" error:&error];
	}
	
	if (error != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Error with Keychain during delete"
													   delegate:self
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	error = nil;
	if([self.eMail.text length]!=0) {
		[SFHFKeychainUtils storeUsername:[self.eMail text]
							 andPassword:[self.password text]
						  forServiceName:@"Less2DoToodleDoAccount"
						  updateExisting:YES
								   error:&error];
		if (error != nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
															message:@"Error with Keychain during save"
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		self.settings.tdEmail = [self.eMail text];
		self.settings.useTDSync = [NSNumber numberWithInt:1];
		self.settings.preferToodleDo = self.preferToodleDo.on == YES ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
	} else {
		self.settings.tdEmail = @"";
		self.settings.useTDSync = [NSNumber numberWithInt:0];
		self.settings.preferToodleDo = [NSNumber numberWithInt:0];
	}

}

- (IBAction)forceLocalToRemoteSync:(id)sender {
	[self saveSettings];
	NSError *error = nil;
	
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate startAnimating];
	
	
	SyncManager *syncManager = [[[SyncManager alloc] init] autorelease];
	BOOL successful = [syncManager overwriteRemote:&error];
	NSString *stopTitle = nil;
	NSString *stopMessage = nil;
	if(!successful)
	{
		stopTitle = @"Error";
		stopMessage = [SyncManager gtdErrorMessage:[error code]];
	}
	else
	{
		stopTitle = @"Success";
		stopMessage = @"Sync with ToodleDo was successful";
	}
	[appDelegate stopAnimatingWithTitle:stopTitle andMessage:stopMessage];
}

- (IBAction)forceRemoteToLocalSync:(id)sender {
	[self saveSettings];
	NSError *error = nil;
	
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate startAnimating];
	
	
	SyncManager *syncManager = [[[SyncManager alloc] init] autorelease];
	BOOL successful = [syncManager overwriteLocal:&error];
	NSString *stopTitle = nil;
	NSString *stopMessage = nil;
	if(!successful)
	{
		stopTitle = @"Error";
		stopMessage = [SyncManager gtdErrorMessage:[error code]];
	}
	else
	{
		stopTitle = @"Success";
		stopMessage = @"Sync with ToodleDo was successful";
	}
	[appDelegate stopAnimatingWithTitle:stopTitle andMessage:stopMessage];
}


- (IBAction)unlinkAccount:(id)sender {
	NSError *error;
	[SFHFKeychainUtils deleteItemForUsername:self.settings.tdEmail andServiceName:@"Less2DoToodleDoAccount" error:&error];
	if (error != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Error with Keychain during delete"
													   delegate:self
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	self.settings.useTDSync = [NSNumber numberWithInt:0];
	self.eMail.text = @"";
	self.password.text = @"";
	self.preferToodleDo.on = NO;
}

- (IBAction)textFinished {
	[self.password resignFirstResponder];
	[self.eMail resignFirstResponder];
}

@end
