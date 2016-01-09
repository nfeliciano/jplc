//
//  LoadingScreen.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-10.
//  Copyright 2011 167Games. All rights reserved.
//

#import "LoadingScreen.h"
#import "GameplayLayer.h"
#import "GameVariables.h"
#import "MainMenu.h"
#import "GameCenterStuff.h"
#import "SimpleAudioEngine.h"
#import "BuyFullVersion.h"

int currentLevel;

@implementation LoadingScreen

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [LoadingScreen node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [self removeAllChildrenWithCleanup:YES];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        CGSize size = [[CCDirector sharedDirector] winSize];
#if JPLCPRO
        GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
#endif
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LoadingScreensOne.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LoadingScreensTwo.plist"];
        
        currentLevel = [[GameVariables sharedGameVariables] getLevel];
        
#if JPLCPRO
        if ([[GameVariables sharedGameVariables] getPractice] != NO && [[GameVariables sharedGameVariables] getNineLivesMode] != NO) {
            if (currentLevel == 5) {
                GKAchievement *achievement = [gkHelper getAchievementByID:kAchievementOneLevelFinished];
                if (achievement.completed == NO) {
                    [gkHelper reportAchievementWithID:kAchievementOneLevelFinished percentComplete:100];
                }
            }
        }
#endif
        
        CCSprite *background;
        
        if (currentLevel == 1 || currentLevel == 5 || currentLevel == 9 || currentLevel == 11 || currentLevel == 6 || currentLevel == 44 || currentLevel == 41 || currentLevel == 43) {
            background = [CCSprite spriteWithSpriteFrameName:@"theChase.png"];
        } else if (currentLevel == 10 || currentLevel == 22 || currentLevel == 8 || currentLevel == 28 || currentLevel == 4 || currentLevel == 40 || currentLevel == 38 || currentLevel == 39) {
            background = [CCSprite spriteWithSpriteFrameName:@"blueprint.png"];
        } else if (currentLevel == 13 || currentLevel == 3 || currentLevel == 27 || currentLevel == 15 || currentLevel == 46 || currentLevel == 14 || currentLevel == 45 || currentLevel == 47) {
            background = [CCSprite spriteWithSpriteFrameName:@"withHammer.png"];
        } else if (currentLevel == 26 || currentLevel == 7 || currentLevel == 2 || currentLevel == 12 || currentLevel == 50 || currentLevel == 51 || currentLevel == 30 || currentLevel == 52) {
            background = [CCSprite spriteWithSpriteFrameName:@"girly.png"];
        } else {
            background = [CCSprite spriteWithSpriteFrameName:@"withForcefield.png"];
        }
        
        background.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:background z:2];
        
        /*if (currentLevel == 101) {
            CCLabelTTF* points = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Points:%d", [[GameVariables sharedGameVariables] getNineLivesScore]] fontName:@"Marker Felt" fontSize:64];
            points.position = CGPointMake(size.width / 2, size.height / 2 - 200);
            [self addChild:points z:4];
        }*/
		
		// Must wait one frame before loading the target scene!
		// Two reasons: first, it would crash if not. Second, the Loading label wouldn't be displayed.
        
		[self schedule:@selector(update: ) interval:1];
    }
    return self;
}

-(void) update:(ccTime) delta {
    [self unscheduleAllSelectors];
    if (currentLevel != 100) {
        if (currentLevel == 101) {
#if JPLCPRO
            CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[MainMenu scene] withColor:ccBLACK];
#elif JPLCLITE
            CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[BuyFullVersion scene] withColor:ccBLACK];
#endif
            [[CCDirector sharedDirector] replaceScene:transition];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensOne.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensTwo.plist"];
            [[CCTextureCache sharedTextureCache] removeAllTextures];
            [self removeAllChildrenWithCleanup:YES];
        } else {
            CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[GameplayLayer scene] withColor:ccBLACK];
            [[CCDirector sharedDirector] replaceScene:transition];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensOne.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensTwo.plist"];
            [[CCTextureCache sharedTextureCache] removeAllTextures];
            [self removeAllChildrenWithCleanup:YES];
        }
    } else {
        CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[MainMenu scene] withColor:ccBLACK];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensOne.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LoadingScreensTwo.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(void) dealloc {
    //[[CCScheduler sharedScheduler] unscheduleAllSelectors];
    [super dealloc];
}

-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper getPlayerInfo:friends];
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	CCLOG(@"onPlayerInfoReceived: %@", [players description]);
	
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	//[gkHelper submitScore:1234 category:@"Playtime"];
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
	
	if (success)
	{
		//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		//[gkHelper retrieveTopTenAllTimeGlobalScores];
	}
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	//[gkHelper showLeaderboard];
	//[gkHelper showAchievements];
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}


-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

@end
