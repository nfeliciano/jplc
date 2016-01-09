//
//  MainMenu.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-11.
//  Copyright 2011 167Games. All rights reserved.
//

#import "MainMenu.h"
#import "SplashPage.h"
#import "LevelPackSelect.h"
#import "QuickPlay.h"
#import "InstructionScreen.h"
#import "GameVariables.h"
#import "CareerStats.h"
#import "SimpleAudioEngine.h"
#import "BuyFullVersion.h"

@implementation MainMenu

CCSprite *musicPaused;
CCSprite *soundsPaused;

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [MainMenu node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
     if (self == [super init]) {
#if JPLCPRO
         if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && ![[GameVariables sharedGameVariables] getPauseMusic]) {
             [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCGameplayOne.m4a" loop:YES];
         }
#elif JPLCLITE
         if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && ![[GameVariables sharedGameVariables] getPauseMusic]) {
             [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCMain.m4a" loop:YES];
         }
#endif
         [[CCTextureCache sharedTextureCache] removeAllTextures];
         [CCTextureCache purgeSharedTextureCache];
         [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
         [self removeAllChildrenWithCleanup:YES];
         
         if ([[GameVariables sharedGameVariables] getRated] != 1) {
             [[GameVariables sharedGameVariables] addNumVisits];
             if (([[GameVariables sharedGameVariables] getNumVisits]%5) == 0) {
                 [self showRateMe];
             }
         }
         
         creditsScreenUp = NO;
         
#if JPLCPRO
         GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
         gkHelper.delegate = self;
         [gkHelper authenticateLocalPlayer];
#endif
         
         onStart = [[GameVariables sharedGameVariables] getOnStart];
         [[GameVariables sharedGameVariables] loadLevelPacks];
         [[GameVariables sharedGameVariables] loadLevels];
         [[GameVariables sharedGameVariables] setDeaths:0];
         [[GameVariables sharedGameVariables] setTime:0];
         [[GameVariables sharedGameVariables] resetNineLives];
         [[GameVariables sharedGameVariables] setNineLivesMode:NO];
         [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButtonSound.caf"];
         [[SimpleAudioEngine sharedEngine] preloadEffect:@"AccessDenied4.caf"];
         [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
         
         CGSize screenSize = [[CCDirector sharedDirector] winSize];
         
         CCLabelTTF *warningGameCenter = [CCLabelTTF labelWithString:@"*WARNING: Log-in Game Center to unlock Achievements and get your name on the leaderboard!" fontName:@"Arial" fontSize:12];
         warningGameCenter.position = CGPointMake(screenSize.width / 2, 12);
         warningGameCenter.color = ccc3(255, 255, 255);
         [self addChild:warningGameCenter z:6];
         
         [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MainMenu.plist"];
         
         CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"mainMenuBG.png"];
         background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
         [self addChild:background z:0];
         
         CCSprite *unavailableQP = [CCSprite spriteWithSpriteFrameName:@"QuickPlayButton.png"];
         unavailableQP.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
         [self addChild:unavailableQP z:6];
         unavailableQP.visible = NO;
         
         CCMenuItem *careerButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"CareerButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"CareerButtonSelected.png"] target:self selector:@selector(goCareer:)];
         CCMenuItem *quickButton;
         if ([[GameVariables sharedGameVariables] getFinishedLevel:1] == NO) {
            quickButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"QuickPlayButtonSelected.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"QuickPlayButtonSelected.png"] target:self selector:@selector(goQuickplay:)];
             unavailableQP.color = ccc3(60, 60, 60);
             unavailableQP.visible = YES;
         } else {
            unavailableQP.visible = NO;
            quickButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"QuickPlayButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"QuickPlayButtonSelected.png"] target:self selector:@selector(goQuickplay:)];
         }
         
         CCMenuItem *instructionButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"InstructionsButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"InstructionsButtonSelected.png"] target:self selector:@selector(goInstructions:)];
         
         CCMenuItem *highScoresButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HighScoresButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"HighScoresButtonSelected.png"] target:self selector:@selector(goHighScores:)];
          
         /*LITE MENU*/
         
         CCMenuItem *buyFullVersionButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"buyFullVersion.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buyFullVersion.png"] target:self selector:@selector(goFullVersion:)];
         
#if JPLCPRO
         CCMenu *theMenu = [CCMenu menuWithItems:careerButton, quickButton, instructionButton, highScoresButton, nil];
#elif JPLCLITE
         unavailableQP.visible = NO;
         CCMenu *theMenu = [CCMenu menuWithItems:careerButton, instructionButton, buyFullVersionButton, nil];
#endif
         
         
         
         [theMenu alignItemsVerticallyWithPadding:30.0];
         [theMenu setPosition: CGPointMake(screenSize.width / 2, screenSize.height / 2 - 50)];
         [self addChild:theMenu z:5];
         
         
         CCMenu *soundMenu;
         CCMenuItem *musicMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseMusicButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseMusicButton.png"] target: self selector:@selector(MusicButtonTapped:)];
         musicMenuItem.position = CGPointMake(920, 720);
         musicMenuItem.scale = 0.5;
         CCMenuItem *soundMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseSoundButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseSoundButton.png"] target: self selector:@selector(SoundsButtonTapped:)];
         soundMenuItem.position = CGPointMake(980, 720);
         soundMenuItem.scale = 0.5;
         
         CCMenuItem *creditsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"creditsButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"creditsButton.png"] target:self selector:@selector(goCredits:)];
         creditsButton.position = CGPointMake(980, 60);
         
         CCMenuItem *leaderboardsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"leaderboardsButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"leaderboardsButton.png"] target:self selector:@selector(goLeaderboards:)];
         leaderboardsButton.position = CGPointMake(60, 60);
         
         CCMenuItem *achievementsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"achievementsButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"achievementsButton.png"] target:self selector:@selector(goAchievements:)];
         achievementsButton.position = CGPointMake(160, 60);
         
         soundMenu = [CCMenu menuWithItems:musicMenuItem, soundMenuItem, creditsButton, leaderboardsButton, achievementsButton, nil];
         soundMenu.position = CGPointMake(0, 0);
         [self addChild: soundMenu z:5];
         
         musicPaused = [CCSprite spriteWithSpriteFrameName:@"pauseSoundOff.png"];
         musicPaused.position = CGPointMake(920, 720);
         musicPaused.scale = 0.5;
         [self addChild:musicPaused z:6];
         if ([[GameVariables sharedGameVariables] getPauseMusic] == NO) musicPaused.visible = NO;
         
         soundsPaused = [CCSprite spriteWithSpriteFrameName:@"pauseSoundOff.png"];
         soundsPaused.position = CGPointMake(980, 720);
         soundsPaused.scale = 0.5;
         [self addChild:soundsPaused z:6];
         if ([[GameVariables sharedGameVariables] getPauseSound] == NO) soundsPaused.visible = NO;
         
         /*if ([[GameVariables sharedGameVariables] getNineLivesMode]) {
          GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
          [gkHelper submitScore:[[GameVariables sharedGameVariables] getNineLivesTopScore] category:@"JPLCNineLivesScore"];       //1672011101
          }*/                   //IN ONPLAYERINFORECEIVED
         
         
     }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) showRateMe {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Rate The App"];
    [alert setMessage:@"We appreciate your support. Would you like to rate this game?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Later"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Never"];
    [alert show];
    [alert release];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //later
    } else if (buttonIndex == 1) {
        [[GameVariables sharedGameVariables] setRated];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=463645803"]];
        //
        //now
    } else if (buttonIndex == 2) {
        [[GameVariables sharedGameVariables] setRated];
        //never
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

-(void) goCareer:(CCMenuItem *) menuItem {
    if (!creditsScreenUp) {
        if (onStart) {
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
            CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[LevelPackSelect scene]];
            [[CCDirector sharedDirector] replaceScene:transition];    
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
            [[CCTextureCache sharedTextureCache] removeAllTextures];
            [self removeAllChildrenWithCleanup:YES];
        } else {
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
            CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[InstructionScreen scene]];
            [[CCDirector sharedDirector] replaceScene:transition];    
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
            [[CCTextureCache sharedTextureCache] removeAllTextures];
            [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
            [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
            [self removeAllChildrenWithCleanup:YES];
        }
    }
}

-(void) goQuickplay:(CCMenuItem *) menuItem {
    if (!creditsScreenUp) {
        if ([[GameVariables sharedGameVariables] getFinishedLevel:1] == YES) {
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
            CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[QuickPlay scene]];
            [[CCDirector sharedDirector] replaceScene:transition];    
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
            [[CCTextureCache sharedTextureCache] removeAllTextures];
            [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
            [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
            [self removeAllChildrenWithCleanup:YES];
        } else {
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
        }
    }
}

-(void) goInstructions:(CCMenuItem *) menuItem {
    if (!creditsScreenUp) {
        if (!onStart) {
            onStart = YES;
            [[GameVariables sharedGameVariables] setOnStart:onStart];
        }
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[InstructionScreen scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(void) goHighScores:(CCMenuItem *) menuItem {
    if (!creditsScreenUp) {
        [[GameVariables sharedGameVariables] setLevel:0];
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[CareerStats scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(void) goCredits:(CCMenuItem *)menuItem {
    if (creditsScreenUp == NO) {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        if (![[GameVariables sharedGameVariables] getPauseMusic]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCCredits.m4a" loop:YES];            
        }
        currentName = 0;
        creditsScreenUp = YES;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CreditsPlist.plist"];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        creditsLayer = [CCLayerColor layerWithColor: ccc4(150, 150, 150, 125) width: screenSize.width height: screenSize.height];
        creditsLayer.position = CGPointZero;
        [self addChild:creditsLayer z:7];
        
        creditsScreen = [[CCSprite spriteWithSpriteFrameName:@"creditsBG.png"] retain];
        creditsScreen.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild: creditsScreen z:8];
        
        /*AAAAAALLLL the names!*/
        CCLabelTTF *projectManager = [CCLabelTTF labelWithString:@"Project Manager" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[0] = projectManager;
        
        CCLabelTTF *terryLin = [CCLabelTTF labelWithString:@"\t\t\t\tTerry \"TerBear\" (Yu Tang) Lin" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[1] = terryLin;
        creditsNames[2] = NULL;
        
        CCLabelTTF *directorOfArtwork = [CCLabelTTF labelWithString:@"Director of Artwork" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[3] = directorOfArtwork;
        
        CCLabelTTF *sydneyBarnes = [CCLabelTTF labelWithString:@"\t\t\t\tSydney \"The Crazy Cat Lady\" Barnes" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[4] = sydneyBarnes;
        creditsNames[5] = NULL;
        
        CCLabelTTF *leadProgrammer = [CCLabelTTF labelWithString:@"Lead Programmer" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[6] = leadProgrammer;
        
        CCLabelTTF *noelFeliciano = [CCLabelTTF labelWithString:@"\t\t\t\t Noel \"Do-able\" (Joseph) Feliciano" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[7] = noelFeliciano;
        creditsNames[8] = NULL;
        
        CCLabelTTF *originalScore = [CCLabelTTF labelWithString:@"Original Score Composed and Arranged by" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[9] = originalScore;
        
        CCLabelTTF *westonRoda = [CCLabelTTF labelWithString:@"\t\t\t\tWeston Roda" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[10] = westonRoda;
        creditsNames[11] = NULL;
        
        CCLabelTTF *programmingConsultants = [CCLabelTTF labelWithString:@"Programming Consultants:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[12] = programmingConsultants;
        CCLabelTTF *anthonyEstey = [CCLabelTTF labelWithString:@"\t\t\t\tAnthony \"The Professor\" Estey" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[13] = anthonyEstey;
        CCLabelTTF *rileyMorrice = [CCLabelTTF labelWithString:@"\t\t\t\tRiley \"Google Sensei\" Morrice" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[14] = rileyMorrice;
        creditsNames[15] = NULL;
        
        CCLabelTTF *leadTesters = [CCLabelTTF labelWithString:@"Lead QA Testers:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[16] = leadTesters;
        CCLabelTTF *timJordison = [CCLabelTTF labelWithString:@"\t\t\t\tTim \"& Angela\" Jordison" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[17] = timJordison;
        CCLabelTTF *angelaJeske = [CCLabelTTF labelWithString:@"\t\t\t\tAngela \"& Tim\" Jeske" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[18] = angelaJeske;
        CCLabelTTF *jasonCummer = [CCLabelTTF labelWithString:@"\t\t\t\tJason \"The T.A.\" Cummer" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[19] = jasonCummer;
        creditsNames[20] = NULL;
        
        CCLabelTTF *internationalAffairs = [CCLabelTTF labelWithString:@"International Affairs Officer:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[21] = internationalAffairs;
        CCLabelTTF *claireMcKenzie = [CCLabelTTF labelWithString:@"\t\t\t\tClaire \"Gal Pal\" McKenzie" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[22] = claireMcKenzie;
        creditsNames[23] = NULL;
        
        CCLabelTTF *qaTesters = [CCLabelTTF labelWithString:@"Lead QA Testers:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[24] = qaTesters;
        CCLabelTTF *bernardDupriez = [CCLabelTTF labelWithString:@"\t\t\t\tBernard Dupriez-Mitchell" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[25] = bernardDupriez;
        CCLabelTTF *derekVroom = [CCLabelTTF labelWithString:@"\t\t\t\tDerek \"Vroom\" Vroom" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[26] = derekVroom;
        CCLabelTTF *leslieSharpe = [CCLabelTTF labelWithString:@"\t\t\t\tLeslie \"Wesley\" Sharpe" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[27] = leslieSharpe;
        CCLabelTTF *liusiHuang = [CCLabelTTF labelWithString:@"\t\t\t\tLiusi \"Goosey\" Huang" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[28] = liusiHuang;
        CCLabelTTF *alisonStockwell = [CCLabelTTF labelWithString:@"\t\t\t\tAlison Stockwell" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[29] = alisonStockwell;
        CCLabelTTF *lindsayWyant = [CCLabelTTF labelWithString:@"\t\t\t\tLindsay Wyant" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[30] = lindsayWyant;
        CCLabelTTF *stefanBourrier = [CCLabelTTF labelWithString:@"\t\t\t\tStefan \"Dirtking\" Bourrier" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[31] = stefanBourrier;
        CCLabelTTF *leahCarder = [CCLabelTTF labelWithString:@"\t\t\t\tLeah \"Blue Box\" Carder" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[32] = leahCarder;
        CCLabelTTF *nathanLam = [CCLabelTTF labelWithString:@"\t\t\t\tNathan \"Sonic\" Lam" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[33] = nathanLam;
        CCLabelTTF *jordanSchriner = [CCLabelTTF labelWithString:@"\t\t\t\tJordan \"Phil Dunphy, Yo\" Schriner" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[34] = jordanSchriner;
        CCLabelTTF *danielleHansen = [CCLabelTTF labelWithString:@"\t\t\t\tDanielle \"Munchkin\" Hansen" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[35] = danielleHansen;
        CCLabelTTF *brendanClement = [CCLabelTTF labelWithString:@"\t\t\t\tBrendan \"Ragequit\" Clement" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[36] = brendanClement;
        CCLabelTTF *fireStarter = [CCLabelTTF labelWithString:@"\t\t\t\t& \" The Fire Starter\"" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[37] = fireStarter;
        creditsNames[38] = NULL;
        
        CCLabelTTF *thanksToUvic = [CCLabelTTF labelWithString:@"Thanks to the University of Victoria" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[39] = thanksToUvic;
        CCLabelTTF *graphicsCandy = [CCLabelTTF labelWithString:@"Graphics (Candy) Lab:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[40] = graphicsCandy;
        CCLabelTTF *amyGooch = [CCLabelTTF labelWithString:@"\t\t\t\tAmy Gooch" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[41] = amyGooch;
        CCLabelTTF *daveBartle = [CCLabelTTF labelWithString:@"\t\t\t\tDave \"Shut Up Terry\" Bartle" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[42] = daveBartle;
        CCLabelTTF *robKelly = [CCLabelTTF labelWithString:@"\t\t\t\tRob \"The Undergrad\" Kelly" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[43] = robKelly;
        CCLabelTTF *shelleyGao = [CCLabelTTF labelWithString:@"\t\t\t\tShelley Gao" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[44] = shelleyGao;
        creditsNames[45] = NULL;
        
        CCLabelTTF *specialThanks = [CCLabelTTF labelWithString:@"And An Even Specialer Thanks To:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[46] = specialThanks;
        CCLabelTTF *bruceGooch = [CCLabelTTF labelWithString:@"\t\t\t\tBruce \"The Almighty\" Gooch" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[47] = bruceGooch;
        creditsNames[48] = NULL;
        creditsNames[49] = NULL;
        
        CCLabelTTF *createdUsing = [CCLabelTTF labelWithString:@"Created Using:" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:22];
        creditsNames[50] = createdUsing;
        
        for (int i = 0; i < 51; i++) {
            if (creditsNames[currentName] == NULL) {
                
            } else {
                creditsNames[currentName].color = ccc3(135, 140, 154);
                creditsNames[currentName].position = CGPointMake(640, 80);
                [creditsNames[currentName] setOpacity:0];
                [self addChild:creditsNames[currentName] z:10];
                CCDelayTime *delay = [CCDelayTime actionWithDuration:i*0.7];
                CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:2.0];
                CCSequence *fadeSeq = [CCSequence actions:delay, fadeIn, nil];
                [creditsNames[currentName] runAction:fadeSeq];
                CCMoveBy *moveUp = [CCMoveBy actionWithDuration:14.0 position:CGPointMake(0, 600)];
                CCSequence *moveSeq = [CCSequence actions:delay, moveUp, nil];
                [creditsNames[currentName] runAction:moveSeq];
                CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:2.0];
                CCSequence *fadeOutSeq = [CCSequence actions:[CCDelayTime actionWithDuration:(i*0.7)+9], fadeOut, nil];
                [creditsNames[currentName] runAction:fadeOutSeq];
            }
            currentName++;
        }
        
        cocos2dLogo = [CCSprite spriteWithSpriteFrameName:@"cocos2dLogo.png"];
        cocos2dLogo.position = CGPointMake(620, 80);
        [cocos2dLogo setOpacity:0];
        [self addChild: cocos2dLogo z:10];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:53*0.7];
        CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:3.0];
        CCSequence *fadeSeq = [CCSequence actions:delay, fadeIn, nil];
        [cocos2dLogo runAction:fadeSeq];
        CCMoveBy *moveUp = [CCMoveBy actionWithDuration:14.0 position:CGPointMake(0, 600)];
        CCSequence *moveSeq = [CCSequence actions:delay, moveUp, nil];
        [cocos2dLogo runAction:moveSeq];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:2.0];
        CCSequence *fadeOutSeq = [CCSequence actions:[CCDelayTime actionWithDuration:(52*0.7)+9], fadeOut, nil];
        [cocos2dLogo runAction:fadeOutSeq];
        
        thanksForPlaying = [CCLabelTTF labelWithString:@"Thanks For Playing!" dimensions:CGSizeMake(500.0f, 40.0f) alignment:UITextAlignmentLeft fontName:@"Arial-BoldMT" fontSize:28];
        thanksForPlaying.color = ccc3(135, 140, 154);
        thanksForPlaying.position = CGPointMake(700, 80);
        [thanksForPlaying setOpacity:0];
        [self addChild:thanksForPlaying z:10];
        CCSequence *fadeInThanks = [CCSequence actions:[CCDelayTime actionWithDuration:57*0.7], [CCFadeIn actionWithDuration:2.0], nil];
        [thanksForPlaying runAction:fadeInThanks];
        CCSequence *moveUpThanks = [CCSequence actions:[CCDelayTime actionWithDuration:57*0.7], [CCMoveBy actionWithDuration:5.8 position:CGPointMake(0, 250)], nil];
        [thanksForPlaying runAction:moveUpThanks];
        
        CCMenuItem *closeCredits = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"quitButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"quitButton.png"] target:self selector:@selector(closeCredits:)];
        closeCredits.position = CGPointMake(180, 690);
        closeCredits.scale = 1.4;
        creditsScreenMenu = [CCMenu menuWithItems:closeCredits, nil];
        creditsScreenMenu.position = CGPointMake(0, 0);
        [self addChild:creditsScreenMenu z:9];
    }
}

-(void) closeCredits:(CCMenuItem *)menuItem {
    [self removeChild:creditsScreen cleanup:YES];
    [creditsScreen release];
	[self removeChild:creditsScreenMenu cleanup:YES];
	[self removeChild:creditsLayer cleanup:YES];
    for (int i = 0; i < 51; i++) {
        [self removeChild:creditsNames[i] cleanup:YES];
    }
    [self removeChild:cocos2dLogo cleanup:YES];
    [self removeChild:thanksForPlaying cleanup:YES];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    if (![[GameVariables sharedGameVariables] getPauseMusic]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCGameplayOne.m4a" loop:YES];
    }
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CreditsPlist.plist"];
	creditsScreenUp=NO;
}

-(void) goLeaderboards:(CCMenuItem *)menuItem {
    if (!creditsScreenUp) {
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        [gkHelper showLeaderboard];
    }
    
}

-(void) goAchievements:(CCMenuItem *)menuItem {
    if (!creditsScreenUp) {
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        [gkHelper showAchievements];
    }
}

-(void) goFullVersion:(CCMenuItem *)menuItem {
    if (!creditsScreenUp) {
        if (!onStart) {
            onStart = YES;
            [[GameVariables sharedGameVariables] setOnStart:onStart];
        }
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[BuyFullVersion scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(void) MusicButtonTapped:(id)sender {
    if (!creditsScreenUp) {
        if ([[GameVariables sharedGameVariables] getPauseMusic] == NO) {
            [[GameVariables sharedGameVariables] setPauseMusic:YES];
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
            musicPaused.visible = YES;
        } else {
            [[GameVariables sharedGameVariables] setPauseMusic:NO];
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
            musicPaused.visible = NO;
        } 
    }
}

-(void) SoundsButtonTapped:(id)sender {
    if (!creditsScreenUp) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) {
            [[GameVariables sharedGameVariables] setPauseSound:YES];
            soundsPaused.visible = YES;
        } else {
            [[GameVariables sharedGameVariables] setPauseSound:NO];
            soundsPaused.visible = NO;
        }
    }
}

@end
