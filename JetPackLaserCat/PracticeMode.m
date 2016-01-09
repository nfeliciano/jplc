//
//  PracticeMode.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-28.
//  Copyright 2011 167Games. All rights reserved.
//

#import "PracticeMode.h"
#import "QuickPlay.h"
#import "LoadingScreen.h"
#import "GameVariables.h"
#import "SimpleAudioEngine.h"


@implementation PracticeMode

CCSprite *backButton;
CCSprite *levelsArray[8];
int currentPack;
int currentImage;
BOOL levelPackFinished;

int recentlyClicked;

CCSprite *paws[6];

CCMenuItem *packOne;
CCMenuItem *packTwo;
CCMenuItem *packThree;
CCMenuItem *packFour;
CCMenuItem *packFive;

CCMenuItem *coverFlowMinusTwo;
CCMenuItem *coverFlowMinusOne;
CCMenuItem *coverFlowPlusOne;
CCMenuItem *coverFlowPlusTwo;
CCMenu *coverFlow;

CCMenu *practiceMenu;
CCMenuItem *clickPlay;
CCMenuItem *clickGoBack;

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [PracticeMode node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && ![[GameVariables sharedGameVariables] getPauseMusic]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCGameplayOne.m4a" loop:YES];
        }
        
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        for (int i = 0; i < 8; i++) {
            [self removeChild:levelsArray[i] cleanup:YES];
            levelsArray[i] = NULL;
        }
        for (int i = 0; i < 6; i++) {
            [self removeChild:paws[i] cleanup:YES];
            paws[i] = NULL;
        }
        [[GameVariables sharedGameVariables] setPracticeMode:YES];
        [[GameVariables sharedGameVariables] loadLevelPacks];
        [[GameVariables sharedGameVariables] newLevelPack];
        [[GameVariables sharedGameVariables] loadLevels];
        [[GameVariables sharedGameVariables] setTime:0];
        [[GameVariables sharedGameVariables] setDeaths:0];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButton4.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButtonSound.caf"];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PracticeMode.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"practiceBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:1];
        
        clickGoBack = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] target:self selector:@selector(goBack:)];
        clickGoBack.position = CGPointMake(70, 710);
        
        clickPlay = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"playLevel.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"playLevel.png"] target:self selector:@selector(playClicked:)];
        clickPlay.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 200);
        clickPlay.scale = 0.5;
        
        paws[0] = [CCSprite spriteWithSpriteFrameName:@"emptyPaw.png"];
        paws[0].position = CGPointMake(screenSize.width / 2 - 100, screenSize.height / 2 + 190);
        paws[0].scale = 0.2;
        [self addChild:paws[0] z:2];
        
        paws[1] = [CCSprite spriteWithSpriteFrameName:@"emptyPaw.png"];
        paws[1].position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 190);
        paws[1].scale = 0.2;
        [self addChild:paws[1] z:2];
        
        paws[2] = [CCSprite spriteWithSpriteFrameName:@"emptyPaw.png"];
        paws[2].position = CGPointMake(screenSize.width / 2 + 100, screenSize.height / 2 + 190);
        paws[2].scale = 0.2;
        [self addChild:paws[2] z:2];
        
        paws[3] = [CCSprite spriteWithSpriteFrameName:@"filledInPaw.png"];
        paws[3].position = CGPointMake(screenSize.width / 2 - 100, screenSize.height / 2 + 190);
        paws[3].scale = 0.2;
        [self addChild:paws[3] z:2];
        paws[3].visible = NO;
        
        paws[4] = [CCSprite spriteWithSpriteFrameName:@"filledInPaw.png"];
        paws[4].position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 190);
        paws[4].scale = 0.2;
        [self addChild:paws[4] z:2];
        paws[4].visible = NO;
        
        paws[5] = [CCSprite spriteWithSpriteFrameName:@"filledInPaw.png"];
        paws[5].position = CGPointMake(screenSize.width / 2 + 100, screenSize.height / 2 + 190);
        paws[5].scale = 0.2;
        [self addChild:paws[5] z:2];
        paws[5].visible = NO;
        
        coverFlowMinusTwo = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] target:self selector:@selector(cfminusTwo:)];
        coverFlowMinusTwo.position = CGPointMake(screenSize.width / 2 - 500, screenSize.height / 2);
        coverFlowMinusTwo.scale = 0.33;
        coverFlowMinusTwo.visible = NO;
        
        coverFlowMinusOne = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] target:self selector:@selector(cfminusOne:)];
        coverFlowMinusOne.position = CGPointMake(screenSize.width / 2 - 325, screenSize.height / 2);
        coverFlowMinusOne.scale = 0.66;
        
        coverFlowPlusOne = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] target:self selector:@selector(cfplusOne:)];
        coverFlowPlusOne.position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        coverFlowPlusOne.scale = 0.66;
        
        coverFlowPlusTwo = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"generic.png"] target:self selector:@selector(cfplusTwo:)];
        coverFlowPlusTwo.position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        coverFlowPlusTwo.scale = 0.33;
        
        coverFlow = [CCMenu menuWithItems:coverFlowMinusTwo, coverFlowMinusOne, coverFlowPlusOne, coverFlowPlusTwo, nil];
        coverFlow.position = CGPointMake(0, 0);
        [self addChild:coverFlow z:0];
        
        
        packOne = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"] target:self selector:@selector(packOneClicked:)];
        packOne.position = CGPointMake(212, 80);
        packOne.scale = 0.6;
        
        packTwo = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"] target:self selector:@selector(packTwoClicked:)];
        packTwo.position = CGPointMake(362, 80);
        packTwo.scale = 0.6;
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevel:10];
        if (!levelPackFinished) {
            CCSprite *packTwoLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packTwoLocked.position = CGPointMake(362, 80);
            packTwoLocked.scale = 0.6;
            [self addChild:packTwoLocked z:4];
        }
        
        packThree = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"] target:self selector:@selector(packThreeClicked:)];
        packThree.position = CGPointMake(512, 80);
        packThree.scale = 0.6;
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevel:13];
        if (!levelPackFinished) {
            CCSprite *packThreeLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packThreeLocked.position = CGPointMake(512, 80);
            packThreeLocked.scale = 0.6;
            [self addChild:packThreeLocked z:4];
        }
        
        packFour = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"] target:self selector:@selector(packFourClicked:)];
        packFour.position = CGPointMake(662, 80);
        packFour.scale = 0.6;
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevel:26];
        if (!levelPackFinished) {
            CCSprite *packFourLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packFourLocked.position = CGPointMake(662, 80);
            packFourLocked.scale = 0.6;
            [self addChild:packFourLocked z:4];
        }
        
        packFive = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"] target:self selector:@selector(packFiveClicked:)];
        packFive.position = CGPointMake(812, 80);
        packFive.scale = 0.6;
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevel:20];
        if (!levelPackFinished) {
            CCSprite *packFiveLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packFiveLocked.position = CGPointMake(812, 80);
            packFiveLocked.scale = 0.6;
            [self addChild:packFiveLocked z:4];
        }
        
        practiceMenu = [CCMenu menuWithItems:clickGoBack, clickPlay, packOne, packTwo, packThree, packFour, packFive, nil];
        practiceMenu.position = CGPointMake(0, 0);
        [self addChild: practiceMenu z:3];
        
        currentPack = 1;
        [self loadCurrentPack:1];
        
        [self changeLevelImages];
    }
    return self;
}

