//
//  IGGridView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Fri May 07 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGridView.h"
#import "PreferencesController.h"

@implementation IGGridView

- (void)drawRect:(NSRect)rect {
    NSDrawWhiteBezel(self.bounds, rect);
    rect = NSIntersectionRect(NSInsetRect(self.bounds, 2.0, 2.0), rect);
    IGDrawGridWithSettingsInRect(controller.gridSpacing, controller.gridColor, rect, NSMakePoint(2.0, 2.0));
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

@end
