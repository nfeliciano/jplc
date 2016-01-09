//
//  GameplayLayer.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-09.
//  Copyright 2011 167Games. All rights reserved.
//

#import "GameplayLayer.h"
#import "PracticeMode.h"
#import "GameVariables.h"
#import "LoadingScreen.h"
#import "CareerStats.h"
#import "Assembling.h"
#import "Congratulations.h"
#import "QuickPlayPostScreens.h"
#import "SimpleAudioEngine.h"

NSDictionary *catPos;
float catPosX;
float catPosY;
NSDictionary *goalPos;
NSDictionary *mainDict;
NSDictionary *levelDict;
int currentLevel;
NSString *levelPlist;
CCSprite* obstaclesArray[30];
CCSprite* objectArray[60];
int obsNum = 0;
int objsNum = 0;
float xDifference;
float yDifference;
BOOL catIsBackwards = FALSE;
int deaths;
int deathsInThisLevel;
int timeInSeconds;
bool backToMenu;
CCLabelTTF* deathCount;
CCLabelTTF* timeDisplay;
CCSprite *musicPaused;
CCSprite *soundsPaused;
CCSprite *nineLivesLives;
CCSprite *multiplier;
int nineLivesScore;
int threeStars;
int twoStars;
int oneStar;
BOOL startNow;
CCSprite *ready;
CCSprite *go;
int whatButtonWasTapped;

CCSprite *pawsitive;
CCMenuItem *pawsitiveYes;
CCMenuItem *pawsitiveNo;
BOOL resetLevelPack;
int startOfLevelPack;

BOOL multiplierGot;
int multiplierScore;
BOOL isInNineLivesMode;
BOOL alreadyDead;

@implementation GameplayLayer

@synthesize catSprite;
@synthesize goalSprite;
@synthesize forceFieldSprite;
@synthesize rt;

+(id) scene {
    CCScene *scene = [CCScene node];
    CCLayer* layer = [GameplayLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init {
    if (self == [super init]) {
        startNow = YES;
        if ([[GameVariables sharedGameVariables] getNineLivesMode] != YES && [[GameVariables sharedGameVariables] getPractice] != YES) {
            if (currentLevel == 1 || currentLevel == 10 || currentLevel == 13 || currentLevel == 26 || currentLevel == 20) startNow = NO;
        }
        
        if ([[GameVariables sharedGameVariables] getNineLivesMode] == YES && [[GameVariables sharedGameVariables]  getNineLivesScore] == 0) startNow = NO;
        
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [self removeAllChildrenWithCleanup:YES];
        deathsInThisLevel = 0;
        pauseScreenUp = NO;
        backToMenu = NO;
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && ![[GameVariables sharedGameVariables] getPauseMusic]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JPLCGameplayTwo.m4a" loop:YES];
        }
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"CatMeetsTool.caf"];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStop autoHandle:YES];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameSprites.plist"];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        pauseButton = [CCSprite spriteWithSpriteFrameName:@"pauseIcon.png"];
        pauseButton.position = CGPointMake(30, 30);
        pauseButton.scale = 0.5;
        [self addChild:pauseButton z:5];
        if ([[GameVariables sharedGameVariables] getNineLivesMode] == NO) {
            timeInSeconds = 0;
            [[GameVariables sharedGameVariables] setTime:timeInSeconds];
        }
        currentLevel = [[GameVariables sharedGameVariables] getLevel];
        deaths = [[GameVariables sharedGameVariables] getDeaths];
        
        /*deathCount = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"x0"] fontName:@"Marker Felt" fontSize:28];
        deathCount.position = CGPointMake(990, 20);
        [self addChild:deathCount z:6];
        [[GameVariables sharedGameVariables] setTime:0];
        timeInSeconds = 0;
        timeDisplay = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"0:00"] fontName:@"Marker Felt" fontSize:28];
        timeDisplay.position = CGPointMake(512, 20);
        [self addChild:timeDisplay z:6];*/
        
        /*timeInSeconds = [[GameVariables sharedGameVariables] getNineLivesTime];
        timeDisplay = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"0:00"] fontName:@"Marker Felt" fontSize:28];
        timeDisplay.position = CGPointMake(512, 20);
        int minutesDisplay;
        int secondsDisplay;
        minutesDisplay = timeInSeconds / 60;
        secondsDisplay = timeInSeconds - (minutesDisplay * 60);
        if (secondsDisplay > 9) {
            [timeDisplay setString:[NSString stringWithFormat:@"%d:%d", minutesDisplay, secondsDisplay]];
        } else {
            [timeDisplay setString:[NSString stringWithFormat:@"%d:0%d", minutesDisplay, secondsDisplay]];
        }
        [self addChild:timeDisplay z:5];*/

        
        isInNineLivesMode = [[GameVariables sharedGameVariables] getNineLivesMode];
        if (isInNineLivesMode) {
            multiplierGot = NO;
            nineLivesScore = [[GameVariables sharedGameVariables] getNineLivesScore];
            CCSprite *catLivesFace = [CCSprite spriteWithSpriteFrameName:@"catNineLivesFace.png"];
            catLivesFace.scale = 0.25;
            catLivesFace.position = CGPointMake(920, 30);
            [self addChild:catLivesFace z:5];
            CCSprite *nineLivesX = [CCSprite spriteWithSpriteFrameName:@"nineLivesX.png"];
            nineLivesX.scale = 0.3;
            nineLivesX.position = CGPointMake(960, 20);
            [self addChild:nineLivesX z:5];
            int nineLivesDeaths = [[GameVariables sharedGameVariables] getNineLivesLives];
            if (nineLivesDeaths == 9) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesNine.png"];
            if (nineLivesDeaths == 8) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesEight.png"];
            if (nineLivesDeaths == 7) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesSeven.png"];
            if (nineLivesDeaths == 6) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesSix.png"];
            if (nineLivesDeaths == 5) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesFive.png"];
            if (nineLivesDeaths == 4) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesFour.png"];
            if (nineLivesDeaths == 3) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesThree.png"];
            if (nineLivesDeaths == 2) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesTwo.png"];
            if (nineLivesDeaths == 1) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesOne.png"];
            nineLivesLives.scale = 0.4;
            nineLivesLives.position = CGPointMake(990, 30);
            [self addChild:nineLivesLives z:5];
            
            timeInSeconds = [[GameVariables sharedGameVariables] getNineLivesTime];
            timeDisplay = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"0:00"] fontName:@"Marker Felt" fontSize:28];
            timeDisplay.position = CGPointMake(512, 20);
            int minutesDisplay;
            int secondsDisplay;
            minutesDisplay = timeInSeconds / 60;
            secondsDisplay = timeInSeconds - (minutesDisplay * 60);
            if (secondsDisplay > 9) {
                [timeDisplay setString:[NSString stringWithFormat:@"%d:%d", minutesDisplay, secondsDisplay]];
            } else {
                [timeDisplay setString:[NSString stringWithFormat:@"%d:0%d", minutesDisplay, secondsDisplay]];
            }
            [self addChild:timeDisplay z:5];
            
            int value = arc4random() % 9;
            if (value <= 4) {
                multiplierScore = 2;
                multiplier = [CCSprite spriteWithSpriteFrameName:@"timesTwoMultiplier.png"];
                multiplier.position = CGPointMake((arc4random() % 925) + 100, (arc4random() % 701) + 68);
                multiplier.scale = 0.3;
                multiplier.visible = YES;
                [self addChild:multiplier z:6];
            } else {
                multiplierScore = 3;
                multiplier = [CCSprite spriteWithSpriteFrameName:@"timesThreeMultiplier.png"];
                multiplier.position = CGPointMake((arc4random() % 925) + 100, (arc4random() % 701) + 68);
                multiplier.scale = 0.2;
                multiplier.visible = YES;
                [self addChild:multiplier z:6];
            }
            
            [self schedule:@selector(updateTime) interval:1];
        }
        
        if ([[GameVariables sharedGameVariables] getPractice]) {            //REMOVE LATER
            timeInSeconds = [[GameVariables sharedGameVariables] getTotalTime];
            timeDisplay = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"0:00"] fontName:@"Marker Felt" fontSize:28];
            timeDisplay.position = CGPointMake(512, 20);
            int minutesDisplay;
            int secondsDisplay;
            minutesDisplay = timeInSeconds / 60;
            secondsDisplay = timeInSeconds - (minutesDisplay * 60);
            if (secondsDisplay > 9) {
                [timeDisplay setString:[NSString stringWithFormat:@"%d:%d", minutesDisplay, secondsDisplay]];
            } else {
                [timeDisplay setString:[NSString stringWithFormat:@"%d:0%d", minutesDisplay, secondsDisplay]];
            }
            [self addChild:timeDisplay z:5];
            [self schedule:@selector(updateTime) interval:1];
        }
        
        self.isTouchEnabled = YES;
        catHasBeenTouched = NO;
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"LevelPList.plist"];
        mainDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        
        if ([[GameVariables sharedGameVariables] getPractice] == YES) {
            CCArray *practiceArray = [mainDict objectForKey:@"practiceStandards"];
            NSDictionary *practiceDict = [practiceArray objectAtIndex:currentLevel-1];
            threeStars = [[practiceDict objectForKey:@"threeStars"] intValue];
            twoStars = [[practiceDict objectForKey:@"twoStars"] intValue];
            oneStar = [[practiceDict objectForKey:@"oneStar"] intValue];
        }
        
        CCArray *catPosArray = [mainDict objectForKey:@"catPosition"];
        catPos = [catPosArray objectAtIndex:currentLevel-1];
        catSprite = [CCSprite spriteWithSpriteFrameName:@"cat.png"];
        catPosX = [[catPos objectForKey:@"xPos"] floatValue];
        catPosY = [[catPos objectForKey:@"yPos"] floatValue];
        catSprite.position = CGPointMake(catPosX, catPosY);
        [self addChild:catSprite z:3];
        
        CCArray *forcefieldColorArray = [mainDict objectForKey:@"forcefieldColor"];
        NSString *colorPath = [forcefieldColorArray objectAtIndex:currentLevel-1];
        forceFieldSprite = [CCSprite spriteWithSpriteFrameName:colorPath];
        forceFieldSprite.position = CGPointMake(catPosX, catPosY);
        forceFieldSprite.visible = NO;
        [self addChild:forceFieldSprite z:3];
        //CCLOG(@"%@", [catPos objectForKey:@"yPos"]);
        
        CCArray *goalPosArray = [mainDict objectForKey:@"itemPosition"];
        goalPos = [goalPosArray objectAtIndex:currentLevel-1];
        CCArray *toolSpriteArray = [mainDict objectForKey:@"toolSprite"];
        NSDictionary *toolSpriteDict = [toolSpriteArray objectAtIndex:currentLevel-1];
        
        NSString *toolPath = [toolSpriteDict objectForKey:@"string"];
        
        goalSprite = [CCSprite spriteWithSpriteFrameName:toolPath];
        goalSprite.scale = [[toolSpriteDict objectForKey:@"scale"] floatValue];
        goalSprite.rotation = [[toolSpriteDict objectForKey:@"rotation"] intValue];
        goalSprite.position = CGPointMake([[goalPos objectForKey:@"xPos"] floatValue], [[goalPos objectForKey:@"yPos"] floatValue]);
        [self addChild:goalSprite z:3];
        CCSprite *toolForcefield = [CCSprite spriteWithSpriteFrameName: colorPath];
        toolForcefield.position = CGPointMake([[goalPos objectForKey:@"xPos"] floatValue], [[goalPos objectForKey:@"yPos"] floatValue]);
        [self addChild:toolForcefield z:3];
        
        rt = [CCRenderTexture renderTextureWithWidth:screenSize.width height:screenSize.height];
        [self addChild:rt];
        rt.visible = NO;
        
        [self levelInit];
        
    }
    return self;
}

