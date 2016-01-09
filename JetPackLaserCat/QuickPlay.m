//
//  QuickPlay.m
//  JetPackLaserCat
//
//  Created by Noel on 11-08-27.
//  Copyright 2011 167Games. All rights reserved.
//

#import "QuickPlay.h"
#import "MainMenu.h"
#import "PracticeMode.h"
#import "SimpleAudioEngine.h"
#import "GameVariables.h"
#import "LoadingScreen.h"

@implementation QuickPlay

CCSprite *backButton;
CCSprite *unavailableNineLives;

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [QuickPlay node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"AccessDenied4.caf"];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"QuickPlay.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"quickPlayBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
        unavailableNineLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesButton.png"];
        unavailableNineLives.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
        [self addChild:unavailableNineLives z:6];
        unavailableNineLives.visible = NO;
        
        CCSprite *darkPractice = [CCSprite spriteWithSpriteFrameName:@"practiceButton.png"];
        darkPractice.color = ccc3(100, 100, 100);
        
        CCSprite *darkBack = [CCSprite spriteWithSpriteFrameName:@"backbutton2.png"];
        darkBack.color = ccc3(100, 100, 100);
        
        CCMenuItem *practiceButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"practiceButton.png"] selectedSprite:darkPractice target:self selector:@selector(goPractice:)];
        practiceButton.position = CGPointMake(screenSize.width / 2, (screenSize.height / 2) + 100);
        CCMenuItem *nineLivesButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesButton.png"] target:self selector:@selector(goNineLives:)];
        nineLivesButton.position = CGPointMake(screenSize.width / 2, (screenSize.height / 2) - 100);
        CCMenuItem *backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] selectedSprite:darkBack target:self selector:@selector(goBack:)];
        backButton.position = CGPointMake(70, 710);
        
        if ([[GameVariables sharedGameVariables] getFinishedLevelPack:5] == NO) {
            unavailableNineLives.color = ccc3(60, 60, 60);
            unavailableNineLives.visible = YES;
            CCLabelTTF *howToUnlock = [CCLabelTTF labelWithString:@"*To unlock Nine Lives, finish Career Mode" fontName:@"Arial" fontSize:12];
            howToUnlock.color = ccc3(0, 0, 0);
            howToUnlock.position = CGPointMake(screenSize.width / 2 + 240, (screenSize.height / 2) - 190);
            [self addChild:howToUnlock z:5];
        }
        
        CCMenu *theMenu = [CCMenu menuWithItems:practiceButton, nineLivesButton, backButton, nil];
        
        [theMenu setPosition: CGPointMake(0, 0)];
        [self addChild:theMenu];

    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) goPractice:(id)sender {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.4 scene:[PracticeMode scene]];
    [[CCDirector sharedDirector] replaceScene:transition];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"QuickPlay.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) goNineLives:(id)sender {
    if ([[GameVariables sharedGameVariables] getFinishedLevelPack:5] == NO) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"AccessDenied4.caf"];
    } else {
        [[GameVariables sharedGameVariables] setPracticeMode:NO];
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[GameVariables sharedGameVariables] setNineLivesMode:YES];
        [[GameVariables sharedGameVariables] setNineLivesLives:9];
        int randomLevel = [[GameVariables sharedGameVariables] getRandomLevel]+1;
        [[GameVariables sharedGameVariables] setLevel:randomLevel];
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(void) goBack:(id)sender {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
    CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.4 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"QuickPlay.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButtonSound.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"AccessDenied4.caf"];
    [self removeAllChildrenWithCleanup:YES];
}

@end