-(void) cfminusTwo:(CCMenuItem *) menuItem {
    if ((currentImage > 2 && currentImage < 7) || currentImage == 8 || currentImage == 7) {
        [self moveImages:-2];
    }
}
-(void) cfminusOne:(CCMenuItem *) menuItem {
    if ((currentImage > 2 && currentImage < 7) || currentImage == 2 || currentImage == 8 || currentImage == 7) {
        [self moveImages:-1];
    }
}
-(void) cfplusOne:(CCMenuItem *) menuItem {
    coverFlowMinusTwo.visible = YES;
    if ((currentImage > 2 && currentImage < 7) || currentImage == 2 || currentImage == 1 || currentImage == 7) {
        [self moveImages:1];
    }
}
-(void) cfplusTwo:(CCMenuItem *) menuItem {
    coverFlowMinusTwo.visible = YES;
    if ((currentImage > 2 && currentImage < 7) || currentImage == 2 || currentImage == 1) {
        [self moveImages:2];
    }
}

-(void) showLevel {
    CCLOG(@"%d", currentImage);
}

-(void) dealloc {
    [super dealloc];
}

-(void) updateStars {
    [[GameVariables sharedGameVariables] loadStars];
    int forThisLevel = [self findLevel];
    int numStars = [[GameVariables sharedGameVariables] getNumStars:forThisLevel];
    
    if (numStars == 3) {
        paws[3].visible = YES;
        paws[4].visible = YES;
        paws[5].visible = YES;
    } else if (numStars == 2) {
        paws[3].visible = YES;
        paws[4].visible = YES;
        paws[5].visible = NO;
    } else if (numStars == 1) {
        paws[3].visible = YES;
        paws[4].visible = NO;
        paws[5].visible = NO;
    } else {
        paws[3].visible = NO;
        paws[4].visible = NO;
        paws[5].visible = NO;
    }
}