-(void) levelInit {
    currentLevel = [[GameVariables sharedGameVariables] getLevel];
    
    CCArray *levelPlistArray = [mainDict objectForKey:@"levelPlists"];
    levelPlist = [levelPlistArray objectAtIndex:currentLevel-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:levelPlist];
    
    CCArray *levelArray = [mainDict objectForKey:@"levels"];
    levelDict = [levelArray objectAtIndex:currentLevel-1];
    
    for (id key in levelDict) {
        NSDictionary *obstacle = [levelDict objectForKey:key];
        NSString *imagePath = [obstacle objectForKey:@"image"];
        CCSprite *obstacleSprite = [CCSprite spriteWithSpriteFrameName:imagePath];
        obstacleSprite.position = CGPointMake([[obstacle objectForKey:@"xPos"] floatValue], [[obstacle objectForKey:@"yPos"] floatValue]);
        [self addChild:obstacleSprite z:[[obstacle objectForKey:@"zVal"] intValue]];
        objectArray[objsNum] = obstacleSprite;
        objsNum++;
        
        NSString *movement = [obstacle objectForKey:@"movement"];
        if (movement != NULL) {
            if ([movement isEqualToString:@"invisible"]) {
                obstacleSprite.visible = NO;
            }
            [self moveObstacle:obstacleSprite withMovement:movement];
        }
        if ([[obstacle objectForKey:@"collide"] boolValue] == YES) {
            obstaclesArray[obsNum] = obstacleSprite;
            obsNum++;
        }
        
    }
    
    if ([[GameVariables sharedGameVariables] getPractice]) [self schedule:@selector(updateTime) interval:1];
    if (startNow && [[GameVariables sharedGameVariables] getPractice] == NO) [self schedule:@selector(updateTime) interval:1];
    if (!startNow) [self readyGo];
    [self scheduleUpdate];
}

-(void) readyGo {
    ready = [CCSprite spriteWithSpriteFrameName:@"ready.png"];
    ready.scale = 0.0;
    ready.position = CGPointMake(512, 384);
    [self addChild:ready z:7];
    go = [CCSprite spriteWithSpriteFrameName:@"go.png"];
    go.scale = 0;
    go.position = CGPointMake(512, 384);
    [self addChild:go z:7];
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:2.0 scale:0.8];
    CCHide *disappear = [CCHide action];
    CCSequence *readySeq = [CCSequence actions:scaleUp, disappear, nil];
    [ready runAction:readySeq];
    
    CCScaleTo *scaleGo = [CCScaleTo actionWithDuration:1.0 scale:0.8];
    CCDelayTime *delayGo = [CCDelayTime actionWithDuration:2.0];
    CCSequence *goSeq = [CCSequence actions: delayGo, scaleGo, disappear, nil];
    [go runAction: goSeq];
    
    [self performSelector:@selector(startTheGame) withObject:nil afterDelay:3.0];
}

-(void) startTheGame {
    startNow = YES;
    [self schedule:@selector(updateTime) interval:1];
}

