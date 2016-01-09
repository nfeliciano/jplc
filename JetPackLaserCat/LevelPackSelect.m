//
//  LevelPackSelect.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-15.
//  Copyright 2011 167Games. All rights reserved.
//

#import "LevelPackSelect.h"
#import "MainMenu.h"
#import "GameVariables.h"
#import "LoadingScreen.h"
#import "SimpleAudioEngine.h"

@implementation LevelPackSelect

CCMenu *levelMenu;
CCMenuItem *packOne;
CCMenuItem *packTwo;
CCMenuItem *packThree;
CCMenuItem *packFour;
CCMenuItem *packFive;
CCMenuItem *backButton;
CGPoint touchLocation;
BOOL levelPackFinished;
CCArray *timeArray;
CCArray *deathArray;

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [LevelPackSelect node];
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
        [[GameVariables sharedGameVariables] setPracticeMode:NO];
        [[GameVariables sharedGameVariables] loadLevelPacks];
        [[GameVariables sharedGameVariables] newLevelPack];
        [[GameVariables sharedGameVariables] setTime:0];
        [[GameVariables sharedGameVariables] setDeaths:0];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"AccessDenied4.caf"];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPackSelect.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"LevelSelectBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
        CCSprite *selectALevel = [CCSprite spriteWithSpriteFrameName:@"SelectALevel.png"];
        selectALevel.position = CGPointMake(360, 620);
        [self addChild:selectALevel z:1];
        
        CCSprite *packOneColored = [CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"];
        packOneColored.color = ccc3(100, 100, 100);
        
        packOne = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"] selectedSprite:packOneColored target:self selector:@selector(goPackOne:)];
        
        //packOne = [CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"];
        packOne.position = CGPointMake(200, 460);
        //[self addChild:packOne z:1];
        
        CCSprite *packTwoColored = [CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"];
        packTwoColored.color = ccc3(100, 100, 100);
        
        packTwo = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"] selectedSprite:packTwoColored target:self selector:@selector(goPackTwo:)];
        packTwo.position = CGPointMake(500, 460);
        //[self addChild:packTwo z:1];
        
#if JPLCPRO
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevelPack:1];
        if (!levelPackFinished) {
            CCSprite *packTwoLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packTwoLocked.position = CGPointMake(500, 460);
            [self addChild:packTwoLocked z:2];
        }
#endif
        
        CCSprite *packThreeColored = [CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"];
        packThreeColored.color = ccc3(100, 100, 100);
        
        packThree = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"] selectedSprite:packThreeColored target:self selector:@selector(goPackThree:)];
        packThree.position = CGPointMake(800, 460);
        //[self addChild:packThree z:1];
        
#if JPLCPRO
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevelPack:2];
        if (!levelPackFinished) {
            CCSprite *packThreeLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packThreeLocked.position = CGPointMake(800, 460);
            [self addChild:packThreeLocked z:2];
        }
#endif
        
        CCSprite *packFourColored = [CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"];
        packFourColored.color = ccc3(100, 100, 100);
        
        packFour = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"] selectedSprite:packFourColored target:self selector:@selector(goPackFour:)];
        packFour.position = CGPointMake(200, 260);
        //[self addChild:packFour z:1];
        
#if JPLCPRO
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevelPack:3];
        if (!levelPackFinished) {
            CCSprite *packFourLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packFourLocked.position = CGPointMake(200, 260);
            [self addChild:packFourLocked z:2];
        }
#elif JPLCLITE
        CCSprite *packFourLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
        packFourLocked.position = CGPointMake(200, 260);
        [self addChild:packFourLocked z:2];
#endif
        
        CCSprite *packFiveColored = [CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"];
        packFiveColored.color = ccc3(100, 100, 100);
        
        packFive = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"] selectedSprite:packFiveColored target:self selector:@selector(goPackFive:)];
        packFive.position = CGPointMake(500, 260);
        //[self addChild:packFive z:1];
        
#if JPLCPRO
        levelPackFinished = [[GameVariables sharedGameVariables] getFinishedLevelPack:4];
        if (!levelPackFinished) {
            CCSprite *packFiveLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
            packFiveLocked.position = CGPointMake(500, 260);
            [self addChild:packFiveLocked z:2];
        }
#elif JPLCLITE
        CCSprite *packFiveLocked = [CCSprite spriteWithSpriteFrameName:@"LevelPackLocked.png"];
        packFiveLocked.position = CGPointMake(500, 260);
        [self addChild:packFiveLocked z:2];
#endif
        
        backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelSelectBack.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelSelectBack.png"] target:self selector:@selector(goBack:)];
        backButton.position = CGPointMake(70, 710);
        backButton.scale = 0.4;
        //[self addChild:backButton z:1];
        
        levelMenu = [CCMenu menuWithItems:packOne, packTwo, packThree, packFour, packFive, backButton, nil];
        levelMenu.position = CGPointMake(0, 0);
        [self addChild:levelMenu z:1];
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) goPackOne:(CCMenuItem *) menuItem {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSDictionary *standardDict = [mainDict objectForKey:@"careerStandards"];
    
    timeArray = [standardDict objectForKey:@"standardTimes"];
    deathArray = [standardDict objectForKey:@"standardDeaths"];
    
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:0] intValue]];
    [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:0] intValue]];
    [[GameVariables sharedGameVariables] setLevel:1];
    [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) goPackTwo:(CCMenuItem *) menuItem {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSDictionary *standardDict = [mainDict objectForKey:@"careerStandards"];
    
    timeArray = [standardDict objectForKey:@"standardTimes"];
    deathArray = [standardDict objectForKey:@"standardDeaths"];
    
#if JPLCPRO
    if ([[GameVariables sharedGameVariables] getFinishedLevelPack:1] == YES) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:1] intValue]];
        [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:1] intValue]];
        [[GameVariables sharedGameVariables] setLevel:10];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
    
