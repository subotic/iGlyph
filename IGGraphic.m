//
//  IGGraphic.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"
#import "IGGraphicView.h"
#import "IGDrawDocument.h"
#import "IGFoundationExtras.h"
#import "IGGlyph.h"

NSString *IGGraphicDidChangeNotification = @"IGGraphicDidChange";
NSString *IGGlyphDidChangeNotification = @"IGGlyphDidChange";

@implementation IGGraphic

  @synthesize strokeThickness;
  @synthesize strokeType; //volle Linie, gestrichelte Linie, usw.
  @synthesize strokeColor; //wird dann mit den entsprechenden Werten gesetzt falls rubric
  @synthesize fillColor; //Füllfarbe
  @synthesize fillType; //Schattierung
  @synthesize angle;
  @synthesize cornerRadius;
  
  @synthesize mirrored;
  @synthesize filled;
  @synthesize stroked;
  
  @synthesize fontSize;  //nur für Hieroglyphen
  @synthesize cartoucheOrientation; //nur für die Cartouche
  
  @synthesize arrowType; //0-kein, 1-eine Seite, 2-zwei Seiten
  @synthesize arrowReversed;
  @synthesize arrowHeadAngle;
  @synthesize arrowHeadSize;

#pragma mark -- init stuff --
// =================================== Initialization ===================================

- (instancetype)init {
    self = [super init];
    if (self) {
        _document = nil;
        self.bounds = NSMakeRect(0.0, 0.0, 1.0, 1.0);
        self.fillColor = [NSColor whiteColor];
        [self setDrawsFill:NO];
        self.strokeColor = [NSColor blackColor];
        [self setDrawsStroke:YES];
        self.strokeLineWidth = 1.0;
        self.pageNr = 1;
        
        _origBounds = NSZeroRect;
        _gFlags.manipulatingBounds = NO;
        _theGlyphBezPath = nil;
        _glyphBezPathShouldRecalculate = NO;
        _glyphIsCreating = NO;
        
        //new variables
        self.strokeThickness = 1.0;
        self.strokeType = 0;
        self.strokeColor = [NSColor blackColor];
        self.fillColor = [NSColor whiteColor];
        self.fillType = 0;
        self.angle = 0;
        self.mirrored = FALSE;
        self.filled = FALSE;
        self.stroked = TRUE;
        
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    id newObj = [[[self class] allocWithZone:zone] init];
    
    // Document is not "copied".  The new graphic will need to be inserted into a document.
    [newObj setBounds:self.bounds];
    [newObj setFillColor:self.fillColor];
    [newObj setDrawsFill:self.drawsFill];
    [newObj setStrokeColor:self.strokeColor];
    [newObj setDrawsStroke:self.drawsStroke];
    [newObj setStrokeLineWidth:self.strokeLineWidth];
    [newObj setPageNr:self.pageNr];
    
    return newObj;
}


// ==================================================================================
#pragma mark -
#pragma mark -- bindings stuff --
// ============================== bindings stuff=====================================



// ==================================================================================
#pragma mark -
#pragma mark -- accessors and conveniences --
// ========================= Document accessors and conveniences ====================

- (void)setDocument:(IGDrawDocument *)document {
    _document = document;
}

- (IGDrawDocument *)document {
    return _document;
}

- (NSUndoManager *)undoManager {
    return self.document.undoManager;
}

- (NSString *)graphicType {
    return NSStringFromClass([self class]);
}

- (void)updateToolboxes {
    //some subclasses need to update the inspector toolboxes then they are selected
}

// ==================================================================================
#pragma mark -
#pragma mark -- primitives --
// =================================== Primitives ===================================

- (void)didChange {
    [_document invalidateGraphic:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:IGGraphicDidChangeNotification object:self];
}

- (void)glyphDidChange {
    [_document invalidateGraphic:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:IGGlyphDidChangeNotification object:self];
}


- (void)setBounds:(NSRect)bounds { //links oben null punkt
    if (!NSEqualRects(bounds, _bounds)) {
        if (!_gFlags.manipulatingBounds) {
            // Send the notification before and after so that observers who invalidate display in views will
            // wind up invalidating both the original rect and the new one.
            if ([self class] == [IGGlyph class]) [self setGlypBezPathShouldRecalculate:NO]; //damit die glyphe beim verschieben nicht neu gerechnet wird sondern nur verschoben wird
            [self didChange];
            [[self.undoManager prepareWithInvocationTarget:self] setBounds:_bounds];
        }
        _bounds = bounds;
        if (!_gFlags.manipulatingBounds) {
            if ([self class] == [IGGlyph class]) [self setGlypBezPathShouldRecalculate:NO]; //damit die glyphe beim verschieben nicht neu gerechnet wird sondern nur verschoben wird
            [self didChange];
        }
    }
}

- (NSRect)bounds {
    return _bounds;
}

- (void)setPageNr:(NSUInteger)page {
    pageNr = page;
}

- (NSUInteger)pageNr {
    return pageNr;
}

- (void)setDrawsFill:(BOOL)flag {
    if (_gFlags.drawsFill != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setDrawsFill:_gFlags.drawsFill];
        _gFlags.drawsFill = (flag ? YES : NO);
        [self didChange];
    }
}

