//
//  IGImage.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Fri May 07 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"


@interface IGImage : IGGraphic {
    @private
    NSImage *_image;
    NSImage *_cachedImage;
    BOOL _flippedHorizontally;
    BOOL _flippedVertically;    
}

- (void)setImage:(NSImage *)image;
- (NSImage *)image;
- (NSImage *)transformedImage;

- (void)setFlippedHorizontally:(BOOL)flag;
- (BOOL)flippedHorizontally;
- (void)setFlippedVertically:(BOOL)flag;
- (BOOL)flippedVertically;

@end
