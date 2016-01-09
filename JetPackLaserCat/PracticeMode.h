//
//  PracticeMode.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-28.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PracticeMode : CCLayer {
    
}

+(id) scene;

-(void) loadCurrentPack:(int)levelPack;
-(void) changeLevelImages;

-(void) updateStars;

-(int) findLevel;
-(void) moveImages:(int)toImage;
-(void) moveOtherImages:(int)thisImage toPosition:(int)order;
-(void) goBack:(CCMenuItem *) menuItem;
-(void) playClicked:(CCMenuItem *) menuItem;
-(void) packOneClicked:(CCMenuItem *) menuItem;
-(void) packTwoClicked:(CCMenuItem *) menuItem;
-(void) packThreeClicked:(CCMenuItem *) menuItem;
-(void) packFourClicked:(CCMenuItem *) menuItem;
-(void) packFiveClicked:(CCMenuItem *) menuItem;
-(void) goToLoadingScreen:(int)toLevel;

-(void) cfminusTwo:(CCMenuItem *) menuItem;
-(void) cfminusOne:(CCMenuItem *) menuItem;
-(void) cfplusOne:(CCMenuItem *) menuItem;
-(void) cfplusTwo:(CCMenuItem *) menuItem;


@end
