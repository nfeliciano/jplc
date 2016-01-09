//
//  Assembling.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-09-04.
//  Copyright 2011 167Games. All rights reserved.
//

#import "Assembling.h"
#import "GameVariables.h"
#import "Congratulations.h"
#import "SimpleAudioEngine.h"

int thisLevelPack;

@implementation Assembling

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [Assembling node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [self removeAllChildrenWithCleanup:YES];
        CGSize size = [[CCDirector sharedDirector] winSize];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AssemblingParts.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AssemblingPartsTwo.plist"];
        
        thisLevelPack = [[GameVariables sharedGameVariables] getLevel];
        
        CCSprite *background;
        
        if (thisLevelPack == 201) {
            background = [CCSprite spriteWithSpriteFrameName:@"assemblingTurbines.png"];
        } else if (thisLevelPack == 202) {
            background = [CCSprite spriteWithSpriteFrameName:@"assemblingNavigation.png"];
        } else if (thisLevelPack == 203) {
            background = [CCSprite spriteWithSpriteFrameName:@"assemblingWings.png"];
        } else if (thisLevelPack == 204) {
            background = [CCSprite spriteWithSpriteFrameName:@"assemblingBoosters.png"];
        } else {
            background = [CCSprite spriteWithSpriteFrameName:@"assemblingFuel.png"];
        }
        
        background.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:background z:2];
        
        [self performSelector:@selector(toCongrats) withObject:nil afterDelay:3.0];

    }
    
    return self;
}

-(void) toCongrats {
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:1 scene:[Congratulations scene] withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"AssemblingParts.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"AssemblingPartsTwo.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) dealloc {
    [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
    [super dealloc];
}

@end
