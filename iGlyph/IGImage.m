//
//  IGImage.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Fri May 07 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGImage.h"


@implementation IGImage

- (instancetype)init {
    self = [super init];
    if (self) {
        _image = nil;
        _cachedImage = nil;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    id newObj = [super copyWithZone:zone];
    
    [newObj setImage:self.image];
    [newObj setFlippedHorizontally:self.flippedHorizontally];
    [newObj setFlippedVertically:self.flippedVertically];
    
    return newObj;
}

// ===========================================================================
#pragma mark -
#pragma mark -- image accessors and convenience methods --
// ====== IGDrawWindowController accessors and convenience methods ===========

- (void)IG_clearCachedImage {
    _cachedImage = nil;
}

- (void)setImage:(NSImage *)image {
    if (image != _image) {
        [[self.undoManager prepareWithInvocationTarget:self] setImage:_image];
        _image = image;
        [self IG_clearCachedImage];
        [self didChange];
    }
}

- (NSImage *)image {
    return _image;
}

- (NSImage *)transformedImage {
    if (!_cachedImage) {
        NSRect bounds = self.bounds;
        NSImage *image = self.image;
        NSSize imageSize = image.size;
        
        if (NSEqualSizes(bounds.size, imageSize)) {
            _cachedImage = _image;
        } else if (!NSIsEmptyRect(bounds)) {
            BOOL flippedHorizontally = self.flippedHorizontally;
            BOOL flippedVertically = self.flippedVertically;
            
            _cachedImage = [[NSImage allocWithZone:nil] initWithSize:bounds.size];
            if (!NSIsEmptyRect(bounds)) {
                // Only draw in the image if it has any content.
                [_cachedImage lockFocus];
                
                if (flippedHorizontally || flippedVertically) {
                    // If the image needs flipping, we need to play some games with the transform matrix
                    NSAffineTransform *transform = [NSAffineTransform transform];
                    [transform scaleXBy:(self.flippedHorizontally ? -1.0 : 1.0) yBy:(self.flippedVertically ? -1.0 : 1.0)];
                    [transform translateXBy:(self.flippedHorizontally ? -bounds.size.width : 0.0) yBy:(self.flippedVertically ? -bounds.size.height : 0.0)];
                    [transform concat];
                }
                
                [[image bestRepresentationForDevice:nil] drawInRect:NSMakeRect(0.0, 0.0, bounds.size.width, bounds.size.height)];
                [_cachedImage unlockFocus];
            }
        }
    }
    return _cachedImage;
}

- (void)setFlippedHorizontally:(BOOL)flag {
    if (_flippedHorizontally != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setFlippedHorizontally:_flippedHorizontally];
        _flippedHorizontally = flag;
        [self IG_clearCachedImage];
        [self didChange];
    }
}

- (BOOL)flippedHorizontally {
    return _flippedHorizontally;
}

- (void)setFlippedVertically:(BOOL)flag {
    if (_flippedVertically != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setFlippedVertically:_flippedVertically];
        _flippedVertically = flag;
        [self IG_clearCachedImage];
        [self didChange];
    }
}

- (BOOL)flippedVertically {
    return _flippedVertically;
}

- (void)flipHorizontally {
    self.flippedHorizontally = (self.flippedHorizontally ? NO : YES);
}

- (void)flipVertically {
    self.flippedVertically = (self.flippedVertically ? NO : YES);
}

- (void)setBounds:(NSRect)bounds {
    if (!NSEqualSizes(self.bounds.size, bounds.size)) {
        [self IG_clearCachedImage];
    }
    super.bounds = bounds;
}

- (BOOL)drawsStroke {
    // Never draw stroke.
    return NO;
}

- (BOOL)canDrawStroke {
    // Never draw stroke.
    return NO;
}

- (void)drawInView:(IGGraphicView *)view isSelected:(BOOL)flag {
    NSRect bounds = self.bounds;
    NSImage *image;
    
    if (self.drawsFill) {
        [self.fillColor set];
        NSRectFill(bounds);
    }
    image = self.transformedImage;
    if (image) {
        [image compositeToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) operation:NSCompositeSourceOver];
    }
    [super drawInView:view isSelected:flag];
}

- (void)makeNaturalSize {
    NSRect bounds = self.bounds;
    NSImage *image = self.image;
    NSSize requiredSize = (image ? image.size : NSMakeSize(10.0, 10.0));
    
    bounds.size = requiredSize;
    self.bounds = bounds;
    [self setFlippedHorizontally:NO];
    [self setFlippedVertically:NO];
}

NSString *IGImageContentsKey = @"Image";
NSString *IGFlippedHorizontallyKey = @"FlippedHorizontally";
NSString *IGFlippedVerticallyKey = @"FlippedVertically";

- (NSMutableDictionary *)propertyListRepresentation {
    NSMutableDictionary *dict = super.propertyListRepresentation;
    dict[IGImageContentsKey] = [NSArchiver archivedDataWithRootObject:self.image];
    dict[IGFlippedHorizontallyKey] = (self.flippedHorizontally ? @"YES" : @"NO");
    dict[IGFlippedVerticallyKey] = (self.flippedVertically ? @"YES" : @"NO");
    return dict;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentation:dict];
    
    obj = dict[IGImageContentsKey];
    if (obj) {
        self.image = [NSUnarchiver unarchiveObjectWithData:obj];
    }
    obj = dict[IGFlippedHorizontallyKey];
    if (obj) {
        self.flippedHorizontally = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGFlippedVerticallyKey];
    if (obj) {
        self.flippedVertically = [obj isEqualToString:@"YES"];
    }
    _cachedImage = nil;
}

- (void)setImageFile:(NSString *)filePath {
    NSImage *newImage;
    filePath = filePath.stringByStandardizingPath;
    filePath = filePath.stringByExpandingTildeInPath;
    newImage = [[NSImage allocWithZone:nil] initWithContentsOfFile:filePath];
    if (newImage) {
        self.image = newImage;
    }
}

- (NSString *)imageFile {
    // This is really a "write-only" attribute used for setting the image for an IGImage shape from a script.  We don't remember the path so the accessor just returns an empty string.
    return @"";
}

@end
