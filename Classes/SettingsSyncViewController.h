//
//  SettingsSyncViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 03.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"


@interface SettingsSyncViewController : SettingsViewController {
	UITextField *eMail;
	UITextField *password;
}

@property (nonatomic, retain) IBOutlet UITextField *eMail;
@property (nonatomic, retain) IBOutlet UITextField *password;

- (IBAction)forceLocalToRemoteSync:(id)sender;
- (IBAction)forceRemoteToLocalSync:(id)sender;
- (IBAction)unlinkAccount:(id)sender;
- (IBAction)textFinished;
@end
