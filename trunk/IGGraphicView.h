//
//  IGGraphicView.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed Sep 10 2003.
//  Copyright (c) 2003 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IGDrawWindowController;
@class IGDrawDocument;
@class IGGraphic;
@class IGGlyph;

#define IG_HALF_HANDLE_WIDTH 3.0
#define IG_HANDLE_WIDTH (IG_HALF_HANDLE_WIDTH * 2.0)



enum {
    obenLinks = 0,
    obenMitte,
    obenRechts,
    mitteLinks,
    mitteMitte,
    mitteRechts,
    untenLinks,
    untenMitte,
    untenRechts,
};

@interface IGGraphicView : NSView {
    @private
    IBOutlet IGDrawWindowController *controller;
    IBOutlet NSPopUpButton *zoomButton;
    IBOutlet NSTextField *currentPageField;
    
    IGGraphic *_creatingGraphic;
    NSRect _rubberbandRect;
    NSSet *_rubberbandGraphics;
    IGGraphic *_editingGraphic;
    NSView *_editorView;
    int _pasteboardChangeCount;
    int _pasteCascadeNumber;
    NSPoint _pasteCascadeDelta;
    NSTimer *_unhideKnobsTimer;
    
    //die Zahl nach dem namen deklariert Bit Fields, dh. das ist die Anzahl Bits die in diesem member gespeichert werden
    struct __gvFlags {
        unsigned int rubberbandIsDeselecting:1;
        unsigned int initedRulers:1;
        unsigned int snapsToGrid:1;
        unsigned int showsGrid:1;
        float gridSpacing;
        unsigned int guidelineType;
        unsigned int guidelineCount;
        unsigned int knobsHidden:1;
        unsigned int _pad:27;
    } _gvFlags;
    
    //float _gridSpacing;
    NSColor *_gridColor;
    NSColor *_backgroundColor;
    
    NSRect _verticalRulerLineRect;
    NSRect _horizontalRulerLineRect;
    
    NSPoint _currentCursorPosition;
    NSRect _currentCursorRect;
    NSRect _oldCursorRect;
    unsigned int _writingDirection;
    struct __glyphFlags {
        unsigned int fontSize;
        unsigned int rubricColor;
        unsigned int mirrored;
        unsigned int angle;
    } _glyphFlags;
    
    NSColor *_cursorColor;
    NSTimer *_blinkingCursorTimer;
    
    //margin stuff
    NSColor *marginLineColor;
    NSColor *pageBackgroundColor;
    NSColor *colorBetweenPages;
    unsigned _currentPage;
    
    //bindings stuff
    NSMutableArray *_selectedGraphics;
}

//binding stuff
//- (NSIndexSet *)selectionIndexes;

// IGDrawWindowController accessors and convenience methods
- (void)setDrawWindowController:(IGDrawWindowController *)theController;
- (IGDrawWindowController *)drawWindowController;
- (IGDrawDocument *)drawDocument;
- (NSArray *)graphicsOnPage:(unsigned)pageNr;
- (NSSize)drawDocumentSize;
- (NSSize)drawDocumentPaperSize;

- (NSRect)documentRectForPageNumber:(unsigned)pageNumber;
- (NSRect)pageRectForPageNumber:(unsigned)pageNumber;
- (NSRect)pageHeaderRect;
- (NSRect)pageHeaderSmalerRect;
- (NSRect)pageFooterRect;
- (NSRect)pageFooterSmalerRect;
- (NSRect)marginRectForSide:(unsigned)side;
- (NSPrintInfo *)drawDocumentPrintInfo;
- (float)pageSeparatorHeight;
- (unsigned)currentPage;
- (void)setCurrentPage:(unsigned)newCurrentPage;

// Display invalidation and toolbar validation
- (void)invalidateGraphic:(IGGraphic *)graphic;
- (void)invalidateGraphics:(NSArray *)graphics;
- (void)redisplayTweak:(IGGraphic *)graphic;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;

// Selection primitives
- (NSMutableArray *)selectedGraphics;
- (NSArray *)cartoucheSelectedGraphics;

- (int)selectedGraphicCountOfClass:(Class)aClass;
- (IGGraphic *)theOnlySelectedGraphicOfClass:(Class)aClass;
- (NSArray *)orderedSelectedGraphics;
- (BOOL)graphicIsSelected:(IGGraphic *)graphic;
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;

- (void)willChangeSomething;
- (void)didChangeSomething;