- (BOOL)drawsFill {
    return _gFlags.drawsFill;
}

/**
- (void)setFillColor:(NSColor *)fillColor {
    if (_fillColor != fillColor) {
        [[[self undoManager] prepareWithInvocationTarget:self] setFillColor:_fillColor];
        [_fillColor autorelease];
        _fillColor = [fillColor retain];
        [self didChange];
    }
    if (_fillColor) {
        [self setDrawsFill:YES];
    } else {
        [self setDrawsFill:NO];
    }
}

- (NSColor *)fillColor {
    return _fillColor;
}
**/

- (void)setDrawsStroke:(BOOL)flag {
    if (_gFlags.drawsStroke != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setDrawsStroke:_gFlags.drawsStroke];
        _gFlags.drawsStroke = (flag ? YES : NO);
        [self didChange];
    }
}

- (BOOL)drawsStroke {
    return _gFlags.drawsStroke;
}

/**
- (void)setStrokeColor:(NSColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        [[[self undoManager] prepareWithInvocationTarget:self] setStrokeColor:_strokeColor];
        [_strokeColor autorelease];
        _strokeColor = [strokeColor retain];
        [self didChange];
    }
    if (_strokeColor) {
        [self setDrawsStroke:YES];
    } else {
        [self setDrawsStroke:NO];
    }
}

- (NSColor *)strokeColor {
    return _strokeColor;
}
**/

- (void)setStrokeLineWidth:(float)width {
    if (_strokeLineWidth != width) {
        [[self.undoManager prepareWithInvocationTarget:self] setStrokeLineWidth:_strokeLineWidth];
        if (width >= 0.0) {
            [self setDrawsStroke:YES];
            _strokeLineWidth = width;
        } else {
            [self setDrawsStroke:NO];
            _strokeLineWidth = 0.0;
        }
        [self didChange];
    }
}

- (float)strokeLineWidth {
    return _strokeLineWidth;
}

// ==================================================================================
#pragma mark -
#pragma mark -- extended mutation --
// =============================== Extended mutation ================================

- (void)startBoundsManipulation {
    // Save the original bounds.
    _gFlags.manipulatingBounds = YES;
    _origBounds = _bounds;
}

- (void)stopBoundsManipulation {
    if (_gFlags.manipulatingBounds) {
        // Restore the original bounds, the set the new bounds.
        if (!NSEqualRects(_origBounds, _bounds)) {
            NSRect temp;
            
            _gFlags.manipulatingBounds = NO;
            temp = _bounds;
            _bounds = _origBounds;
            self.bounds = temp;
        } else {
            _gFlags.manipulatingBounds = NO;
        }
    }
}

- (void)moveBy:(NSPoint)vector {
    self.bounds = NSOffsetRect(self.bounds, vector.x, vector.y);
}

- (void)moveTo:(NSPoint)position {
    self.bounds = NSMakeRect(position.x,position.y,self.bounds.size.width,self.bounds.size.height);
}

