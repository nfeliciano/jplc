//
//  AppDelegate.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-05.
//  Copyright 2011 167Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
