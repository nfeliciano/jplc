//
//  SplashPage.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-10.
//  Copyright 2011 167Games. All rights reserved.
//

#import "SplashPage.h"
#import "MainMenu.h"
#import "SimpleAudioEngine.h"

@implementation SplashPage

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [SplashPage node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
/*#if JPLCPRO
        NSLog(@"LOL");
#elif JPLCLITE
        NSLog(@"HAHA");
#endif*/
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButton4.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCMain.m4a" loop:NO];
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SplashPage.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Homescreen.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
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
        [self addChild:sprite];
        
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

-(void) moveOn {
    [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButton4.caf"];
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"SplashPage.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton4.caf"];
    [self removeAllChildrenWithCleanup:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self moveOn];
    return YES;
}

@end