- (void)flipHorizontally {
    // Some subclasses need to know.
    return;
}

- (void)flipVertically {
    // Some subclasses need to know.
    return;
}

+ (int)flipKnob:(int)knob horizontal:(BOOL)horizFlag {
    static BOOL initedFlips = NO;
    static int horizFlips[9];
    static int vertFlips[9];
    
    if (!initedFlips) {
        horizFlips[UpperLeftKnob] = UpperRightKnob;
        horizFlips[UpperMiddleKnob] = UpperMiddleKnob;
        horizFlips[UpperRightKnob] = UpperLeftKnob;
        horizFlips[MiddleLeftKnob] = MiddleRightKnob;
        horizFlips[MiddleRightKnob] = MiddleLeftKnob;
        horizFlips[LowerLeftKnob] = LowerRightKnob;
        horizFlips[LowerMiddleKnob] = LowerMiddleKnob;
        horizFlips[LowerRightKnob] = LowerLeftKnob;
        
        vertFlips[UpperLeftKnob] = LowerLeftKnob;
        vertFlips[UpperMiddleKnob] = LowerMiddleKnob;
        vertFlips[UpperRightKnob] = LowerRightKnob;
        vertFlips[MiddleLeftKnob] = MiddleLeftKnob;
        vertFlips[MiddleRightKnob] = MiddleRightKnob;
        vertFlips[LowerLeftKnob] = UpperLeftKnob;
        vertFlips[LowerMiddleKnob] = UpperMiddleKnob;
        vertFlips[LowerRightKnob] = UpperRightKnob;
        initedFlips = YES;
    }
    if (horizFlag) {
        return horizFlips[knob];
    } else {
        return vertFlips[knob];
    }
}

- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point {
    NSRect bounds = self.bounds;
    
    if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob)) {
        // Adjust left edge
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob)) {
        // Adjust right edge
        bounds.size.width = point.x - bounds.origin.x;
    }
    if (bounds.size.width < 0.0) {
        knob = [IGGraphic flipKnob:knob horizontal:YES];
        bounds.size.width = -bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        [self flipHorizontally];
    }
    
    if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob)) {
        // Adjust top edge
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob)) {
        // Adjust bottom edge
        bounds.size.height = point.y - bounds.origin.y;
    }
    if (bounds.size.height < 0.0) {
        knob = [IGGraphic flipKnob:knob horizontal:NO];
        bounds.size.height = -bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        [self flipVertically];
    }
    self.bounds = bounds;
    return knob;
}

- (void)makeNaturalSize {
    // Do nothing by default
}


// ==================================================================================
#pragma mark -
#pragma mark -- subclass capabilities --
// ============================== Subclass capabilities =============================

// Some subclasses will not ever have a stroke or fill or a natural size.
// Overriding these methods in such subclasses allows the Inspector and Menu items
// to better reflect allowable actions.

- (BOOL)canDrawStroke {
    return YES;
}

- (BOOL)canDrawFill {
    return YES;
}

- (BOOL)hasNaturalSize {
    return YES;
}

// ==================================================================================
#pragma mark -
#pragma mark -- persistence --
// ================================== Persistence ===================================

NSString *IGClassKey = @"Class";
NSString *IGBoundsKey = @"Bounds";
NSString *IGDrawsFillKey = @"DrawsFill";
NSString *IGFillColorKey = @"FillColor";
NSString *IGDrawsStrokeKey = @"DrawsStroke";
NSString *IGStrokeColorKey = @"StrokeColor";
NSString *IGStrokeLineWidthKey = @"StrokeLineWidth";
NSString *IGPageNum = @"PageNr";

