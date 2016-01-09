//
//  MainMenu.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-11.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKitHelper.h"
#import "GameCenterStuff.h"

@interface MainMenu : CCLayer <GameKitHelperProtocol> {
    BOOL onStart;
    
    bool creditsScreenUp;
    CCLayer *creditsLayer;
    CCSprite *creditsScreen;
    CCMenu *creditsScreenMenu;
    CCLabelTTF *creditsNames[51];
    int currentName;
    CCSprite *cocos2dLogo;
    CCLabelTTF *thanksForPlaying;
}

+(id) scene;

-(void) showRateMe;

-(void) goCareer:(CCMenuItem *) menuItem;
-(void) goQuickplay:(CCMenuItem *) menuItem;
-(void) goInstructions:(CCMenuItem *) menuItem;
-(void) goHighScores:(CCMenuItem *) menuItem;
-(void) goCredits:(CCMenuItem *) menuItem;
-(void) closeCredits:(CCMenuItem *) menuItem;
-(void) goLeaderboards:(CCMenuItem *)menuItem;
-(void) goAchievements:(CCMenuItem *)menuItem;
-(void) goFullVersion:(CCMenuItem *)menuItem;

@end
