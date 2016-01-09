//
//  QuickPlay.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-27.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface QuickPlay : CCLayer {
    
}

+(id) scene;

-(void) goPractice:(id)sender;
-(void) goNineLives:(id)sender;

-(void) goBack:(id)sender;

@end
