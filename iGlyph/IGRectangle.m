//
//  IGRectangle.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGRectangle.h"


@implementation IGRectangle


- (instancetype)init {
  self = [super init];
  if (self) {
    self.bounds = NSMakeRect(275, 325, 75, 75);
  }
  return self;
}

- (NSBezierPath *)bezierPath {
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.bounds];
    //NSLog(@"x: %f, y: %f, w: %f, h: %f", [self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height); 
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

@end
