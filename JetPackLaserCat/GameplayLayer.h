//
//  GameplayLayer.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-09.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameplayLayer : CCLayer {
    BOOL catHasBeenTouched;
    CCSprite *catSprite;
    CCSprite *goalSprite;
    CCSprite *forceFieldSprite;
    CCRenderTexture *rt;
    
    bool pauseScreenUp;
    CCLayer *pauseLayer;
    CCSprite *pauseButton;
    CCSprite *pauseScreen;
    CCMenu *pauseScreenMenu;
}

@property (nonatomic, assign) CCSprite *catSprite;
@property (nonatomic, assign) CCSprite *goalSprite;
@property (nonatomic, assign) CCSprite *forceFieldSprite;
@property (nonatomic, assign) CCRenderTexture *rt;


+(id) scene;

-(void) updateDeaths;
-(void) updateTime;
-(void) updateTimer;
-(void) checkCollisions;
-(BOOL) isACollisionBetweenSpriteA:(CCSprite*)sprite1 SpriteB:(CCSprite*)sprite2 pixelPerfect:(BOOL)p;
-(void) animateDeath;
-(int) getNextLevel;
-(void) levelPassed;

-(void) readyGo;
-(void) startTheGame;

-(void) moveObstacle:(CCSprite*)obstacle withMovement:(NSString *)movement;

-(void) levelInit;

-(void) resetCat;

-(void) updateScore;
-(void) calculateStars;

-(void) pauseGame:(id)sender;
-(void) ResumeButtonTapped:(id)sender;
-(void) QuitButtonTapped:(id)sender;
-(void) ResetButtonTapped:(id)sender;
-(void) MusicButtonTapped:(id)sender;
-(void) SoundsButtonTapped:(id)sender;
-(void) pawsitiveYes:(id)sender;
-(void) pawsitiveNo:(id)sender;

@end
