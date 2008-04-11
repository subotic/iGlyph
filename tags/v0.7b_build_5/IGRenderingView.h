//
//  IGRenderingView.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed May 05 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class IGDrawDocument;

@interface IGRenderingView : NSView {
    @private	
    NSArray *_graphics;
    NSSize _paperSize;
    unsigned _pageCount;
    IGDrawDocument *_drawDocument;
}

- (id)initWithFrame:(NSRect)frame graphics:(NSArray *)graphics pageCount:(unsigned)count document:(IGDrawDocument *)document;

@end
