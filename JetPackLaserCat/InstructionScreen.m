//
//  InstructionScreen.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-24.
//  Copyright 2011 167Games. All rights reserved.
//

#import "InstructionScreen.h"
#import "MainMenu.h"
#import "LevelPackSelect.h"
#import "GameVariables.h"
#import "SimpleAudioEngine.h"

CCSprite *backButton;

@implementation InstructionScreen

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [InstructionScreen node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [self removeAllChildrenWithCleanup:YES];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        onStart = [[GameVariables sharedGameVariables] getOnStart];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButton4.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButtonSound.caf"];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"InstructionsPage.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"InstructionsBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
        if (!onStart) {
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
        } else {
            backButton = [CCSprite spriteWithSpriteFrameName:@"backbutton2.png"];
            backButton.position = CGPointMake(70, 710);
            [self addChild:backButton z:2];
        }
        
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

-(void) moveOn {
    onStart = [[GameVariables sharedGameVariables] getOnStart];
    if (!onStart) {
        onStart = YES;
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButton4.caf"];
        [[GameVariables sharedGameVariables] setOnStart:onStart];
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[LevelPackSelect scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"InstructionsPage.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
        CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.8 scene:[MainMenu scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"InstructionsPage.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton4.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButtonSound.caf"];
        [self removeAllChildrenWithCleanup:YES];
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    onStart = [[GameVariables sharedGameVariables] getOnStart];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];  
    if (!onStart) {
        [self moveOn];
    } else {
        if (CGRectContainsPoint([backButton boundingBox], touchLocation)) {
            backButton.color = ccc3(100, 100, 100);
            [self performSelector:@selector(moveOn) withObject:nil afterDelay:0.2];
        }
    }
    
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    backButton.color = ccc3(255, 255, 255);
}

@end
