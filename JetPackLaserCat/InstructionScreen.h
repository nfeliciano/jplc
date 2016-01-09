//
//  InstructionScreen.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-24.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface InstructionScreen : CCLayer {
    BOOL onStart;
}

+(id) scene;

-(void) moveOn;

@end