-(void) packOneClicked:(CCMenuItem *) menuItem {
    if (currentPack != 1) {
        if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
        if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
        if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
        if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
        [self loadCurrentPack:1];
        [self changeLevelImages];
    }
}
-(void) packTwoClicked:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getFinishedLevel:10]) {
        if (currentPack != 2) {
            if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
            if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
            if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
            if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
            [self loadCurrentPack:2];
            [self changeLevelImages];
        }
    }
}
-(void) packThreeClicked:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getFinishedLevel:13]) {
        if (currentPack != 3) {
            if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
            if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
            if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
            if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
            [self loadCurrentPack:3];
            [self changeLevelImages];
        }
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
}
-(void) packFourClicked:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getFinishedLevel:26]) {
        if (currentPack != 4) {
            if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
            if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
            if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
            if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
            [self loadCurrentPack:4];
            [self changeLevelImages];
        }
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
}
-(void) packFiveClicked:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getFinishedLevel:20]) {
        if (currentPack != 5) {
            if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
            if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
            if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
            if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
            [self loadCurrentPack:5];
            [self changeLevelImages];
        }
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
}

-(void) loadCurrentPack:(int)levelPack {
    currentPack = levelPack;
    if (currentPack == 1) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackOne.plist"];
    } else if (currentPack == 2) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackTwo.plist"];
    } else if (currentPack == 3) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackThree.plist"];
    } else if (currentPack == 4) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackFour.plist"];
    } else if (currentPack == 5) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackFive.plist"];
    }
}

