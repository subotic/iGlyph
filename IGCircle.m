//
//  IGCircle.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGCircle.h"
#import "IGGraphic.h"

@implementation IGCircle


- (instancetype)init {
  self = [super init];
  if (self) {
    self.bounds = NSMakeRect(250, 300, 100, 100);
  }
  return self;
}

- (NSBezierPath *)bezierPath {
    
    NSRect bounds = self.bounds;
    
    if (bounds.size.width < bounds.size.height) {
        bounds.size.height = bounds.size.width;
        self.bounds = bounds;
    } else if (bounds.size.width > bounds.size.height) {
        bounds.size.width = bounds.size.height;
        self.bounds = bounds;
    }

    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:bounds];
    
    path.lineWidth = self.strokeLineWidth;
    
    return path;
}

- (void)makeNaturalSize {
    NSRect bounds = self.bounds;
    if (bounds.size.width < bounds.size.height) {
        bounds.size.height = bounds.size.width;
        self.bounds = bounds;
    } else if (bounds.size.width > bounds.size.height) {
        bounds.size.width = bounds.size.height;
        self.bounds = bounds;
    }
}


//hier werden die dx und dy bewegungen abgefangen und umgebogen so das immer
//ein Kreis resultiert.
- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point {
    NSRect bounds = self.bounds;
    
    if (bounds.size.width < bounds.size.height) {
        bounds.size.height = bounds.size.width;
    } else if (bounds.size.width > bounds.size.height) {
        bounds.size.width = bounds.size.height;
    }
    
     
    if (knob == LowerLeftKnob) {
        // Adjust left edge
        NSLog(@"LowerLeftKnob");
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
        
        // Adjust bottom edge
        //bounds.size.height = point.y - bounds.origin.y;
        bounds.size.height = bounds.size.width;
        
    
    } else if (knob == UpperLeftKnob) { 
        NSLog(@"UpperLeftKnob");
        
        float dX = NSMinX(bounds) - point.x;
        float dY = NSMinY(bounds) - point.y;
        
        if (dX < dY) {
            // Adjust left edge
            bounds.size.width = NSMaxX(bounds) - point.x;
            bounds.origin.x -= dX;
            
            // Adjust top edge
            bounds.size.height = bounds.size.width;
            bounds.origin.y -= dX;
        } else {
            // Adjust top edge
            bounds.size.height = NSMaxY(bounds) - point.y;
            bounds.origin.y -= dY;
        
            // Adjust left edge
            bounds.size.width = bounds.size.height;
            bounds.origin.x -= dY;
        }
        
        
        
    } else if (knob == UpperRightKnob) {
        // Adjust top edge
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
        
        // Adjust right edge
        //bounds.size.width = point.x - bounds.origin.x;
        bounds.size.width = bounds.size.height;
        
        
    } else if (knob == LowerRightKnob) {
        // Adjust right edge
        bounds.size.width = point.x - bounds.origin.x;
        
        // Adjust bottom edge
        //bounds.size.height = point.y - bounds.origin.y;
        bounds.size.height = bounds.size.width;
        
    } 
    
    if (bounds.size.width < 0.0) {
        knob = [IGGraphic flipKnob:knob horizontal:YES];
        bounds.size.width = -bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        [self flipHorizontally];
    }
    
    if (bounds.size.height < 0.0) {
        knob = [IGGraphic flipKnob:knob horizontal:NO];
        bounds.size.height = -bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        [self flipVertically];
    }
    self.bounds = bounds;
    return knob;
}

- (void)setStartsAtLowerLeft:(BOOL)flag {
    if (_startsAtLowerLeft != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setStartsAtLowerLeft:_startsAtLowerLeft];
        _startsAtLowerLeft = flag;
        [self didChange];
    }
}

- (BOOL)startsAtLowerLeft {
    return _startsAtLowerLeft;
}

- (void)flipHorizontally {
    NSLog(@"IGCircle(flipHorizontally");
    [self setStartsAtLowerLeft:![self startsAtLowerLeft]];
    return;
}

- (void)flipVertically {
    NSLog(@"IGCircle(flipVertically");
    [self setStartsAtLowerLeft:![self startsAtLowerLeft]];
    //[self reverseArrow];
    return;
}


- (unsigned)knobMask {
    return LowerLeftKnobMask + UpperLeftKnobMask + LowerRightKnobMask + UpperRightKnobMask;
}

@end
