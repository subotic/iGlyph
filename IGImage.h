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

@property (NS_NONATOMIC_IOSONLY, copy) NSImage *image;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *transformedImage;

@property (NS_NONATOMIC_IOSONLY) BOOL flippedHorizontally;
@property (NS_NONATOMIC_IOSONLY) BOOL flippedVertically;

@end
