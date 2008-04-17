//
//  IGGraphic.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//
/*!
@header IGGraphic
 @abstract   (description)
 @discussion (description)
 */

#import <Foundation/Foundation.h>

@class IGGraphicView;
@class IGDrawDocument;

enum {
  NoKnob = 0,
  UpperLeftKnob,
  UpperMiddleKnob,
  UpperRightKnob,
  MiddleLeftKnob,
  MiddleRightKnob,
  LowerLeftKnob,
  LowerMiddleKnob,
  LowerRightKnob,
};

enum {
  NoKnobsMask = 0,
  UpperLeftKnobMask = 1 << UpperLeftKnob,
  UpperMiddleKnobMask = 1 << UpperMiddleKnob,
  UpperRightKnobMask = 1 << 
  UpperRightKnob,
  MiddleLeftKnobMask = 1 << MiddleLeftKnob,
  MiddleRightKnobMask = 1 << MiddleRightKnob,
  LowerLeftKnobMask = 1 << LowerLeftKnob,
  LowerMiddleKnobMask = 1 << LowerMiddleKnob,
  LowerRightKnobMask = 1 << LowerRightKnob,
  AllKnobsMask = 0xffffffff,
};

extern NSString *IGGraphicDidChangeNotification;
extern NSString *IGGlyphDidChangeNotification;

@interface IGGraphic : NSObject <NSCopying> {
  
  //neue gemeinsame Variablen
  CGFloat strokeThickness;
  NSInteger strokeType; //volle Linie, gestrichelte Linie, usw.
  NSColor *strokeColor; //wird dann mit den entsprechenden Werten gesetzt falls rubric
  NSColor *fillColor; //Füllfarbe
  NSInteger fillType; //Schattierung
  NSInteger angle;
  NSInteger cornerRadius;
  
  BOOL mirrored;
  BOOL filled;
  BOOL stroked;
  
  CGFloat fontSize;  //nur für Hieroglyphen
  NSInteger cartoucheOrientation; //nur für die Cartouche
  
  NSInteger arrowType; //0-kein, 1-eine Seite, 2-zwei Seiten
  BOOL arrowReversed;
  NSInteger arrowHeadAngle;
  NSInteger arrowHeadSize;
  
  //ende neue gemeinsame Variablen
  
  @private
  IGDrawDocument *_document;
  NSRect _bounds;
  NSRect _origBounds;
  float _strokeLineWidth;
  NSColor *_fillColor;
  NSColor *_strokeColor;
  struct __gFlags {
    unsigned int drawsFill:1;
    unsigned int drawsStroke:1;
    unsigned int manipulatingBounds:1;
    unsigned int _pad:29;
  } _gFlags;
  
  @protected
    //------------------------------------------
    
    struct __glyphGraphicFlags {
      float fontSize;
      BOOL rubricColor;
      BOOL mirrored;
      int angle;
    } _glyphGraphicFlags;
  
  NSString *_fontName;
  int _glyphASC;
  NSGlyph _theGlyph;
  NSBezierPath *_theGlyphBezPath;
  NSSize _oldGlyphBoundsSize;
  BOOL _glyphIsCreating;
  BOOL _glyphBezPathShouldRecalculate;
  
  //------------------------------------------    
  
  struct __cartoucheGraphicFlags {
    unsigned int xEdge;
    unsigned int yEdge;
    unsigned int borderTyp;
    unsigned int rubricCartouche:1;
    unsigned int endCartoucheAlignment;
  } _cartoucheGraphicFlags;
  
  //------------------------------------------
  
  struct __lineGraphicFlags {
    unsigned int lineType;
    unsigned int rubricLine:1;
    float lineWidth;
    unsigned int arrowType;
    float arrowHead;        
    float arrowHeadSize;
    unsigned int reverseArrow:1;
  } _lineGraphicFlags;
  
  //------------------------------------------
  
  unsigned pageNr;
  
}

  @property (assign) CGFloat strokeThickness;
  @property (assign) NSInteger strokeType; //volle Linie, gestrichelte Linie, usw.
  @property (assign) NSColor *strokeColor; //wird dann mit den entsprechenden Werten gesetzt falls rubric
  @property (assign) NSColor *fillColor; //Füllfarbe
  @property (assign) NSInteger fillType; //Schattierung
  @property (assign) NSInteger angle;
  @property (assign) NSInteger cornerRadius;
  
  @property (assign) BOOL mirrored;
  @property (assign) BOOL filled;
  @property (assign) BOOL stroked;
  
  @property (assign) CGFloat fontSize;  //nur für Hieroglyphen
  @property (assign) NSInteger cartoucheOrientation; //nur für die Cartouche
  
  @property (assign) NSInteger arrowType; //0-kein, 1-eine Seite, 2-zwei Seiten
  @property (assign) BOOL arrowReversed;
  @property (assign) NSInteger arrowHeadAngle;
  @property (assign) NSInteger arrowHeadSize;

- (id)init;

  // ========================= Binding Stuff =========================


  // ========================= Document accessors and conveniences =========================
- (void)setDocument:(IGDrawDocument *)document;
- (IGDrawDocument *)document;
- (NSUndoManager *)undoManager;
- (void)updateToolboxes;

  // =================================== Primitives ===================================
- (void)didChange;
  // This sends the did change notification.  All change primitives should call it.

