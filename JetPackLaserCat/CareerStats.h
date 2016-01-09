//
//  CareerStats.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-26.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CareerStats : CCLayer {
    
}

+(id) scene;

-(void) seePackOne:(CCMenuItem *) menuItem;
-(void) seePackTwo:(CCMenuItem *) menuItem;
-(void) seePackThree:(CCMenuItem *) menuItem;
-(void) seePackFour:(CCMenuItem *) menuItem;
-(void) seePackFive:(CCMenuItem *) menuItem;
-(void) seeNineLives:(CCMenuItem *) menuItem;
-(void) goBack:(CCMenuItem *) menuItem;

@end
