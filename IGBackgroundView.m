//
//  IGBackgroundView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue Jun 08 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGBackgroundView.h"


@implementation IGBackgroundView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    [[NSColor darkGrayColor] set];
    NSRectFill(rect);
    
    [[NSColor blackColor] set];
    NSFrameRect(NSMakeRect(100,100,50,50));
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

@end
