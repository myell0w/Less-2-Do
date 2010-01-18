//
//  SettingsSyncViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 03.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import "SettingsSyncViewController.h"
#import "SFHFKeychainUtils.h"

@implementation SettingsSyncViewController

@synthesize eMail;
@synthesize password;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
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

}


- (void)dealloc {
    [super dealloc];
}

- (void)saveSettings {
	NSError *error;
	[SFHFKeychainUtils storeUsername:[self.eMail text]
						 andPassword:[self.password text]
					  forServiceName:@"Less2DoToodleDoAccount"
					  updateExisting:YES
							   error:&error];
}

- (IBAction)forceLocalToRemoteSync:(id)sender {
	
}

- (IBAction)forceRemoteToLocalSync:(id)sender {
	
}

- (IBAction)unlinkAccount:(id)sender {
	NSError *error;
	[SFHFKeychainUtils deleteItemForUsername:[self.eMail text] andServiceName:@"Less2DoToodleDoAccount" error:&error];
}

- (IBAction)textFinished {
	[self.password resignFirstResponder];
	[self.eMail resignFirstResponder];
}

@end
