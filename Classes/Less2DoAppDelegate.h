//
//  Less2DoAppDelegate.h
//  Less2Do
//
//  Created by Matthias Tretter on 30.10.09.
//  Copyright BIAC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Less2DoAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
