//
//  QuickPlayPostScreens.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-09-05.
//  Copyright 2011 167Games. All rights reserved.
//

#import "QuickPlayPostScreens.h"
#import "GameVariables.h"
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "LoadingScreen.h"
#import "PracticeMode.h"
#import "GameCenterStuff.h"
#import "GameKitHelper.h"

int typeOfBG;

@implementation QuickPlayPostScreens

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [QuickPlayPostScreens node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        self.isTouchEnabled = NO;
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"QuickPlayPostScreens.plist"];
        
        typeOfBG = [[GameVariables sharedGameVariables] getLevel];
        GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
        
        if (typeOfBG == 150) { //nine lives
            
            CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"gameOverBG.png"];
            background.position = CGPointMake(size.width / 2, size.height / 2);
            [self addChild:background];
            
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", [[GameVariables sharedGameVariables] getNineLivesScore]] fontName:@"Marker Felt" fontSize:56];
            scoreLabel.position = CGPointMake(200, 140);
            scoreLabel.color = ccc3(0, 0, 0);
            [self addChild:scoreLabel];
            
            CCMenu *nineLivesMenu;
            CCMenuItem *retryButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesRetry.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesRetry.png"] target:self selector:@selector(retryNineLives:)];
            retryButton.position = CGPointMake(200, 60);
            CCMenuItem *quitButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesQuit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesQuit.png"] target:self selector:@selector(toMenu:)];
            quitButton.position = CGPointMake(560, 60);
            nineLivesMenu = [CCMenu menuWithItems:retryButton, quitButton, nil];
            
            nineLivesMenu.position = CGPointMake(0, 0);
            [self addChild: nineLivesMenu z:9];
            
            if ([[GameVariables sharedGameVariables] getNineLivesScore] > [[GameVariables sharedGameVariables] getNineLivesTopScore]) {
                [[GameVariables sharedGameVariables] setNineLivesTopTime];
                [[GameVariables sharedGameVariables] setNineLivesTopScore:[[GameVariables sharedGameVariables] getNineLivesScore]];
                [[GameVariables sharedGameVariables] saveHighScores];
                [[GameVariables sharedGameVariables] setNineLivesTopLevelsFinished];
            }
        } else if (typeOfBG == 151) {   //nine lives finished
            //in congratulations screen instead
        } else {    //practice
            self.isTouchEnabled = YES;
            CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"zenModeBG.png"];
            background.position = CGPointMake(size.width / 2, size.height / 2);
            [self addChild:background];
            
            int currentLevel = [[GameVariables sharedGameVariables] getLevel];
            
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
            NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
            CCArray *practiceArray = [mainDict objectForKey:@"practiceStandards"];
            NSDictionary *practiceDict = [practiceArray objectAtIndex:currentLevel-1];
            int threeStars = [[practiceDict objectForKey:@"threeStars"] intValue];
            int twoStars = [[practiceDict objectForKey:@"twoStars"] intValue];
            int oneStar = [[practiceDict objectForKey:@"oneStar"] intValue];
            
            CCSprite *pawOne = [CCSprite spriteWithSpriteFrameName:@"zenModePaw.png"];
            pawOne.position = CGPointMake(243, 253);
            [self addChild:pawOne z:5];
            pawOne.visible = NO;
            
            CCSprite *pawTwo = [CCSprite spriteWithSpriteFrameName:@"zenModePaw.png"];
            pawTwo.position = CGPointMake(370, 253);
            [self addChild:pawTwo z:5];
            pawTwo.visible = NO;
            
            CCSprite *pawThree = [CCSprite spriteWithSpriteFrameName:@"zenModePaw.png"];
            pawThree.position = CGPointMake(492, 253);
            [self addChild:pawThree z:5];
            pawThree.visible = NO;
            
            CCSprite *goodJob = [CCSprite spriteWithSpriteFrameName:@"zenModeGoodJob.png"];
            goodJob.position = CGPointMake(size.width / 2, 590);
            [self addChild:goodJob z:5];
            
            CCSprite *perfect = [CCSprite spriteWithSpriteFrameName:@"zenModePerfect.png"];
            perfect.position = CGPointMake(size.width / 2, 590);
            [self addChild:perfect z:5];
            perfect.visible = NO;
            
            CCLabelTTF *threeStarsText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", threeStars] fontName:@"Marker Felt" fontSize:48];
            threeStarsText.position = CGPointMake(720, 180);
            
            int threeStarsMinutesDisplay;
            int threeStarsSecondsDisplay;
            threeStarsMinutesDisplay = threeStars / 60;
            threeStarsSecondsDisplay = threeStars - (threeStarsMinutesDisplay * 60);
            if (threeStarsSecondsDisplay > 9) {
                [threeStarsText setString:[NSString stringWithFormat:@"0:00 - %d:%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay]];
            } else {
                [threeStarsText setString:[NSString stringWithFormat:@"0:00 - %d:0%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay]];
            }
            [self addChild:threeStarsText];
            
            CCLabelTTF *twoStarsText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", twoStars] fontName:@"Marker Felt" fontSize:48];
            twoStarsText.position = CGPointMake(720, 310);
            
            int twoStarsMinutesDisplay;
            int twoStarsSecondsDisplay;
            twoStarsMinutesDisplay = twoStars / 60;
            twoStarsSecondsDisplay = twoStars - (twoStarsMinutesDisplay * 60);
            if (twoStarsSecondsDisplay > 9 && threeStarsSecondsDisplay > 9) {
                [twoStarsText setString:[NSString stringWithFormat:@"%d:%d - %d:%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay+1, twoStarsMinutesDisplay, twoStarsSecondsDisplay]];
            } else if (twoStarsSecondsDisplay > 9 && threeStarsSecondsDisplay <= 9) {
                [twoStarsText setString:[NSString stringWithFormat:@"%d:0%d - %d:%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay+1, twoStarsMinutesDisplay, twoStarsSecondsDisplay]];
            } else if (twoStarsSecondsDisplay <= 9 && threeStarsSecondsDisplay > 9) {
                [twoStarsText setString:[NSString stringWithFormat:@"%d:%d - %d:0%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay+1, twoStarsMinutesDisplay, twoStarsSecondsDisplay]];
            } else {
                [twoStarsText setString:[NSString stringWithFormat:@"%d:0%d - %d:0%d", threeStarsMinutesDisplay, threeStarsSecondsDisplay+1, twoStarsMinutesDisplay, twoStarsSecondsDisplay]];
            }
            [self addChild:twoStarsText];
            
            int oneStarMinutesDisplay;
            int oneStarSecondsDisplay;
            CCLabelTTF *oneStarText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", oneStar] fontName:@"Marker Felt" fontSize:48];
            oneStarText.position = CGPointMake(720, 430);
            
            oneStarMinutesDisplay = oneStar / 60;
            oneStarSecondsDisplay = oneStar - (oneStarMinutesDisplay * 60);
            if (oneStarSecondsDisplay > 9 && twoStarsSecondsDisplay > 9) {
                [oneStarText setString:[NSString stringWithFormat:@"%d:%d - %d:%d", twoStarsMinutesDisplay, twoStarsSecondsDisplay+1, oneStarMinutesDisplay, oneStarSecondsDisplay]];
            } else if (oneStarSecondsDisplay > 9 && twoStarsSecondsDisplay <= 9) {
                [oneStarText setString:[NSString stringWithFormat:@"%d:0%d - %d:%d", twoStarsMinutesDisplay, twoStarsSecondsDisplay+1, oneStarMinutesDisplay, oneStarSecondsDisplay]];
            } else if (oneStarSecondsDisplay <= 9 && twoStarsSecondsDisplay > 9) {
                [oneStarText setString:[NSString stringWithFormat:@"%d:%d - %d:0%d", twoStarsMinutesDisplay, twoStarsSecondsDisplay+1, oneStarMinutesDisplay, oneStarSecondsDisplay]];
            } else {
                [oneStarText setString:[NSString stringWithFormat:@"%d:0%d - %d:0%d", twoStarsMinutesDisplay, twoStarsSecondsDisplay+1, oneStarMinutesDisplay, oneStarSecondsDisplay]];
            }
            [self addChild:oneStarText];
            
            int timeInSeconds = [[GameVariables sharedGameVariables] getTime];
            
            if (timeInSeconds <= threeStars) {
                pawOne.visible = YES;
                pawTwo.visible = YES;
                pawThree.visible = YES;
                goodJob.visible = NO;
                perfect.visible = YES;
            } else if (timeInSeconds <= twoStars && timeInSeconds > threeStars) {
                pawOne.visible = YES;
                pawTwo.visible = YES;
                pawThree.visible = NO;
            } else if (timeInSeconds <= oneStar && timeInSeconds > twoStars) {
                pawOne.visible = YES;
                pawTwo.visible = NO;
                pawThree.visible = NO;
            } else {
                pawOne.visible = NO;
                pawTwo.visible = NO;
                pawThree.visible = NO;
            }
            
            //stars, etc.
            
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
            
            CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", timeInSeconds] fontName:@"Marker Felt" fontSize:156];
            timeLabel.position = CGPointMake(370, 430);
            timeLabel.color = ccc3(170, 180, 185);
            
            int minutesDisplay;
            int secondsDisplay;
            
            minutesDisplay = timeInSeconds / 60;
            secondsDisplay = timeInSeconds - (minutesDisplay * 60);
            if (secondsDisplay > 9) {
                [timeLabel setString:[NSString stringWithFormat:@"%d:%d", minutesDisplay, secondsDisplay]];
            } else {
                [timeLabel setString:[NSString stringWithFormat:@"%d:0%d", minutesDisplay, secondsDisplay]];
            }
            [self addChild:timeLabel];
            
            if (timeInSeconds <= threeStars) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsFirst];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsFirst percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:1] == 3 && [[GameVariables sharedGameVariables] getNumStars:5] == 3 && [[GameVariables sharedGameVariables] getNumStars:9] == 3 && [[GameVariables sharedGameVariables] getNumStars:11] == 3 && [[GameVariables sharedGameVariables] getNumStars:6] == 3 && [[GameVariables sharedGameVariables] getNumStars:44] == 3 && [[GameVariables sharedGameVariables] getNumStars:41] == 3 && [[GameVariables sharedGameVariables] getNumStars:43] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsPackOne];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsPackOne percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:10] == 3 && [[GameVariables sharedGameVariables] getNumStars:22] == 3 && [[GameVariables sharedGameVariables] getNumStars:8] == 3 && [[GameVariables sharedGameVariables] getNumStars:28] == 3 && [[GameVariables sharedGameVariables] getNumStars:4] == 3 && [[GameVariables sharedGameVariables] getNumStars:40] == 3 && [[GameVariables sharedGameVariables] getNumStars:38] == 3 && [[GameVariables sharedGameVariables] getNumStars:39] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsPackTwo];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsPackTwo percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:13] == 3 && [[GameVariables sharedGameVariables] getNumStars:3] == 3 && [[GameVariables sharedGameVariables] getNumStars:27] == 3 && [[GameVariables sharedGameVariables] getNumStars:15] == 3 && [[GameVariables sharedGameVariables] getNumStars:46] == 3 && [[GameVariables sharedGameVariables] getNumStars:14] == 3 && [[GameVariables sharedGameVariables] getNumStars:45] == 3 && [[GameVariables sharedGameVariables] getNumStars:47] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsPackThree];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsPackThree percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:26] == 3 && [[GameVariables sharedGameVariables] getNumStars:7] == 3 && [[GameVariables sharedGameVariables] getNumStars:2] == 3 && [[GameVariables sharedGameVariables] getNumStars:12] == 3 && [[GameVariables sharedGameVariables] getNumStars:50] == 3 && [[GameVariables sharedGameVariables] getNumStars:51] == 3 && [[GameVariables sharedGameVariables] getNumStars:30] == 3 && [[GameVariables sharedGameVariables] getNumStars:52] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsPackFour];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsPackFour percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:20] == 3 && [[GameVariables sharedGameVariables] getNumStars:25] == 3 && [[GameVariables sharedGameVariables] getNumStars:19] == 3 && [[GameVariables sharedGameVariables] getNumStars:42] == 3 && [[GameVariables sharedGameVariables] getNumStars:48] == 3 && [[GameVariables sharedGameVariables] getNumStars:23] == 3 && [[GameVariables sharedGameVariables] getNumStars:49] == 3 && [[GameVariables sharedGameVariables] getNumStars:21] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsPackFive];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsPackFive percentComplete:100];
            }
            
            if ([[GameVariables sharedGameVariables] getNumStars:1] == 3 && [[GameVariables sharedGameVariables] getNumStars:5] == 3 && [[GameVariables sharedGameVariables] getNumStars:9] == 3 && [[GameVariables sharedGameVariables] getNumStars:11] == 3 && [[GameVariables sharedGameVariables] getNumStars:6] == 3 && [[GameVariables sharedGameVariables] getNumStars:44] == 3 && [[GameVariables sharedGameVariables] getNumStars:41] == 3 && [[GameVariables sharedGameVariables] getNumStars:43] == 3 && [[GameVariables sharedGameVariables] getNumStars:10] == 3 && [[GameVariables sharedGameVariables] getNumStars:22] == 3 && [[GameVariables sharedGameVariables] getNumStars:8] == 3 && [[GameVariables sharedGameVariables] getNumStars:28] == 3 && [[GameVariables sharedGameVariables] getNumStars:4] == 3 && [[GameVariables sharedGameVariables] getNumStars:40] == 3 && [[GameVariables sharedGameVariables] getNumStars:38] == 3 && [[GameVariables sharedGameVariables] getNumStars:39] == 3 && [[GameVariables sharedGameVariables] getNumStars:13] == 3 && [[GameVariables sharedGameVariables] getNumStars:3] == 3 && [[GameVariables sharedGameVariables] getNumStars:27] == 3 && [[GameVariables sharedGameVariables] getNumStars:15] == 3 && [[GameVariables sharedGameVariables] getNumStars:46] == 3 && [[GameVariables sharedGameVariables] getNumStars:14] == 3 && [[GameVariables sharedGameVariables] getNumStars:45] == 3 && [[GameVariables sharedGameVariables] getNumStars:47] == 3 && [[GameVariables sharedGameVariables] getNumStars:26] == 3 && [[GameVariables sharedGameVariables] getNumStars:7] == 3 && [[GameVariables sharedGameVariables] getNumStars:2] == 3 && [[GameVariables sharedGameVariables] getNumStars:12] == 3 && [[GameVariables sharedGameVariables] getNumStars:50] == 3 && [[GameVariables sharedGameVariables] getNumStars:51] == 3 && [[GameVariables sharedGameVariables] getNumStars:30] == 3 && [[GameVariables sharedGameVariables] getNumStars:52] == 3 && [[GameVariables sharedGameVariables] getNumStars:20] == 3 && [[GameVariables sharedGameVariables] getNumStars:25] == 3 && [[GameVariables sharedGameVariables] getNumStars:19] == 3 && [[GameVariables sharedGameVariables] getNumStars:42] == 3 && [[GameVariables sharedGameVariables] getNumStars:48] == 3 && [[GameVariables sharedGameVariables] getNumStars:23] == 3 && [[GameVariables sharedGameVariables] getNumStars:49] == 3 && [[GameVariables sharedGameVariables] getNumStars:21] == 3) {
                GKAchievement *achievementThreePawsOne = [gkHelper getAchievementByID:kAchievementThreePawsAll];
                if (achievementThreePawsOne.completed == NO) [gkHelper reportAchievementWithID:kAchievementThreePawsAll percentComplete:100];
            }
            
        }
        
    }
    return self;
}

-(void) dealloc {
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

-(void) toMenu:(CCMenuItem *)menuItem {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    [[GameVariables sharedGameVariables] resetNineLives];
    [[GameVariables sharedGameVariables] setNineLivesMode:NO];
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"QuickPlayPostScreens.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) retryNineLives:(CCMenuItem *)menuItem {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    [[GameVariables sharedGameVariables] resetNineLives];
    [[GameVariables sharedGameVariables] setNineLivesMode:YES];
    [[GameVariables sharedGameVariables] setNineLivesLives:9];
    int randomLevel = [[GameVariables sharedGameVariables] getRandomLevel]+1;
    [[GameVariables sharedGameVariables] setLevel:randomLevel];
    [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"QuickPlayPostScreens.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

-(void) moveOn {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[PracticeMode scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CareerStats.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
    
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (typeOfBG != 150 && typeOfBG != 151) [self moveOn];
    return YES;
}

@end
