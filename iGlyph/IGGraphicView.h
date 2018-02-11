//
//  IGGraphicView.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed Sep 10 2003.
//  Copyright (c) 2003 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IGDocumentWindowController;
@class IGDrawDocument;
@class IGGraphic;
@class IGGlyph;

#define IG_HALF_HANDLE_WIDTH 3.0
#define IG_HANDLE_WIDTH (IG_HALF_HANDLE_WIDTH * 2.0)


// FIXME: modernize
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
    
    NSPoint currentCursorPosition;
    NSRect currentCursorRect;
    NSRect oldCursorRect;
    NSUInteger currentPage;
    
    @private
    IBOutlet IGDocumentWindowController *controller;
    IBOutlet NSPopUpButton *zoomButton;
    IBOutlet NSTextField *currentPageField;
    
    IGGraphic *_creatingGraphic;
    NSRect _rubberbandRect;
    NSSet *_rubberbandGraphics;
    IGGraphic *_editingGraphic;
    NSView *_editorView;
    NSInteger _pasteboardChangeCount;
    NSInteger _pasteCascadeNumber;
    NSPoint _pasteCascadeDelta;
    NSTimer *_unhideKnobsTimer;
    
    //die Zahl nach dem namen deklariert Bit Fields, dh. das ist die Anzahl Bits die in diesem member gespeichert werden
    struct __gvFlags {
        NSUInteger rubberbandIsDeselecting:1;
        NSUInteger initedRulers:1;
        NSUInteger snapsToGrid:1;
        NSUInteger showsGrid:1;
        float gridSpacing;
        NSUInteger guidelineType;
        NSUInteger guidelineCount;
        NSUInteger knobsHidden:1;
        NSUInteger _pad:27;
    } _gvFlags;
    
    //float _gridSpacing;
    NSColor *_gridColor;
    NSColor *_backgroundColor;
    
    NSRect _verticalRulerLineRect;
    NSRect _horizontalRulerLineRect;
    
    
    NSUInteger _writingDirection;
    struct __glyphFlags {
        NSUInteger fontSize;
        NSUInteger rubricColor;
        NSUInteger mirrored;
        NSUInteger angle;
    } _glyphFlags;
    
    NSColor *_cursorColor;
    NSTimer *_blinkingCursorTimer;
    
    //margin stuff
    NSColor *marginLineColor;
    NSColor *pageBackgroundColor;
    NSColor *colorBetweenPages;
    
    
    //bindings stuff (wurde ins modell verschoben)
    NSMutableArray *_selectedGraphics;
}

  @property NSPoint currentCursorPosition;
  @property NSRect currentCursorRect;
  @property NSRect oldCursorRect;
  @property NSUInteger currentPage;


// IGDrawWindowController accessors and convenience methods
@property (NS_NONATOMIC_IOSONLY, strong) IGDocumentWindowController *drawWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawDocument *drawDocument;
- (NSArray *)graphicsOnPage:(NSUInteger)pageNr;
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize drawDocumentSize;
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize drawDocumentPaperSize;

- (NSRect)documentRectForPageNumber:(NSUInteger)pageNumber;
- (NSRect)pageRectForPageNumber:(NSUInteger)pageNumber;
@property (NS_NONATOMIC_IOSONLY, readonly) NSRect pageHeaderRect;
@property (NS_NONATOMIC_IOSONLY, readonly) NSRect pageHeaderSmalerRect;
@property (NS_NONATOMIC_IOSONLY, readonly) NSRect pageFooterRect;
@property (NS_NONATOMIC_IOSONLY, readonly) NSRect pageFooterSmalerRect;
- (NSRect)marginRectForSide:(NSUInteger)side;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSPrintInfo *drawDocumentPrintInfo;
@property (NS_NONATOMIC_IOSONLY, readonly) float pageSeparatorHeight;

// Display invalidation and toolbar validation
- (void)invalidateGraphic:(IGGraphic *)graphic;
- (void)invalidateGraphics:(NSArray *)graphics;
- (void)redisplayTweak:(IGGraphic *)graphic;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;

// Selection primitives
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *selectedGraphics;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *cartoucheSelectedGraphics;

- (int)selectedGraphicCountOfClass:(Class)aClass;
- (IGGraphic *)theOnlySelectedGraphicOfClass:(Class)aClass;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *orderedSelectedGraphics;
- (BOOL)graphicIsSelected:(IGGraphic *)graphic;
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;

- (void)willChangeSomething;
- (void)didChangeSomething;

// Managing editoring graphics
- (void)setEditingGraphic:(IGGraphic *)graphic editorView:(NSView *)editorView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphic *editingGraphic;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *editorView;
- (void)startEditingGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)event;
- (void)endEditing;

// Geometry calculations
- (IGGraphic *)graphicUnderPoint:(NSPoint)point onPage:(NSUInteger)pageNr;
- (NSSet *)graphicsIntersectingRect:(NSRect)rect onPage:(NSUInteger)pageNr;
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
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphic *creatingGraphic;


- (void)trackKnob:(int)knob ofGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)theEvent;
- (void)rubberbandSelectWithEvent:(NSEvent *)theEvent;
- (void)moveCursorWithEvent:(NSEvent *)theEvent;
- (void)moveSelectedGraphicsWithEvent:(NSEvent *)theEvent;
- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

// Currsor stuff
- (void)setCurrentCursorPosition:(NSPoint)position;
- (void)displayCursorPos;
- (void)blinkingCursorTimer:(NSTimer *)aTimer;
- (void)drawCursor;
- (void)invalidateBlinkingCursorTimer;
//new row
-(IBAction)newRowButtonAction:(id)sender; 

// Dragging
- (NSUInteger)dragOperationForDraggingInfo:(id <NSDraggingInfo>)sender;
- (NSUInteger)draggingEntered:(id <NSDraggingInfo>)sender;
- (NSUInteger)draggingUpdated:(id <NSDraggingInfo>)sender;
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
@property (NS_NONATOMIC_IOSONLY) BOOL snapsToGrid;
@property (NS_NONATOMIC_IOSONLY) BOOL showsGrid;
@property (NS_NONATOMIC_IOSONLY) float gridSpacing;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *gridColor;

@property (NS_NONATOMIC_IOSONLY) NSInteger guidelineType;
@property (NS_NONATOMIC_IOSONLY) NSInteger guidelineCount;

// Multiple page view stuff
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *marginLineColor;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *pageBackgroundColor;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger pageCount;
- (IBAction)pageDown:(id)sender;
- (IBAction)pageUp:(id)sender;
- (IBAction)insertPageBeforeThisOne:(id)sender;
- (IBAction)appendPageToEnd:(id)sender;
- (IBAction)deleteCurrentPage:(id)sender;
- (IBAction)goToPage:(id)sender;
- (void)updateCurrentPageField;

@end

extern NSString *IGGraphicViewSelectionDidChangeNotification;
