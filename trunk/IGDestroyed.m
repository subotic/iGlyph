//
//  IGDestroyed.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGDestroyed.h"


@implementation IGDestroyed

- (id)init {
  self = [super init];
  if (self) {
    [self setBounds:NSMakeRect(250, 350, 100, 50)];
  }
  return self;
}

- (NSBezierPath *)bezierPath {
    NSRect localBounds = [self bounds];
    float abstand = 3;
    NSPoint linkerPunkt;
    NSPoint rechterPunkt;
    int i;
    if (localBounds.size.width > localBounds.size.height) {
        localBounds.size.width *= 2;
        localBounds.size.height = localBounds.size.width;
    } else {
        localBounds.size.height *= 2;
        localBounds.size.width = localBounds.size.height;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    int lines = localBounds.size.height / abstand;
        
    [path moveToPoint:localBounds.origin];
       
    for (i = 1; i < lines; i++) {
        linkerPunkt = NSMakePoint(localBounds.origin.x, localBounds.origin.y + (abstand * i));
        rechterPunkt = NSMakePoint(localBounds.origin.x + (abstand * i), localBounds.origin.y);
        [path moveToPoint:linkerPunkt];
        [path lineToPoint:rechterPunkt];
    }
    [path setLineWidth:0.5];
    return path;
}

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected {
    if (isSelected && ([self knobUnderPoint:point] != NoKnob)) {
        return YES;
    } else {//jeder klick innerhalb soll die Graphic markieren. würde ich den original bezPath nehmen, dann würde dies nur passieren wenn ich die schrafur treffe
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]]; 
        
        if (path) {
            if ([path containsPoint:point]) {
                return YES;
            }
        } else {
            if (NSPointInRect(point, [self bounds])) {
                return YES;
            }
        }
        return NO;
    }
}

- (BOOL)drawsFill {
    // IGDestroyed never does
    return NO;
}

- (BOOL)canDrawFill {
    // IGDestroyed never
    return NO;
}

- (BOOL)canDrawStroke {
    // IGDestroyed does allways
    return YES;
}

- (BOOL)drawsStroke {
    // IGDestroyed does allways
    return YES;
}

- (BOOL)hasNaturalSize {
    // IGLine have no "natural" size
    return NO;
}

- (unsigned)knobMask {
    return UpperRightKnobMask + LowerLeftKnobMask;
}

@end
