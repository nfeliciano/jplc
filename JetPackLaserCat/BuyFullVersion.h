//
//  BuyFullVersion.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-10-18.
//  Copyright 2011 University of Victoria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BuyFullVersion : CCLayer {
    
}

+(id) scene;

-(void) goBack:(CCMenuItem *) menuItem;
-(void) goBuy:(CCMenuItem *) menuItem;
-(void) moveOn;

@end
