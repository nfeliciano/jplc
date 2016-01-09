//
//  LevelSelect.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-15.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelPackSelect : CCLayer {
    
}

+(id) scene;

-(void) goPackOne:(CCMenuItem *) menuItem;
-(void) goPackTwo:(CCMenuItem *) menuItem;
-(void) goPackThree:(CCMenuItem *) menuItem;
-(void) goPackFour:(CCMenuItem *) menuItem;
-(void) goPackFive:(CCMenuItem *) menuItem;
-(void) goBack:(CCMenuItem *) menuItem;

@end
