//
//  IGArc.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGArc.h"


@implementation IGArc

- (id)init {
  self = [super init];
  if (self) {
    [self setBounds:NSMakeRect(250, 300, 100, 50)];
  }
  return self;
}

- (NSBezierPath *)bezierPath {
    /*
    NSRect localBounds = [self bounds];
    float radius = localBounds.size.width / 2;
    NSPoint center = NSMakePoint(NSMidX(localBounds), NSMaxY(localBounds));
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:180 endAngle:360];
    
    NSRect arcBounds = [path bounds];
    float xScale = arcBounds.size.width / localBounds.size.width;
    float yScale = localBounds.size.height / arcBounds.size.height;
    
    NSAffineTransform *ovalArcTrans = [NSAffineTransform transform];
    [ovalArcTrans setTransformStruct:(NSAffineTransformStruct){1, 0, 0, yScale, 0, 0}];
    [path transformUsingAffineTransform:ovalArcTrans];
    */
    
    NSRect localBounds = [self bounds];
    localBounds.size.height *= 2;
    localBounds.size.height += 7;
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:localBounds];
    
    //[path setLineWidth:[self strokeLineWidth]];
    [path setLineWidth: self.strokeThickness];

    return path;
}

- (unsigned)knobMask {
    return UpperRightKnobMask + LowerLeftKnobMask;
}


@end
