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
    NSArray *graphics;
    NSSize _paperSize;
    NSInteger pageCount;
    IGDrawDocument *drawDocument;
}

@property (copy) NSArray *graphics;
@property NSInteger pageCount;
@property IGDrawDocument *drawDocument;

- (id)initWithFrame:(NSRect)frame graphics:(NSArray *)graphicsArr pageCount:(unsigned)count document:(IGDrawDocument *)document;

@end