- (NSMutableDictionary *)propertyListRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *className = NSStringFromClass([self class]);

    dict[IGClassKey] = className;
    dict[IGBoundsKey] = NSStringFromRect(self.bounds);
    dict[IGDrawsFillKey] = (self.drawsFill ? @"YES" : @"NO");
    if (self.fillColor) {
        dict[IGFillColorKey] = [NSArchiver archivedDataWithRootObject:self.fillColor];
    }
    dict[IGDrawsStrokeKey] = (self.drawsStroke ? @"YES" : @"NO");
    if (self.strokeColor) {
        dict[IGStrokeColorKey] = [NSArchiver archivedDataWithRootObject:self.strokeColor];
    }
    dict[IGStrokeLineWidthKey] = [NSString stringWithFormat:@"%.2f", self.strokeLineWidth];
    dict[IGPageNum] = [NSString stringWithFormat:@"%d", self.pageNr];
    
    return dict;
}

+ (instancetype)graphicWithPropertyListRepresentation:(NSDictionary *)dict {
    Class theClass = NSClassFromString(dict[IGClassKey]);
    id theGraphic = nil;
    
    if (theClass) {
        theGraphic = [[theClass allocWithZone:NULL] init];
        if (theGraphic) {
            [theGraphic loadPropertyListRepresentation:dict];
        }
    }
    return theGraphic;
}

//wenn ich das PC file einlese, muss ich noch gewisse abfragen machen, die ich am besten beim Objekt erstellen mache, da dort schon alles vorhanden ist
+ (instancetype)graphicWithPropertyListRepresentationFromPC:(NSDictionary *)dict {
    Class theClass = NSClassFromString(dict[IGClassKey]);
    id theGraphic = nil;
    
    if (theClass) {
        theGraphic = [[theClass allocWithZone:NULL] init];
        if (theGraphic) {
            [theGraphic loadPropertyListRepresentationFromPC:dict];
        }
    }
    return theGraphic;
}




- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    obj = dict[IGBoundsKey];
    if (obj) {
        if ([dict[IGClassKey] isEqualToString:@"IGGlyph"]) { //bounds tweakink only for IGGlyph
            NSRect tmpRect = NSRectFromString(obj);
            [self setOldGlyphBoundsSize:tmpRect.size];
            self.bounds = tmpRect;
        } else {
        self.bounds = NSRectFromString(obj);
        }
    }
    obj = dict[IGFillColorKey];
    if (obj) {
        self.fillColor = [NSUnarchiver unarchiveObjectWithData:obj];
    }
    obj = dict[IGDrawsFillKey];
    if (obj) {
        self.drawsFill = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGStrokeColorKey];
    if (obj) {
        self.strokeColor = [NSUnarchiver unarchiveObjectWithData:obj];
    }
    obj = dict[IGStrokeLineWidthKey];
    if (obj) {
        self.strokeLineWidth = [obj floatValue];
    }
    obj = dict[IGDrawsStrokeKey];
    if (obj) {
        self.drawsStroke = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGPageNum];
    if (obj) {
        self.pageNr = (NSUInteger)[obj intValue];
    }
    
    return;
}

- (void)loadPropertyListRepresentationFromPC:(NSDictionary *)dict {
    id obj;
    
    obj = dict[IGBoundsKey];
    if (obj) {
        if ([dict[IGClassKey] isEqualToString:@"IGGlyph"]) { //bounds tweakink only for IGGlyph
            NSRect tmpRect = NSRectFromString(obj);
            [self setOldGlyphBoundsSize:tmpRect.size];
            self.bounds = tmpRect;
        } else {
            self.bounds = NSRectFromString(obj);
        }
    }
    obj = dict[IGFillColorKey];
    if (obj) {
        self.fillColor = [NSUnarchiver unarchiveObjectWithData:obj];
    }
    obj = dict[IGDrawsFillKey];
    if (obj) {
        self.drawsFill = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGStrokeColorKey];
    if (obj) {
        self.strokeColor = [NSUnarchiver unarchiveObjectWithData:obj];
    }
    obj = dict[IGStrokeLineWidthKey];
    if (obj) {
        self.strokeLineWidth = [obj floatValue];
    }
    obj = dict[IGDrawsStrokeKey];
    if (obj) {
        self.drawsStroke = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGPageNum];
    if (obj) {
        self.pageNr = (NSUInteger)[obj intValue];
    }
    
    return;
}



// ==================================================================================
#pragma mark -
#pragma mark -- drawing --
// =================================== Drawing ======================================