-(void) changeLevelImages {
    int levelPack = currentPack;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (int i = 0; i < 8; i++) {
        [self removeChild:levelsArray[i] cleanup:YES];
    }
    
    if (levelPack == 1) {
        levelsArray[0] = [CCSprite spriteWithSpriteFrameName:@"levelOneOne.png"];
        levelsArray[0].position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:levelsArray[0] z:4];
        currentImage = 1;
        levelsArray[1] = [CCSprite spriteWithSpriteFrameName:@"levelOneTwo.png"];
        levelsArray[1].position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        levelsArray[1].scale = 0.66;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:5] == NO) levelsArray[1].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[1] z:3];
        levelsArray[2] = [CCSprite spriteWithSpriteFrameName:@"levelOneThree.png"];
        levelsArray[2].position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        levelsArray[2].scale = 0.33;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:9] == NO) levelsArray[2].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[2] z:2];
        levelsArray[3] = [CCSprite spriteWithSpriteFrameName:@"levelOneFour.png"];
        levelsArray[3].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[3].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:11] == NO) levelsArray[3].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[3] z:2];
        levelsArray[4] = [CCSprite spriteWithSpriteFrameName:@"levelOneFive.png"];
        levelsArray[4].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[4].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:6] == NO) levelsArray[4].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[4] z:2];
        levelsArray[5] = [CCSprite spriteWithSpriteFrameName:@"levelOneSix.png"];
        levelsArray[5].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[5].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:44] == NO) levelsArray[5].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[5] z:2];
        levelsArray[6] = [CCSprite spriteWithSpriteFrameName:@"levelOneSeven.png"];
        levelsArray[6].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[6].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:41] == NO) levelsArray[6].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[6] z:2];
        levelsArray[7] = [CCSprite spriteWithSpriteFrameName:@"levelOneEight.png"];
        levelsArray[7].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[7].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:43] == NO) levelsArray[7].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[7] z:2];
    } else if (levelPack == 2) {
        levelsArray[0] = [CCSprite spriteWithSpriteFrameName:@"levelTwoOne.png"];
        levelsArray[0].position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        if ([[GameVariables sharedGameVariables] getFinishedLevel:10] == NO) levelsArray[0].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[0] z:2];
        currentImage = 1;
        levelsArray[1] = [CCSprite spriteWithSpriteFrameName:@"levelTwoTwo.png"];
        levelsArray[1].position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        levelsArray[1].scale = 0.66;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:22] == NO) levelsArray[1].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[1] z:3];
        levelsArray[2] = [CCSprite spriteWithSpriteFrameName:@"levelTwoThree.png"];
        levelsArray[2].position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        levelsArray[2].scale = 0.33;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:8] == NO) levelsArray[2].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[2] z:2];
        levelsArray[3] = [CCSprite spriteWithSpriteFrameName:@"levelTwoFour.png"];
        levelsArray[3].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[3].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:28] == NO) levelsArray[3].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[3] z:2];
        levelsArray[4] = [CCSprite spriteWithSpriteFrameName:@"levelTwoFive.png"];
        levelsArray[4].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[4].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:4] == NO) levelsArray[4].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[4] z:2];
        levelsArray[5] = [CCSprite spriteWithSpriteFrameName:@"levelTwoSix.png"];
        levelsArray[5].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[5].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:40] == NO) levelsArray[5].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[5] z:2];
        levelsArray[6] = [CCSprite spriteWithSpriteFrameName:@"levelTwoSeven.png"];
        levelsArray[6].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[6].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:38] == NO) levelsArray[6].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[6] z:2];
        levelsArray[7] = [CCSprite spriteWithSpriteFrameName:@"levelTwoEight.png"];
        levelsArray[7].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[7].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:39] == NO) levelsArray[7].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[7] z:2];
    } else if (levelPack == 3) {
        levelsArray[0] = [CCSprite spriteWithSpriteFrameName:@"levelThreeOne.png"];
        levelsArray[0].position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        if ([[GameVariables sharedGameVariables] getFinishedLevel:13] == NO) levelsArray[0].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[0] z:2];
        currentImage = 1;
        levelsArray[1] = [CCSprite spriteWithSpriteFrameName:@"levelThreeTwo.png"];
        levelsArray[1].position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        levelsArray[1].scale = 0.66;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:3] == NO) levelsArray[1].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[1] z:3];
        levelsArray[2] = [CCSprite spriteWithSpriteFrameName:@"levelThreeThree.png"];
        levelsArray[2].position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        levelsArray[2].scale = 0.33;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:27] == NO) levelsArray[2].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[2] z:2];
        levelsArray[3] = [CCSprite spriteWithSpriteFrameName:@"levelThreeFour.png"];
        levelsArray[3].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[3].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:15] == NO) levelsArray[3].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[3] z:2];
        levelsArray[4] = [CCSprite spriteWithSpriteFrameName:@"levelThreeFive.png"];
        levelsArray[4].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[4].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:46] == NO) levelsArray[4].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[4] z:2];
        levelsArray[5] = [CCSprite spriteWithSpriteFrameName:@"levelThreeSix.png"];
        levelsArray[5].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[5].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:14] == NO) levelsArray[5].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[5] z:2];
        levelsArray[6] = [CCSprite spriteWithSpriteFrameName:@"levelThreeSeven.png"];
        levelsArray[6].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[6].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:45] == NO) levelsArray[6].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[6] z:2];
        levelsArray[7] = [CCSprite spriteWithSpriteFrameName:@"levelThreeEight.png"];
        levelsArray[7].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[7].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:47] == NO) levelsArray[7].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[7] z:2];
    } else if (levelPack == 4) {
        levelsArray[0] = [CCSprite spriteWithSpriteFrameName:@"levelFourOne.png"];
        levelsArray[0].position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        if ([[GameVariables sharedGameVariables] getFinishedLevel:26] == NO) levelsArray[0].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[0] z:2];
        currentImage = 1;
        levelsArray[1] = [CCSprite spriteWithSpriteFrameName:@"levelFourTwo.png"];
        levelsArray[1].position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        levelsArray[1].scale = 0.66;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:7] == NO) levelsArray[1].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[1] z:3];
        levelsArray[2] = [CCSprite spriteWithSpriteFrameName:@"levelFourThree.png"];
        levelsArray[2].position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        levelsArray[2].scale = 0.33;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:2] == NO) levelsArray[2].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[2] z:2];
        levelsArray[3] = [CCSprite spriteWithSpriteFrameName:@"levelFourFour.png"];
        levelsArray[3].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[3].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:12] == NO) levelsArray[3].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[3] z:2];
        levelsArray[4] = [CCSprite spriteWithSpriteFrameName:@"levelFourSix.png"];
        levelsArray[4].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[4].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:50] == NO) levelsArray[4].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[4] z:2];
        levelsArray[5] = [CCSprite spriteWithSpriteFrameName:@"levelFourFive.png"];
        levelsArray[5].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[5].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:51] == NO) levelsArray[5].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[5] z:2];
        levelsArray[6] = [CCSprite spriteWithSpriteFrameName:@"levelFourSeven.png"];
        levelsArray[6].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[6].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:30] == NO) levelsArray[6].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[6] z:2];
        levelsArray[7] = [CCSprite spriteWithSpriteFrameName:@"levelFourEight.png"];
        levelsArray[7].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[7].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:52] == NO) levelsArray[7].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[7] z:2];
    } else if (levelPack == 5) {
        levelsArray[0] = [CCSprite spriteWithSpriteFrameName:@"levelFiveOne.png"];
        levelsArray[0].position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        if ([[GameVariables sharedGameVariables] getFinishedLevel:20] == NO) levelsArray[0].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[0] z:2];
        currentImage = 1;
        levelsArray[1] = [CCSprite spriteWithSpriteFrameName:@"levelFiveTwo.png"];
        levelsArray[1].position = CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2);
        levelsArray[1].scale = 0.66;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:25] == NO) levelsArray[1].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[1] z:3];
        levelsArray[2] = [CCSprite spriteWithSpriteFrameName:@"levelFiveThree.png"];
        levelsArray[2].position = CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2);
        levelsArray[2].scale = 0.33;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:19] == NO) levelsArray[2].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[2] z:2];
        levelsArray[3] = [CCSprite spriteWithSpriteFrameName:@"levelFiveFour.png"];
        levelsArray[3].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[3].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:42] == NO) levelsArray[3].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[3] z:2];
        levelsArray[4] = [CCSprite spriteWithSpriteFrameName:@"levelFiveFive.png"];
        levelsArray[4].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[4].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:48] == NO) levelsArray[4].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[4] z:2];
        levelsArray[5] = [CCSprite spriteWithSpriteFrameName:@"levelFiveSix.png"];
        levelsArray[5].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[5].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:23] == NO) levelsArray[5].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[5] z:2];
        levelsArray[6] = [CCSprite spriteWithSpriteFrameName:@"levelFiveSeven.png"];
        levelsArray[6].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[6].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:49] == NO) levelsArray[6].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[6] z:2];
        levelsArray[7] = [CCSprite spriteWithSpriteFrameName:@"levelFiveEight.png"];
        levelsArray[7].position = CGPointMake(screenSize.width /2 + 700, screenSize.height / 2);
        levelsArray[7].scale = 0.0;
        if ([[GameVariables sharedGameVariables] getFinishedLevel:21] == NO) levelsArray[7].color = ccc3(100, 100, 100);
        [self addChild:levelsArray[7] z:2];
    }
    [self updateStars];
}

