//
//  IGSupView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue Jun 08 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGSupView.h"


@implementation IGSupView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    [[NSColor yellowColor] set];
    NSRectFill(rect);
}

- (BOOL)isFlipped {
    return YES;
}
@end