- (void)setBounds:(NSRect)bounds;
- (NSRect)bounds;
- (void)setDrawsFill:(BOOL)flag;
- (void)setPageNr:(unsigned)page;
- (unsigned)pageNr;
- (BOOL)drawsFill;
- (void)setFillColor:(NSColor *)fillColor;
- (NSColor *)fillColor;
- (void)setDrawsStroke:(BOOL)flag;
- (BOOL)drawsStroke;
- (void)setStrokeColor:(NSColor *)strokeColor;
- (NSColor *)strokeColor;
- (void)setStrokeLineWidth:(float)width;
- (float)strokeLineWidth;

  // =================================== Extended mutation ===================================
- (void)startBoundsManipulation;
- (void)stopBoundsManipulation;
- (void)moveBy:(NSPoint)vector;
- (void)moveTo:(NSPoint)position;
- (void)flipHorizontally;
- (void)flipVertically;
+ (int)flipKnob:(int)knob horizontal:(BOOL)horizFlag; 
- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point;
- (void)makeNaturalSize;

  // =================================== Subclass capabilities ===================================
- (BOOL)canDrawStroke;
- (BOOL)canDrawFill;
- (BOOL)hasNaturalSize;

  // =================================== Persistence ===================================
- (NSMutableDictionary *)propertyListRepresentation;
+ (id)graphicWithPropertyListRepresentation:(NSDictionary *)dict;
+ (id)graphicWithPropertyListRepresentationFromPC:(NSDictionary *)dict;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;
- (void)loadPropertyListRepresentationFromPC:(NSDictionary *)dict;

@end


@interface IGGraphic (IGDrawing)

- (NSRect)drawingBounds;
- (NSBezierPath *)bezierPath;
- (NSBezierPath *)glyphBezierPath;
- (void)drawInView:(IGGraphicView *)view isSelected:(BOOL)flag;
- (unsigned)knobMask;
- (int)knobUnderPoint:(NSPoint)point;
- (void)drawHandleAtPoint:(NSPoint)point inView:(IGGraphicView *)view;
- (void)drawHandlesInView:(IGGraphicView *)view;

@end


@interface IGGraphic (IGEventHandling)

+ (NSCursor *)creationCursor;

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(IGGraphicView *)view;
- (BOOL)replaceGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName;
- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos;

- (BOOL)isEditable;
- (void)startEditingWithEvent:(NSEvent *)event inView:(IGGraphicView *)view;
- (void)endEditingInView:(IGGraphicView *)view;

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected;

@end

@interface IGGraphic (IGScriptingExtras)

// These are methods that we probably wouldn't bother with if we weren't scriptable.

- (NSScriptObjectSpecifier *)objectSpecifier;

- (float)xPosition;
- (void)setXPosition:(float)newVal;

- (float)yPosition;
- (void)setYPosition:(float)newVal;

- (float)width;
- (void)setWidth:(float)newVal;

- (float)height;
- (void)setHeight:(float)newVal;
@end

@interface IGGraphic (IGGlyphExtraStuff)

- (BOOL)glyphIsCreating;
- (void)setGlyphIsCreating:(BOOL)state;

- (void)setOldGlyphBoundsSize:(NSSize)size;

- (void)setBoundsDangerous:(NSRect)newBounds;

- (NSBezierPath *)getOldGlyphBezPath;
- (void)setGlyphBezPath:(NSBezierPath *)path;

- (void)setGlypBezPathShouldRecalculate:(BOOL)flag;    
- (BOOL)bezPathShouldRecalculate;

- (NSString *)fontName;
- (void)setFontName:(NSString *)fontName;

- (int)glyphASC;
- (void)setGlyphASC:(int)glyphASC;

- (NSGlyph)theGlyph;
- (void)setTheGlyph:(NSGlyph)theGlyph;

- (float)fontSize;
- (void)setFontSize:(float)fontSize;

- (BOOL)rubricColor;
- (void)setRubricColor:(BOOL)value;

- (BOOL)mirrored;
- (void)setMirrored:(BOOL)value;

- (int)angle;
- (void)setAngle:(int)value;

@end

/*
@interface IGGraphic (IGCartoucheExtraStuff)

- (int)xEdge;
- (void)setXEdge:(int)value;

- (int)yEdge;
- (void)setYEdge:(int)value;

- (int)cartoucheBorderType;
- (void)setCartoucheBorderType:(int)value;

- (int)endCartoucheAlignment;
- (void)setEndCartoucheAlignment:(int)value;

- (BOOL)rubricCartouche;
- (void)setRubricCartouche:(BOOL)value;

@end
*/

@interface IGGraphic (IGLineExtraStuff)

- (int)lineType;
- (void)setLineType:(int)value;

- (float)lineWidth;
- (void)setLineWidth:(float)value;

- (BOOL)rubricLine;
- (void)setRubricLine:(BOOL)value;

- (int)arrowType;
- (void)setArrowType:(int)value;

- (float)arrowHead;
- (void)setArrowHead:(float)value;

- (void)doReverseArrow;
- (BOOL)reverseArrow;
- (void)setReverseArrow:(BOOL)aValue;
@end

extern NSString *IGClassKey;
extern NSString *IGBoundsKey;
extern NSString *IGDrawsFillKey;
extern NSString *IGFillColorKey;
extern NSString *IGDrawsStrokeKey;
extern NSString *IGStrokeColorKey;
extern NSString *IGStrokeLineWidthKey;
extern NSString *IGPageNum;