-(void) moveOtherImages:(int)thisImage toPosition:(int)order {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCMoveTo *moveImage;
    CCScaleTo *scaleImage;
    if (order == -3) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 - 700, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.00];
        [self reorderChild:levelsArray[thisImage-1] z:2];
    } else if (order == -2) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 - 500, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.33];
        [self reorderChild:levelsArray[thisImage-1] z:2];
    } else if (order == -1) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 - 325, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.66];
        [self reorderChild:levelsArray[thisImage-1] z:3];
    } else if (order == 0) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:1.0];
        [self reorderChild:levelsArray[thisImage-1] z:4];
    } else if (order == 1) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 + 325, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.66];
        [self reorderChild:levelsArray[thisImage-1] z:3];
    } else if (order == 2) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 + 500, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.33];
        [self reorderChild:levelsArray[thisImage-1] z:2];
    }  else if (order == 3) {
        moveImage = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(screenSize.width / 2 + 700, screenSize.height / 2)];
        scaleImage = [CCScaleTo actionWithDuration:0.5 scale:0.00];
        [self reorderChild:levelsArray[thisImage-1] z:2];
    } else {
        moveImage = [CCMoveTo actionWithDuration:0.0 position:CGPointMake(0, 0)];
        scaleImage = [CCScaleTo actionWithDuration:0.0 scale:0.00];
        [self reorderChild:levelsArray[thisImage-1] z:2];
    }
    [levelsArray[thisImage-1] runAction:moveImage];
    [levelsArray[thisImage-1] runAction:scaleImage];
}

