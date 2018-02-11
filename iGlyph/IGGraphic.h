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

// FIXME: modernize
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

// FIXME: modernize
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


@protocol IGGraphicProtocol
// list of methods and properties
@end

@interface IGGraphic : NSObject <NSCopying> {
    
    //neue gemeinsame Variablen
    CGFloat strokeThickness;
    NSInteger strokeType; //volle Linie, gestrichelte Linie, usw.
    NSColor *__weak strokeColor; //wird dann mit den entsprechenden Werten gesetzt falls rubric
    NSColor *__weak fillColor; //Füllfarbe
    NSInteger fillType; //Schattierung
    NSInteger angle;
    NSInteger cornerRadius;
    
    BOOL mirrored;
    BOOL filled;
    BOOL stroked;
    
    NSInteger fontSize;  //nur für Hieroglyphen
    NSInteger cartoucheOrientation; //nur für die Cartouche
    
    //ende neue gemeinsame Variablen
    
@private
    
    NSRect _origBounds;
    float _strokeLineWidth;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    struct __gFlags {
        NSUInteger drawsFill:1;
        NSUInteger drawsStroke:1;
        NSUInteger manipulatingBounds:1;
        NSUInteger _pad:29;
    } _gFlags;
    
@protected
    
    // FIXME: Should this be defined here or in each subclass?
    NSRect _bounds;
    
    struct __glyphGraphicFlags {
        NSInteger fontSize;
        BOOL rubricColor;
        BOOL mirrored;
        NSInteger angle;
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
        NSUInteger xEdge;
        NSUInteger yEdge;
        NSUInteger borderTyp;
        NSUInteger rubricCartouche:1;
        NSUInteger endCartoucheAlignment;
    } _cartoucheGraphicFlags;
    
    //------------------------------------------
    
    struct __lineGraphicFlags {
        NSInteger lineType;
        NSInteger rubricLine:1;
        NSInteger lineWidth;
        NSInteger arrowType;
        NSInteger arrowHead;
        NSInteger arrowHeadSize;
        NSInteger reverseArrow:1;
    } _lineGraphicFlags;
    
    //------------------------------------------
    
    NSUInteger pageNr;
    
}

@property (assign) CGFloat strokeThickness;
@property (assign) NSInteger strokeType; //volle Linie, gestrichelte Linie, usw.
@property (weak) NSColor *strokeColor; //wird dann mit den entsprechenden Werten gesetzt falls rubric
@property (weak) NSColor *fillColor; //Füllfarbe
@property (assign) NSInteger fillType; //Schattierung
@property (assign) NSInteger angle;
@property (assign) NSInteger cornerRadius;

@property (assign) BOOL mirrored;
@property (assign) BOOL filled;
@property (assign) BOOL stroked;

@property (assign) NSInteger fontSize;  //nur für Hieroglyphen
@property (assign) NSInteger cartoucheOrientation; //nur für die Cartouche

- (IGGraphic *)init;


// ========================= Document accessors and conveniences =========================
@property (weak) IGDrawDocument *document;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) NSUndoManager *undoManager;
- (void)updateToolboxes;

// =================================== Primitives ===================================
- (void)didChange;
// This sends the did change notification.  All change primitives should call it.

@property (NS_NONATOMIC_IOSONLY) NSRect bounds;
@property (NS_NONATOMIC_IOSONLY) NSUInteger pageNr;
@property (NS_NONATOMIC_IOSONLY) BOOL drawsFill;
- (void)setFillColor:(NSColor *)fillColor;
- (NSColor *)fillColor;
@property (NS_NONATOMIC_IOSONLY) BOOL drawsStroke;
- (void)setStrokeColor:(NSColor *)strokeColor;
- (NSColor *)strokeColor;
@property (NS_NONATOMIC_IOSONLY) float strokeLineWidth;

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
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canDrawStroke;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canDrawFill;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasNaturalSize;

// =================================== Persistence ===================================
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableDictionary *propertyListRepresentation;
+ (instancetype)graphicWithPropertyListRepresentation:(NSDictionary *)dict;
+ (instancetype)graphicWithPropertyListRepresentationFromPC:(NSDictionary *)dict;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;
- (void)loadPropertyListRepresentationFromPC:(NSDictionary *)dict;

@end


@interface IGGraphic (IGDrawing)

@property (NS_NONATOMIC_IOSONLY, readonly) NSRect drawingBounds;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSBezierPath *bezierPath;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSBezierPath *glyphBezierPath;
- (void)drawInView:(IGGraphicView *)view isSelected:(BOOL)flag;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger knobMask;
- (int)knobUnderPoint:(NSPoint)point;
- (void)drawHandleAtPoint:(NSPoint)point inView:(IGGraphicView *)view;
- (void)drawHandlesInView:(IGGraphicView *)view;

@end


@interface IGGraphic (IGEventHandling)

+ (NSCursor *)creationCursor;

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(IGGraphicView *)view;

/*
- (BOOL)replaceGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName;
- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos;
*/

@property (NS_NONATOMIC_IOSONLY, getter=isEditable, readonly) BOOL editable;
- (void)startEditingWithEvent:(NSEvent *)event inView:(IGGraphicView *)view;
- (void)endEditingInView:(IGGraphicView *)view;

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected;

@end

@interface IGGraphic (IGScriptingExtras)

// These are methods that we probably wouldn't bother with if we weren't scriptable.

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSScriptObjectSpecifier *objectSpecifier;

@property (NS_NONATOMIC_IOSONLY) float xPosition;

@property (NS_NONATOMIC_IOSONLY) float yPosition;

@property (NS_NONATOMIC_IOSONLY) float width;

@property (NS_NONATOMIC_IOSONLY) float height;
@end

/*
@interface IGGraphic (IGGlyphExtraStuff)

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

@end
*/

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

/*
@interface IGGraphic (IGLineExtraStuff)

@property (NS_NONATOMIC_IOSONLY) NSInteger lineType;

@property (NS_NONATOMIC_IOSONLY) float lineWidth;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowType;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHead;

- (void)doReverseArrow;
@property (NS_NONATOMIC_IOSONLY) BOOL reverseArrow;
@end
*/

extern NSString *IGClassKey;
extern NSString *IGBoundsKey;
extern NSString *IGDrawsFillKey;
extern NSString *IGFillColorKey;
extern NSString *IGDrawsStrokeKey;
extern NSString *IGStrokeColorKey;
extern NSString *IGStrokeLineWidthKey;
extern NSString *IGPageNum;