- (NSRect)drawingBounds {
    float inset = -IG_HALF_HANDLE_WIDTH;
    if (self.drawsStroke) {
        float halfLineWidth = (self.strokeLineWidth / 2.0) + 1.0;
        if (-halfLineWidth < inset) {
            inset = -halfLineWidth;
        }
    }
    //inset += -1.0; //weggemacht da ansonsten beim arc unter den knöpfen noch linie erscheint da ich bescheisse
    //NSLog(@"IGGraphic(drawingBounds) -> inset = %f", inset);
    return NSInsetRect(self.bounds, inset, inset);
}

- (NSBezierPath *)bezierPath {
    // Subclasses that just have a simple path override this to return it.
    // The basic drawInView:isSelected: implementation below will stroke and fill this path.
    // Subclasses that need more complex drawing will just override drawInView:isSelected:.
    return nil;
}

- (NSBezierPath *)glyphBezierPath { //wird für IGGlyph überladen
    return nil;
}

- (void)drawInView:(IGGraphicView *)view isSelected:(BOOL)flag { //wird für IGGlyph überladen
    NSBezierPath *path = self.bezierPath;
    if (path) {
        if (self.drawsFill) {
            [self.fillColor set];
            [path fill];
        }
        if (self.drawsStroke) {
            [self.strokeColor set];
            [path stroke];
        }
    }
    if (flag) {
        [self drawHandlesInView:view];
    }
}

- (NSUInteger)knobMask {
    return LowerLeftKnobMask + UpperRightKnobMask;
}

- (int)knobUnderPoint:(NSPoint)point {
    NSRect bounds = self.bounds;
    NSUInteger knobMask = self.knobMask;
    NSRect handleRect;
    
    handleRect.size.width = IG_HANDLE_WIDTH;
    handleRect.size.height = IG_HANDLE_WIDTH;
    
    if (knobMask & UpperLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperLeftKnob;
        }
    }
    if (knobMask & UpperMiddleKnobMask) {
        handleRect.origin.x = NSMidX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperMiddleKnob;
        }
    }
    if (knobMask & UpperRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperRightKnob;
        }
    }
    if (knobMask & MiddleLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMidY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return MiddleLeftKnob;
        }
    }
    if (knobMask & MiddleRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMidY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return MiddleRightKnob;
        }
    }
    if (knobMask & LowerLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerLeftKnob;
        }
    }
    if (knobMask & LowerMiddleKnobMask) {
        handleRect.origin.x = NSMidX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerMiddleKnob;
        }
    }
    if (knobMask & LowerRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - IG_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - IG_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerRightKnob;
        }
    }
    
    return NoKnob;
}

- (void)drawHandleAtPoint:(NSPoint)point inView:(IGGraphicView *)view {
    NSRect handleRect;
    
    handleRect.origin.x = point.x - IG_HALF_HANDLE_WIDTH;
    handleRect.origin.y = point.y - IG_HALF_HANDLE_WIDTH;
    handleRect.size.width = IG_HANDLE_WIDTH;
    handleRect.size.height = IG_HANDLE_WIDTH;
    handleRect = [view centerScanRect:handleRect];
    
    /*
    [[NSColor controlDarkShadowColor] set];
    NSRectFill(handleRect);
    handleRect = NSOffsetRect(handleRect, -1.0, -1.0);
    [[NSColor knobColor] set];
    NSRectFill(handleRect);
     */
    
    [[NSColor blackColor] set];
    NSFrameRect(handleRect);
    [[NSColor blueColor] set];
    NSRectFill(NSInsetRect(handleRect, 0.75, 0.75));
}

- (void)drawHandlesInView:(IGGraphicView *)view {
    NSRect bounds = self.bounds;
    //NSLog(@"IGGraphic(drawHandlesInView) -> handleBounds x: %f, y: %f, w: %f, h: %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    NSUInteger knobMask = self.knobMask;
    
    if (knobMask & UpperLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds)) inView:view];
    }
    if (knobMask & UpperMiddleKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds)) inView:view];
    }
    if (knobMask & UpperRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)) inView:view];
    }
    
    if (knobMask & MiddleLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds)) inView:view];
    }
    if (knobMask & MiddleRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds)) inView:view];
    }
    
    if (knobMask & LowerLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) inView:view];
    }
    if (knobMask & LowerMiddleKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds)) inView:view];
    }
    if (knobMask & LowerRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)) inView:view];
    }
}

