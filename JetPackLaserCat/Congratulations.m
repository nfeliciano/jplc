//
//  Congratulations.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-09-04.
//  Copyright 2011 167Games. All rights reserved.
//

#import "Congratulations.h"
#import "GameVariables.h"
#import "CareerStats.h"
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "GameCenterStuff.h"

int thisLevelPack;

@implementation Congratulations

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [Congratulations node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        self.isTouchEnabled = YES;
        CGSize size = [[CCDirector sharedDirector] winSize];
        GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CongratulationsScreen.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CongratulationsScreenTwo.plist"];
        
        thisLevelPack = [[GameVariables sharedGameVariables] getLevel];
        
        CCSprite *background;
        
        if (thisLevelPack == 201) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsTurbines.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementLevelPackOneFinished];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementLevelPackOneFinished percentComplete:100];
        } else if (thisLevelPack == 202) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsNavigation.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementLevelPackTwoFinished];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementLevelPackTwoFinished percentComplete:100];
        } else if (thisLevelPack == 203) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsWings.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementLevelPackThreeFinished];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementLevelPackThreeFinished percentComplete:100];
        } else if (thisLevelPack == 204) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsBoosters.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementLevelPackFourFinished];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementLevelPackFourFinished percentComplete:100];
        } else if (thisLevelPack == 205) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsFuel.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementLevelPackFiveFinished];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementLevelPackFiveFinished percentComplete:100];
        } else if (thisLevelPack == 151) {
            background = [CCSprite spriteWithSpriteFrameName:@"congratulationsNineLives.png"];
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", [[GameVariables sharedGameVariables] getNineLivesScore]] fontName:@"Marker Felt" fontSize:56];
            scoreLabel.position = CGPointMake(200, 50);
            scoreLabel.color = ccc3(59, 59, 59);
            [self addChild:scoreLabel z:6];
            if ([[GameVariables sharedGameVariables] getNineLivesScore] > [[GameVariables sharedGameVariables] getNineLivesTopScore]) {
                [[GameVariables sharedGameVariables] setNineLivesTopTime];
                [[GameVariables sharedGameVariables] setNineLivesTopScore:[[GameVariables sharedGameVariables] getNineLivesScore]];
                [[GameVariables sharedGameVariables] saveHighScores];
                [[GameVariables sharedGameVariables] setNineLivesTopLevelsFinished];
                
            }
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementNineLivesDone];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementNineLivesDone percentComplete:100];
        } else {
            background = [CCSprite spriteWithSpriteFrameName:@"finalComic.png"];
            GKAchievement* achievement = [gkHelper getAchievementByID:kAchievementJetPackAssembled];
            if (achievement.completed == NO) [gkHelper reportAchievementWithID:kAchievementJetPackAssembled percentComplete:100];
        }
        
        background.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:background z:2];
        
        NSMutableArray *animFrames = [NSMutableArray array];
        CCSpriteFrame *frame1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"TapToContinue1.png"];
        [animFrames addObject:frame1];
        CCSpriteFrame *frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"TapToContinue2.png"];
        [animFrames addObject:frame2];
        CCSpriteFrame *frame3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"TapToContinue3.png"];
        [animFrames addObject:frame3];
        
        CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:0.1f];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"TapToContinue1.png"];
        sprite.position = CGPointMake(800, 40);
        sprite.scale = 0.5f;
        [self addChild:sprite z:3];
        
        id animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO];
        id repeat = [CCRepeatForever actionWithAction:animate];
        [sprite runAction:repeat];
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

-(void) toCareerStats {
    if (thisLevelPack != 206 && thisLevelPack != 151) {
        CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[CareerStats scene] withColor:ccBLACK];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CongratulationsScreen.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CongratulationsScreenTwo.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[MainMenu scene] withColor:ccBLACK];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CongratulationsScreen.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CongratulationsScreenTwo.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    }
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

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self toCareerStats];
    return YES;
}


@end
