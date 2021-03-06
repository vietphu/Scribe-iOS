//
//  SCCellView.m
//  Scribe
//
//  Created by Stephen Searles on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SCCellView.h"
#import "SCMiniGridView.h"
#import "SCMiniGrid.h"
#import "SCScribeBoard.h"
#import "XY.h"

float UNPLAYED_COLOR[4] = {0.8, 0.8, 0.8, 0.8};
float BLUE_COLOR[4] = {0.0, 0.0, 1.0, 1.0};
float RED_COLOR[4] = {1.0, 0, 0, 1.0};
float OVERLAY_COLOR[4] = {0.0, 0.0, 0.0, 0.2};

@implementation SCCellView

@synthesize positionInMiniGrid = xy;
@synthesize listenForTaps = _listenForTaps;
@synthesize cellState = _cellState;
@synthesize cellOwnership = _cellOwnership;
@synthesize cellShade = _shade;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin;
        self.contentMode = UIViewContentModeRedraw;
        _cellState = SCCellUnplayed;
        _cellOwnership = SCCellUnowned;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellPlayed:) name:SCCellPlayedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelected:) name:SCCellSelectedNotification object:nil];
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyOnTap)];
        self.listenForTaps = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellState:(SCCellState)cellState {
    _cellState = cellState;
    [self setNeedsDisplay];
}

- (void)setListenForTaps:(BOOL)listenForTaps {
    if (listenForTaps) {
        [self addGestureRecognizer:recognizer];
    } else {
        [self removeGestureRecognizer:recognizer];
    }
    _listenForTaps = listenForTaps;
}

- (void)notifyOnTap {
    [[NSNotificationCenter defaultCenter] postNotificationName:SCCellTappedNotification object:self];
}

- (void)cellSelected:(NSNotification *)notification {
    if (_cellState == SCCellInPlay) {
        self.cellState = SCCellUnplayed;
        self.cellOwnership = SCCellUnowned;
    }
}

- (void)cellPlayed:(NSNotification *)notification {
    if (([[[notification userInfo] objectForKey:@"Player"] unsignedIntegerValue] == SCRedPlayer && _cellOwnership == SCCellRed) ||
        ([[[notification userInfo] objectForKey:@"Player"] unsignedIntegerValue] == SCBluePlayer && _cellOwnership == SCCellBlue)) {
        switch (_cellState) {
            case SCCellInPlay:
                self.cellState = SCCellJustPlayed;
                break;
            case SCCellJustPlayed:
                self.cellState = SCCellPlayed;
                break;
            default:
                break;
        }
    }
}

- (CGPathRef)roundedRect:(CGRect)bounds radius:(CGFloat)radius {
    CGMutablePathRef _roundedRect = CGPathCreateMutable();
    CGPathMoveToPoint(_roundedRect, NULL, bounds.origin.x + radius, bounds.origin.y);
    CGPathAddArcToPoint(_roundedRect, NULL, bounds.origin.x, bounds.origin.y, bounds.origin.x, bounds.origin.y + radius, radius);
    CGPathAddLineToPoint(_roundedRect, NULL, bounds.origin.x,bounds.size.height - radius);
    CGPathAddArcToPoint(_roundedRect, NULL, bounds.origin.x, bounds.size.height, bounds.origin.x + radius, bounds.size.height, radius);
    CGPathAddLineToPoint(_roundedRect, NULL, bounds.size.width - radius, bounds.size.height);
    CGPathAddArcToPoint(_roundedRect, NULL, bounds.size.width, bounds.size.height, bounds.size.width, bounds.size.height - radius, radius);
    CGPathAddLineToPoint(_roundedRect, NULL, bounds.size.width, bounds.origin.y + radius);
    CGPathAddArcToPoint(_roundedRect, NULL, bounds.size.width, bounds.origin.y, bounds.size.width - radius, bounds.origin.y, radius);
    CGPathCloseSubpath(_roundedRect);
    return _roundedRect;
}

- (CGAffineTransform *)transformToSmall {
    if (!_transformToSmall) {
        _transformToSmall = malloc(sizeof(CGAffineTransform));
        * _transformToSmall = CGAffineTransformMakeScale(2, 2);
    }
    return _transformToSmall;
}

- (CGColorRef)unplayed {
    if (!_unplayed) {
        _unplayed = CGColorCreate([self colorSpace], UNPLAYED_COLOR);
    }
    return _unplayed;
}

- (CGColorRef)red {
    if (!_red) {
        _red = CGColorCreate([self colorSpace], RED_COLOR);
    }
    return _red;
}
- (CGColorRef)blue {
    if (!_blue) {
        _blue = CGColorCreate([self colorSpace], BLUE_COLOR);
    }
    return _blue;
}
- (CGColorRef)overlayColor {
    if (!_overlayColor) {
        _overlayColor = CGColorCreate([self colorSpace], OVERLAY_COLOR);
    }
    return _overlayColor;
}
- (CGColorSpaceRef)colorSpace {
    if (!_colorSpace) {
        _colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return _colorSpace;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef color;
    if (_cellOwnership == SCCellRed) {
        color = [self red];
    } else if (_cellOwnership == SCCellBlue) {
        color = [self blue];
    } else {
        color = [self unplayed];
    }
    
    CGContextSetFillColorWithColor(context, color);
    CGContextBeginPath(context);
    CGPathRef roundedRect = [self roundedRect:rect radius:self.bounds.size.height/5];
    CGContextAddPath(context, roundedRect);
    CGContextFillPath(context);
    
    if (_shade) {
        CGContextSetFillColorWithColor(context, [self overlayColor]);
        CGContextBeginPath(context);
        CGContextAddPath(context, roundedRect);
        CGContextFillPath(context);
    }
    
    CGContextBeginPath(context);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddPath(context, roundedRect);
    CGContextSetRGBStrokeColor(context, .1, .1, .1, .4);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    if (_cellState == SCCellInPlay) {
        CGContextBeginPath(context);
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
        CGContextAddArc(context, self.bounds.size.height/2,self.bounds.size.width/2, self.bounds.size.height/4, 0, 2*M_PI, 0);
        CGContextStrokePath(context);
    } else if (_cellState == SCCellJustPlayed) {
        CGContextBeginPath(context);
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextAddArc(context, self.bounds.size.height/2,self.bounds.size.width/2, self.bounds.size.height/4, 0, 2*M_PI, 0);
        CGContextFillPath(context);
    }
    
}


@end