// Managing editoring graphics
- (void)setEditingGraphic:(IGGraphic *)graphic editorView:(NSView *)editorView;
- (IGGraphic *)editingGraphic;
- (NSView *)editorView;
- (void)startEditingGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)event;
- (void)endEditing;

// Geometry calculations
- (IGGraphic *)graphicUnderPoint:(NSPoint)point onPage:(unsigned)pageNr;
- (NSSet *)graphicsIntersectingRect:(NSRect)rect onPage:(unsigned)pageNr;
- (BOOL)cursorUnderPoint:(NSPoint)point;

// Drawing and mouse tracking
- (void)drawRect:(NSRect)rect;

- (void)beginEchoingMoveToRulers:(NSRect)echoRect;
- (void)continueEchoingMoveToRulers:(NSRect)echoRect;
- (void)stopEchoingMoveToRulers;


// Creating Graphics
- (void)createGraphicOfClass:(Class)theClass withEvent:(NSEvent *)theEvent;
- (void)createGraphicOfClassGlyph:(unichar)glyphChar WithFont:(NSString *)fontName;
- (void)createGraphicsOfClassGlyphFromDic:(NSDictionary *)glyphGroupDic;
- (IGGraphic *)creatingGraphic;


- (void)trackKnob:(int)knob ofGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)theEvent;
- (void)rubberbandSelectWithEvent:(NSEvent *)theEvent;
- (void)moveCursorWithEvent:(NSEvent *)theEvent;
- (void)moveSelectedGraphicsWithEvent:(NSEvent *)theEvent;
- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

// Currsor stuff
- (NSPoint)currentCursorPosition;
- (void)setCurrentCursorPosition:(NSPoint)position;
- (void)displayCursorPos;
- (void)blinkingCursorTimer:(NSTimer *)aTimer;
- (void)drawCursor;
- (void)invalidateBlinkingCursorTimer;
//new row
-(IBAction)newRowButtonAction:(id)sender; 

// Dragging
- (unsigned int)dragOperationForDraggingInfo:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;

// Ruler support
- (void)updateRulers;
- (BOOL)rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker;
- (float)rulerView:(NSRulerView *)ruler willMoveMarker:(NSRulerMarker *)marker toLocation:(float)location;
- (void)rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker;
- (BOOL)rulerView:(NSRulerView *)ruler shouldRemoveMarker:(NSRulerMarker *)marker;

// Action methods and other UI entry points
- (void)changeColor:(id)sender;

- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;

- (IBAction)delete:(id)sender;
- (IBAction)bringToFront:(id)sender;
- (IBAction)sendToBack:(id)sender;
- (IBAction)alignLeftEdges:(id)sender;
- (IBAction)alignRightEdges:(id)sender;
- (IBAction)alignTopEdges:(id)sender;
- (IBAction)alignBottomEdges:(id)sender;
- (IBAction)alignHorizontalCenters:(id)sender;
- (IBAction)alignVerticalCenters:(id)sender;
- (IBAction)makeSameWidth:(id)sender;
- (IBAction)makeSameHeight:(id)sender;
- (IBAction)makeNaturalSize:(id)sender;
- (IBAction)snapsToGridMenuAction:(id)sender;
- (IBAction)showsGridMenuAction:(id)sender;
- (IBAction)gridSelectedGraphicsAction:(id)sender;
- (IBAction)writeGlyphGroupAction:(id)sender;

// Grid and Guidelines settings
- (BOOL)snapsToGrid;
- (void)setSnapsToGrid:(BOOL)flag;
- (BOOL)showsGrid;
- (void)setShowsGrid:(BOOL)flag;
- (float)gridSpacing;
- (void)setGridSpacing:(float)spacing;
- (NSColor *)gridColor;
- (void)setGridColor:(NSColor *)color;

- (int)guidelineType;
- (void)setGuidelineType:(int)value;

- (int)guidelineCount;
- (void)setGuidelineCount:(int)value;

// Multiple page view stuff
- (void)setMarginLineColor:(NSColor *)color;
- (NSColor *)marginLineColor;
- (void)setPageBackgroundColor:(NSColor *)color;
- (NSColor *)pageBackgroundColor;

- (int)pageCount;
- (IBAction)pageDown:(id)sender;
- (IBAction)pageUp:(id)sender;
- (IBAction)insertPageBeforeThisOne:(id)sender;
- (IBAction)appendPageToEnd:(id)sender;
- (IBAction)deleteCurrentPage:(id)sender;
- (IBAction)goToPage:(id)sender;
- (void)updateCurrentPageField;

@end

extern NSString *IGGraphicViewSelectionDidChangeNotification;
