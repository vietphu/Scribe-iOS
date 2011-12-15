//
//  SCMiniGrid.h
//  Scribe
//
//  Created by Stephen Searles on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XY.h"

extern const NSUInteger MINI_GRID_SIZE;

@interface SCMiniGrid : NSObject {
    XY * positionInGrid;
}

@property (readonly) XY * positionInGrid;

@end