// ==================================================================================
#pragma mark -
#pragma mark -- event handling --
// ================================= Event Handling =================================

+ (NSCursor *)creationCursor {
    // By default we use the crosshair cursor
    static NSCursor *crosshairCursor = nil;
    if (!crosshairCursor) {
        NSImage *crosshairImage = [NSImage imageNamed:@"Cross"];
        NSSize imageSize = crosshairImage.size;
        crosshairCursor = [[NSCursor allocWithZone:nil] initWithImage:crosshairImage hotSpot:NSMakePoint((imageSize.width / 2.0), (imageSize.height / 2.0))];
    }
    return crosshairCursor;
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(IGGraphicView *)view {
    // default implementation tracks until mouseUp: just setting the bounds of the new graphic.
    NSPoint point = [view convertPoint:theEvent.locationInWindow fromView:nil];
    int knob = LowerRightKnob;
    NSRect bounds;
    BOOL snapsToGrid = view.snapsToGrid;
    float spacing = view.gridSpacing;
    BOOL echoToRulers = view.enclosingScrollView.rulersVisible;
    
    [self startBoundsManipulation];
    if (snapsToGrid) {
        point.x = floor((point.x / spacing) + 0.5) * spacing;
        point.y = floor((point.y / spacing) + 0.5) * spacing;
    }
    self.bounds = NSMakeRect(point.x, point.y, 0.0, 0.0);
    if (echoToRulers) {
        [view beginEchoingMoveToRulers:self.bounds];
    }
    while (1) {
        theEvent = [view.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        point = [view convertPoint:theEvent.locationInWindow fromView:nil];
        if (snapsToGrid) {
            point.x = floor((point.x / spacing) + 0.5) * spacing;
            point.y = floor((point.y / spacing) + 0.5) * spacing;
        }
        [view setNeedsDisplayInRect:self.drawingBounds];
        knob = [self resizeByMovingKnob:knob toPoint:point];
        [view setNeedsDisplayInRect:self.drawingBounds];
        if (echoToRulers) {
            [view continueEchoingMoveToRulers:self.bounds];
        }
        if (theEvent.type == NSLeftMouseUp) {
            break;
        }
    }
    if (echoToRulers) {
        [view stopEchoingMoveToRulers];
    }
    
    [self stopBoundsManipulation];
    
    bounds = self.bounds;
    if ((bounds.size.width > 0.0) || (bounds.size.height > 0.0)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)replaceGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName {
    //override by IGGlyph class
    return NO;
}

- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos {
    //override by IGGlyph class
    return NO;
}

- (BOOL)isEditable {
    return NO;
}

- (void)startEditingWithEvent:(NSEvent *)event inView:(IGGraphicView *)view {
    return;
}

- (void)endEditingInView:(IGGraphicView *)view {
    return;
}

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected {
    if (isSelected && ([self knobUnderPoint:point] != NoKnob)) {
        return YES;
    } else {
        NSBezierPath *path = self.bezierPath;
        
        if (path) {
            if ([path containsPoint:point]) {
                return YES;
            }
        } else {
            if (NSPointInRect(point, self.bounds)) {
                return YES;
            }
        }
        return NO;
    }
}

- (NSString *)description {
    return self.propertyListRepresentation.description;
}

@end

@implementation IGGraphic (IGScriptingExtras)

// These are methods that we probably wouldn't bother with if we weren't scriptable.

- (NSScriptObjectSpecifier *)objectSpecifier {
    NSArray *graphics = [self.document graphicsOnPage:self.pageNr];
    NSUInteger index = [graphics indexOfObjectIdenticalTo:self];
    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = self.document.objectSpecifier;
        return [[NSIndexSpecifier allocWithZone:nil] initWithContainerClassDescription:containerRef.keyClassDescription containerSpecifier:containerRef key:@"graphics" index:index];
    } else {
        return nil;
    }
}

- (float)xPosition {
    return self.bounds.origin.x;
}

- (void)setXPosition:(float)newVal {
    NSRect bounds = self.bounds;
    bounds.origin.x = newVal;
    self.bounds = bounds;
}

- (float)yPosition {
    return self.bounds.origin.y;
}

- (void)setYPosition:(float)newVal {
    NSRect bounds = self.bounds;
    bounds.origin.y = newVal;
    self.bounds = bounds;
}

- (float)width {
    return self.bounds.size.width;
}

- (void)setWidth:(float)newVal {
    NSRect bounds = self.bounds;
    bounds.size.width = newVal;
    self.bounds = bounds;
}

- (float)height {
    return self.bounds.size.height;
}

- (void)setHeight:(float)newVal {
    NSRect bounds = self.bounds;
    bounds.size.height = newVal;
    self.bounds = bounds;
}

@end

@implementation IGGraphic (IGGlyphExtraStuff)

- (BOOL)glyphIsCreating {
    return _glyphIsCreating;
}

- (void)setGlyphIsCreating:(BOOL)state {
    _glyphIsCreating = state;
}

- (void)setOldGlyphBoundsSize:(NSSize)size {
    _oldGlyphBoundsSize = size;
}

//---------

- (void)setBoundsDangerous:(NSRect)newBounds {
    _bounds = newBounds;
}

//---------
//damit nicht der bezPath immer neu erstellt werden muss; zBsp beim verschieben oder anderer Farbe

- (NSBezierPath *)getOldGlyphBezPath {
    return _theGlyphBezPath;
}

- (void)setGlyphBezPath:(NSBezierPath *)path {
    _theGlyphBezPath = path;
}

//---------
//gehört zur vorhergehenden Geschichte
- (void)setGlypBezPathShouldRecalculate:(BOOL)flag {
    _glyphBezPathShouldRecalculate = flag;
}

- (BOOL)bezPathShouldRecalculate {
    return _glyphBezPathShouldRecalculate;
}

//---------

- (NSString *)fontName {
    return _fontName;
}

- (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    [self setGlypBezPathShouldRecalculate:YES];
    [self didChange];
}

//---------

- (int)glyphASC {
    return _glyphASC;
}

- (void)setGlyphASC:(int)glyphASC {
    _glyphASC = glyphASC;
}


//---------

- (NSGlyph)theGlyph {
    return _theGlyph;
}

- (void)setTheGlyph:(NSGlyph)theGlyph {
    _theGlyph = theGlyph;
}

//---------

- (NSUInteger)fontSize {
    return _glyphGraphicFlags.fontSize;
}

- (void)setFontSize:(NSUInteger)size {
    if (size) {
        _glyphGraphicFlags.fontSize = size;
    } else {
        _glyphGraphicFlags.fontSize = 25;
    }
    [self setGlypBezPathShouldRecalculate:YES];
    [self didChange];
}

//---------

- (BOOL)rubricColor {
    return _glyphGraphicFlags.rubricColor;
}

- (void)setRubricColor:(BOOL)value {
    if (value) {
        _glyphGraphicFlags.rubricColor = value;
    } else {
        _glyphGraphicFlags.rubricColor = NO;
    }
    [self setGlypBezPathShouldRecalculate:NO];
    [self didChange];
}

//---------

- (BOOL)mirrored {
    return _glyphGraphicFlags.mirrored;
}

- (void)setMirrored:(BOOL)value {
    if (value) {
        _glyphGraphicFlags.mirrored = value;
    } else {
        _glyphGraphicFlags.mirrored = NO;
    }
    [self setGlypBezPathShouldRecalculate:YES];
    [self didChange];
}

//---------

- (NSInteger)angle {
    return _glyphGraphicFlags.angle;
}

- (void)setAngle:(NSInteger)value {
    if (value) {
        _glyphGraphicFlags.angle = value;
    } else {
        _glyphGraphicFlags.angle = NO;
    }
    [self setGlypBezPathShouldRecalculate:YES];
    [self didChange];
}
@end

/*
@implementation IGGraphic (IGCartoucheExtraStuff)

- (int)xEdge {
    return _cartoucheGraphicFlags.xEdge;
}

- (void)setXEdge:(int)value {
    _cartoucheGraphicFlags.xEdge = value;
    [self didChange];
}

- (int)yEdge {
    return _cartoucheGraphicFlags.yEdge;
}

- (void)setYEdge:(int)value {
    _cartoucheGraphicFlags.yEdge = value;
    [self didChange];
}

- (int)cartoucheBorderType {
    return _cartoucheGraphicFlags.borderTyp;
}

- (void)setCartoucheBorderType:(int)value {
    _cartoucheGraphicFlags.borderTyp = value;
    [self didChange];
}

- (int)endCartoucheAlignment {
    return _cartoucheGraphicFlags.endCartoucheAlignment;
}

- (void)setEndCartoucheAlignment:(int)value {
    _cartoucheGraphicFlags.endCartoucheAlignment = value;
    [self didChange];
}

- (BOOL)rubricCartouche {
    return _cartoucheGraphicFlags.rubricCartouche;
}

- (void)setRubricCartouche:(BOOL)value {
    _cartoucheGraphicFlags.rubricCartouche = value;
    [self didChange];
}

@end
*/

@implementation IGGraphic (IGLineExtraStuff)

- (NSUInteger)lineType
{
    return _lineGraphicFlags.lineType;
}

- (void)setLineType:(NSUInteger)value
{
    _lineGraphicFlags.lineType = value;
    NSLog(@"IGGraphic(setLineType)->%ld", (long)_lineGraphicFlags.lineType);
    [self didChange];
}

- (float)lineWidth
{
    return _lineGraphicFlags.lineWidth;
}

- (void)setLineWidth:(float)value
{
    _lineGraphicFlags.lineWidth = value;
    NSLog(@"IGGraphic(setLineWidth)->%f", _lineGraphicFlags.lineWidth);
    [self didChange];
}

- (BOOL)rubricLine
{
    return _lineGraphicFlags.rubricLine;
}

- (void)setRubricLine:(BOOL)value
{
    _lineGraphicFlags.rubricLine = value;
    NSLog(@"IGGraphic(setRubricLine)->%i", _lineGraphicFlags.rubricLine);
    [self didChange];
}

- (NSUInteger)arrowType
{
       NSLog(@"IGGraphic(arrowType) -> %ld", (long)_lineGraphicFlags.arrowType);
    return  _lineGraphicFlags.arrowType;
}

- (void)setArrowType:(NSUInteger)value
{
       _lineGraphicFlags.arrowType = value;
    
    NSLog(@"++++++++++++++++++++++++++++++++++");
    NSLog(@"IGGraphic(setArrowType)->%ld", (long)_lineGraphicFlags.arrowType);
    NSLog(@"++++++++++++++++++++++++++++++++++");
    [self didChange];
}

- (float)arrowHead
{
    return _lineGraphicFlags.arrowHead;
}

- (void)setArrowHead:(float)value
{
    _lineGraphicFlags.arrowHead = value;
    NSLog(@"IGGraphic(setArrowHead)->%f", _lineGraphicFlags.arrowHead);
    [self didChange];
}


- (void)doReverseArrow
{
    _lineGraphicFlags.reverseArrow = (self.reverseArrow) ?  0 : 1;
    [self didChange];
    NSLog(@"-----------------------------------------------");
    NSLog(@"IGGraphic(reverseArrow) -> true?:%i", _lineGraphicFlags.reverseArrow);
    NSLog(@"-----------------------------------------------");
}

- (BOOL)reverseArrow
{
    return _lineGraphicFlags.reverseArrow;
}

- (void)setReverseArrow:(BOOL)aValue
{ //brauche ich um beim laden einer Datei die Werte herstellen zu können. Ansonsten wird im Programm selber die reverseArrow Methode benutzt
    _lineGraphicFlags.reverseArrow = aValue;
}

@end


