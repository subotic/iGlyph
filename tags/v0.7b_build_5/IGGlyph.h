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

- (NSGlyph)getTheGlyph:(unichar)glyphUniChar forFont:(NSString *)fontName andSize:(float)size;
- (NSFont *)getFont:(NSString *)fontName withSize:(float)fontSize; 
@end

extern NSString *IGFontNameKey;
extern NSString *IGTheGlyphKey;
extern NSString *IGGlyphASCKey;
extern NSString *IGFontSizeKey;
extern NSString *IGGlyphRubricColorKey;
extern NSString *IGMirroredKey;
extern NSString *IGAngleKey;