#elif JPLCLITE
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:1] intValue]];
    [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:1] intValue]];
    [[GameVariables sharedGameVariables] setLevel:10];
    [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
#endif
}

-(void) goPackThree:(CCMenuItem *) menuItem {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSDictionary *standardDict = [mainDict objectForKey:@"careerStandards"];
    
    timeArray = [standardDict objectForKey:@"standardTimes"];
    deathArray = [standardDict objectForKey:@"standardDeaths"];
    
#if JPLCPRO
    if ([[GameVariables sharedGameVariables] getFinishedLevelPack:2] == YES) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:2] intValue]];
        [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:2] intValue]];
        [[GameVariables sharedGameVariables] setLevel:13];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
#elif JPLCLITE
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:2] intValue]];
    [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:2] intValue]];
    [[GameVariables sharedGameVariables] setLevel:13];
    [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
#endif
}

-(void) goPackFour:(CCMenuItem *) menuItem {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSDictionary *standardDict = [mainDict objectForKey:@"careerStandards"];
    
    timeArray = [standardDict objectForKey:@"standardTimes"];
    deathArray = [standardDict objectForKey:@"standardDeaths"];
    
#if JPLCPRO
    if ([[GameVariables sharedGameVariables] getFinishedLevelPack:3] == YES) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:4] intValue]];
        [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:4] intValue]];
        [[GameVariables sharedGameVariables] setLevel:26];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
#endif
}

-(void) goPackFive:(CCMenuItem *) menuItem {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSDictionary *standardDict = [mainDict objectForKey:@"careerStandards"];
    
    timeArray = [standardDict objectForKey:@"standardTimes"];
    deathArray = [standardDict objectForKey:@"standardDeaths"];
    
#if JPLCPRO
    if ([[GameVariables sharedGameVariables] getFinishedLevelPack:4] == YES) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[GameVariables sharedGameVariables] setCareerStandardTime:[[timeArray objectAtIndex:4] intValue]];
        [[GameVariables sharedGameVariables] setCareerStandardDeaths:[[deathArray objectAtIndex:4] intValue]];
        [[GameVariables sharedGameVariables] setLevel:20];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    }
#endif
}

-(void) goBack:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
    CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.8 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

@end
