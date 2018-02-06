//
//  IGRubric.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//
// Verbesserungsvorschlag:
// Die Farbe welche benutzt wird soll in den Präferenzen ausgewählt werden können.

#import "IGRubric.h"


@implementation IGRubric

- (instancetype)init {
  self = [super init];
  if (self) {
    self.fillColor = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:0.15];
    self.bounds = NSMakeRect(250, 350, 100, 50);
  }
  return self;
}

- (NSBezierPath *)bezierPath {
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.bounds];
    return path;
}


- (BOOL)drawsFill {
    // IGRubric draws fill
    return YES;
}

- (BOOL)canDrawFill {
    // IGRubric draws fill
    return YES;
}

- (BOOL)canDrawStroke {
    // IGRubric never does
    return NO;
}

- (BOOL)drawsStroke {
    // IGRubric never does
    return NO;
}

- (BOOL)hasNaturalSize {
    // IGLine have no "natural" size
    return NO;
}


@end