-(void) moveImages:(int)toImage {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButton4.caf"];
    if (toImage == -2) {
        for (int i = 0; i < 9; i++) {
            if (i == currentImage - 4) {
                if (currentImage > 4) [self moveOtherImages:currentImage-4 toPosition:-2];
            } else if (i == currentImage - 3) {
                if (currentImage > 3) [self moveOtherImages:currentImage-3 toPosition:-1];
            } else if (i == currentImage - 2) {
                if (currentImage > 2) [self moveOtherImages:currentImage-2 toPosition:0];
            } else if (i == currentImage - 1) {
                if (currentImage > 1) [self moveOtherImages:currentImage-1 toPosition:1];
            } else if (i == currentImage) {
                [self moveOtherImages:currentImage toPosition:2];
            } else if (i == currentImage + 1) {
                if (currentImage < 8) [self moveOtherImages:currentImage+1 toPosition:3];
            } else if (i == currentImage + 2) {
                if (currentImage < 7) [self moveOtherImages:currentImage+2 toPosition:3];
            } else if (i == currentImage + 3) {
                if (currentImage < 6) [self moveOtherImages:currentImage+3 toPosition:3];
            } else if (i == currentImage + 4) {
                if (currentImage < 5) [self moveOtherImages:currentImage+4 toPosition:3];
            }
        }
    } else if (toImage == -1) {
        for (int i = 0; i < 9; i++) {
            if (i == currentImage - 4) {
                if (currentImage > 4) [self moveOtherImages:currentImage-4 toPosition:-3];
            } else if (i == currentImage - 3) {
                if (currentImage > 3) [self moveOtherImages:currentImage-3 toPosition:-2];
            } else if (i == currentImage - 2) {
                if (currentImage > 2) [self moveOtherImages:currentImage-2 toPosition:-1];
            } else if (i == currentImage - 1) {
                if (currentImage > 1) [self moveOtherImages:currentImage-1 toPosition:0];
            } else if (i == currentImage) {
                [self moveOtherImages:currentImage toPosition:1];
            } else if (i == currentImage + 1) {
                if (currentImage < 8) [self moveOtherImages:currentImage+1 toPosition:2];
            } else if (i == currentImage + 2) {
                if (currentImage < 7) [self moveOtherImages:currentImage+2 toPosition:3];
            } else if (i == currentImage + 3) {
                if (currentImage < 6) [self moveOtherImages:currentImage+3 toPosition:3];
            } else if (i == currentImage + 4) {
                if (currentImage < 5) [self moveOtherImages:currentImage+4 toPosition:3];
            }
        }
    } else if (toImage == 1) {
        for (int i = 0; i < 9; i++) {
            if (i == currentImage - 4) {
                if (currentImage > 4) [self moveOtherImages:currentImage-4 toPosition:-3];
            } else if (i == currentImage - 3) {
                if (currentImage > 3) [self moveOtherImages:currentImage-3 toPosition:-3];
            } else if (i == currentImage - 2) {
                if (currentImage > 2) [self moveOtherImages:currentImage-2 toPosition:-3];
            } else if (i == currentImage - 1) {
                if (currentImage > 1) [self moveOtherImages:currentImage-1 toPosition:-2];
            } else if (i == currentImage) {
                [self moveOtherImages:currentImage toPosition:-1];
            } else if (i == currentImage + 1) {
                if (currentImage < 8) [self moveOtherImages:currentImage+1 toPosition:0];
            } else if (i == currentImage + 2) {
                if (currentImage < 7) [self moveOtherImages:currentImage+2 toPosition:1];
            } else if (i == currentImage + 3) {
                if (currentImage < 6) [self moveOtherImages:currentImage+3 toPosition:2];
            } else if (i == currentImage + 4) {
                if (currentImage < 5) [self moveOtherImages:currentImage+4 toPosition:3];
            }
        }
    } else if (toImage == 2) {
        for (int i = 0; i < 9; i++) {
            if (i == currentImage - 4) {
                if (currentImage > 4) [self moveOtherImages:currentImage-4 toPosition:-3];
            } else if (i == currentImage - 3) {
                if (currentImage > 3) [self moveOtherImages:currentImage-3 toPosition:-3];
            } else if (i == currentImage - 2) {
                if (currentImage > 2) [self moveOtherImages:currentImage-2 toPosition:-3];
            } else if (i == currentImage - 1) {
                if (currentImage > 1) [self moveOtherImages:currentImage-1 toPosition:-3];
            } else if (i == currentImage) {
                [self moveOtherImages:currentImage toPosition:-2];
            } else if (i == currentImage + 1) {
                if (currentImage < 8) [self moveOtherImages:currentImage+1 toPosition:-1];
            } else if (i == currentImage + 2) {
                if (currentImage < 7) [self moveOtherImages:currentImage+2 toPosition:0];
            } else if (i == currentImage + 3) {
                if (currentImage < 6) [self moveOtherImages:currentImage+3 toPosition:1];
            } else if (i == currentImage + 4) {
                if (currentImage < 5) [self moveOtherImages:currentImage+4 toPosition:2];
            }
        }
    }
    currentImage = currentImage + toImage;
    [self updateStars];
}