-(void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
    [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [CCTextureCache purgeSharedTextureCache];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    [super dealloc];
}

//Update! Update! Update!
-(void) update:(ccTime) delta {
    [self checkCollisions];
    //[self updateDeaths];
    //[self updateTimer];
    if ([[GameVariables sharedGameVariables] getNineLivesMode] && startNow) [self updateTimer];
    if ([[GameVariables sharedGameVariables] getPractice]) [self updateTimer];          //REMOVE LATER
    
    currentLevel = [[GameVariables sharedGameVariables] getLevel];
    if (currentLevel == 8) {
        for (int i = 0; i < obsNum; i++) {
            CCSprite *tempObs = obstaclesArray[i];
            if (tempObs.position.y < -60) {
                tempObs.position = CGPointMake(tempObs.position.x, 980);
                [self moveObstacle:tempObs withMovement:@"levelEightBoxColFour"];
            } else if (tempObs.position.y > 980) {
                tempObs.position = CGPointMake(tempObs.position.x, -60);
                [self moveObstacle:tempObs withMovement:@"levelEightBoxColTwo"];
            }
        }
    } else if (currentLevel == 25) {
        for (int i =0; i < obsNum; i++) {
            CCSprite *tempObs = obstaclesArray[i];
            if (tempObs.position.y >= 800) {
                tempObs.position = CGPointMake(tempObs.position.x, -300);
                [self moveObstacle:tempObs withMovement:@"levelTwentyfiveBar"];
            }
        }
    } else if (currentLevel == 39) {
        for (int i =0; i < obsNum; i++) {
            CCSprite *tempObs = obstaclesArray[i];
            if (tempObs.position.x >= 1600) {
                tempObs.position = CGPointMake(-190, tempObs.position.y);
                [self moveObstacle:tempObs withMovement:@"levelThirtynineOneBox"];
            } else if (tempObs.position.x <= -300) {
                tempObs.position = CGPointMake(1290, tempObs.position.y);
                [self moveObstacle:tempObs withMovement:@"levelThirtynineTwoBoxes"];
            }
        }
    } else if (currentLevel == 47) {
        for (int i =0; i < obsNum; i++) {
            CCSprite *tempObs = obstaclesArray[i];
            if (tempObs.position.x >= 1312) {
                tempObs.position = CGPointMake(-188, tempObs.position.y);
                [self moveObstacle:tempObs withMovement:@"levelFourtysevenWindmill"];
            }        }
    }
}

-(void) updateTime {
    timeInSeconds++;
    [[GameVariables sharedGameVariables] setTime:timeInSeconds];
    if ([[GameVariables sharedGameVariables] getNineLivesMode]) [[GameVariables sharedGameVariables] setNineLivesTime:timeInSeconds];
}

-(void) updateTimer {
    timeInSeconds = [[GameVariables sharedGameVariables] getTime];
    int minutesDisplay;
    int secondsDisplay;
    minutesDisplay = timeInSeconds / 60;
    secondsDisplay = timeInSeconds - (minutesDisplay * 60);
    if (secondsDisplay > 9) {
        [timeDisplay setString:[NSString stringWithFormat:@"%d:%d", minutesDisplay, secondsDisplay]];
    } else {
        [timeDisplay setString:[NSString stringWithFormat:@"%d:0%d", minutesDisplay, secondsDisplay]];
    }
}

-(void) updateDeaths {
    deaths = [[GameVariables sharedGameVariables] getDeaths];
    [deathCount setString:[NSString stringWithFormat:@"x%d", deaths]];
}

-(void) moveObstacle:(CCSprite*)obstacle withMovement:(NSString *)movement {
    currentLevel = [[GameVariables sharedGameVariables] getLevel];
    if (currentLevel == 2) {
        if ([movement isEqualToString:@"levelTwoInner"]) {
            CCRotateBy* innerRotation = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:innerRotation];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwoMiddle"]) {
            CCRotateBy* middleRotation = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:middleRotation];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwoOuterMove"]) {
            obstacle.anchorPoint = ccp(3.4, 0.4);
            CCRotateBy* outerRotationUp = [CCRotateBy actionWithDuration:1.0 angle:8];
            CCRotateBy* outerRotationDown = [CCRotateBy actionWithDuration:1.0 angle:-10];
            CCRotateBy* outerRotationDownTwo = [CCRotateBy actionWithDuration: 1.0 angle: -10];
            CCRotateBy* outerRotationUpTwo = [CCRotateBy actionWithDuration:1.0 angle:12];
            CCSequence* sequence = [CCSequence actions:outerRotationUp, outerRotationDown, outerRotationDownTwo, outerRotationUpTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 3) {
        if ([movement isEqualToString:@"levelThreeWindmill"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelThreeWindmillOpposite"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 4) {
        if ([movement isEqualToString:@"levelFourBlockOne"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(0, 100)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(0, -100)];
            CCSequence* sequence = [CCSequence actions:delay,moveDown, delay, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourBlockTwo"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(0, 90)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(0, -90)];
            CCSequence* sequence = [CCSequence actions:moveDown, delay, moveDown, delay, moveUp, delay, moveUp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourBlockThree"]) {
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(0, 120)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(0, -120)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(230, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(-230, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveDown, moveLeft, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourBlockFour"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(0, 230)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(0, -230)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(230, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(-230, 0)];
            CCSequence* sequence = [CCSequence actions:delay, moveRight,moveLeft, delay, moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourBlockFive"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveRightShort = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(115, 0)];
            CCMoveBy* moveLeftShort = [CCMoveBy actionWithDuration:0.25 position:CGPointMake(-115, 0)];
            CCMoveBy* moveRightLong = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(460, 0)];
            CCMoveBy* moveLeftLong = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(-460, 0)];
            CCSequence* sequence = [CCSequence actions:delay, moveRightShort, delay, moveLeftShort, delay, moveRightLong, delay, moveLeftLong, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 6) {
        if ([movement isEqualToString:@"levelSixBar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -230)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 230)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 7) {
        if ([movement isEqualToString:@"levelSevenWheelOne"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:0.5 angle:45];
            CCRepeatForever* rotate = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:rotate];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 230)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -230)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(-625, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(625, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveDown, moveLeft, moveRight, moveUp, moveLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelSevenWheelTwo"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:0.5 angle:45];
            CCRepeatForever* rotate = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:rotate];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 260)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -260)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(-575, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(575, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveDown, moveLeft, moveRight, moveUp, moveLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 8) {
        if ([movement isEqualToString:@"levelEightBoxColTwo"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, 210)];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:moveDown];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelEightBoxColFour"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, -210)];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:moveDown];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 9) {
        if ([movement isEqualToString:@"levelNineBoxOne"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, -320)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, 320)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelNineBoxTwo"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -320)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 10) {
        if ([movement isEqualToString:@"levelTenBlockOne"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, 600)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, -600)];
            CCSequence* sequence = [CCSequence actions:moveDown,delay, moveUp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTenBlockTwo"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, 600)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, -600)];
            CCSequence* sequence = [CCSequence actions:delay, moveUp,delay, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 11) {
        if ([movement isEqualToString:@"levelElevenWindmill"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:0.6 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 12) {
        if ([movement isEqualToString:@"levelTwelveWheelTwo"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:2.0];
            CCRotateBy* wheelTwoRot = [CCRotateBy actionWithDuration:4.0 angle:180];
            CCSequence* sequence = [CCSequence actions:delay, wheelTwoRot, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwelveWheelFour"]) {
            CCRotateBy* windFourRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windFourRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwelveWheelSix"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0];
            CCRotateBy* wheelTwoRotCC = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCRotateBy* wheelTwoRotC = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions:delay, wheelTwoRotCC, delay, wheelTwoRotC, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwelveWheelEight"]) {
            CCRotateBy* windEightRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windEightRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwelveWheelNine"]) {
            CCRotateBy* windNineRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windNineRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 13) {
        if ([movement isEqualToString:@"levelThirteenWindmill"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:5.0 angle:180];
            CCRotateBy* windOneCounterRot = [CCRotateBy actionWithDuration:2.5 angle:-90];
            CCSequence* sequence = [CCSequence actions:windOneRot, delay, windOneCounterRot, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 14) {
        if ([movement isEqualToString:@"levelFourteenWindmillOne"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourteenWindmillTwo"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 15) {  ///////CHOP LEVEL UP TO IMPROVE FRAMERATE
        if ([movement isEqualToString:@"levelFifteenWindmillOne"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFifteenWindmillTwo"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 19) {
        if ([movement isEqualToString:@"levelNinteenBarOne"]) {
            obstacle.rotation += 90;
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, -480)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, 480)];
            CCSequence* sequence = [CCSequence actions:delay, moveUp, delay, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelNineteenBarTwo"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.25];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:7.0 position:CGPointMake(-600, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:7.0 position:CGPointMake(600, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, delay, moveLeft, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelNineteenBarThree"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.25];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:7.0 position:CGPointMake(-610, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:7.0 position:CGPointMake(610, 0)];
            CCSequence* sequence = [CCSequence actions:moveLeft, delay, moveRight, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 20) {
        if ([movement isEqualToString:@"levelTwentyTopbar"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(400, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(-200, 0)];
            CCSequence* sequence = [CCSequence actions:moveLeft, moveRight, moveLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyMid"]) {
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:3.0 position:CGPointMake(-600, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(300, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveLeft, moveRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyBottom"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(400, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(-200, 0)];
            CCSequence* sequence = [CCSequence actions:moveLeft, moveRight, moveLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 21) {
        if ([movement isEqualToString:@"levelTwentyoneTopBar"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(-300, 0)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(300, 0)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:3.4 position:CGPointMake(510, 0)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:3.4 position:CGPointMake(-510, 0)];
            CCSequence* sequence = [CCSequence actions: moveLeft, moveRight, moveRightTwo, delay, moveLeftTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyoneBottomBar"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:4.13 position:CGPointMake(690, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:4.13 position:CGPointMake(-690, 0)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(-120, 0)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(120, 0)];
            CCSequence* sequence = [CCSequence actions: moveRight, moveLeft, moveLeftTwo, moveRightTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 22) {
        if ([movement isEqualToString:@"levelTwentytwoTopbar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -120)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 120)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentytwoBottombar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -150)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 150)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 23) {
        if ([movement isEqualToString:@"levelTwentythreeTopbar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:3.0 position:CGPointMake(0, -300)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:6.0 position:CGPointMake(0, 600)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentythreeBottombar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:3.0 position:CGPointMake(0, -300)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:6.0 position:CGPointMake(0, 600)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 25) {
        if ([movement isEqualToString:@"levelTwentyfiveBar"]) {
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:2.0 position:CGPointMake(0, 300)];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:moveDown];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 26) {
        if ([movement isEqualToString:@"levelTwentysixWheelRightStop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCRotateBy* rotate = [CCRotateBy actionWithDuration:1.0 angle:90];
            CCSequence* sequence = [CCSequence actions:rotate, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentysixWheelLeftStop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
            CCRotateBy* rotate = [CCRotateBy actionWithDuration:1.0 angle:-90];
            CCSequence* sequence = [CCSequence actions:rotate, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentysixWheelRightCont"]) {
            CCRotateBy* rotate = [CCRotateBy actionWithDuration:1.5 angle:90];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentysixWheelLeftCont"]) {
            CCRotateBy* rotate = [CCRotateBy actionWithDuration:1.5 angle:-90];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 27) { ////////CHOP LEVEL UP TO IMPROVE FRAMERATE
        if ([movement isEqualToString:@"levelTwentysevenWindmill"]) {
            CCRotateBy* windOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windOneRot];
            [obstacle runAction:repeat];
        }
    }
    else if (currentLevel == 28) {
        if ([movement isEqualToString:@"levelTwentyeightBlockEleven"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 120)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -120)];
            CCSequence* sequence = [CCSequence actions:delay, moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockTwelve"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.5];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 120)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -120)];
            CCSequence* sequence = [CCSequence actions:moveDown, moveUp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockThirteen"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.5];    
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCSequence* sequence = [CCSequence actions:moveLeft, moveRight, delay, moveRight, moveLeft, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockFourteen"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:3.0];    
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCSequence* sequence = [CCSequence actions:moveLeft, moveRight, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockFifteen"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 120)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -120)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveDown, moveLeft, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockSixteen"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.5];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCSequence* sequence = [CCSequence actions:moveRight, moveLeft, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockSeventeen"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, 120)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -120)];
            CCSequence* sequence = [CCSequence actions:moveLeft, moveUp, moveRight, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelTwentyeightBlockEighteen"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.5];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(140, 0)];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(-140, 0)];
            CCSequence* sequence = [CCSequence actions:delay, moveLeft, moveRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 30) { ///////IMPROVE FRAMERATE URGENT
        if ([movement isEqualToString:@"levelThirtyCircleOne"]) {
            CCRotateBy* circleOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelThirtyCircleTwo"]) {
            CCRotateBy* circleTwoRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleTwoRot];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 38) {
        if ([movement isEqualToString:@"levelThirtyeightBoxOne"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.4];;
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.33 position:CGPointMake(0, 120)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:0.33 position:CGPointMake(0, -120)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:0.66 position:CGPointMake(0, 324)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:0.66 position:CGPointMake(0, -324)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 484)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -484)];
            CCSequence* sequence = [CCSequence actions:delay, moveUpOne, moveDownOne, delay, moveUpTwo, moveDownTwo, delay, moveUpThree, moveDownThree, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelThirtyeightBoxTwo"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.4];;
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.33 position:CGPointMake(0, 100)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:0.33 position:CGPointMake(0, -100)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:0.66 position:CGPointMake(0, 284)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:0.66 position:CGPointMake(0, -284)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 484)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -484)];
            CCSequence* sequence = [CCSequence actions:delay, moveDownOne, moveUpOne, delay, moveDownTwo, moveUpTwo, delay, moveDownThree, moveUpThree, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 39) {
        if ([movement isEqualToString:@"levelThirtynineOneBox"]) {
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(200, 0)];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:moveRight];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelThirtynineTwoBoxes"]) {
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(-200, 0)];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:moveLeft];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 40) {
        if ([movement isEqualToString:@"levelFortyBoxOne"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions:moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxTwo"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxThree"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxFour"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxFive"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxSix"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxSeven"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxEight"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveLeftTwo, moveDownThree, moveLeftThree, moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyBoxNine"]) {
            CCMoveBy* moveRightOne = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(245, 0)];
            CCMoveBy* moveUpOne = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, 150)];
            CCMoveBy* moveRightTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(365, 0)];
            CCMoveBy* moveDownOne = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -245)];
            CCMoveBy* moveRightThree = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(235, 0)];
            CCMoveBy* moveDownTwo = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(0, -380)];
            CCMoveBy* moveLeftOne = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-395, 0)];
            CCMoveBy* moveUpTwo = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 320)];
            CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-195, 0)];
            CCMoveBy* moveDownThree = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(0, -150)];
            CCMoveBy* moveLeftThree = [CCMoveBy actionWithDuration:1.4 position:CGPointMake(-400, 0)];
            CCMoveBy* moveUpThree = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 305)];
            CCMoveBy* moveRightFour = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(145, 0)];
            CCSequence* sequence = [CCSequence actions: moveUpThree, moveRightFour, moveRightOne, moveUpOne, moveRightTwo, moveDownOne, moveRightThree, moveDownTwo, moveLeftOne, moveUpTwo, moveLeftTwo, moveDownThree, moveLeftThree, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 41) {
        if ([movement isEqualToString:@"levelFortyoneWheelCW"]) {
            CCRotateBy* circleOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyoneWheelCCW"]) {
            CCRotateBy* circleTwoRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleTwoRot];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 42) {
        if ([movement isEqualToString:@"levelFortytwoBar"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0];
            CCMoveBy* barDown = [CCMoveBy actionWithDuration:5.6 position:CGPointMake(0, -560)];
            CCMoveBy* barUp = [CCMoveBy actionWithDuration:5.6 position:CGPointMake(0, 560)];
            CCSequence* sequence = [CCSequence actions: delay, barDown, barUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }else if (currentLevel == 43) {
        if ([movement isEqualToString:@"levelFortythreeBox"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(-100, 0)];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(0, -140)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(0, 140)];
            CCMoveBy* moveRight = [CCMoveBy actionWithDuration:0.6 position:CGPointMake(100, 0)];
            CCSequence* sequence = [CCSequence actions:delay, moveLeft, delay, moveDown, delay, moveUp, delay, moveRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortythreeWindmill"]) {
            CCRotateBy* windmillRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windmillRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortythreeElevator"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:3.0 position:CGPointMake(0, -320)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:3.0 position:CGPointMake(0, 320)];
            CCSequence* sequence = [CCSequence actions:delay, moveDown, delay, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortythreeWheelOne"]) {
            CCRotateBy* circleOneRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleOneRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortythreeWheelTwo"]) {
            CCRotateBy* circleTwoRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:circleTwoRot];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 44) {
        if ([movement isEqualToString:@"levelFortyfourBarOneTop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: moveDown, moveUp, delay, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarOneBottom"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: moveUp, moveDown, delay, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarTwoTop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, moveDown, moveUp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarTwoBottom"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, moveUp, moveDown, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarThreeTop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, delay, moveDown, moveUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarThreeBottom"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, delay, moveUp, moveDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarFourTop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, moveDown, moveUp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarFourBottom"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: delay, moveUp, moveDown, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarFiveTop"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: moveDown, moveUp, delay, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFortyfourBarFiveBottom"]) {
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.2];
            CCMoveBy* moveDown = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, -130)];
            CCMoveBy* moveUp = [CCMoveBy actionWithDuration:0.4 position:CGPointMake(0, 130)];
            CCSequence* sequence = [CCSequence actions: moveUp, moveDown, delay, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 45) {
        if ([movement isEqualToString:@"levelFourtyfiveWindmillOne"]) {
            CCRotateBy* windmillRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windmillRot];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourtyfiveWindmillTwo"]) {
            CCRotateBy* windmillRot = [CCRotateBy actionWithDuration:1.0 angle:-45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windmillRot];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 46) {
        if ([movement isEqualToString:@"levelFourtysixWindmill"]) {
            CCRotateBy* windmillRot = [CCRotateBy actionWithDuration:1.0 angle:45];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windmillRot];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 47) {
        if ([movement isEqualToString:@"levelFourtysevenWindmill"]) {
            CCRotateBy* windmillRot = [CCRotateBy actionWithDuration:1.0 angle:90];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:windmillRot];
            [obstacle runAction:repeat];
            CCMoveBy* windmillMove = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(400, 0)];
            CCRepeatForever* repeatTwo = [CCRepeatForever actionWithAction:windmillMove];
            [obstacle runAction:repeatTwo];
        }
    } else if (currentLevel == 48) {
        if ([movement isEqualToString:@"levelFourtyeightBar"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.75];
            CCMoveBy* windmillMoveRight = [CCMoveBy actionWithDuration:5.0 position:CGPointMake(800, 0)];
            CCMoveBy* windmillMoveLeft = [CCMoveBy actionWithDuration:5.0 position:CGPointMake(-800, 0)];
            CCSequence* sequence = [CCSequence actions: windmillMoveLeft, delay, windmillMoveRight, delay, nil];
            CCRepeatForever* repeatTwo = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeatTwo];
        }
    } else if (currentLevel == 49) {
        if ([movement isEqualToString:@"levelFourtynineBottombar"]) {
            CCMoveBy* barDown = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, -420)];
            CCMoveBy* barUp = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, 420)];
            CCSequence* sequence = [CCSequence actions: barUp, barDown, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFourtynineTopbar"]) {
            CCMoveBy* barDown = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, -420)];
            CCMoveBy* barUp = [CCMoveBy actionWithDuration:4.0 position:CGPointMake(0, 420)];
            CCSequence* sequence = [CCSequence actions: barDown, barUp, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 50) {
        if ([movement isEqualToString:@"levelFiftyWheelTopleft"]) {
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:12.0 angle:-270];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:12.0 angle:270];
            CCSequence* sequence = [CCSequence actions: rotLeft, rotRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyWheelTopright"]) {
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyWheelBottomleft"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:1.0];
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions: rotRight, rotRight, delay, rotLeft, rotLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyWheelBottomright"]) {
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
            [obstacle runAction:repeat];
        }
    } else if (currentLevel == 51) {
        if ([movement isEqualToString:@"levelFiftyoneTopLeft"]) {
            obstacle.rotation = -90;
        } else if ([movement isEqualToString:@"levelFiftyoneTopMiddle"]) {
            obstacle.rotation = 90;
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions:rotate, rotate, delay, rotate, rotate, delay, nil];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneTopright"]) {
            obstacle.rotation = 90;
        } else if ([movement isEqualToString:@"levelFiftyoneMidLeft"]) {
            obstacle.rotation = -90;
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCRotateBy *rotateOpp = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCSequence *sequence = [CCSequence actions:rotate, rotate, delay, rotateOpp, rotateOpp, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneMidTwo"]) {
            obstacle.rotation = -90;
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCSequence *sequence = [CCSequence actions:rotate, rotate, delay, rotate, rotate, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneMid"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions:rotate, rotate, delay, rotate, rotate, delay, nil];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneMidFour"]) {
            obstacle.rotation = -90;
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCSequence* sequence = [CCSequence actions:rotate, rotate, delay, rotate, rotate, delay, nil];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneMidRight"]) {
            obstacle.rotation = 90;
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCRotateBy *rotateOpp = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCSequence *sequence = [CCSequence actions:rotateOpp, rotateOpp, delay, rotate, rotate, delay, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneBottomLeft"]) {
            obstacle.rotation = 180;
        } else if ([movement isEqualToString:@"levelFiftyoneBottomMid"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.25];
            CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCSequence* sequence = [CCSequence actions:rotate, rotate, delay, rotate, rotate, delay, nil];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyoneBottomRight"]) {
            obstacle.rotation = 90;
        }
    } else if (currentLevel == 52) {
        if ([movement isEqualToString:@"LisaLeftEye"]) {
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions: rotLeft, rotRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyTwoRightEye"]) {
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:2.0 angle:-90];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:2.0 angle:90];
            CCSequence* sequence = [CCSequence actions: rotLeft, rotLeft, rotRight, rotRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyTwoLeftEyebrow"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:2.0 angle:-35];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:2.0 angle:35];
            CCSequence* sequence = [CCSequence actions: rotRight, delay, rotLeft, rotLeft, delay, rotRight, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        } else if ([movement isEqualToString:@"levelFiftyTwoRightEyebrow"]) {
            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
            CCRotateBy *rotRight = [CCRotateBy actionWithDuration:2.0 angle:-35];
            CCRotateBy *rotLeft = [CCRotateBy actionWithDuration:2.0 angle:35];
            CCSequence* sequence = [CCSequence actions: rotLeft, delay, rotRight, rotRight, delay, rotLeft, nil];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
            [obstacle runAction:repeat];
        }
    }
}

-(void) checkCollisions {
    for (int i = 0; i < obsNum; i++) {
        if ([self isACollisionBetweenSpriteA:catSprite SpriteB:obstaclesArray[i] pixelPerfect:YES]) {
            [self animateDeath];
        }
    }
    if ([self isACollisionBetweenSpriteA:catSprite SpriteB:goalSprite pixelPerfect:YES]) {
        [self levelPassed];
    } if (isInNineLivesMode) {
        if ([self isACollisionBetweenSpriteA:catSprite SpriteB:multiplier pixelPerfect:YES]) {
            multiplierGot = YES;
            multiplier.visible = NO;
        }
    }
}

-(BOOL) isACollisionBetweenSpriteA:(CCSprite *)sprite1 SpriteB:(CCSprite *)sprite2 pixelPerfect:(BOOL)p {
    BOOL isCollision = NO;
    CGRect intersection = CGRectIntersection([sprite1 boundingBox], [sprite2 boundingBox]);
    
    if (!CGRectIsEmpty(intersection)) {
        if (!p) {return YES;}
        
        unsigned int x = intersection.origin.x;
        unsigned int y = intersection.origin.y;
        unsigned int w = intersection.size.width;
        unsigned int h = intersection.size.height;
        unsigned int numPixels = w * h;
        
        [rt beginWithClear:0 g:0 b:0 a:0];
        
        glColorMask(1, 0, 0, 1);
        [sprite1 visit];
        glColorMask(0, 1, 0, 1);
        [sprite2 visit];
        glColorMask(1, 1, 1, 1);
        
        ccColor4B *buffer = malloc ( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        [rt end];
        
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+= step) {
            ccColor4B color = buffer[i];
            
            if (color.r > 0 && color.g > 0) {
                isCollision = YES;
                break;
            }
        }
        free(buffer);
    }
    
    return isCollision;
}

-(void) delay {
    alreadyDead = NO;
}

-(void) animateDeath {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"CatDeathSound.caf"];
    if ([[GameVariables sharedGameVariables] getNineLivesMode] && !alreadyDead) {
        int nineLivesDeaths = [[GameVariables sharedGameVariables] getNineLivesLives];
        nineLivesDeaths--;
        [[GameVariables sharedGameVariables] setNineLivesLives:nineLivesDeaths];
        multiplier.visible = NO;
        if (nineLivesDeaths == 0) {
            [[GameVariables sharedGameVariables] setLevel:150];
            backToMenu = YES;
            [self removeChild:nineLivesLives cleanup:YES];
            [self levelPassed];
        } else {
            [self removeChild:nineLivesLives cleanup:YES];
            if (nineLivesDeaths == 8) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesEight.png"];
            if (nineLivesDeaths == 7) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesSeven.png"];
            if (nineLivesDeaths == 6) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesSix.png"];
            if (nineLivesDeaths == 5) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesFive.png"];
            if (nineLivesDeaths == 4) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesFour.png"];
            if (nineLivesDeaths == 3) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesThree.png"];
            if (nineLivesDeaths == 2) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesTwo.png"];
            if (nineLivesDeaths == 1) nineLivesLives = [CCSprite spriteWithSpriteFrameName:@"nineLivesOne.png"];
            nineLivesLives.scale = 0.4;
            nineLivesLives.position = CGPointMake(990, 30);
            [self addChild:nineLivesLives z:5];
            alreadyDead = YES;
            [self performSelector:@selector(delay) withObject:nil afterDelay:0.3];
        }
    }
    deaths++;
    deathsInThisLevel++;
    [[GameVariables sharedGameVariables] setDeaths:deaths];
    
    CCMoveBy* moveLeft = [CCMoveBy actionWithDuration:0.05 position:CGPointMake(10, 0)];
    CCMoveBy* moveUpRight = [CCMoveBy actionWithDuration:0.05 position:CGPointMake(-20, 10)];
    CCMoveBy* moveLeftTwo = [CCMoveBy actionWithDuration:0.05 position:CGPointMake(20, 0)];
    CCMoveBy* moveDownRight = [CCMoveBy actionWithDuration:0.05 position:CGPointMake(-20, -10)];
    CCMoveTo* moveBack = [CCMoveTo actionWithDuration:0.05 position:CGPointMake(0, 0)];
    CCSequence* sequence = [CCSequence actions: moveLeft, moveUpRight, moveLeftTwo, moveDownRight, moveBack, nil];
    
    [self runAction:sequence];
    
    [self performSelector:@selector(resetCat) withObject:nil afterDelay:0.0];
}

-(void) resetCat {
    catHasBeenTouched = NO;
    catSprite.scaleX = 1.0;
    forceFieldSprite.position = CGPointMake(catPosX, catPosY);
    catSprite.position = CGPointMake(catPosX, catPosY);
    forceFieldSprite.visible = NO;
}

-(int) getNextLevel {
    if (currentLevel == 1) {
        levelPlist = @"LevelOnePlist.plist";
        return 5;
    } else if (currentLevel == 5) {
        levelPlist = @"LevelFivePlist.plist";
        return 9;
    } else if (currentLevel == 9) {
        levelPlist = @"LevelNinePlist.plist";
        return 11;
    } else if (currentLevel == 11) {
        levelPlist = @"LevelElevenPlist.plist";
        return 6;
    } else if (currentLevel == 6) {
        levelPlist = @"LevelSixPlist.plist";
#if JPLCPRO
        return 44;
#elif JPLCLITE
        return 101;
#endif
    } else if (currentLevel == 44) {
        levelPlist = @"LevelFortyfourPlist.plist";
        return 41;
    } else if (currentLevel == 41) {
        levelPlist = @"LevelFortyonePlist.plist";
        return 43;
    } else if (currentLevel == 43) {
        levelPlist = @"LevelFortythreePlist.plist";
        return 201;
    } else if (currentLevel == 10) {
        levelPlist = @"LevelTenPlist.plist";
        return 22;
    } else if (currentLevel == 22) {
        levelPlist = @"LevelTwentytwoPlist.plist";
        return 8;
    } else if (currentLevel == 8) {
        levelPlist = @"LevelEightPlist.plist";
        return 28;
    } else if (currentLevel == 28) {
        levelPlist = @"LevelTwentyeightPlist.plist";
        return 4;
    } else if (currentLevel == 4) {
        levelPlist = @"LevelFourPlist.plist";
#if JPLCPRO
        return 40;
#elif JPLCLITE
        return 101;
#endif
    } else if (currentLevel == 40) {
        levelPlist = @"LevelFortyPlist.plist";
        return 38;
    } else if (currentLevel == 38) {
        levelPlist = @"LevelThirtyeightPlist.plist";
        return 39;
    } else if (currentLevel == 39) {
        levelPlist = @"LevelThirtyninePlist.plist";
        return 202;
    } else if (currentLevel == 13) {
        levelPlist = @"LevelThirteenPlist.plist";
        return 3;
    } else if (currentLevel == 3) {
        levelPlist = @"LevelThreePlist.plist";
        return 27;
    } else if (currentLevel == 27) {
        levelPlist = @"LevelTwentysevenPlist.plist";
        return 15;
    } else if (currentLevel == 15) {
        levelPlist = @"LevelFifteenPlist.plist";
        return 46;
    } else if (currentLevel == 46) {
        levelPlist = @"LevelFourtysixPlist.plist";
#if JPLCPRO
        return 14;
#elif JPLCLITE
        return 101;
#endif
    } else if (currentLevel == 14) {
        levelPlist = @"LevelFourteenPlist.plist";
        return 45;
    } else if (currentLevel == 45) {
        levelPlist = @"LevelFourtyfivePlist.plist";
        return 47;
    } else if (currentLevel == 47) {
        levelPlist = @"LevelFourtysevenPlist.plist";
        return 203;
    } else if (currentLevel == 26) {
        levelPlist = @"LevelTwentysixPlist.plist";
        return 7;
    } else if (currentLevel == 7) {
        levelPlist = @"LevelSevenPlist.plist";
        return 2;
    } else if (currentLevel == 2) {
        levelPlist = @"LevelTwoPlist.plist";
        return 12;
    } else if (currentLevel == 12) {
        levelPlist = @"LevelTwelvePlist.plist";
        return 50;
    } else if (currentLevel == 50) {
        levelPlist = @"LevelFiftyPlist.plist";
        return 51;
    } else if (currentLevel == 51) {
        levelPlist = @"LevelFiftyonePlist.plist";
        return 30;
    } else if (currentLevel == 30) {
        levelPlist = @"LevelThirtyPlist.plist";
        return 52;
    } else if (currentLevel == 52) {
        levelPlist = @"LevelFiftytwoPlist.plist";
        return 204;
    } else if (currentLevel == 20) {
        levelPlist = @"LevelTwentyPlist.plist";
        return 25;
    } else if (currentLevel == 25) {
        levelPlist = @"LevelTwentyfivePlist.plist";
        return 19;
    } else if (currentLevel == 19) {
        levelPlist = @"LevelNineteenPlist.plist";
        return 42;
    } else if (currentLevel == 42) {
        levelPlist = @"LevelFortytwoPlist.plist";
        return 48;
    } else if (currentLevel == 48) {
        levelPlist = @"LevelFourtyeightPlist.plist";
        return 23;
    } else if (currentLevel == 23) {
        levelPlist = @"LevelTwentythrePlist.plist";
        return 49;
    } else if (currentLevel == 49) {
        levelPlist = @"LevelFourtyninePlist.plist";
        return 21;
    } else if (currentLevel == 21) {
        levelPlist = @"LevelTwentyonePlist.plist";
        return 205;
    } else {
        return 100;
    }
}

-(void) levelPassed {
    
    BOOL areWeInPracticeMode = [[GameVariables sharedGameVariables] getPractice];
    BOOL areWeInNineLivesMode = [[GameVariables sharedGameVariables] getNineLivesMode];
    
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"CatMeetsTool.caf"];
    
    if (!backToMenu && !areWeInPracticeMode && !areWeInNineLivesMode) {
        if ([[GameVariables sharedGameVariables] getFinishedLevel:currentLevel] == NO) [[GameVariables sharedGameVariables] setFinishedLevel:currentLevel];
        [[GameVariables sharedGameVariables] saveLevels];
    }
    int nextLevel = [self getNextLevel];
    if (!backToMenu && !areWeInPracticeMode && !areWeInNineLivesMode) {         //CAREER MODE
        [[GameVariables sharedGameVariables] setLevel:nextLevel];
        [self updateScore];
        [[GameVariables sharedGameVariables] setCareerScore];
        int levelPack;
        if (currentLevel == 43) levelPack = 1;
        if (currentLevel == 39) levelPack = 2;
        if (currentLevel == 47) levelPack = 3;
        if (currentLevel == 52) levelPack = 4;
        if (currentLevel == 21) levelPack = 5;
        if (currentLevel == 43 || currentLevel == 39 || currentLevel == 47 || currentLevel == 52 || currentLevel == 21) {
            [[GameVariables sharedGameVariables] setFinishedLevelPack:levelPack];
            if ([[GameVariables sharedGameVariables] getLevelPackTopScoreForPack:levelPack] < [[GameVariables sharedGameVariables] getCareerScore]) {
                [[GameVariables sharedGameVariables] setLevelPackTopTimeForPack:levelPack withTime:[[GameVariables sharedGameVariables] getTotalTime]];
                [[GameVariables sharedGameVariables] setLevelPackTopDeathsForPack:levelPack withDeaths:[[GameVariables sharedGameVariables] getTotalDeaths]];
                [[GameVariables sharedGameVariables] setLevelPackTopScoreForPack:levelPack withScore:[[GameVariables sharedGameVariables] getCareerScore]];
                [[GameVariables sharedGameVariables] saveHighScores];
            }
        }
        
    } else if (!backToMenu && areWeInPracticeMode) {            //PRACTICE MODE
        [self calculateStars];
    }
    
    
    
    for (int i = 0; i < obsNum; i++) {
        //[self removeChild:obstaclesArray[i] cleanup:YES];
        obstaclesArray[i] = NULL;
    }
    obsNum = 0;
    
    for (int i = 0; i < objsNum; i++) {
        [self removeChild:objectArray[i] cleanup:YES];
        objectArray[i] = NULL;
    }
    objsNum = 0;
    
    if (backToMenu) [[GameVariables sharedGameVariables] setTime:0];
    
    currentLevel = [[GameVariables sharedGameVariables] getLevel];
    if (areWeInPracticeMode && !backToMenu) {
        
        [[CCDirector sharedDirector] replaceScene:[QuickPlayPostScreens scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:levelPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameSprites.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatMeetsTool.caf"];
    } else if (!backToMenu && areWeInNineLivesMode) {
        nineLivesScore = [[GameVariables sharedGameVariables] getNineLivesScore];
        if (multiplierGot) {
            nineLivesScore += 10137*multiplierScore;
        } else {
            nineLivesScore += 10123;
        }
        [[GameVariables sharedGameVariables] setNineLivesScore:nineLivesScore];
        [[GameVariables sharedGameVariables] setNineLivesLevel:currentLevel isFinished:YES];
        int randomLevel = [[GameVariables sharedGameVariables] getRandomLevel] + 1;
        [[GameVariables sharedGameVariables] setLevel:randomLevel];
        if (randomLevel == 101) {
            [[GameVariables sharedGameVariables] setLevel:151];
            nineLivesScore = [[GameVariables sharedGameVariables] getNineLivesScore];
            nineLivesScore += (900 - timeInSeconds)*1007;
            [[GameVariables sharedGameVariables] setNineLivesScore:nineLivesScore];
        }
        if (nineLivesScore > [[GameVariables sharedGameVariables] getNineLivesTopScore]) {
            [[GameVariables sharedGameVariables] setNineLivesTopTime];
            [[GameVariables sharedGameVariables] setNineLivesTopLevelsFinished];
            [[GameVariables sharedGameVariables] saveHighScores];
        }
        if ([[GameVariables sharedGameVariables] getLevel] != 151) [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        if ([[GameVariables sharedGameVariables] getLevel] == 151) [[CCDirector sharedDirector] replaceScene:[Congratulations scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:levelPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameSprites.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatMeetsTool.caf"];
    } else if (areWeInNineLivesMode && backToMenu) {
        [[GameVariables sharedGameVariables] setLevel:150];
        [[CCDirector sharedDirector] replaceScene:[QuickPlayPostScreens scene]];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:levelPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameSprites.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatMeetsTool.caf"];
    } else if (currentLevel > 200 && !backToMenu) {
        [[CCDirector sharedDirector] replaceScene:[Assembling scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:levelPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameSprites.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatMeetsTool.caf"];
    } else {
        if (backToMenu) [[GameVariables sharedGameVariables] setLevel:100];
        if (resetLevelPack) {
            [[GameVariables sharedGameVariables] setLevel:startOfLevelPack];
            [[GameVariables sharedGameVariables] newLevelPack];
            resetLevelPack = NO;
        }
        [[CCDirector sharedDirector] replaceScene:[LoadingScreen scene]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:levelPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameSprites.plist"];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [CCTextureCache purgeSharedTextureCache];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        [CCSpriteFrameCache purgeSharedSpriteFrameCache];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatDeathSound.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"MenuButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"BackButton.caf"];
        [[SimpleAudioEngine sharedEngine] unloadEffect:@"CatMeetsTool.caf"];
    }

}

-(void) calculateStars {
    if (timeInSeconds <= threeStars) {
        if ([[GameVariables sharedGameVariables] getNumStars:currentLevel] < 3) [[GameVariables sharedGameVariables] setNumStars:currentLevel withStars:3];
    } else if (timeInSeconds <= twoStars && timeInSeconds > threeStars) {
        if ([[GameVariables sharedGameVariables] getNumStars:currentLevel] < 2) [[GameVariables sharedGameVariables] setNumStars:currentLevel withStars:2];
    } else if (timeInSeconds <= oneStar && timeInSeconds > twoStars) {
        if ([[GameVariables sharedGameVariables] getNumStars:currentLevel] < 1) [[GameVariables sharedGameVariables] setNumStars:currentLevel withStars:1];
    }
    [[GameVariables sharedGameVariables] saveStars];
}

-(void) updateScore {
    [[GameVariables sharedGameVariables] setCareerTime:timeInSeconds];
    [[GameVariables sharedGameVariables] setCareerDeaths:deathsInThisLevel];
    [[GameVariables sharedGameVariables] setTotalTime];
    [[GameVariables sharedGameVariables] setTotalDeaths];
}

-(void) pauseGame:(id)sender {
    if (pauseScreenUp == NO) {
        pauseScreenUp = YES;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pauseMenu.plist"];
        [[CCDirector sharedDirector] pause];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        pauseLayer = [CCLayerColor layerWithColor: ccc4(150, 150, 150, 125) width: screenSize.width height: screenSize.height];
        pauseLayer.position = CGPointZero;
        [self addChild:pauseLayer z:7];
        
        pauseScreen = [[CCSprite spriteWithSpriteFrameName:@"pauseBG.png"] retain];
        pauseScreen.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild: pauseScreen z:8];
        
        CCMenuItem *resumeMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"resumeButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"resumeButton.png"] target:self selector:@selector(ResumeButtonTapped:)];
        resumeMenuItem.position = CGPointMake(screenSize.width / 2, 550);
        
        CCMenuItem *quitMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseQuitButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseQuitButton.png"] target:self selector:@selector(QuitButtonTapped:)];
        quitMenuItem.position = CGPointMake(screenSize.width / 2, 330);
        
        CCMenuItem *resetMenuItem;
        
        if ([[GameVariables sharedGameVariables] getPractice] == YES || [[GameVariables sharedGameVariables] getNineLivesMode] == YES) {
            resetMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseResetButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseResetButton.png"] target:self selector:@selector(ResetButtonTapped:)];
            if ([[GameVariables sharedGameVariables] getNineLivesMode] == YES) {
                resetMenuItem.visible = NO;
                resumeMenuItem.position = CGPointMake(screenSize.width / 2, 500);
                quitMenuItem.position = CGPointMake(screenSize.width / 2, 380);
            }
        } else {
            resetMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseRestartPackButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseRestartPackButton.png"] target:self selector:@selector(ResetButtonTapped:)];
        }
        resetMenuItem.position = CGPointMake(screenSize.width / 2, 440);
        
        CCMenuItem *musicMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseMusicButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseMusicButton.png"] target: self selector:@selector(MusicButtonTapped:)];
        musicMenuItem.position = CGPointMake(220, 180);
        CCMenuItem *soundMenuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pauseSoundButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pauseSoundButton.png"] target: self selector:@selector(SoundsButtonTapped:)];
        soundMenuItem.position = CGPointMake(780, 180);
        
        pawsitive = [CCSprite spriteWithSpriteFrameName:@"pawsitive.png"];
        pawsitive.position = CGPointMake(screenSize.width / 2, 250);
        [self addChild:pawsitive z:10];
        pawsitive.visible = NO;
        
        pawsitiveYes = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pawsitiveYes.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pawsitiveYes.png"] target:self selector:@selector(pawsitiveYes:)];
        pawsitiveYes.position = CGPointMake(screenSize.width / 2 - 100, 180);
        pawsitiveYes.visible = NO;
        
        pawsitiveNo = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pawsitiveNo.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pawsitiveNo.png"] target:self selector:@selector(pawsitiveNo:)];
        pawsitiveNo.position = CGPointMake(screenSize.width / 2 + 100, 180);
        pawsitiveNo.visible = NO;
        
        pauseScreenMenu = [CCMenu menuWithItems:resumeMenuItem, quitMenuItem, resetMenuItem, musicMenuItem, soundMenuItem, pawsitiveYes, pawsitiveNo, nil];
        pauseScreenMenu.position = CGPointMake(0, 0);
        [self addChild: pauseScreenMenu z:9];
        
        musicPaused = [CCSprite spriteWithSpriteFrameName:@"pauseSoundOff.png"];
        musicPaused.position = CGPointMake(220, 180);
        [self addChild:musicPaused z:10];
        if ([[GameVariables sharedGameVariables] getPauseMusic] == NO) musicPaused.visible = NO;
        
        soundsPaused = [CCSprite spriteWithSpriteFrameName:@"pauseSoundOff.png"];
        soundsPaused.position = CGPointMake(780, 180);
        [self addChild:soundsPaused z:10];
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) soundsPaused.visible = NO;
    }
}

-(void) ResumeButtonTapped:(id)sender {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
    [self removeChild:pauseScreen cleanup:YES];
    [pauseScreen release];
	[self removeChild:pauseScreenMenu cleanup:YES];
	[self removeChild:pauseLayer cleanup:YES];
    [self removeChild:musicPaused cleanup:YES];
    [self removeChild:soundsPaused cleanup:YES];
    [self removeChild:pawsitive cleanup:YES];
    whatButtonWasTapped = 0;
	[[CCDirector sharedDirector] resume];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"pauseMenu.plist"];
	pauseScreenUp=FALSE;
}

-(void) QuitButtonTapped:(id)sender {
    whatButtonWasTapped = 1;
    pawsitive.visible = YES;
    pawsitiveYes.visible = YES;
    pawsitiveNo.visible = YES;
}

-(void) ResetButtonTapped:(id)sender {
    whatButtonWasTapped = 2;
    pawsitive.visible = YES;
    pawsitiveYes.visible = YES;
    pawsitiveNo.visible = YES;
}

-(void) MusicButtonTapped:(id)sender {
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

-(void) SoundsButtonTapped:(id)sender {
    if ([[GameVariables sharedGameVariables] getPauseSound] == NO) {
        [[GameVariables sharedGameVariables] setPauseSound:YES];
        soundsPaused.visible = YES;
    } else {
        [[GameVariables sharedGameVariables] setPauseSound:NO];
        soundsPaused.visible = NO;
    }
}

-(void) pawsitiveYes:(id)sender {
    if (whatButtonWasTapped == 1) {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        if (![[GameVariables sharedGameVariables] getNineLivesMode]) [[GameVariables sharedGameVariables] setTime:0];
        if (![[GameVariables sharedGameVariables] getNineLivesMode]) timeInSeconds = 0;
        [self removeChild:pauseScreen cleanup:YES];
        [self removeChild:pauseScreenMenu cleanup:YES];
        [self removeChild:pauseLayer cleanup:YES];
        [self removeChild:musicPaused cleanup:YES];
        [self removeChild:soundsPaused cleanup:YES];
        [self removeChild:pawsitive cleanup:YES];
        [self removeChild:pawsitiveYes cleanup:YES];
        [self removeChild:pawsitiveNo cleanup:YES];
        backToMenu = YES;
        [[CCDirector sharedDirector] resume];
        [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"pauseMenu.plist"];
        pauseScreenUp=FALSE;
        [self performSelector:@selector(levelPassed) withObject:nil afterDelay:0.4];
    } else {
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        BOOL areWeInPracticeMode = [[GameVariables sharedGameVariables] getPractice];
        BOOL areWeInNineLivesMode = [[GameVariables sharedGameVariables] getNineLivesMode];
        
        if (areWeInPracticeMode) {          //ZEN
            timeInSeconds = 0;
            [[GameVariables sharedGameVariables] setTime:timeInSeconds];
            [self resetCat];
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"BackButtonSound.caf"];
            [self removeChild:pauseScreen cleanup:YES];
            [self removeChild:pauseScreenMenu cleanup:YES];
            [self removeChild:pauseLayer cleanup:YES];
            [self removeChild:musicPaused cleanup:YES];
            [self removeChild:soundsPaused cleanup:YES];
            [self removeChild:pawsitive cleanup:YES];
            whatButtonWasTapped = 0;
            [[CCDirector sharedDirector] resume];
            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"pauseMenu.plist"];
            pauseScreenUp=FALSE;
        } else if (areWeInNineLivesMode) {          //NINE LIVES
            //NOEXIST
        } else {            //CAREER
            if (currentLevel == 1 || currentLevel == 5 || currentLevel == 9 || currentLevel == 11 || currentLevel == 6 || currentLevel == 44 || currentLevel == 41 || currentLevel == 43) startOfLevelPack = 1;
            if (currentLevel == 10 || currentLevel == 22 || currentLevel == 8 || currentLevel == 28 || currentLevel == 4 || currentLevel == 40 || currentLevel == 38 || currentLevel == 39) startOfLevelPack = 10;
            if (currentLevel == 13 || currentLevel == 3 || currentLevel == 27 || currentLevel == 15 || currentLevel == 46 || currentLevel == 14 || currentLevel == 45 || currentLevel == 47) startOfLevelPack = 13;
            if (currentLevel == 26 || currentLevel == 7 || currentLevel == 2 || currentLevel == 12 || currentLevel == 50 || currentLevel == 51 || currentLevel == 30 || currentLevel == 52) startOfLevelPack = 26;
            if (currentLevel == 20 || currentLevel == 25 || currentLevel == 19 || currentLevel == 42 || currentLevel == 48 || currentLevel == 23 || currentLevel == 49 || currentLevel == 21) startOfLevelPack = 20;
            resetLevelPack = YES;
            if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
            [[GameVariables sharedGameVariables] setTime:0];
            timeInSeconds = 0;
            [self removeChild:pauseScreen cleanup:YES];
            [self removeChild:pauseScreenMenu cleanup:YES];
            [self removeChild:pauseLayer cleanup:YES];
            [self removeChild:musicPaused cleanup:YES];
            [self removeChild:soundsPaused cleanup:YES];
            [self removeChild:pawsitive cleanup:YES];
            [self removeChild:pawsitiveYes cleanup:YES];
            [self removeChild:pawsitiveNo cleanup:YES];
            [[CCDirector sharedDirector] resume];
            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"pauseMenu.plist"];
            pauseScreenUp=FALSE;
            [self performSelector:@selector(levelPassed) withObject:nil afterDelay:0.4];
        }
    }
}

-(void) pawsitiveNo:(id)sender {
    pawsitive.visible = NO;
    pawsitiveYes.visible = NO;
    pawsitiveNo.visible = NO;
    whatButtonWasTapped = 0;
}

-(void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

/*-(CGPoint) getTouchLocation:(UITouch*)touch
{
	return [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
}*/

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint([forceFieldSprite boundingBox], location) && startNow) {
        catHasBeenTouched = YES;
        forceFieldSprite.visible = YES;
        xDifference = location.x - catSprite.position.x;
        yDifference = location.y - catSprite.position.y;
    } else if (CGRectContainsPoint([pauseButton boundingBox], location) && startNow) {
        pauseButton.color = ccc3(100, 100, 100);
        if ([[GameVariables sharedGameVariables] getPauseSound] == NO) [[SimpleAudioEngine sharedEngine] playEffect:@"MenuButtonSound.caf"];
        [self performSelector:@selector(pauseGame: ) withObject:nil afterDelay:0.0];
    }
    
    return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event {
    CGPoint currentTouchLocation = [touch locationInView:[touch view]];
    currentTouchLocation = [[CCDirector sharedDirector] convertToGL:currentTouchLocation];
    CGPoint lastTouchLocation = [touch previousLocationInView:[touch view]];
    if (catHasBeenTouched) {
        //CCMoveTo* moveCat = [CCMoveTo actionWithDuration:0.05 position:CGPointMake(currentTouchLocation.x, currentTouchLocation.y)];
        //[catSprite runAction:moveCat];
        //catSprite.position = currentTouchLocation;
        CGPoint goTo = CGPointMake(currentTouchLocation.x - xDifference, currentTouchLocation.y - yDifference);
        [forceFieldSprite setPosition:goTo];
        [catSprite setPosition:goTo];
        if (lastTouchLocation.x > currentTouchLocation.x) {
            catSprite.scaleX = -1.0;
            catIsBackwards = TRUE;
        }
        if (lastTouchLocation.x < currentTouchLocation.x) {
            if (catIsBackwards) {
                catSprite.scaleX = 1.0;
                catIsBackwards = FALSE;
            }
        }
    }
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event {
    catHasBeenTouched = NO;
    forceFieldSprite.visible = NO;
    pauseButton.color = ccc3(255, 255, 255);
}

@end
