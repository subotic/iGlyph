//
//  IGGlyph.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"

@interface IGGlyph : IGGraphic <NSCopying> {
}

@property (NS_NONATOMIC_IOSONLY) BOOL glyphIsCreating;

- (void)setOldGlyphBoundsSize:(NSSize)size;

- (void)setBoundsDangerous:(NSRect)newBounds;

@property (NS_NONATOMIC_IOSONLY, getter=getOldGlyphBezPath, readonly, copy) NSBezierPath *oldGlyphBezPath;
- (void)setGlyphBezPath:(NSBezierPath *)path;

- (void)setGlypBezPathShouldRecalculate:(BOOL)flag;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL bezPathShouldRecalculate;

@property (NS_NONATOMIC_IOSONLY, copy) NSString *fontName;

@property (NS_NONATOMIC_IOSONLY) int glyphASC;

@property (NS_NONATOMIC_IOSONLY) NSGlyph theGlyph;

@property (NS_NONATOMIC_IOSONLY) NSInteger fontSize;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricColor;

@property (NS_NONATOMIC_IOSONLY) BOOL mirrored;

@property (NS_NONATOMIC_IOSONLY) NSInteger angle;




- (NSGlyph)getTheGlyph:(unichar)glyphUniChar forFont:(NSString *)fontName andSize:(float)size;
- (NSFont *)getFont:(NSString *)fontName withSize:(float)fontSize;
- (BOOL)replaceGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName;
- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos onPage:(NSUInteger)page;
- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName inView:(IGGraphicView *)view;
@end

extern NSString *IGFontNameKey;
extern NSString *IGTheGlyphKey;
extern NSString *IGGlyphASCKey;
extern NSString *IGFontSizeKey;
extern NSString *IGGlyphRubricColorKey;
extern NSString *IGMirroredKey;
extern NSString *IGAngleKey;
