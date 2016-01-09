//
//  BuyFullVersion.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-10-18.
//  Copyright 2011 University of Victoria. All rights reserved.
//

#import "BuyFullVersion.h"
#import "MainMenu.h"
#import "SimpleAudioEngine.h"
#import "GameVariables.h"

int currentLevel;

@implementation BuyFullVersion

+(id)scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [BuyFullVersion node];
    [scene addChild:layer];
    return scene;
}

-(id)init {
    if (self == [super init]) {
        self.isTouchEnabled = YES;
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButtonSound.caf"];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BuyFullVersion.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"buyFullBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
        CCMenuItem *backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] target:self selector:@selector(goBack:)];
        backButton.position = CGPointMake(70, 710);
        
        CCMenuItem *buyButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"buyNowButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buyNowButton.png"] target:self selector:@selector(goBuy:)];
        buyButton.position = CGPointMake(730, 320);
        
        currentLevel = [[GameVariables sharedGameVariables] getLevel];
        CCMenu *menu;
        if (currentLevel != 101) {
            menu = [CCMenu menuWithItems:backButton, buyButton, nil];
        } else {
            menu = [CCMenu menuWithItems:buyButton, nil];
        }
        
        menu.position = CGPointMake(0, 0);
        [self addChild:menu z:3];
        
        if (currentLevel == 101) {
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
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) goBack:(CCMenuItem *) menuItem {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
    CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.8 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelect.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) goBuy:(CCMenuItem *) menuItem {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=463645803"]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"BuyFullVersion.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) moveOn {
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"BuyFullVersion.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"%d", [[GameVariables sharedGameVariables] getLevel]);
    if ([[GameVariables sharedGameVariables] getLevel] == 101) [self moveOn];
    return YES;
}

@end
