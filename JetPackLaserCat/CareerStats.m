//
//  CareerStats.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-26.
//  Copyright 2011 167Games. All rights reserved.
//

#import "CareerStats.h"
#import "GameplayLayer.h"
#import "LevelPackSelect.h"
#import "GameVariables.h"
#import "Congratulations.h"
#import "MainMenu.h"
#import "SimpleAudioEngine.h"

CCLabelTTF *topScore;
CCLabelTTF *topTime;
CCLabelTTF *topDeaths;

@implementation CareerStats

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer *layer = [CareerStats node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        [self removeAllChildrenWithCleanup:YES];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CareerStats.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"careerStatsBG.png"];
        background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:background z:0];
        
        if ([[GameVariables sharedGameVariables] getLevel] != 0) {
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
            
            CCLabelTTF* timeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Time: %d", [[GameVariables sharedGameVariables] getTotalTime]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            timeLabel.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
            int minutesDisplay;
            int secondsDisplay;
            minutesDisplay = [[GameVariables sharedGameVariables] getTotalTime] / 60;
            secondsDisplay = [[GameVariables sharedGameVariables] getTotalTime] - (minutesDisplay * 60);
            if (secondsDisplay > 9) {
                [timeLabel setString:[NSString stringWithFormat:@"Total Time: %d:%d", minutesDisplay, secondsDisplay]];
            } else {
                [timeLabel setString:[NSString stringWithFormat:@"Total Time: %d:0%d", minutesDisplay, secondsDisplay]];
            }
            
            [self addChild:timeLabel];
            
            CCLabelTTF* deathLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Deaths: %d", [[GameVariables sharedGameVariables] getTotalDeaths]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            deathLabel.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
            [self addChild:deathLabel];
            
            CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Score: %d", [[GameVariables sharedGameVariables] getCareerScore]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            scoreLabel.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
            [self addChild:scoreLabel];
        } else {
            [[GameVariables sharedGameVariables] loadHighScores];
            topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
            int minutesDisplay;
            int secondsDisplay;
            minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1] / 60;
            secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1] - (minutesDisplay * 60);
            if (secondsDisplay > 9) {
                [topTime setString:[NSString stringWithFormat:@"Pack 1 Time: %d:%d", minutesDisplay, secondsDisplay]];
            } else {
                [topTime setString:[NSString stringWithFormat:@"Pack 1 Time: %d:0%d", minutesDisplay, secondsDisplay]];
            }
            
            [self addChild:topTime];
            
            topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:1]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
            [self addChild:topDeaths];
            
            int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:1];
            
            topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
            topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
            [self addChild:topScore];

            
            CCMenu *choosePack;
            
            CCMenuItem *packOneMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack1.png"] target:self selector:@selector(seePackOne:)];
            packOneMenu.position = CGPointMake(250, 200);
            packOneMenu.scale = 0.4;
            CCMenuItem *packTwoMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack2.png"] target:self selector:@selector(seePackTwo:)];
            packTwoMenu.position = CGPointMake(340, 200);
            packTwoMenu.scale = 0.4;
            CCMenuItem *packThreeMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack3.png"] target:self selector:@selector(seePackThree:)];
            packThreeMenu.position = CGPointMake(430, 200);
            packThreeMenu.scale = 0.4;
            CCMenuItem *packFourMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack4.png"] target:self selector:@selector(seePackFour:)];
            packFourMenu.position = CGPointMake(520, 200);
            packFourMenu.scale = 0.4;
            CCMenuItem *packFiveMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"LevelPack5.png"] target:self selector:@selector(seePackFive:)];
            packFiveMenu.position = CGPointMake(610, 200);
            packFiveMenu.scale = 0.4;
            CCMenuItem *nineLivesMenu = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nineLivesButton.png"] target:self selector:@selector(seeNineLives:)];
            nineLivesMenu.position = CGPointMake(700, 200);
            nineLivesMenu.scale = 0.4;
            
            CCMenuItem *backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton2.png"] target:self selector:@selector(goBack:)];
            backButton.position = CGPointMake(70, 710);
            
            choosePack = [CCMenu menuWithItems:packOneMenu, packTwoMenu, packThreeMenu, packFourMenu, packFiveMenu, nineLivesMenu, backButton, nil];
            choosePack.position = CGPointMake(0, 0);
            [self addChild: choosePack z:9];
        }
        
        
        
        /*CCLabelTTF* timeLabel = [CCLabelTTF labelWithString:@"UNDER CONSTRUCTION" dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
		timeLabel.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
		[self addChild:timeLabel];*/
    }
    return self;
}

-(void) seePackOne:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:1] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Pack 1 Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Pack 1 Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:1]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:1];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];

}
-(void) seePackTwo:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 2 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:2]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:2] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:2] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Pack 2 Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Pack 2 Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 2 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:2]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:2];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 2 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];
}
-(void) seePackThree:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 1 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:3]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:3] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:3] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Pack 3 Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Pack 3 Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 3 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:3]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:3];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 3 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];
}
-(void) seePackFour:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 4 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:4]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:4] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:4] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Pack 4 Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Pack 4 Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 4 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:4]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:4];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 4 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];
}
-(void) seePackFive:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 5 Time: %d", [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:5]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:5] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getLevelPackTopTimeForPack:5] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Pack 5 Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Pack 5 Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 5 Deaths: %d", [[GameVariables sharedGameVariables] getLevelPackTopDeathsForPack:5]] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:5];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Pack 5 Score: %d", score] dimensions:CGSizeMake(600.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];
}
-(void) seeNineLives:(CCMenuItem *) menuItem {
    [self removeChild:topTime cleanup:YES];
    [self removeChild:topDeaths cleanup:YES];
    [self removeChild:topScore cleanup:YES];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    topTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Nine Lives Time: %d", [[GameVariables sharedGameVariables] getNineLivesTopTime]] dimensions:CGSizeMake(700.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topTime.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 + 100);
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = [[GameVariables sharedGameVariables] getNineLivesTopTime] / 60;
    secondsDisplay = [[GameVariables sharedGameVariables] getNineLivesTopTime] - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [topTime setString:[NSString stringWithFormat:@"Nine Lives Time: %d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [topTime setString:[NSString stringWithFormat:@"Nine Lives Time: %d:0%d", minutesDisplay, secondsDisplay]];
    }
    
    [self addChild:topTime];
    
    topDeaths = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Nine Lives Levels: %d", [[GameVariables sharedGameVariables] getNineLivesTopLevelsFinished]] dimensions:CGSizeMake(700.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topDeaths.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:topDeaths];
    
    int score = [[GameVariables sharedGameVariables] getNineLivesTopScore];
    
    topScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Nine Lives Score: %d", score] dimensions:CGSizeMake(700.0f, 70.0f) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:64];
    topScore.position = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 100);
    [self addChild:topScore];
}
-(void) goBack:(CCMenuItem *) menuItem {
    CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.8 scene:[MainMenu scene]];
    [[CCDirector sharedDirector] replaceScene:transition];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CareerStats.plist"];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [self removeAllChildrenWithCleanup:YES];
}

-(void) dealloc {
    [super dealloc];
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

-(void) moveOn {
    if ([[GameVariables sharedGameVariables] getLevel] != 205) {
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[LevelPackSelect scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CareerStats.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    } else {
        [[GameVariables sharedGameVariables] setLevel:206];
        CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.8 scene:[Congratulations scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CareerStats.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [self removeAllChildrenWithCleanup:YES];
    }
    
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([[GameVariables sharedGameVariables] getLevel] != 0) [self moveOn];
    return YES;
}


@end
