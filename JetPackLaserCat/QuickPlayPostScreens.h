//
//  QuickPlayPostScreens.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-09-05.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKitHelper.h"

@interface QuickPlayPostScreens : CCLayer <GameKitHelperProtocol> {
    
}

+(id) scene;

-(void) toMenu:(CCMenuItem *) menuItem;
-(void) retryNineLives:(CCMenuItem *) menuItem;

@end
