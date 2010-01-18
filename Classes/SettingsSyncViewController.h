//
//  SettingsSyncViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 03.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "Setting.h"


@interface SettingsSyncViewController : SettingsViewController {
	Setting *settings;
	UITextField *eMail;
	UITextField *password;
	UISwitch *preferToodleDo;
}

@property (nonatomic, retain) Setting *settings;

@property (nonatomic, retain) IBOutlet UITextField *eMail;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UISwitch *preferToodleDo;


- (IBAction)forceLocalToRemoteSync:(id)sender;
- (IBAction)forceRemoteToLocalSync:(id)sender;
- (IBAction)unlinkAccount:(id)sender;
- (IBAction)textFinished;

-  (void)saveSettings;
@end