-(void) goBack:(CCMenuItem *)menuItem {
    for (int i = 0; i < 8; i++) {
        levelsArray[i] = NULL;
    }
    for (int i = 0; i < 6; i++) {
        [self removeChild:paws[i] cleanup:YES];
    }
    CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.8 scene:[QuickPlay scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
    if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
    if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
    if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
    if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"PracticeMode.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton4.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
    [self removeAllChildrenWithCleanup:YES];
}

-(int) findLevel {
    int goToLevel = 100;
    if (currentPack == 1) {
        if (currentImage == 1) goToLevel = 1;
        if (currentImage == 2) goToLevel = 5;
        if (currentImage == 3) goToLevel = 9;
        if (currentImage == 4) goToLevel = 11;
        if (currentImage == 5) goToLevel = 6;
        if (currentImage == 6) goToLevel = 44;
        if (currentImage == 7) goToLevel = 41;
        if (currentImage == 8) goToLevel = 43;
    } else if (currentPack == 2) {
        if (currentImage == 1) goToLevel = 10;
        if (currentImage == 2) goToLevel = 22;
        if (currentImage == 3) goToLevel = 8;
        if (currentImage == 4) goToLevel = 28;
        if (currentImage == 5) goToLevel = 4;
        if (currentImage == 6) goToLevel = 40;
        if (currentImage == 7) goToLevel = 38;
        if (currentImage == 8) goToLevel = 39;
    } else if (currentPack == 3) {
        if (currentImage == 1) goToLevel = 13;
        if (currentImage == 2) goToLevel = 3;
        if (currentImage == 3) goToLevel = 27;
        if (currentImage == 4) goToLevel = 15;
        if (currentImage == 5) goToLevel = 46;
        if (currentImage == 6) goToLevel = 14;
        if (currentImage == 7) goToLevel = 45;
        if (currentImage == 8) goToLevel = 47;
    } else if (currentPack == 4) {
        if (currentImage == 1) goToLevel = 26;
        if (currentImage == 2) goToLevel = 7;
        if (currentImage == 3) goToLevel = 2;
        if (currentImage == 4) goToLevel = 12;
        if (currentImage == 5) goToLevel = 50;
        if (currentImage == 6) goToLevel = 51;
        if (currentImage == 7) goToLevel = 30;
        if (currentImage == 8) goToLevel = 52;
    } else if (currentPack == 5) {
        if (currentImage == 1) goToLevel = 20;
        if (currentImage == 2) goToLevel = 25;
        if (currentImage == 3) goToLevel = 19;
        if (currentImage == 4) goToLevel = 42;
        if (currentImage == 5) goToLevel = 48;
        if (currentImage == 6) goToLevel = 23;
        if (currentImage == 7) goToLevel = 49;
        if (currentImage == 8) goToLevel = 21;
    }
    return goToLevel;
}

-(void) playClicked:(CCMenuItem *)menuItem {
    [self goToLoadingScreen:currentImage];
    
}

-(void) goToLoadingScreen:(int)toLevel {
    int goToLevel = [self findLevel];
    
    if ([[GameVariables sharedGameVariables] getFinishedLevel:goToLevel] == YES) {
        for (int i = 0; i < 8; i++) {
            [self removeChild:levelsArray[i] cleanup:YES];
        }
        for (int i = 0; i < 6; i++) {
            [self removeChild:paws[i] cleanup:YES];
        }
        [[GameVariables sharedGameVariables] setLevel:goToLevel];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        if (currentPack == 1) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackOne.plist"];
        if (currentPack == 2) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackTwo.plist"];
        if (currentPack == 3) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackThree.plist"];
        if (currentPack == 4) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFour.plist"];
        if (currentPack == 5) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelPackFive.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton4.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
        [self removeAllChildrenWithCleanup:YES];
    }
}

@end
