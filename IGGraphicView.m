//
//  IGMainView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed Sep 10 2003.
//  Copyright (c) 2003 Ivan Subotic. All rights reserved.
//

#import "IGFontData.h"
#import "IGGraphicView.h"
#import "IGlyphDelegate.h"
#import "IGDrawWindowController.h"
#import "IGDrawDocument.h"
#import "IGGraphic.h"
#import "IGFoundationExtras.h"
#import "ObjectsController.h"
#import "IGImage.h"
#import "PreferencesController.h"
#import "WritingDirectionController.h"
#import "FormatGlyphController.h"
#import "IGGlyph.h"
#import "IGCartouche.h"
#import "CartoucheController.h"
#import "IGLine.h"
#import "LineController.h"
#import "IGTextArea.h"
#import "IGInspectorController.h"

enum {
  IGLeftToRight0 = 0,
  IGRightToLeft0Mirrored,
  IGUpToDown90Mirrored,
  IGUpToDown270,
  IGUpToDown0,
  IGUpToDown0Mirrored,
};


NSString *IGGraphicViewSelectionDidChangeNotification = @"IGGraphicViewSelectionDidChange";

@implementation IGGraphicView

static float IGDefaultPasteCascadeDelta = 10.0;


  @dynamic currentCursorPosition;
  @synthesize currentCursorRect;
  @synthesize oldCursorRect;
  @synthesize currentPage;


- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NSMutableArray *dragTypes = [NSMutableArray arrayWithObjects:NSColorPboardType, NSFilenamesPboardType, nil];
    [dragTypes addObjectsFromArray:[NSImage imagePasteboardTypes]];
    [self registerForDraggedTypes:dragTypes];
    _selectedGraphics = [[NSMutableArray allocWithZone:[self zone]] init];
    _creatingGraphic = nil;
    _rubberbandRect = NSZeroRect;
    _rubberbandGraphics = nil;
    _gvFlags.rubberbandIsDeselecting = NO;
    _gvFlags.initedRulers = NO;
    _editingGraphic = nil;
    _editorView = nil;
    _pasteboardChangeCount = -1;
    _pasteCascadeNumber = 0;
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
    _gvFlags.knobsHidden = NO;
    _unhideKnobsTimer = nil;
    _writingDirection = IGLeftToRight0;
    _glyphFlags.fontSize = 48;
    _glyphFlags.rubricColor = NO;
    _glyphFlags.mirrored = NO;
    _glyphFlags.angle = 0;
    self.currentCursorRect = NSMakeRect(self.currentCursorPosition.x - IG_HALF_HANDLE_WIDTH, self.currentCursorPosition.y - IG_HALF_HANDLE_WIDTH, IG_HANDLE_WIDTH, IG_HANDLE_WIDTH);
    self.oldCursorRect = self.currentCursorRect;
    _cursorColor = [NSColor whiteColor];
    _blinkingCursorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(blinkingCursorTimer:) userInfo:nil repeats:YES];
    [self setMarginLineColor:[NSColor lightGrayColor]];
    colorBetweenPages = [NSColor darkGrayColor];
    self.currentPage = 1;
    
    [self setShowsGrid:[[PreferencesController sharedPreferencesController] showsGrid]];
    _gvFlags.showsGrid = NO;
    _gvFlags.snapsToGrid = NO;
    _gvFlags.gridSpacing = 8.0;
    _gridColor = [[NSColor lightGrayColor] retain];
    
    [self setPageBackgroundColor:[NSColor whiteColor]];
    
    NSLog(@"IGGraphicView(init)");
  }
  
  return self;    
}

- (void)dealloc {
  [self endEditing];
  [super dealloc];
}

// ===========================================================================
#pragma mark -
#pragma mark bindings stuff
// =========================== bindings stuff ================================
/*
- (NSIndexSet *)selectionIndexes
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[_selectedGraphics count])];
}
*/

// ===========================================================================
#pragma mark -
#pragma mark accessors and convenience methods
// ====== IGDrawWindowController accessors and convenience methods ===========

- (void)setDrawWindowController:(IGDrawWindowController *)theController {
  controller = theController;
}

- (IGDrawWindowController *)drawWindowController {
  return controller;
}

- (IGDrawDocument *)drawDocument {
  return [self drawWindowController].document;
}

- (NSArray *)graphicsOnPage:(unsigned)pageNr {
  return [[self drawWindowController].document graphicsOnPage:pageNr];
}

- (NSSize)drawDocumentSize { //paperSize minus margins
  return [[self drawDocument] documentSize];
}

- (NSSize)drawDocumentPaperSize {
  return [[self drawDocument] paperSize];
}

- (NSRect)documentRectForPageNumber:(unsigned)pageNumber {    /* First page is page 0, of course! */

NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
NSRect rect = [self pageRectForPageNumber:pageNumber];
rect.origin.x += printInfo.leftMargin;
rect.origin.y += printInfo.topMargin;
rect.size = [self drawDocumentSize];
return rect;
}

- (NSRect)pageRectForPageNumber:(unsigned)pageNumber {
  NSRect rect;
  rect.size = [self drawDocumentPaperSize];
  //rect.origin = [self frame].origin;
  rect.origin = NSMakePoint(0, 0);
  rect.origin.y += ((rect.size.height + [self pageSeparatorHeight]) * pageNumber);
  return rect;
}

- (NSRect)pageHeaderRect {
  NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
  NSRect rect = NSZeroRect;
  rect.size.width = printInfo.paperSize.width;
  rect.size.height = printInfo.topMargin;
  return rect;
}

- (NSRect)pageHeaderSmalerRect {
  NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
  NSRect rect = NSZeroRect;
  rect.size.width = printInfo.paperSize.width;
  rect.size.height = printInfo.topMargin - 5;
  return rect;
}

- (NSRect)pageFooterRect {
  NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
  NSRect rect = NSZeroRect;
  rect.size.width = printInfo.paperSize.width;
  rect.size.height = printInfo.bottomMargin;
  rect.origin.y = printInfo.paperSize.height - rect.size.height;
  return rect;
}

- (NSRect)pageFooterSmalerRect {
  NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
  NSRect rect = NSZeroRect;
  rect.size.width = printInfo.paperSize.width;
  rect.size.height = printInfo.bottomMargin;
  rect.origin.y = printInfo.paperSize.height - rect.size.height + 5;
  return rect;
}


- (NSRect)marginRectForSide:(unsigned)side { //leftMarginRect = 0, rightMarginRect = 1, bottomMarginRect = 2
  NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
  NSRect rect = NSZeroRect;
  if (side == 0) {
    rect.origin.y += printInfo.topMargin;
    rect.size.width = printInfo.leftMargin;
    rect.size.height = [self drawDocumentSize].height;
    return rect;
  } else if (side == 1) {
    rect.origin.x = printInfo.paperSize.width - printInfo.rightMargin;
    rect.origin.y += printInfo.topMargin;
    rect.size.width = printInfo.rightMargin;
    rect.size.height = [self drawDocumentSize].height;
    return rect;
  } else if (side == 2) {
    rect.origin.y = printInfo.paperSize.height - printInfo.bottomMargin;
    rect.size.width = printInfo.paperSize.width;
    rect.size.height = printInfo.bottomMargin;
    return rect;
  }
  return rect; //sollte nie auftreten
}

- (float)pageSeparatorHeight {
  return 0.0;
}

- (NSPrintInfo *)drawDocumentPrintInfo {
  return [self drawDocument].printInfo;
}

- (int)tag {
  return 12345;
}

// ===========================================================================
#pragma mark -
#pragma mark display invalidation and toolbar validation
// ======================= Display invalidation ==============================

- (void)invalidateGraphic:(IGGraphic *)graphic {
  NSLog(@"IGGraphicView(invalidateGraphic)");
  [self setNeedsDisplayInRect:[graphic drawingBounds]];
}

- (void)invalidateGraphics:(NSArray *)graphics {
  NSLog(@"IGGraphicView(invalidateGraphics)");
  for (IGGraphic *oneGraphic in graphics) {
    [self invalidateGraphic: oneGraphic];
  }
}

- (void)redisplayTweak:(IGGraphic *)graphic {
  NSLog(@"IGGraphicView(redisplayTweak)");
  //[self display];
  [self displayRect:NSInsetRect([graphic drawingBounds], -3, -3)];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{ // works just like menu item validation, but for the toolbar.
  int tag = toolbarItem.tag;
  if (tag == 31) { //BackToFront
                   //NSLog(@"tag 31 validate");
    if ([self selectedGraphics].count == 0) {
      return NO;
    } else if ([self selectedGraphics].count == 1) {
      if ([self selectedGraphics][0] == [self graphicsOnPage:self.currentPage][0]) {
        return NO;
      } else {
        return YES;
      }
    }
  } else if (tag == 32) { //FrontToBack
                          //NSLog(@"tag 32 validate");
    if ([self selectedGraphics].count == 0) {
      return NO;
    } else if ([self selectedGraphics].count == 1) {
      if ([self selectedGraphics][0] == [self graphicsOnPage:self.currentPage].lastObject) {
        return NO;
      } else {
        return YES;
      }
    }
  }
  return YES; // we'll assume anything else is OK, which is the default
}


// ===========================================================================
#pragma mark -
#pragma mark selection primitives
// ======================= Selection primitives ==============================

- (NSMutableArray *)selectedGraphics
{
  return [[self drawWindowController] selectedGraphics];
}

- (NSArray *)cartoucheSelectedGraphics
{
  Class filterClass = [IGCartouche class];
  NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[self selectedGraphics].count];
  NSEnumerator *objectsEnumerator = [[self selectedGraphics] objectEnumerator];
  id item;
  
  while (item = [objectsEnumerator nextObject]) {
    if ([item class] == filterClass) {
      [filteredObjects addObject:item];
      NSLog(@"IGGraphicView(cartoucheSelectedGraphics) -> xEdge: %@", [item valueForKey:@"xEdge"]);
    }
  }
  return [filteredObjects retain];
}


- (int)selectedGraphicCountOfClass:(Class)aClass {
  
  NSEnumerator *enumerator = [[self selectedGraphics] objectEnumerator];
  id anObject;
  int count = 0;
  
  while (anObject = [enumerator nextObject]) {
    if ([anObject class] == aClass) count++;
  }
  
  return count;
}

- (IGGraphic *)theOnlySelectedGraphicOfClass:(Class)aClass {
  
  if ([self selectedGraphicCountOfClass:[IGGlyph class]] == 1) {
    NSEnumerator *enumerator = [[self selectedGraphics] objectEnumerator];
    IGGraphic *theGraphic;
    id anObject;
    
    while (anObject = [enumerator nextObject]) {
      if ([anObject class] == aClass) {
        theGraphic = anObject;
        NSLog(@"IGGraphicView(theOnlySelectedGraphicOfClass) -> glyphe returned");
        return theGraphic;
      }
    }
  }
  return nil;
}

static int IG_orderGraphicsFrontToBack(id graphic1, id graphic2, void *gArray) {
  NSArray *graphics = (NSArray *)gArray;
  unsigned index1, index2;
  
  index1 = [graphics indexOfObjectIdenticalTo:graphic1];
  index2 = [graphics indexOfObjectIdenticalTo:graphic2];
  if (index1 == index2) {
    return NSOrderedSame;
  } else if (index1 < index2) {
    return NSOrderedAscending;
  } else {
    return NSOrderedDescending;
  }
}

- (NSArray *)orderedSelectedGraphics  {
  //NSAssert([[self selectedGraphics] sortedArrayUsingFunction:IG_orderGraphicsFrontToBack context:[self graphicsOnPage:self.currentPage]], @"orderedSelectedGraphics: probleme eine geordneten Array mit den Graphics zur zu geben");
  return [[self selectedGraphics] sortedArrayUsingFunction:IG_orderGraphicsFrontToBack context:[self graphicsOnPage:self.currentPage]];
}

- (BOOL)graphicIsSelected:(IGGraphic *)graphic {
  return (([[self selectedGraphics] indexOfObjectIdenticalTo:graphic] == NSNotFound) ? NO : YES);
}

- (void)selectGraphic:(IGGraphic *)graphic
{
  NSLog(@"IGGraphicView(selectGraphic)");
  [[self drawWindowController] selectGraphic: graphic];
  
  /**
  unsigned curIndex = [_selectedGraphics indexOfObjectIdenticalTo:graphic];
  if (curIndex == NSNotFound) {
    [[[self undoManager] prepareWithInvocationTarget:self] deselectGraphic:graphic];
    [[[self drawDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
    
    [self willChangeSomething]; //KVO manual notification
    [_selectedGraphics addObject:graphic];
    [self didChangeSomething]; //KVO manual notification
        
    [self invalidateGraphic:graphic];
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
    [[NSNotificationCenter defaultCenter] postNotificationName:IGGraphicViewSelectionDidChangeNotification object:self];
    [self updateRulers];
  }
  **/
}

- (void)deselectGraphic:(IGGraphic *)graphic
{
  NSLog(@"IGGraphicView(deselectGraphic)");
  [[self drawWindowController] deselectGraphic:graphic];
  
  /**
  unsigned curIndex = [_selectedGraphics indexOfObjectIdenticalTo:graphic];
  if (curIndex != NSNotFound) {
    [[[self undoManager] prepareWithInvocationTarget:self] selectGraphic:graphic];
    [[[self drawDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
    
    [self willChangeSomething]; //KVO manual notification
    [_selectedGraphics removeObjectAtIndex:curIndex];
    [self didChangeSomething]; //KVO manual notification
        
    [self invalidateGraphic:graphic];
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
    [[NSNotificationCenter defaultCenter] postNotificationName:IGGraphicViewSelectionDidChangeNotification object:self];
    [self updateRulers];
  }
  **/
}

- (void)clearSelection
{  
  NSLog(@"IGGraphicView(clearSelection)");
  [[self drawWindowController] clearSelection];
  
  /**  
  int i, c = [_selectedGraphics count];
  id curGraphic;
  
  if (c > 0) {
    for (i=0; i<c; i++) {
      curGraphic = [_selectedGraphics objectAtIndex:i];
      [[[self undoManager] prepareWithInvocationTarget:self] selectGraphic:curGraphic];
      [self invalidateGraphic:curGraphic];
    }
    [[[self drawDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
    
    [self willChangeSomething]; //KVO manual notification
    [_selectedGraphics removeAllObjects];
    [self didChangeSomething]; //KVO manual notification
    
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
    [[NSNotificationCenter defaultCenter] postNotificationName:IGGraphicViewSelectionDidChangeNotification object:self];
    [self updateRulers];
  }
  **/
}

- (void)willChangeSomething
{
  [self willChangeValueForKey:@"cartoucheSelectedGraphics"]; //KVO manual notification
  [self willChangeValueForKey:@"selectedGraphics"]; //KVO manual notification
}

- (void)didChangeSomething
{
  [self didChangeValueForKey:@"selectedGraphics"]; //KVO manual notification
  [self didChangeValueForKey:@"cartoucheSelectedGraphics"];
}

// ===========================================================================
#pragma mark -
#pragma mark editing
// ================================ Editing ==================================

- (void)setEditingGraphic:(IGGraphic *)graphic editorView:(NSView *)editorView {
  // Called by a IGGraphic that is told to start editing.  IGGraphicView doesn't do anything with editorView, just remembers it.
  _editingGraphic = graphic;
  _editorView = editorView;
}

- (IGGraphic *)editingGraphic {
  return _editingGraphic;
}

- (NSView *)editorView {
  return _editorView;
}

- (void)startEditingGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)event {
  [graphic startEditingWithEvent:event inView:self];
}

- (void)endEditing {
  if (_editingGraphic) {
    [_editingGraphic endEditingInView:self];
    _editingGraphic = nil;
    _editorView = nil;
  }
}

// ===========================================================================
#pragma mark -
#pragma mark geometry calculations
// ======================= Geometry calculations =============================

- (IGGraphic *)graphicUnderPoint:(NSPoint)point onPage:(unsigned)pageNr {
  NSArray *graphics = [self graphicsOnPage:pageNr];
  unsigned i, c = graphics.count;
  IGGraphic *curGraphic = nil;
  
  for (i=0; i<c; i++) {
    curGraphic = graphics[i];
    if ([self mouse:point inRect:[curGraphic drawingBounds]] && [curGraphic hitTest:point isSelected:[self graphicIsSelected:curGraphic]]) {
      break;
    }
  }
  if (i < c) {
    return curGraphic;
  } else {
    return nil;
  }
}

- (NSSet *)graphicsIntersectingRect:(NSRect)rect onPage:(unsigned)pageNr {
  NSArray *graphics = [self graphicsOnPage:pageNr];
  NSArray *headerGraphics = [self graphicsOnPage:0];
  unsigned i, c = graphics.count;
  unsigned j, k = headerGraphics.count;
  NSMutableSet *result = [NSMutableSet set];
  IGGraphic *curGraphic;
  
  for (i = 0; i < c; i++) {
    curGraphic = graphics[i];
    if (NSIntersectsRect(rect, [curGraphic drawingBounds])) {
      [result addObject:curGraphic];
    }
  }
  //ich will ja auch die sachen im header auswählen können
  for (j = 0; j < k; j++) {
    curGraphic = headerGraphics[j];
    if (NSIntersectsRect(rect, [curGraphic drawingBounds])) {
      [result addObject:curGraphic];
    }
  }
  return result;
}

- (BOOL)cursorUnderPoint:(NSPoint)point {
  NSRect cursorRect = NSMakeRect(self.currentCursorPosition.x - IG_HALF_HANDLE_WIDTH, self.currentCursorPosition.y - IG_HALF_HANDLE_WIDTH, IG_HANDLE_WIDTH, IG_HANDLE_WIDTH);
  return NSMouseInRect(point, cursorRect, YES);
}

// ===========================================================================
#pragma mark -
#pragma mark drawing stuff
// ============================== Drawing stuff ==============================

- (BOOL)isFlipped {
  return YES;
}

- (BOOL)isOpaque {
  return YES;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)becomeFirstResponder {
  [self updateRulers];
  return YES;
}

- (BOOL)resignFirstResponder {
  return YES;
}

/*!
@method     drawRect
 @abstract   (brief description)
 @discussion (comprehensive description)
 */

- (void)drawRect:(NSRect)rect
{
  IGDrawWindowController *drawWindowController = [self drawWindowController];
  NSArray *graphics;
  unsigned i, firstPage, lastPage;
  IGGraphic *curGraphic;
  BOOL isSelected;
  NSRect drawingBounds;
  NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
  
  int twoPageView = 0;
  
  if (twoPageView) {
    firstPage = 0;
    lastPage = 2;
  } else {
    firstPage = 0;
    lastPage = 1;
  }
  
  //NSLog(@"IGGraphicView(drawRect) -> rect bounds x: %f, y: %f, w: %f, h: %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  
  
  [pageBackgroundColor set];
  NSRectFill(rect);
  
  
  if ([self showsGrid]) {
    //Testing the Grid Image
    NSImage *gridPatternImage = [[NSImage alloc] initWithSize:NSMakeSize(24.0, 24.0)];
    
    [gridPatternImage lockFocus];
    
    [pageBackgroundColor set];
    NSRectFill(NSMakeRect(0, 0, 24, 24));
    
    [[NSColor grayColor] set];
    NSRectFill(NSMakeRect(12, 12, 1, 1));
    //[[NSBezierPath bezierPathWithRect: NSMakeRect(1, 1, 2, 2)] stroke];
    //[NSBezierPath strokeLineFromPoint: point1 toPoint: point2];
    //[[NSBezierPath bezierPathWithOvalInRect: NSMakeRect(x, y, width, height)] fill];
    [gridPatternImage unlockFocus];
    
    [currentContext saveGraphicsState];
    currentContext.patternPhase = NSMakePoint(0, drawWindowController.window.frame.size.height);
    [[NSColor colorWithPatternImage: gridPatternImage] set];
    NSRectFill(rect);
    [currentContext restoreGraphicsState];
    
    //IGDrawGridWithSettingsInRect([self gridSpacing], [self gridColor], rect, NSZeroPoint);
  }
  
  
  //margin line
  [marginLineColor set];
  for (i = firstPage; i <= lastPage; i++) {
    NSRect docRect = NSInsetRect([self documentRectForPageNumber:i], -1.0, -1.0);
    NSFrameRectWithWidth(docRect, 0.0);
  }
  
  //farbe zwischen den Seiten
  [colorBetweenPages set];
  for (i = firstPage; i <= lastPage; i++) {
    NSRect pageRect = [self pageRectForPageNumber:i];
    NSRectFill (NSMakeRect(pageRect.origin.x, NSMaxY(pageRect), pageRect.size.width, [self pageSeparatorHeight]));
  }
  
  [[NSColor whiteColor] set];
  
  //versuch doppelseiten zu erstellen
  //wenn ja dann ist es eine doppelseite
  //header
  if (twoPageView) {
    graphics = [drawWindowController.document graphicsOnPage:0];
    i = graphics.count;
    while (i-- > 0) {
      curGraphic = graphics[i];
      drawingBounds = [curGraphic drawingBounds];
      if (NSIntersectsRect(rect, drawingBounds)) {
        if (!_gvFlags.knobsHidden && (curGraphic != _editingGraphic)) {
          // Figure out if we should draw selected.
          isSelected = [self graphicIsSelected:curGraphic];
          // Account for any current rubberband selection state
          if (_rubberbandGraphics && (isSelected == _gvFlags.rubberbandIsDeselecting) && [_rubberbandGraphics containsObject:curGraphic]) {
            isSelected = (isSelected ? NO : YES);
          }
        } else {
          // Do not draw handles on graphics that are editing.
          isSelected = NO;
        }
        //damit die glyphe auch als selected gezeichnet wird wenn sie es auch ist....könnte probleme geben mit dem code vorher
        isSelected = [self graphicIsSelected:curGraphic];
        [currentContext saveGraphicsState];
        [NSBezierPath clipRect:drawingBounds];
        [curGraphic drawInView:self isSelected:isSelected]; //hiermit wird die grafik gezeichnet, bzw. ihre zeichenroutine aufgerufen
        [currentContext restoreGraphicsState];
      }
    }
    
    
    
    
  } else {
    //header
    graphics = [drawWindowController.document graphicsOnPage:0];
    i = graphics.count;
    while (i-- > 0) {
      curGraphic = graphics[i];
      drawingBounds = [curGraphic drawingBounds];
      if (NSIntersectsRect(rect, drawingBounds)) {
        if (!_gvFlags.knobsHidden && (curGraphic != _editingGraphic)) {
          // Figure out if we should draw selected.
          isSelected = [self graphicIsSelected:curGraphic];
          // Account for any current rubberband selection state
          if (_rubberbandGraphics && (isSelected == _gvFlags.rubberbandIsDeselecting) && [_rubberbandGraphics containsObject:curGraphic]) {
            isSelected = (isSelected ? NO : YES);
          }
        } else {
          // Do not draw handles on graphics that are editing.
          isSelected = NO;
        }
        //damit die glyphe auch als selected gezeichnet wird wenn sie es auch ist....könnte probleme geben mit dem code vorher
        isSelected = [self graphicIsSelected:curGraphic];
        [currentContext saveGraphicsState];
        [NSBezierPath clipRect:drawingBounds];
        [curGraphic drawInView:self isSelected:isSelected]; //hiermit wird die grafik gezeichnet, bzw. ihre zeichenroutine aufgerufen
        [currentContext restoreGraphicsState];
      }
    }
  }
  
  //body
  graphics = [drawWindowController.document graphicsOnPage:self.currentPage];
  i = graphics.count;
  while (i-- > 0) {
    curGraphic = graphics[i];
    drawingBounds = [curGraphic drawingBounds];
    if (NSIntersectsRect(rect, drawingBounds)) {
      if (!_gvFlags.knobsHidden && (curGraphic != _editingGraphic)) {
        // Figure out if we should draw selected.
        isSelected = [self graphicIsSelected:curGraphic];
        // Account for any current rubberband selection state
        if (_rubberbandGraphics && (isSelected == _gvFlags.rubberbandIsDeselecting) && [_rubberbandGraphics containsObject:curGraphic]) {
          isSelected = (isSelected ? NO : YES);
        }
      } else {
        // Do not draw handles on graphics that are editing.
        isSelected = NO;
      }
      //damit die glyphe auch als selected gezeichnet wird wenn sie es auch ist....könnte probleme geben mit dem code vorher
      isSelected = [self graphicIsSelected:curGraphic];
      [currentContext saveGraphicsState];
      [NSBezierPath clipRect:drawingBounds];
      [curGraphic drawInView:self isSelected:isSelected]; //hiermit wird die grafik gezeichnet, bzw. ihre zeichenroutine aufgerufen
      [currentContext restoreGraphicsState];
    }
  }
  
  //----------------anfang pagenumbers----------------        
  //Page Numbers
  //nicht vergessen die printversion auch anzupassen!!!!!!
  if ([[self drawDocument] showPageNumbers]) {
    NSPrintInfo *printInfo = [self drawDocumentPrintInfo]; 
    
    
    NSMutableDictionary *pageNrAttribsDict = [NSMutableDictionary dictionary];
    NSMutableString *pnMutableString = [[NSMutableString alloc] init];
    
    NSString *pnFontName = [[self drawDocument] pageNumberFont];
    float pnFontSize = [[self drawDocument] pageNumberSize];
    int pnStyle = [[self drawDocument] pageNumberStyle];
    NSMutableArray *pnFormatArr = [[self drawDocument] pageNumberFormatArr];
    int initialPageNumber = [[self drawDocument] initialPageNr]; //die Zahl ab welcher gezählt werden soll
    int firstPageNumberToShow = [[self drawDocument] firstPageNumberToShow]; //die erste Seite ab wann angezeigt werden soll
    
    int pageNrAlignment = [[self drawDocument] pageNrAlignment];
    int pageNrPosition = [[self drawDocument] pageNrPosition];
    
    signed int pnNumberToShow = self.currentPage - firstPageNumberToShow + initialPageNumber;
    
    //NSLog(@"IGGraphicView(drawRect) -> pnStyle= %i", pnStyle);
    //Fontname and Size... fehlt nur noch Style
    NSFont *pnFont = [NSFont fontWithName:pnFontName size:pnFontSize];
    if (pnStyle == 1) {
      //NSLog(@"IGGraphicView(drawRect) -> BoldFontFace");
      [pnFont autorelease];
      pnFont = [[NSFontManager sharedFontManager] convertFont:pnFont toHaveTrait:NSBoldFontMask];
    } else if (pnStyle == 2) {
      //NSLog(@"IGGraphicView(drawRect) -> ItalicFontFace");
      [pnFont autorelease];
      pnFont = [[NSFontManager sharedFontManager] convertFont:pnFont toHaveTrait:NSItalicFontMask];
    }
    
    if (pnFont == nil) {
      pnFont = [NSFont fontWithName:@"Arial" size:pnFontSize];
    }
    pageNrAttribsDict[NSFontAttributeName] = pnFont;
    
    
    //links von der Seitenzahl
    if (![pnFormatArr[0] isEqualTo:@""]) {
      [pnMutableString insertString:pnFormatArr[0] atIndex:0];
    }
    //die Seitenzahl
    [pnMutableString appendString:[NSString stringWithFormat:@"%i", pnNumberToShow]];
    //rechts von der Seitenzahl
    if (![pnFormatArr[1] isEqualTo:@""]) {
      [pnMutableString appendString:pnFormatArr[1]];
    }
    
    
    NSPoint pnPosition = NSZeroPoint;
    int pnAlternate = initialPageNumber & 1; //gibt scheinbar 0 oder 1..... 0 falls gerade zahl...
    
    //NSMutableParagraphStyle *myParaStyle = [[NSMutableParagraphStyle alloc] init];
    //anpassen in X
    if (pageNrAlignment == 0) { //left
      pnPosition.x = printInfo.rightMargin;
    } else if (pageNrAlignment == 1) { //center
      pnPosition.x = NSMidX([self pageHeaderRect]) - pnFontSize + 2;
      
    } else if (pageNrAlignment == 2) { //right
      pnPosition.x = printInfo.paperSize.width - printInfo.rightMargin - pnFontSize;
      //[myParaStyle setAlignment:NSRightTextAlignment];
      
    } else if (pageNrAlignment == 3) { //alternate
      if (pnAlternate == (pnNumberToShow & 1)) {//rechts
        pnPosition.x = printInfo.paperSize.width - printInfo.rightMargin - pnFontSize;
      } else {//links
        pnPosition.x = printInfo.rightMargin;
      }
    } else {
      NSAssert(0, @"Houston we have a problem");
    }
    
    //anpassen in Y
    if (pageNrPosition == 0) { //Header
      
      pnPosition.y = NSMidY([self pageHeaderRect]);
      
    } else { //Footer
      pnPosition.y = NSMidY([self pageFooterRect]);
    }
    
    //anpassen um die fontgrösse
    pnPosition.y -= pnFontSize;
    
    //PNr finetune
    NSSize pnDelta = [[self drawDocument] pnDeltaPosition];
    pnPosition.x += pnDelta.width;
    pnPosition.y += pnDelta.height;
    
    //[pageNrAttribsDict setObject:myParaStyle forKey:NSParagraphStyleAttributeName];
    NSAttributedString *pageNumberObject = [[NSAttributedString alloc] initWithString:pnMutableString attributes:pageNrAttribsDict];
    
    //damit die Seitenzahl erst aber der gewünschten Seite angezeigt wird
    if (self.currentPage >= firstPageNumberToShow) {
      [pageNumberObject drawAtPoint:pnPosition];
    }
    
    [pnMutableString release];
  }
  //----------------ende pagenumers----------------    
  
  if (_creatingGraphic) {
    drawingBounds = [_creatingGraphic drawingBounds];
    if (NSIntersectsRect(rect, drawingBounds)) {
      [currentContext saveGraphicsState];
      [NSBezierPath clipRect:drawingBounds];
      [_creatingGraphic drawInView:self isSelected:NO];
      [currentContext restoreGraphicsState];
    }
  }
  if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
    [[NSColor knobColor] set];
    NSFrameRect(_rubberbandRect);
  }
  
  if (NSIntersectsRect(rect, self.currentCursorRect)) {
    [self drawCursor];
  }
}

// ===========================================================================
#pragma mark -
#pragma mark ruler stuff
// ============================= ruler stuff =================================

- (void)beginEchoingMoveToRulers:(NSRect)echoRect {
  NSRulerView *horizontalRuler = self.enclosingScrollView.horizontalRulerView;
  NSRulerView *verticalRuler = self.enclosingScrollView.verticalRulerView;
  
  _horizontalRulerLineRect = [self convertRect:echoRect toView:horizontalRuler];
  _verticalRulerLineRect = [self convertRect:echoRect toView:verticalRuler];
  
  [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMinX(_horizontalRulerLineRect)];
  [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMidX(_horizontalRulerLineRect)];
  [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMaxX(_horizontalRulerLineRect)];
  
  [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMinY(_verticalRulerLineRect)];
  [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMidY(_verticalRulerLineRect)];
  [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMaxY(_verticalRulerLineRect)];
}

- (void)continueEchoingMoveToRulers:(NSRect)echoRect {
  NSRulerView *horizontalRuler = self.enclosingScrollView.horizontalRulerView;
  NSRulerView *verticalRuler = self.enclosingScrollView.verticalRulerView;
  NSRect newHorizontalRect = [self convertRect:echoRect toView:horizontalRuler];
  NSRect newVerticalRect = [self convertRect:echoRect toView:verticalRuler];
  
  [horizontalRuler moveRulerlineFromLocation:NSMinX(_horizontalRulerLineRect) toLocation:NSMinX(newHorizontalRect)];
  [horizontalRuler moveRulerlineFromLocation:NSMidX(_horizontalRulerLineRect) toLocation:NSMidX(newHorizontalRect)];
  [horizontalRuler moveRulerlineFromLocation:NSMaxX(_horizontalRulerLineRect) toLocation:NSMaxX(newHorizontalRect)];
  
  [verticalRuler moveRulerlineFromLocation:NSMinY(_verticalRulerLineRect) toLocation:NSMinY(newVerticalRect)];
  [verticalRuler moveRulerlineFromLocation:NSMidY(_verticalRulerLineRect) toLocation:NSMidY(newVerticalRect)];
  [verticalRuler moveRulerlineFromLocation:NSMaxY(_verticalRulerLineRect) toLocation:NSMaxY(newVerticalRect)];
  
  _horizontalRulerLineRect = newHorizontalRect;
  _verticalRulerLineRect = newVerticalRect;
}

- (void)stopEchoingMoveToRulers {
  NSRulerView *horizontalRuler = self.enclosingScrollView.horizontalRulerView;
  NSRulerView *verticalRuler = self.enclosingScrollView.verticalRulerView;
  
  [horizontalRuler moveRulerlineFromLocation:NSMinX(_horizontalRulerLineRect) toLocation:-1.0];
  [horizontalRuler moveRulerlineFromLocation:NSMidX(_horizontalRulerLineRect) toLocation:-1.0];
  [horizontalRuler moveRulerlineFromLocation:NSMaxX(_horizontalRulerLineRect) toLocation:-1.0];
  
  [verticalRuler moveRulerlineFromLocation:NSMinY(_verticalRulerLineRect) toLocation:-1.0];
  [verticalRuler moveRulerlineFromLocation:NSMidY(_verticalRulerLineRect) toLocation:-1.0];
  [verticalRuler moveRulerlineFromLocation:NSMaxY(_verticalRulerLineRect) toLocation:-1.0];
  
  _horizontalRulerLineRect = NSZeroRect;
  _verticalRulerLineRect = NSZeroRect;
}

// ===========================================================================
#pragma mark -
#pragma mark creating graphics
// ========================== creating graphics ==============================

- (void)createGraphicOfClass:(Class)theClass withEvent:(NSEvent *)theEvent {
  IGDrawDocument *document = [self drawDocument];
  _creatingGraphic = [[theClass allocWithZone:[document zone]] init];
  if ([_creatingGraphic createWithEvent:theEvent inView:self]) {
    [_creatingGraphic setPageNr:self.currentPage];
    [document insertGraphic:_creatingGraphic atIndex:0];
    [self selectGraphic:_creatingGraphic];
    if ([_creatingGraphic isEditable]) {
      [self startEditingGraphic:_creatingGraphic withEvent:nil ];
    }
    [document.undoManager setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created graphics.  Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:NSStringFromClass(theClass) value:@"" table:@"GraphicClassNames"]]];
  }
  [_creatingGraphic release];
  _creatingGraphic = nil;
}

- (void)createGraphicOfClassGlyph:(unichar)glyphUniChar WithFont:(NSString *)fontName {
  [self clearSelection];
  //wenn ich eine neue glyphe erstelle, will ich sie mit den standard eigenschaften erstellen und nicht wie die letzte die ich verändert habe
  //ich muss dann ins leere klicken und dann die einstellungen ändern, welche für alle neuen glyphen gelten
  [[FormatGlyphController sharedFormatGlyphController] restoreTmpFormating];
  
  IGDrawDocument *document = [self drawDocument];
  _creatingGraphic = [[IGGlyph allocWithZone:[document zone]] init];
  //NSLog(@"IGGraphicView(createGraphicOfClassGlyph) nach init -> %@", _creatingGraphic);
  if ([_creatingGraphic createGlyph:glyphUniChar withFont:fontName InView:self]) {
    //NSLog(@"IGGraphicView(createGraphicOfClassGlyph) nach createGlyph -> %@", _creatingGraphic);
    
    if (NSPointInRect([_creatingGraphic bounds].origin, [self pageHeaderRect])) {
      [_creatingGraphic setPageNr:0]; //falls die Glyphe im Headerteil erstellt wurde, wird sie automatisch in die Headerseite eingefügt
    } else {
      [_creatingGraphic setPageNr:self.currentPage]; //ansonsten ganz normal
    }
    [document insertGraphic:_creatingGraphic atIndex:0];
    [self selectGraphic:_creatingGraphic];
    
    //nur für den textblock interessant
    if ([_creatingGraphic isEditable]) {
      [self startEditingGraphic:_creatingGraphic withEvent:nil ];
    }
    
    [document.undoManager setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created graphics.  Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:@"IGGlyph" value:@"" table:@"GraphicClassNames"]]];
  }
  
  //moving the cursor
  NSPoint mainCursor = self.currentCursorPosition;
  NSPoint tempCursor = mainCursor;
  int wd = [[WritingDirectionController sharedWritingDirectionController] writingDirection];
  NSRect glyphBounds = [_creatingGraphic bounds];
  
  if (wd == upToDown | wd == upToDownMirr | wd == upToDownVert | wd == upToDownVertMirr)
  {
    NSLog(@"I'm in down");
    tempCursor.y = mainCursor.y + glyphBounds.size.height + glyphBounds.size.height * 0.20;
  }
  
  if (wd == rightToLeft)
  {
    NSLog(@"I'm in left");
    tempCursor.x = mainCursor.x - glyphBounds.size.width - glyphBounds.size.width * 0.20;
  }
  
  if (wd == leftToRight)
  {
    NSLog(@"I'm in right");
    tempCursor.x = mainCursor.x + glyphBounds.size.width + glyphBounds.size.width * 0.20;
  }
  
  if (NSIntersectsRect([self marginRectForSide:0],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1))) {
    NSBeep();
  } else if (NSIntersectsRect([self marginRectForSide:1],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1)))  {
    NSBeep();
  }  else if (NSIntersectsRect([self marginRectForSide:2],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1)))  {
    NSBeep();
  }
  
  self.currentCursorPosition = tempCursor;        
  [self.window invalidateCursorRectsForView:self];
  
  [_creatingGraphic release];
  _creatingGraphic = nil;
}


- (IBAction)writeGlyphGroupAction:(id)sender {
  
  //[[IGFontData sharedFontData] getGlyphForSymbol:[sender stringValue]];
  
  NSString *groupString = [sender stringValue];
  if ([groupString isEqualToString:@""]) {
    NSLog(@"error: empty group string");
    NSBeep();
    return;
  }
  
  NSString *cleanGroupString = @"";
  
  NSString *str1 = nil;
  NSString *str2 = nil;
  NSString *str3 = nil;
  NSString *str4 = nil;
  char sgn[3] = "000";
  int sgnPos[3];
  sgnPos[0] = 0; sgnPos[1] = 0; sgnPos[2] = 0;
  int anzahlSigns = 0;
  
  NSMutableArray *stringArray = [NSMutableArray array]; //hier habe ich maximal 4 strings drinnen, welche den maximal 4 Glyphen entsprechen werden.
  NSArray *tempGlyphData = nil; //stringArray umgewandelt in charNummber und fontName
  
  //hier tue ich die einzelnen Glyphen plazieren wo wir sie darstellen wollen (es ist eigentlich eine 3x3 matrix)
  //an jeder position wird sich ein array befinden, welcher den fontNamen und die charNummer (wie in IG_GlyphCodes.txt) beinhaltet
  //
  //      ol   om   or
  //      ml   mm   mr
  //      ul   um   ur
  //
  NSMutableDictionary *glyphGroupDic = [NSMutableDictionary dictionary];
  
  groupString = [groupString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  //hier werden die klamern und leerzeichen entfernt
  const char *cGroupStr = [groupString cString];
  int i;
  for (i = 0; i < strlen(cGroupStr); i++) {
    if (cGroupStr[i] == ' ') {
      continue;
    } else if (cGroupStr[i] == '(') {
      continue;
    } else if (cGroupStr[i] == ')') {
      continue;
    } 
    
    //NSLog(@"temp const char string %@", [NSString stringWithFormat:@"%c", cGroupStr[i]]); 
    cleanGroupString = [cleanGroupString stringByAppendingFormat:@"%c", cGroupStr[i]];
    
    //NSLog(@"%c index i:%d", cGroupStr[i], i);
  }
  
  //hier finde ich die position von "+" und "/" 
  const char *cCleanGroupStr = [cleanGroupString cString];
  int j = 0;
  for (i = 0; i < strlen(cCleanGroupStr); i++) {
    if (cCleanGroupStr[i] == '+') {
      if (j==3) {
        NSLog(@"zu viele gruppen Zeichen");
        break;
      }
      sgn[j] = cCleanGroupStr[i];
      sgnPos[j] = i;
      j++;
      continue;
    } else if (cCleanGroupStr[i] == '/') {
      if (j==3) {
        NSLog(@"zu viele gruppen Zeichen");
        break;
      }
      sgn[j] = cCleanGroupStr[i];
      sgnPos[j] = i;
      j++;
      continue;
    }
  }
  
  for (i=0;i<3;i++) {
    NSLog(@"sgn: %c, pos: %d", sgn[i], sgnPos[i]);
  }
  
  //an hand von der position der zeichen "+" und "/" kann ich den text parsen
  while (1) {
    
    if (sgn[0] == '0') { //keine signs
      if (cleanGroupString == @"") {
        NSLog(@"leerer cleanGroupString");
        break;
      } else {
        NSLog(@"keine signs");
        str1 = cleanGroupString;
        
        [stringArray addObject:cleanGroupString];
        tempGlyphData = [[IGFontData sharedFontData] getGlyphForSymbols:stringArray];
        
        break;
      }
    }
    if (sgn[0] != '0' && sgn[1] == '0') { //nur ein sign
      str1 = [cleanGroupString substringToIndex:sgnPos[0]];
      str2 = [cleanGroupString substringFromIndex:(sgnPos[0] + 1)];
      anzahlSigns = 1;
      
      [stringArray addObject:[cleanGroupString substringToIndex:sgnPos[0]]]; //str1
      [stringArray addObject:[cleanGroupString substringFromIndex:(sgnPos[0] + 1)]]; //str2
      
      tempGlyphData = [[IGFontData sharedFontData] getGlyphForSymbols:stringArray];
      
      break;
    }
    if (sgn[0] != '0' && sgn[1] != '0' && sgn[2] == '0') { //zwei signs
      str1 = [cleanGroupString substringToIndex:sgnPos[0]];
      str2 = [cleanGroupString substringWithRange:NSMakeRange((sgnPos[0] + 1), (sgnPos[1] - sgnPos[0] - 1))];
      str3 = [cleanGroupString substringFromIndex:(sgnPos[1] + 1)];
      anzahlSigns = 2;
      
      [stringArray addObject:[cleanGroupString substringToIndex:sgnPos[0]]]; //str1
      [stringArray addObject:[cleanGroupString substringWithRange:NSMakeRange((sgnPos[0] + 1), (sgnPos[1] - sgnPos[0] - 1))]]; //str2
      [stringArray addObject:[cleanGroupString substringFromIndex:(sgnPos[1] + 1)]]; //str3
      
      tempGlyphData = [[IGFontData sharedFontData] getGlyphForSymbols:stringArray];
      
      break;
    }
    if (sgn[0] != '0' && sgn[1] != '0' && sgn[2] != '0') { //drei signs
      str1 = [cleanGroupString substringToIndex:sgnPos[0]];
      str2 = [cleanGroupString substringWithRange:NSMakeRange((sgnPos[0] + 1), (sgnPos[1] - sgnPos[0] - 1))];
      str3 = [cleanGroupString substringWithRange:NSMakeRange((sgnPos[1] + 1), (sgnPos[2] - sgnPos[1] - 1))];
      str4 = [cleanGroupString substringFromIndex:(sgnPos[2] + 1)];
      anzahlSigns = 3;
      
      [stringArray addObject:[cleanGroupString substringToIndex:sgnPos[0]]]; //str1
      [stringArray addObject:[cleanGroupString substringWithRange:NSMakeRange((sgnPos[0] + 1), (sgnPos[1] - sgnPos[0] - 1))]]; //str2
      [stringArray addObject:[cleanGroupString substringWithRange:NSMakeRange((sgnPos[1] + 1), (sgnPos[2] - sgnPos[1] - 1))]]; //str3            
      [stringArray addObject:[cleanGroupString substringFromIndex:(sgnPos[2] + 1)]]; //str4
      
      tempGlyphData = [[IGFontData sharedFontData] getGlyphForSymbols:stringArray];
      
      break;
    }
  }
  //Gruppen sind 1-4 Zeichen
  
  int wd = [[WritingDirectionController sharedWritingDirectionController] writingDirection];
  
  if (wd == leftToRight)
  {
    NSLog(@"I'm in leftToRight");
    if (sgn[0] == '/') {
      if (sgn[1] == '/') {
        NSLog(@"str1 / str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else if (sgn[1] == '+') {
        NSLog(@"str1 / str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 / str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (sgn[0] == '+') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else if (sgn[1] == '/' && sgn[2] == '+') {
        NSLog(@"str1 + str2 / str3 + str4");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [glyphGroupDic setValue:tempGlyphData[3] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
    }
  }
  
  if (wd == rightToLeft)
  {
    NSLog(@"I'm in rightToLeft");
    if (sgn[0] == '/') {
      if (sgn[1] == '/') {
        NSLog(@"str1 / str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else if (sgn[1] == '+') {
        NSLog(@"str1 / str2 + str3"); //die reihenfolge bei der Ausgabe von str2 + str3 muss umgekehrt sein
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 / str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (sgn[0] == '+') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3"); //die reihenfolge bei der Ausgabe von str1 + str2 muss umgekehrt sein
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
    }
  }
  
  if (wd == upToDown)
  {
    NSLog(@"I'm in upToDown");
    
    if (sgn[0] == '/') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 / str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 / str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 / str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (sgn[0] == '+') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
    }
  }
  
  if (wd == upToDownMirr)
  {
    NSLog(@"I'm in upToDownMirr");
    
    if (sgn[0] == '/') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 / str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 / str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 / str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (sgn[0] == '+') {
      if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
    }
  }
  
  if (wd == upToDownVert)
  {
    NSLog(@"I'm in upToDownVert");
    
    if (sgn[0] == '+') {
      if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 + str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
        
      } else if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 + str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    
    if (sgn[0] == '/') {
      if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 / str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
      //NSRunAlertPanel(@"Error Writing Group", @"Wrong Group",@"OK",nil,nil);
      
    }
  }
  
  if (wd == upToDownVertMirr)
  {
    NSLog(@"I'm in upToDownVertMirr");
    
    if (sgn[0] == '+') {
      if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 + str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
        
      } else if (sgn[1] == '/' && sgn[2] == '0') {
        NSLog(@"str1 + str2 / str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", obenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenMitte]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      } else {
        NSLog(@"str1 + str2");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteLinks]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", mitteRechts]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    
    if (sgn[0] == '/') {
      if (sgn[1] == '+' && sgn[2] == '0') {
        NSLog(@"str1 / str2 + str3");
        [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", obenMitte]];
        [glyphGroupDic setValue:tempGlyphData[1] forKey:[NSString stringWithFormat:@"%d", untenRechts]];
        [glyphGroupDic setValue:tempGlyphData[2] forKey:[NSString stringWithFormat:@"%d", untenLinks]];
        [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
      }
    }
    if (tempGlyphData.count == 1) {
      [glyphGroupDic setValue:tempGlyphData[0] forKey:[NSString stringWithFormat:@"%d", mitteMitte]];
      [self createGraphicsOfClassGlyphFromDic:glyphGroupDic];
    } else {
      NSLog(@"error: invalid group");
      NSBeep();
      //NSRunAlertPanel(@"Error Writing Group", @"Wrong Group",@"OK",nil,nil);
      
    }
  }
  
  [self.window invalidateCursorRectsForView:self];
  
  //damit das Textfeld als keyView bestehen bleibt
  [sender selectText:self];
}

- (void)createGraphicsOfClassGlyphFromDic:(NSDictionary *)glyphGroupDic {
  
  [self clearSelection];
  //wenn ich eine neue glyphe erstelle, will ich sie mit den standard eigenschaften erstellen und nicht wie die letzte die ich verändert habe
  //ich muss dann ins leere klicken und dann die einstellungen ändern, welche für alle neuen glyphen gelten
  [[FormatGlyphController sharedFormatGlyphController] restoreTmpFormating];
  
  //dies ist unser Ausgangspunkt. von hier aus berechne ich den endgültigen standort der glyphe
  NSPoint mainCursor = self.currentCursorPosition;
  NSPoint tempCursor = mainCursor;
  
  unichar glyphUniChar;
  NSString *fontName;
  NSRect glyphBounds;
  
  int i;
  float x, y; //meine neuen x und y koordinaten
  float fontSize = [[FormatGlyphController sharedFormatGlyphController] fontSize];
  NSSize groupBoundsSize = NSMakeSize(0.88085938 * fontSize, 0.87988275 * fontSize);
  NSRect glyphGroupBounds = NSZeroRect;
  
  IGDrawDocument *document = [self drawDocument];
  
  NSEnumerator *enumerator = [glyphGroupDic keyEnumerator];
  id key;
  while ((key = [enumerator nextObject])) {
    glyphUniChar = (0xF000 + [glyphGroupDic[key][0] intValue]);
    fontName = glyphGroupDic[key][1];
    
    _creatingGraphic = [[IGGlyph allocWithZone:[document zone]] init];
    //NSLog(@"IGGraphicView(createGraphicsOfClassGlyphFromADic) nach init -> %@", _creatingGraphic);
    if ([_creatingGraphic createGlyph:glyphUniChar withFont:fontName InView:self]) {
      //NSLog(@"IGGraphicView(createGraphicsOfClassGlyphFromArray) nach createGlyph -> %@", _creatingGraphic);
      glyphBounds = [_creatingGraphic bounds]; //dies muss ich nun anpassen so das sie in der groupBounds an der richtigen Stelle liegt
      
      int temp = [key intValue];
      switch (temp)
      {
        case obenLinks:
          NSLog(@"dieses Zeichen obenLinks, %u", glyphUniChar);
          
          x = mainCursor.x;
          y = mainCursor.y - groupBoundsSize.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];                     
          
          break;
          
        case obenMitte:
          NSLog(@"dieses Zeichen obenMitte, %u", glyphUniChar);
          
          x = mainCursor.x + (groupBoundsSize.width - glyphBounds.size.width) * 0.5;
          y = mainCursor.y - groupBoundsSize.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case obenRechts:
          NSLog(@"dieses Zeichen obenRechts, %u", glyphUniChar);
          
          x = mainCursor.x + groupBoundsSize.width - glyphBounds.size.width;
          y = mainCursor.y - groupBoundsSize.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case mitteLinks:
          NSLog(@"dieses Zeichen mitteLinks, %u", glyphUniChar);
          
          x = mainCursor.x;
          y = mainCursor.y - (groupBoundsSize.height - glyphBounds.size.height) * 0.5 - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case mitteMitte:
          NSLog(@"dieses Zeichen mitteMitte, %u", glyphUniChar);
          
          x = mainCursor.x + (groupBoundsSize.width - glyphBounds.size.width) * 0.5;
          y = mainCursor.y - (groupBoundsSize.height - glyphBounds.size.height) * 0.5 - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case mitteRechts:
          NSLog(@"dieses Zeichen mitteRechts, %u", glyphUniChar);
          
          x = mainCursor.x + groupBoundsSize.width - glyphBounds.size.width;
          y = mainCursor.y - (groupBoundsSize.height - glyphBounds.size.height) * 0.5 - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case untenLinks:
          NSLog(@"dieses Zeichen untenLinks, %u", glyphUniChar);
          
          x = mainCursor.x;
          y = mainCursor.y - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case untenMitte:
          NSLog(@"dieses Zeichen untenMitte, %u", glyphUniChar);
          
          x = mainCursor.x + (groupBoundsSize.width - glyphBounds.size.width) * 0.5;
          y = mainCursor.y - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
        case untenRechts:
          NSLog(@"dieses Zeichen untenRechts, %u", glyphUniChar);
          
          x = mainCursor.x + groupBoundsSize.width - glyphBounds.size.width;
          y = mainCursor.y - glyphBounds.size.height;
          
          glyphBounds.origin = NSMakePoint(x,y);
          [_creatingGraphic setBounds:glyphBounds];
          
          break;
          
      }
      //damite der cursor nacher richtig verschoben werden kann.
      glyphGroupBounds = NSUnionRect(glyphGroupBounds, glyphBounds);
      if (NSPointInRect([_creatingGraphic bounds].origin, [self pageHeaderRect])) {
        [_creatingGraphic setPageNr:0]; //falls die Glyphe im Headerteil erstellt wurde, wird sie automatisch in die Headerseite eingefügt
      } else {
        [_creatingGraphic setPageNr:self.currentPage]; //ansonsten ganz normal
      }
      [document insertGraphic:_creatingGraphic atIndex:0];
      [document.undoManager setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created graphics.  Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:@"IGGlyph" value:@"" table:@"GraphicClassNames"]]];
    }
    [_creatingGraphic release];
    _creatingGraphic = nil;
  }
  
  
  //moving the cursor
  int wd = [[WritingDirectionController sharedWritingDirectionController] writingDirection];
  
  if (wd == upToDown | wd == upToDownMirr | wd == upToDownVert | wd == upToDownVertMirr)
  {
    NSLog(@"moving cursor: I'm in down");
    tempCursor.y = mainCursor.y + glyphGroupBounds.size.height + glyphGroupBounds.size.height * 0.25;
    if (glyphGroupBounds.size.height < groupBoundsSize.height) {
      for (i = 0; i < glyphGroupDic.count; i++) {
        [[self graphicsOnPage:self.currentPage][i] moveBy:NSMakePoint(0,(groupBoundsSize.height - glyphGroupBounds.size.height) * 0.5 + glyphGroupBounds.size.height)];
      }
    } else {
      for (i = 0; i < glyphGroupDic.count; i++) {
        [[self graphicsOnPage:self.currentPage][i] moveBy:NSMakePoint(0, glyphGroupBounds.size.height)];
      }
    }
  }
  
  if (wd == rightToLeft)
  {
    NSLog(@"moving cursor: I'm in left");
    tempCursor.x = mainCursor.x - glyphGroupBounds.size.width - glyphGroupBounds.size.width * 0.25;
    if (glyphGroupBounds.size.width < groupBoundsSize.width) {
      for (i = 0; i < glyphGroupDic.count; i++) {
        [[self graphicsOnPage:self.currentPage][i] moveBy:NSMakePoint((groupBoundsSize.width - glyphGroupBounds.size.width) * -0.5 - glyphGroupBounds.size.width, 0)];
      }
    } else {
      for (i = 0; i < glyphGroupDic.count; i++) {
        [[self graphicsOnPage:self.currentPage][i] moveBy:NSMakePoint(-groupBoundsSize.width, 0)];
      }
    }
  }
  
  if (wd == leftToRight)
  {
    NSLog(@"moving cursor: I'm in right");
    tempCursor.x = mainCursor.x + glyphGroupBounds.size.width + glyphGroupBounds.size.width * 0.25;
    if (glyphGroupBounds.size.width < groupBoundsSize.width) {
      for (i = 0; i < glyphGroupDic.count; i++) {
        id tempGraphic = [self graphicsOnPage:self.currentPage][i];
        [tempGraphic moveBy:NSMakePoint((groupBoundsSize.width - glyphGroupBounds.size.width) * -0.5, 0)];
      }
    }
  }
  
  if (NSIntersectsRect([self marginRectForSide:0],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1))) {
    NSBeep();
  } else if (NSIntersectsRect([self marginRectForSide:1],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1)))  {
    NSBeep();
  } else if (NSIntersectsRect([self marginRectForSide:2],NSMakeRect(tempCursor.x, tempCursor.y, 1, 1)))  {
    NSBeep();
  }
  
  self.currentCursorPosition = tempCursor;
}


- (IGGraphic *)creatingGraphic {
  return _creatingGraphic;
}


// ===========================================================================
#pragma mark -
#pragma mark selection stuff
// =========================== selection stuff ===============================

- (void)trackKnob:(int)knob ofGraphic:(IGGraphic *)graphic withEvent:(NSEvent *)theEvent {
  NSPoint point;
  BOOL snapsToGrid = [self snapsToGrid];
  float spacing = [self gridSpacing];
  BOOL echoToRulers = self.enclosingScrollView.rulersVisible;
  
  [graphic startBoundsManipulation];
  if (echoToRulers) {
    [self beginEchoingMoveToRulers:[graphic bounds]];
  }
  while (1) {
    theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [self invalidateGraphic:graphic];
    if (snapsToGrid) {
      point.x = floor((point.x / spacing) + 0.5) * spacing;
      point.y = floor((point.y / spacing) + 0.5) * spacing;
    }
    knob = [graphic resizeByMovingKnob:knob toPoint:point];
    [self invalidateGraphic:graphic];
    if (echoToRulers) {
      [self continueEchoingMoveToRulers:[graphic bounds]];
    }
    if (theEvent.type == NSLeftMouseUp) {
      break;
    }
  }
  if (echoToRulers) {
    [self stopEchoingMoveToRulers];
  }
  
  [graphic stopBoundsManipulation];
  
  [[self drawDocument].undoManager setActionName:NSLocalizedStringFromTable(@"Resize", @"UndoStrings", @"Action name for resizes.")];
}

- (void)rubberbandSelectWithEvent:(NSEvent *)theEvent {
  NSPoint origPoint, curPoint;
  NSEnumerator *objEnum;
  IGGraphic *curGraphic;
  
  _gvFlags.rubberbandIsDeselecting = ((theEvent.modifierFlags & NSAlternateKeyMask) ? YES : NO);
  origPoint = curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  
  while (1) {
    theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (NSEqualPoints(origPoint, curPoint)) {
      if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
        [self setNeedsDisplayInRect:_rubberbandRect];
        [self performSelector:@selector(invalidateGraphic:) withEachObjectInSet:_rubberbandGraphics];
      }
      _rubberbandRect = NSZeroRect;
      [_rubberbandGraphics release];
      _rubberbandGraphics = nil;
    } else {
      NSRect newRubberbandRect = IGRectFromPoints(origPoint, curPoint);
      if (!NSEqualRects(_rubberbandRect, newRubberbandRect)) {
        [self setNeedsDisplayInRect:_rubberbandRect];
        [self performSelector:@selector(invalidateGraphic:) withEachObjectInSet:_rubberbandGraphics];
        _rubberbandRect = newRubberbandRect;
        [_rubberbandGraphics release];
        _rubberbandGraphics = [[self graphicsIntersectingRect:_rubberbandRect onPage:self.currentPage] retain];
        
        [self setNeedsDisplayInRect:_rubberbandRect];
        [self performSelector:@selector(invalidateGraphic:) withEachObjectInSet:_rubberbandGraphics];
      }
    }
    if (theEvent.type == NSLeftMouseUp) {
      break;
    }
  }
  
  // Now select or deselect the rubberbanded graphics.
  objEnum = [_rubberbandGraphics objectEnumerator];
  while ((curGraphic = [objEnum nextObject]) != nil) {
    if (_gvFlags.rubberbandIsDeselecting) {
      [self deselectGraphic:curGraphic];
    } else {
      [self selectGraphic:curGraphic];
    }
  }
  if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
    [self setNeedsDisplayInRect:_rubberbandRect];
  }
  
  _rubberbandRect = NSZeroRect;
  [_rubberbandGraphics release];
  _rubberbandGraphics = nil;
}


- (void)moveCursorWithEvent:(NSEvent *)theEvent {
  NSPoint lastPoint, curPoint;
  BOOL didMove = NO, isMoving = NO;
  NSPoint selPointOffset = NSZeroPoint;
  NSPoint boundsOrigin;
  BOOL snapsToGrid = [self snapsToGrid];
  float spacing = [self gridSpacing];
  BOOL echoToRulers = self.enclosingScrollView.rulersVisible;
  //++NSRect selBounds = NSMakeRect(self.currentCursorPosition.x, self.currentCursorPosition.y, 0, 0);
  NSPoint selPoint = self.currentCursorPosition;
  lastPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  
  //wenn ctrl gedrückt, kann ich den cursor in alle richtungen verschieben
  BOOL ctrlKeyDown = ((theEvent.modifierFlags & NSControlKeyMask) ? YES : NO);
  
  int wd = [[WritingDirectionController sharedWritingDirectionController] writingDirection];
  
  if (snapsToGrid || echoToRulers) {
    //++selOriginOffset = NSMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));
    selPointOffset = NSMakePoint((lastPoint.x - selPoint.x), (lastPoint.y - selPoint.y));
  }
  if (echoToRulers) {
    [self beginEchoingMoveToRulers:NSMakeRect(selPoint.x, selPoint.y, 0, 0)];
  }
  
  while (1) {
    theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    //hier wird die bewegung in der x-Achse oder der y-Achse beschränkt je nach schreibrichtung
    if (!ctrlKeyDown && (wd == leftToRight || wd == rightToLeft)) {
      curPoint.y = self.currentCursorPosition.y + selPointOffset.y;
    } else if (!ctrlKeyDown) {
      curPoint.x = self.currentCursorPosition.x + selPointOffset.x;
    } else if (ctrlKeyDown) {
      //damit ich mit ctrlKey den Cursor frei bewegen kann
      curPoint.x = self.currentCursorPosition.x + selPointOffset.x;
      curPoint.y = self.currentCursorPosition.y + selPointOffset.y;
    }
    
    if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0))) {
      isMoving = YES;
    }
    
    if (isMoving) {
      if (snapsToGrid) {
        boundsOrigin.x = curPoint.x - selPointOffset.x;
        boundsOrigin.y = curPoint.y - selPointOffset.y;
        boundsOrigin.x = floor((boundsOrigin.x / spacing) + 0.5) * spacing;
        boundsOrigin.y = floor((boundsOrigin.y / spacing) + 0.5) * spacing;
        curPoint.x = boundsOrigin.x + selPointOffset.x;
        curPoint.y = boundsOrigin.y + selPointOffset.y;
      }
      if (!NSEqualPoints(lastPoint, curPoint)) {
        self.currentCursorPosition = NSMakePoint(curPoint.x - selPointOffset.x, curPoint.y - selPointOffset.y);
        didMove = YES;
        if (echoToRulers) {
          [self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selPointOffset.x, curPoint.y - selPointOffset.y, 0, 0)];
        }
        didMove = YES;
      }
      lastPoint = curPoint;
    }
    
    [self.window invalidateCursorRectsForView:self];
    
    if (theEvent.type == NSLeftMouseUp) {
      break;
    }
  }
  
  if (echoToRulers)  {
    [self stopEchoingMoveToRulers];
  }
}

- (void)moveSelectedGraphicsWithEvent:(NSEvent *)theEvent {
  NSPoint lastPoint, curPoint;
  NSArray *selGraphics = [self selectedGraphics];
  unsigned i, c;
  IGGraphic *graphic;
  BOOL didMove = NO, isMoving = NO;
  NSPoint selOriginOffset = NSZeroPoint;
  NSPoint boundsOrigin;
  BOOL snapsToGrid = [self snapsToGrid];
  float spacing = [self gridSpacing];
  BOOL echoToRulers = self.enclosingScrollView.rulersVisible;
  NSRect selBounds = [[self drawDocument] boundsForGraphics:selGraphics];
  
  c = selGraphics.count;
  
  lastPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  if (snapsToGrid || echoToRulers) {
    selOriginOffset = NSMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));
  }
  if (echoToRulers) {
    [self beginEchoingMoveToRulers:selBounds];
  }
  
  while (1) {
    c = selGraphics.count;
    theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0))) {
      isMoving = YES;
      [selGraphics makeObjectsPerformSelector:@selector(startBoundsManipulation)];
      _gvFlags.knobsHidden = YES;
    }
    if (isMoving) {
      if (snapsToGrid) {
        boundsOrigin.x = curPoint.x - selOriginOffset.x;
        boundsOrigin.y = curPoint.y - selOriginOffset.y + selBounds.size.height;
        boundsOrigin.x = floor((boundsOrigin.x / spacing) + 0.5) * spacing;
        boundsOrigin.y = floor((boundsOrigin.y / spacing) + 0.5) * spacing;
        curPoint.x = boundsOrigin.x + selOriginOffset.x;
        curPoint.y = boundsOrigin.y + selOriginOffset.y - selBounds.size.height;
      }
      if (!NSEqualPoints(lastPoint, curPoint)) {
        for (i = 0; i < c; i++) {
          graphic = selGraphics[i];
          [self invalidateGraphic:graphic];
          [graphic moveBy:NSMakePoint(curPoint.x - lastPoint.x, curPoint.y - lastPoint.y)];
          if (NSContainsRect([self pageHeaderSmalerRect],[graphic bounds]) || NSContainsRect([self pageFooterSmalerRect],[graphic bounds])) {
            //if (NSPointInRect(NSMakePoint([graphic bounds].origin.x, [graphic bounds].origin.y + 5), [self pageHeaderRect])) {
            if ([graphic pageNr] != 0) {
              [[self drawDocument] moveGraphic:graphic toPage:0]; //falls die Glyphe in den Headerteil verschoben wurde, muss sie auch in die Headerpage verschoben werden
            }
            } else if (!NSContainsRect([self pageHeaderSmalerRect],[graphic bounds])  && !NSContainsRect([self pageFooterSmalerRect],[graphic bounds])) {
              //} else if (!NSPointInRect(NSMakePoint([graphic bounds].origin.x, [graphic bounds].origin.y + 5), [self pageHeaderRect])) {
              if ([graphic pageNr] != self.currentPage) {
                [[self drawDocument] moveGraphic:graphic toPage:self.currentPage]; //ansonsten müssen wir sie in die self.currentPage verschieben
              }
              }
          
          [self invalidateGraphic:graphic];
          if (echoToRulers) { 
            [self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selOriginOffset.x, curPoint.y - selOriginOffset.y, NSWidth(selBounds),NSHeight(selBounds))];
          }
          didMove = YES;
          }
        //NSLog(@"moving graphics...koennte ich hier den cursor immer updaten?");
        //um in der Statusleiste die Koordinaten wärend dem verschieben der Objekte anzeigen zu können
        NSRect tmpRect = [[self drawDocument] drawingBoundsForGraphics:selGraphics];
        tmpRect.origin.y += tmpRect.size.height;
        tmpRect.origin.x += IG_HALF_HANDLE_WIDTH;
        tmpRect.origin.y -= IG_HALF_HANDLE_WIDTH;
        [[self drawWindowController] displayMousePos:tmpRect.origin];
        
        // Adjust the delta that is used for cascading pastes.  Pasting and then moving the pasted graphic is the way you determine the cascade delta for subsequent pastes.
        _pasteCascadeDelta.x += (curPoint.x - lastPoint.x);
        _pasteCascadeDelta.y += (curPoint.y - lastPoint.y);
        }
      lastPoint = curPoint;
      }
    if (theEvent.type == NSLeftMouseUp) {
      break;
    }
    }
  
  if (echoToRulers)  {
    [self stopEchoingMoveToRulers];
  }
  if (isMoving) {
    [selGraphics makeObjectsPerformSelector:@selector(stopBoundsManipulation)];
    _gvFlags.knobsHidden = NO;
    
    if (didMove) {
      // Only if we really moved.
      [[self drawDocument].undoManager setActionName:NSLocalizedStringFromTable(@"Move", @"UndoStrings", @"Action name for moves.")];
    }
  }
  }

- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent {
  NSPoint curPoint;
  IGGraphic *graphic = nil;
  BOOL isSelected;
  BOOL cursorSelected;
  
  //mit shift key kann ich sachen dazu selecten/deselecten
  BOOL shiftKeyDown = ((theEvent.modifierFlags & NSShiftKeyMask) ? YES : NO);
  
  curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  graphic = [self graphicUnderPoint:curPoint onPage:self.currentPage] ? [self graphicUnderPoint:curPoint onPage:self.currentPage] : [self graphicUnderPoint:curPoint onPage:0];
  
  NSLog(@"graphic under point %@", graphic);
  cursorSelected = [self cursorUnderPoint:curPoint];
  isSelected = (graphic ? [self graphicIsSelected:graphic] : NO);
  
  int knobHit = [graphic knobUnderPoint:curPoint];
  
  if (!shiftKeyDown && !isSelected && !knobHit) {
    NSLog(@"Clear selection aber nicht falls shift key down");
    [self clearSelection];
  }
  
  if (graphic) {
    // Add or remove this graphic from selection.
    if (shiftKeyDown) { //shift pressed
      if (isSelected) {
        [self deselectGraphic:graphic];
        isSelected = NO;
      } else {
        [self selectGraphic:graphic];
        isSelected = YES;
      }
    } else {
      if (isSelected) {
        if (knobHit != NoKnob) {
          if ([graphic class] == [IGGlyph class]) {
            [self moveSelectedGraphicsWithEvent:theEvent]; //die glyphe darf mit dem knob nicht in der grösse verändert werden, sondern nur verschoben werden
            return;
          }
          [self trackKnob:knobHit ofGraphic:graphic withEvent:theEvent];
          return;
        }
      }
      [self selectGraphic:graphic];
      isSelected = YES;
    }
  } else if (cursorSelected) {
    [self moveCursorWithEvent:theEvent];
    return;
  } else {
    [self rubberbandSelectWithEvent:theEvent];
    return;
  }
  
  if (isSelected) {
    [self moveSelectedGraphicsWithEvent:theEvent];
    return;
  }
  
  // If we got here then there must be nothing else to do.  Just track until mouseUp:.
  while (1) {
    theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    if (theEvent.type == NSLeftMouseUp) {
      break;
    }
  }
}


// ===========================================================================
#pragma mark -
#pragma mark mouse stuff
// ============================= mouse stuff =================================

- (void)mouseDown:(NSEvent *)theEvent {
  //Class theClass = [[ObjectsController sharedObjectsController] currentGraphicClass];
  
  BOOL ctrlKeyDown = ((theEvent.modifierFlags & NSControlKeyMask) ? YES : NO);
  //BOOL shiftKeyDown = (([theEvent modifierFlags] & NSShiftKeyMask) ? YES : NO);
  
  //passiert nur beim text object
  if ([self editingGraphic]) {
    [self endEditing];
  }
  //ist nur für das text objekt interessant da dieses nur editable ist
  if (theEvent.clickCount > 1) {
    NSPoint curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    IGGraphic *graphic = [self graphicUnderPoint:curPoint onPage:self.currentPage];
    if (graphic && [graphic isEditable]) {
      [self startEditingGraphic:graphic withEvent:theEvent];
      return;
    }
  }
  
  //ctrl-klick um den cursor auf diese position zu setzen
  if (theEvent.clickCount == 1 && ctrlKeyDown) {
    NSLog(@"IGGraphicView(mouseDown) -> ctrl-click sollte es sein");
    NSPoint curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    self.currentCursorPosition = curPoint;
    [self setNeedsDisplay:YES];
  }
  
  //wenn der pointer ausgewählt ist, ist die class = null
  //da es den ObjectsController nicht mehr gibt, ist es immer null
  //if (theClass) {
  //    [self clearSelection];
  //    [self createGraphicOfClass:theClass withEvent:theEvent];
  //    [[ObjectsController sharedObjectsController] selectArrowTool];
  //} else {
  [self selectAndTrackMouseWithEvent:theEvent];
  //}
  
  //Glyphen Auswahl
  if ([self selectedGraphicCountOfClass:[IGGlyph class]] == 0) {
    NSLog(@"IGGraphicView(mouseDown) keine Glyphe");
    [[FormatGlyphController sharedFormatGlyphController] restoreTmpFormating];
  } else if ([self selectedGraphicCountOfClass:[IGGlyph class]] == 1) {
    NSLog(@"IGGraphicView(mouseDown) nur eine Glyphe ausgewaehlt");
    [[FormatGlyphController sharedFormatGlyphController] showSelectedGlyphFormating];
  }

  //Cartouche Auswahl
  //hier will ich erst mal die Bindings zum laufen bringen.
  //eigentlich sollte der update dann automagicaly geschehen
  if ([self selectedGraphicCountOfClass:[IGCartouche class]] == 0) {
    NSLog(@"IGGraphicView(mouseDown) keine Cartouche ausgewaehlt");
    //[[CartoucheController sharedCartoucheController] restoreTmpFormating];
  } else if ([self selectedGraphicCountOfClass:[IGCartouche class]] == 1) {
    NSLog(@"IGGraphicView(mouseDown) nur eine Cartouche ausgewaehlt");
    //[[CartoucheController sharedCartoucheController] showSelectedCartoucheFormating];
  }

  //Linien Auswahl
  if ([self selectedGraphicCountOfClass:[IGLine class]] == 0) {
    NSLog(@"IGGraphicView(mouseDown) keine Linie ausgewaehlt");
    [[LineController sharedLineController] restoreTmpFormating];
  } else if ([self selectedGraphicCountOfClass:[IGLine class]] == 1) {
    NSLog(@"IGGraphicView(mouseDown) nur eine Linie ausgewaehlt");
    [[LineController sharedLineController] showSelectedLineFormating];
  }
}
/*
 - (void)mouseDragged:(NSEvent *)theEvent {
   NSLog(@"IGGraphicView(mouseDragged) -> rechts-click sollte es sein");
   
 }
 
 - (void)mouseUp:(NSEvent *)theEvent {
   if ([[self enclosingScrollView] rulersVisible])  {
     [self stopEchoingMoveToRulers];
   }
 }
 */

//mit einem rechts-click setze ich den cursor oder verschiebe ihn beliebig
- (void)rightMouseDown:(NSEvent *)theEvent {
  //NSLog(@"IGGraphicView(mouseDown) -> rechts-click sollte es sein");
  NSPoint lastPoint, curPoint;
  BOOL didMove = NO, isMoving = NO;
  NSPoint selPointOffset = NSZeroPoint;
  NSPoint boundsOrigin;
  BOOL snapsToGrid = [self snapsToGrid];
  float spacing = [self gridSpacing];
  BOOL echoToRulers = self.enclosingScrollView.rulersVisible;
  
  NSPoint selPoint = self.currentCursorPosition;
  lastPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  
  if (snapsToGrid || echoToRulers) {
    //++selOriginOffset = NSMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));
    selPointOffset = NSMakePoint((lastPoint.x - selPoint.x), (lastPoint.y - selPoint.y));
  }
  if (echoToRulers) {
    [self beginEchoingMoveToRulers:NSMakeRect(selPoint.x, selPoint.y, 0, 0)];
  }
  
  //damit der cursor beim rechts-click auch dorthin springt
  self.currentCursorPosition = lastPoint;
  
  if (echoToRulers)  {
    [self stopEchoingMoveToRulers];
  }
}

// ich muss die event loop aus rightMouseDown brechen
- (void)rightMouseDragged:(NSEvent *)theEvent {
  NSLog(@"IGGraphicView(rightMouseDragged) -> rechts-click und drag sollte es sein");
  NSPoint lastPoint, curPoint;
  BOOL didMove = NO, isMoving = NO;
  NSPoint selPointOffset = NSZeroPoint;
  NSPoint boundsOrigin;
  BOOL snapsToGrid = [self snapsToGrid];
  float spacing = [self gridSpacing];
  BOOL echoToRulers = self.enclosingScrollView.rulersVisible;
  
  
  theEvent = [self.window nextEventMatchingMask:(NSRightMouseDraggedMask | NSRightMouseUpMask)];
  curPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  
  //damit der cursor beim rechts-click auch dorthin springt
  //[self.currentCursorPosition = curPoint];
  
  if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0))) {
    isMoving = YES;
  }
  if (isMoving) {
    if (snapsToGrid) {
      boundsOrigin.x = curPoint.x - selPointOffset.x;
      boundsOrigin.y = curPoint.y - selPointOffset.y;
      boundsOrigin.x = floor((boundsOrigin.x / spacing) + 0.5) * spacing;
      boundsOrigin.y = floor((boundsOrigin.y / spacing) + 0.5) * spacing;
      curPoint.x = boundsOrigin.x + selPointOffset.x;
      curPoint.y = boundsOrigin.y + selPointOffset.y;
    }
    if (!NSEqualPoints(lastPoint, curPoint)) {
      self.currentCursorPosition = NSMakePoint(curPoint.x - selPointOffset.x, curPoint.y - selPointOffset.y);
      didMove = YES;
      if (echoToRulers) {
        [self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selPointOffset.x, curPoint.y - selPointOffset.y, 0, 0)];
      }
      didMove = YES;
    }
    lastPoint = curPoint;
  }
  
  [self.window invalidateCursorRectsForView:self];
  
  /*
   if ([theEvent type] == NSRightMouseUp) {
     break;
   }
   */
  
}


- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
  return YES;
}

- (void)mouseMoved:(NSEvent *)theEvent {
  NSPoint mousePos = [self convertPoint:theEvent.locationInWindow toView:nil];
  //die mousePos umrechnen so das ich es gebrauchen kann
  
  if (mousePos.x < 0.0f) mousePos.x = 0.0f;
  if (mousePos.y < 0.0f) mousePos.y = 0.0f;
  if (mousePos.x > [self drawDocumentPaperSize].width) mousePos.x = [self drawDocumentPaperSize].width;
  if (mousePos.y > [self drawDocumentPaperSize].height) mousePos.y = [self drawDocumentPaperSize].height;
  
  
  [[self drawWindowController] displayMousePos:mousePos];
}


// ===========================================================================
#pragma mark -
#pragma mark IGImage graphic creation
// ======================= IGImage graphic creation ==========================

- (BOOL)makeNewImageFromPasteboard:(NSPasteboard *)pboard atPoint:(NSPoint)point {
  NSString *type = [pboard availableTypeFromArray:[NSImage imagePasteboardTypes]];
  if (type) {
    NSImage *contents = [[NSImage allocWithZone:[[self drawDocument] zone]] initWithPasteboard:pboard];
    if (contents) {
      IGImage *newImage = [[IGImage allocWithZone:[[self drawDocument] zone]] init];
      [newImage setBounds:NSMakeRect(point.x, point.y - contents.size.height, contents.size.width, contents.size.height)];
      [newImage setImage:contents];
      [contents release];
      [[self drawDocument] insertGraphic:newImage atIndex:0];
      [newImage release];
      [self clearSelection];
      [self selectGraphic:newImage];
      return YES;
    }
  }
  return NO;
}

- (BOOL)makeNewImageFromContentsOfFile:(NSString *)filename atPoint:(NSPoint)point {
  NSString *extension = filename.pathExtension;
  if ([[NSImage imageFileTypes] containsObject:extension]) {
    NSImage *contents = [[NSImage allocWithZone:[[self drawDocument] zone]] initWithContentsOfFile:filename];
    if (contents) {
      IGImage *newImage = [[IGImage allocWithZone:[[self drawDocument] zone]] init];
      [newImage setBounds:NSMakeRect(point.x, point.y, contents.size.width, contents.size.height)];
      [newImage setImage:contents];
      [contents release];
      [[self drawDocument] insertGraphic:newImage atIndex:0];
      [newImage release];
      [self clearSelection];
      [self selectGraphic:newImage];
      return YES;
    }
  }
  return NO;
}

// ===========================================================================
#pragma mark -
#pragma mark currsor stuff
// ============================ Currsor stuff ===============================

- (NSPoint)currentCursorPosition {
  return currentCursorPosition;
}

- (void)setCurrentCursorPosition:(NSPoint)position {
  currentCursorPosition = position;
  self.currentCursorRect = NSMakeRect(position.x - IG_HALF_HANDLE_WIDTH, position.y - IG_HALF_HANDLE_WIDTH, IG_HANDLE_WIDTH, IG_HANDLE_WIDTH);
  
  [self setNeedsDisplayInRect:NSInsetRect(self.currentCursorRect, -1, -1)];
  [self setNeedsDisplayInRect:NSInsetRect(self.oldCursorRect, -1, -1)];
  self.oldCursorRect = self.currentCursorRect;
  
}

- (void)displayCursorPos {
  //NSLog(@"IGGraphicView(displayCursorPos)");
  //[[self drawWindowController] displayCursorPos:self.currentCursorPosition];
}

- (void)blinkingCursorTimer:(NSTimer *)aTimer {
  _cursorColor = (_cursorColor == [NSColor whiteColor] ? [NSColor redColor] : [NSColor whiteColor]);
  [self setNeedsDisplayInRect:self.currentCursorRect];
}

- (void)drawCursor {
  [[NSColor blackColor] set];
  NSFrameRect(self.currentCursorRect);
  [_cursorColor set];
  NSRectFill(NSInsetRect(self.currentCursorRect, 1, 1));
}

- (void)invalidateBlinkingCursorTimer {
  [_blinkingCursorTimer invalidate];
}

- (void)resetCursorRects {
  [self addCursorRect:self.currentCursorRect cursor:[NSCursor pointingHandCursor]];
  NSLog(@"IGGraphicView(resetCursorRects)");
}

// ===========================================================================
#pragma mark -
#pragma mark new row button
// ========================== new row button =================================

- (IBAction)newRowButtonAction:(id)sender {
  float lineSpacing = [[self drawDocument] documentLineSpacing];
  float fontSize = [[self drawDocument] documentFontSize];

  self.currentCursorPosition = NSMakePoint([self documentRectForPageNumber:0].origin.x + 10, self.currentCursorPosition.y + (lineSpacing * fontSize));
}

// ===========================================================================
#pragma mark -
#pragma mark dragging stuff
// ============================ Dragging stuff ===============================

- (unsigned int)dragOperationForDraggingInfo:(id <NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  NSString *type = [pboard availableTypeFromArray:@[NSColorPboardType, NSFilenamesPboardType]];
  
  if (type) {
    if ([type isEqualToString:NSColorPboardType]) {
      NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
      if ([self graphicUnderPoint:point onPage:self.currentPage]) {
        return NSDragOperationGeneric;
      }
    }
    if ([type isEqualToString:NSFilenamesPboardType]) {
      return NSDragOperationCopy;
    }
  }
  
  type = [pboard availableTypeFromArray:[NSImage imagePasteboardTypes]];
  if (type) {
    return NSDragOperationCopy;
  }
  
  return NSDragOperationNone;
}

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender {
  return [self dragOperationForDraggingInfo:sender];
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender {
  return [self dragOperationForDraggingInfo:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
  return;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
  return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
  return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  NSString *type = [pboard availableTypeFromArray:@[NSColorPboardType, NSFilenamesPboardType]];
  NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
  NSPoint draggedImageLocation = [self convertPoint:[sender draggedImageLocation] fromView:nil];
  
  if (type) {
    if ([type isEqualToString:NSColorPboardType]) {
      IGGraphic *hitGraphic = [self graphicUnderPoint:point onPage:self.currentPage];
      
      if (hitGraphic) {
        NSColor *color = [[NSColor colorFromPasteboard:pboard] colorWithAlphaComponent:1.0];
        hitGraphic.fillColor = color;
        [self.undoManager setActionName:NSLocalizedStringFromTable(@"Set Fill Color", @"UndoStrings", @"Action name for setting fill color.")];
      }
    } else if ([type isEqualToString:NSFilenamesPboardType]) {
      NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
      // Handle multiple files (cascade them?)
      if (filenames.count == 1) {
        NSString *filename = filenames[0];
        [self makeNewImageFromContentsOfFile:filename atPoint:point];
      }
    }
    return;
  }
  
  (void)[self makeNewImageFromPasteboard:pboard atPoint:draggedImageLocation];
}

// ===========================================================================
#pragma mark -
#pragma mark ruler support
// ============================ Ruler support ================================

- (void)updateRulers {
  NSScrollView *enclosingScrollView = self.enclosingScrollView;
  if (enclosingScrollView.rulersVisible) {
    // MF: Eventually, it'd be nice if we added ruler markers for the selection, but for now we just clear them.  By clearing the markers we make sure that no markers from text editing are left over when the editing stops.
    [enclosingScrollView.verticalRulerView setMarkers:nil];
    [enclosingScrollView.horizontalRulerView setMarkers:nil];
  }
}

- (BOOL)rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker {
  return YES;
}

- (float)rulerView:(NSRulerView *)ruler willMoveMarker:(NSRulerMarker *)marker toLocation:(float)location {
  return location;
}

- (void)rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker {
  
}

- (BOOL)rulerView:(NSRulerView *)ruler shouldRemoveMarker:(NSRulerMarker *)marker {
  return NO;
}

#define IG_RULER_MARKER_THICKNESS 8.0
#define IG_RULER_ACCESSORY_THICKNESS 10.0

- (IBAction)toggleRuler:(id)sender {
  NSScrollView *enclosingScrollView = self.enclosingScrollView;
  BOOL rulersAreVisible = enclosingScrollView.rulersVisible;
  if (rulersAreVisible) {
    [enclosingScrollView setRulersVisible:NO];
  } else {
    if (!_gvFlags.initedRulers) {
      NSRulerView *ruler;
      ruler = enclosingScrollView.horizontalRulerView;
      [ruler setReservedThicknessForMarkers:IG_RULER_MARKER_THICKNESS];
      [ruler setReservedThicknessForAccessoryView:IG_RULER_ACCESSORY_THICKNESS];
      ruler = enclosingScrollView.verticalRulerView;
      [ruler setReservedThicknessForMarkers:IG_RULER_MARKER_THICKNESS];
      [ruler setReservedThicknessForAccessoryView:IG_RULER_ACCESSORY_THICKNESS];
      _gvFlags.initedRulers = YES;
    }
    [enclosingScrollView setRulersVisible:YES];
    [self updateRulers];
  }
}

// ===========================================================================
#pragma mark -
#pragma mark ordering selection stuff
// ====================== ordering selection stuff ===========================

- (void)changeColor:(id)sender {
  NSArray *selGraphics = [self selectedGraphics];
  unsigned i, c = selGraphics.count;
  if (c > 0) {
    IGGraphic *curGraphic;
    NSColor *color = [sender color];
    
    for (i=0; i<c; i++) {
      curGraphic = selGraphics[i];
      curGraphic.fillColor = color;
      [curGraphic setDrawsFill:YES];
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Set Fill Color", @"UndoStrings", @"Action name for setting fill color.")];
  }
}

- (IBAction)selectAll:(id)sender {
  NSMutableArray *graphics = [NSMutableArray arrayWithArray:[[self drawDocument] graphicsOnPage:self.currentPage]];
  [graphics addObjectsFromArray:[[self drawDocument] graphicsOnPage:0]];
  [self performSelector:@selector(selectGraphic:) withEachObjectInArray:graphics];
}

- (IBAction)deselectAll:(id)sender {
  [self clearSelection];
}

- (IBAction)delete:(id)sender {
  NSArray *selCopy = [[NSArray allocWithZone:[self zone]] initWithArray:[self selectedGraphics]];
  if (selCopy.count > 0) {
    [[self drawDocument] performSelector:@selector(removeGraphic:) withEachObjectInArray:selCopy];
    [selCopy release];
    [[self drawDocument].undoManager setActionName:NSLocalizedStringFromTable(@"Delete", @"UndoStrings", @"Action name for deletions.")];
  }
}

- (IBAction)bringToFront:(id)sender {
  NSArray *orderedSelection = [self orderedSelectedGraphics];
  unsigned c = orderedSelection.count;
  if (c > 0) {
    IGDrawDocument *document = [self drawDocument];
    while (c-- > 0) {
      [document moveGraphic:orderedSelection[c] toIndex:0];
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Bring To Front", @"UndoStrings", @"Action name for bring to front.")];
  }
}

- (IBAction)sendToBack:(id)sender {
  NSArray *orderedSelection = [self orderedSelectedGraphics];
  unsigned i, c = orderedSelection.count;
  if (c > 0) {
    IGDrawDocument *document = [self drawDocument];
    unsigned lastIndex = [self graphicsOnPage:self.currentPage].count;
    for (i=0; i<c; i++) {
      [document moveGraphic:orderedSelection[i] toIndex:lastIndex];
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Send To Back", @"UndoStrings", @"Action name for send to back.")];
  }
}

- (IBAction)alignLeftEdges:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (curBounds.origin.x != firstBounds.origin.x) {
        curBounds.origin.x = firstBounds.origin.x;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Left Edges", @"UndoStrings", @"Action name for align left edges.")];
  }
}

- (IBAction)alignRightEdges:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (NSMaxX(curBounds) != NSMaxX(firstBounds)) {
        curBounds.origin.x = NSMaxX(firstBounds) - curBounds.size.width;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Right Edges", @"UndoStrings", @"Action name for align right edges.")];
  }
}

- (IBAction)alignTopEdges:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (curBounds.origin.y != firstBounds.origin.y) {
        curBounds.origin.y = firstBounds.origin.y;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Top Edges", @"UndoStrings", @"Action name for align top edges.")];
  }
}

- (IBAction)alignBottomEdges:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (NSMaxY(curBounds) != NSMaxY(firstBounds)) {
        curBounds.origin.y = NSMaxY(firstBounds) - curBounds.size.height;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Bottom Edges", @"UndoStrings", @"Action name for align bottom edges.")];
  }
}

- (IBAction)alignHorizontalCenters:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (NSMidX(curBounds) != NSMidX(firstBounds)) {
        curBounds.origin.x = NSMidX(firstBounds) - (curBounds.size.width / 2.0);
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Horizontal Centers", @"UndoStrings", @"Action name for align horizontal centers.")];
  }
}

- (IBAction)alignVerticalCenters:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (NSMidY(curBounds) != NSMidY(firstBounds)) {
        curBounds.origin.y = NSMidY(firstBounds) - (curBounds.size.height / 2.0);
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Align Vertical Centers", @"UndoStrings", @"Action name for align vertical centers.")];
  }
}

- (IBAction)makeSameWidth:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (curBounds.size.width != firstBounds.size.width) {
        curBounds.size.width = firstBounds.size.width;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Make Same Width", @"UndoStrings", @"Action name for make same width.")];
  }
}

- (IBAction)makeSameHeight:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 1) {
    NSRect firstBounds = [selection[0] bounds];
    IGGraphic *curGraphic;
    NSRect curBounds;
    for (i=1; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      if (curBounds.size.height != firstBounds.size.height) {
        curBounds.size.height = firstBounds.size.height;
        [curGraphic setBounds:curBounds];
      }
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Make Same Width", @"UndoStrings", @"Action name for make same width.")];
  }
}

- (IBAction)makeNaturalSize:(id)sender {
  NSArray *selection = [self selectedGraphics];
  if (selection.count > 0) {
    [selection makeObjectsPerformSelector:@selector(makeNaturalSize)];
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Make Natural Size", @"UndoStrings", @"Action name for natural size.")];
  }
}


// ===========================================================================
#pragma mark -
#pragma mark menu stuff
// ============================== menu stuff =================================

- (BOOL)validateMenuItem:(NSMenuItem *)item {
  SEL action = item.action;
  
  if (action == @selector(snapsToGridMenuAction:)) {
    item.state = ([self snapsToGrid] ? NSOnState : NSOffState);
    return YES;
  } else if (action == @selector(showsGridMenuAction:)) {
    item.state = ([self showsGrid] ? NSOnState : NSOffState);
    return YES;
  } else if (action == @selector(makeNaturalSize:)) {
    // Return YES if we have at least one selected graphic that has a natural size.
    NSArray *selectedGraphics = [self selectedGraphics];
    unsigned i, c = selectedGraphics.count;
    if (c > 0) {
      for (i=0; i<c; i++) {
        if ([selectedGraphics[i] hasNaturalSize]) {
          return YES;
        }
      }
    }
    return NO;
  } else if ((action == @selector(gridSelectedGraphicsAction:)) || (action == @selector(delete:)) || (action == @selector(bringToFront:)) || (action == @selector(sendToBack:)) || (action == @selector(cut:)) || (action == @selector(copy:))) {
    // These only apply if there is a selection
    return (([self selectedGraphics].count > 0) ? YES : NO);
  } else if ((action == @selector(alignLeftEdges:)) || (action == @selector(alignRightEdges:)) || (action == @selector(alignTopEdges:)) || (action == @selector(alignBottomEdges:)) || (action == @selector(alignHorizontalCenters:)) || (action == @selector(alignVerticalCenters:)) || (action == @selector(alignTextBaselines:)) || (action == @selector(makeSameWidth:)) || (action == @selector(makeSameHeight:))) {
    // These only apply to multiple selection
    return (([self selectedGraphics].count > 1) ? YES : NO);
  } else {
    return YES;
  }
}

- (IBAction)copy:(id)sender {
  NSArray *orderedSelection = [self orderedSelectedGraphics];
  if (orderedSelection.count > 0)
  {
    int i;
    for (i = 0; i < orderedSelection.count; i++)
    {
      NSLog(@"IGGraphicView(copy) -> %@", orderedSelection[i]);
    }
    
    IGDrawDocument *document = [self drawDocument];
    NSPasteboard *generalPBoard = [NSPasteboard generalPasteboard];
    NSPasteboard *privatePBoard = [NSPasteboard pasteboardWithName:@"IGGlyphPasteboard"];
    
    //[pboard declareTypes:[NSArray arrayWithObjects:IGDrawDocumentType, NSPDFPboardType, NSPostScriptPboardType, NSTIFFPboardType, nil] owner:nil];
    
    //pasteboard für innerhalb der Applikation
    [privatePBoard declareTypes:@[IGDrawDocumentType] owner:nil];
    
    [privatePBoard setData:[document drawDocumentDataForGraphicsSinglePage:orderedSelection] forType:IGDrawDocumentType];
    NSLog(@"nach setData drawDocument....");
    
    //pasteboard für ausserhalb der Applikation
    [generalPBoard declareTypes:@[NSPDFPboardType, NSPICTPboardType, NSTIFFPboardType] owner:nil];
    
    [generalPBoard setData:[document PDFRepresentationForGraphics:orderedSelection] forType:NSPDFPboardType];
    NSLog(@"nach setData PDFRep....");
    
    //[document EPSRepresentationForGraphics:orderedSelection];
    //[pboard setData:[document EPSRepresentationForGraphics:orderedSelection] forType:NSPostScriptPboardType];
    
    //NSLog(@"nach setData EPSRep....");
    
    [generalPBoard setData:[document TIFFRepresentationForGraphics:orderedSelection] forType:NSTIFFPboardType];
    NSLog(@"nach setData TIFFRep....");
    
    [generalPBoard setData:[document PICTRepresentationForGraphics:orderedSelection] forType:NSPICTPboardType];
    NSLog(@"nach setData PICTRep....");
    
    _pasteboardChangeCount = privatePBoard.changeCount;
    _pasteCascadeNumber = 1;
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
  }
}

- (IBAction)cut:(id)sender {
  [self copy:sender];
  [self delete:sender];
  [self.undoManager setActionName:NSLocalizedStringFromTable(@"Cut", @"UndoStrings", @"Action name for cut.")];
}

- (IBAction)paste:(id)sender {
  NSPasteboard *generalPBoard = [NSPasteboard generalPasteboard];
  NSPasteboard *privatePBoard = [NSPasteboard pasteboardWithName:@"IGGlyphPasteboard"];
  
  NSString *privateType = [privatePBoard availableTypeFromArray:@[IGDrawDocumentType, NSFilenamesPboardType]];
  NSString *generalType = [generalPBoard availableTypeFromArray:@[NSFilenamesPboardType]];
  
  if (privateType) {
    if ([privateType isEqualToString:IGDrawDocumentType]) {
      IGDrawDocument *document = [self drawDocument];
      NSDictionary *docDict = [document drawDocumentDictionaryFromData:[privatePBoard dataForType:privateType]];
      NSArray *array = [document graphicsFromDrawDocumentDictionarySinglePage:docDict];
      
      NSPoint pastePositionDelta = NSZeroPoint;
      pastePositionDelta.x = self.currentCursorPosition.x - [document boundsForGraphics:array].origin.x;
      pastePositionDelta.y = self.currentCursorPosition.y - [document boundsForGraphics:array].origin.y;
      pastePositionDelta.y -= [document boundsForGraphics:array].size.height;
      
      int i = array.count;
      if (i > 0) {
        id curGraphic;
        [self clearSelection];
        while (i-- > 0) {
          curGraphic = array[i];
          
          [curGraphic setPageNr:self.currentPage];
          [curGraphic moveBy:pastePositionDelta];
          
          [document insertGraphic:curGraphic atIndex:0];
          [self selectGraphic:curGraphic];
        }
        [self.undoManager setActionName:NSLocalizedStringFromTable(@"Paste", @"UndoStrings", @"Action name for paste.")];
      }
    }
  }
  if (generalType) {
    if ([generalType isEqualToString:NSFilenamesPboardType]) {
      NSArray *filenames = [generalPBoard propertyListForType:NSFilenamesPboardType];
      if (filenames.count == 1) {
        NSString *filename = filenames[0];
        if ([self makeNewImageFromContentsOfFile:filename atPoint:self.currentCursorPosition]) {
          [self.undoManager setActionName:NSLocalizedStringFromTable(@"Paste", @"UndoStrings", @"Action name for paste.")];
        }
      }
    }
  }
  
  /*
   if ([self makeNewImageFromPasteboard:pboard atPoint:NSMakePoint(50, 50)]) {
     [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Paste", @"UndoStrings", @"Action name for paste.")];
   }
   */
}

- (IBAction)duplicateSelection:(id)sender {
  
  NSArray *orderedSelection = [self orderedSelectedGraphics];
  IGDrawDocument *document = [self drawDocument];
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  
  if (orderedSelection.count > 0)
  {
    int i;
    for (i = 0; i < orderedSelection.count; i++)
    {
      NSLog(@"IGGraphicView(copy) -> %@", orderedSelection[i]);
    }
    
    [pboard declareTypes:@[IGDrawDocumentType] owner:nil];
    
    [pboard setData:[document drawDocumentDataForGraphicsSinglePage:orderedSelection] forType:IGDrawDocumentType];
    _pasteboardChangeCount = pboard.changeCount;
    _pasteCascadeNumber = 1;
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
  }
  
  NSDictionary *docDict = [document drawDocumentDictionaryFromData:[pboard dataForType:IGDrawDocumentType]];
  NSArray *array = [document graphicsFromDrawDocumentDictionarySinglePage:docDict];
  int i = array.count;
  int currentChangeCount = pboard.changeCount;
  
  if (_pasteboardChangeCount != currentChangeCount) {
    _pasteboardChangeCount = currentChangeCount;
    _pasteCascadeNumber = 0;
    _pasteCascadeDelta = NSMakePoint(IGDefaultPasteCascadeDelta, IGDefaultPasteCascadeDelta);
  }
  
  if (i > 0) {
    id curGraphic;
    NSPoint savedPasteCascadeDelta = _pasteCascadeDelta;
    
    [self clearSelection];
    while (i-- > 0) {
      curGraphic = array[i];
      if (_pasteCascadeNumber > 0) {
        [curGraphic setPageNr:self.currentPage];
        [curGraphic moveBy:NSMakePoint(_pasteCascadeNumber * savedPasteCascadeDelta.x, _pasteCascadeNumber * savedPasteCascadeDelta.y)];
      }
      NSLog(@"paste -> %@", curGraphic);
      [document insertGraphic:curGraphic atIndex:0];
      [self selectGraphic:curGraphic];
    }
    _pasteCascadeNumber++;
    _pasteCascadeDelta = savedPasteCascadeDelta;
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Paste", @"UndoStrings", @"Action name for paste.")];
  }
}


// ===========================================================================
#pragma mark -
#pragma mark keyboard commands
// ====================== keyboard commands ===========================


- (void)keyDown:(NSEvent *)event {
  // Pass on the key binding manager.  This will end up calling insertText: or some command selector.
  [self interpretKeyEvents:@[event]];
}

- (void)insertText:(NSString *)str {
  NSBeep();
}

- (void)hideKnobsMomentarily {
  if (_unhideKnobsTimer) {
    [_unhideKnobsTimer invalidate];
    _unhideKnobsTimer = nil;
  }
  _unhideKnobsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unhideKnobs:) userInfo:nil repeats:NO];
  _gvFlags.knobsHidden = YES;
  [self invalidateGraphics:[self selectedGraphics]];
}

- (void)unhideKnobs:(NSTimer *)timer {
  _gvFlags.knobsHidden = NO;
  [self invalidateGraphics:[self selectedGraphics]];
  [_unhideKnobsTimer invalidate];
  _unhideKnobsTimer = nil;
}

- (void)moveSelectedGraphicsByPoint:(NSPoint)delta {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 0) {
    [self hideKnobsMomentarily];
    for (i=0; i<c; i++) {
      [selection[i] moveBy:delta];
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Nudge", @"UndoStrings", @"Action name for nudge keyboard commands.")];
  }
}

- (void)moveLeft:(id)sender {
  [self moveSelectedGraphicsByPoint:NSMakePoint(-1.0, 0.0)];
}

- (void)moveRight:(id)sender {
  [self moveSelectedGraphicsByPoint:NSMakePoint(1.0, 0.0)];
}

- (void)moveUp:(id)sender {
  [self moveSelectedGraphicsByPoint:NSMakePoint(0.0, -1.0)];
}

- (void)moveDown:(id)sender {
  [self moveSelectedGraphicsByPoint:NSMakePoint(0.0, 1.0)];
}

- (void)moveForwardAndModifySelection:(id)sender {
  // We will use this to move by the grid spacing.
  [self moveSelectedGraphicsByPoint:NSMakePoint([self gridSpacing], 0.0)];
}

- (void)moveBackwardAndModifySelection:(id)sender {
  // We will use this to move by the grid spacing.
  [self moveSelectedGraphicsByPoint:NSMakePoint(-[self gridSpacing], 0.0)];
}

- (void)moveUpAndModifySelection:(id)sender {
  // We will use this to move by the grid spacing.
  [self moveSelectedGraphicsByPoint:NSMakePoint(0.0, -[self gridSpacing])];
}

- (void)moveDownAndModifySelection:(id)sender {
  // We will use this to move by the grid spacing.
  [self moveSelectedGraphicsByPoint:NSMakePoint(0.0, [self gridSpacing])];
}

- (void)deleteForward:(id)sender {
  [self delete:sender];
}

- (void)deleteBackward:(id)sender {
  [self delete:sender];
}

// ===========================================================================
#pragma mark -
#pragma mark grid IBAction stuff
// ============================= grid stuff ==================================

- (IBAction)snapsToGridMenuAction:(id)sender {
  [self setSnapsToGrid:([sender state] ? NO : YES)];
  // Menu item will get state fixed up in validateMenuItem:
  //[[PreferencesController sharedPreferencesController] updatePanel];
}

- (IBAction)showsGridMenuAction:(id)sender {
  [self setShowsGrid:([sender state] ? NO : YES)];
  // Menu item will get state fixed up in validateMenuItem:
  //[[PreferencesController sharedPreferencesController] updatePanel];
}

- (IBAction)gridSelectedGraphicsAction:(id)sender {
  NSArray *selection = [self selectedGraphics];
  unsigned i, c = selection.count;
  if (c > 0) {
    IGGraphic *curGraphic;
    NSRect curBounds;
    NSPoint curMaxPoint;
    float spacing = [self gridSpacing];
    
    for (i=0; i<c; i++) {
      curGraphic = selection[i];
      curBounds = [curGraphic bounds];
      curMaxPoint = NSMakePoint(NSMaxX(curBounds), NSMaxY(curBounds));
      curBounds.origin.x = floor((curBounds.origin.x / spacing) + 0.5) * spacing;
      curBounds.origin.y = floor((curBounds.origin.y / spacing) + 0.5) * spacing;
      curMaxPoint.x = floor((curMaxPoint.x / spacing) + 0.5) * spacing;
      curMaxPoint.y = floor((curMaxPoint.y / spacing) + 0.5) * spacing;
      curBounds.size.width = curMaxPoint.x - curBounds.origin.x;
      curBounds.size.height = curMaxPoint.y - curBounds.origin.y;
      [curGraphic setBounds:curBounds];
    }
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Grid Selected Graphics", @"UndoStrings", @"Action name for grid selected graphics.")];
  }
}

// ===========================================================================
#pragma mark -
#pragma mark grid and guideline settings
// ====================== Grid settings ===========================

- (BOOL)snapsToGrid {
  return _gvFlags.snapsToGrid;
}

- (void)setSnapsToGrid:(BOOL)flag {
  _gvFlags.snapsToGrid = flag;
}

- (BOOL)showsGrid {
  return _gvFlags.showsGrid;
}

- (void)setShowsGrid:(BOOL)flag {
  if (_gvFlags.showsGrid != flag) {
    NSLog(@"IGGraphicView(setShowsGrid)YES");
    _gvFlags.showsGrid = flag;
    [self setNeedsDisplay:YES];
  }
  NSLog(@"IGGraphicView(setShowsGrid)NO %i", _gvFlags.showsGrid);
}

- (float)gridSpacing {
  return _gvFlags.gridSpacing;
}

- (void)setGridSpacing:(float)spacing {
  if (_gvFlags.gridSpacing != spacing) {
    _gvFlags.gridSpacing = spacing;
    [self setNeedsDisplay:YES];
  }
}

- (NSColor *)gridColor {
  return (_gridColor ? _gridColor : [NSColor lightGrayColor]);
}

- (void)setGridColor:(NSColor *)color {
  if (_gridColor != color) {
    [_gridColor release];
    _gridColor = [color retain];
    [self setNeedsDisplay:YES];
  }
}

- (NSColor *)backgroundColor {
  return [_backgroundColor retain];
}

- (void)setBackgroundColor:(NSColor *)color {
  if (_backgroundColor != color) {
    [_backgroundColor release];
    _backgroundColor = [color retain];
    [self setNeedsDisplay:YES];
  }
}

- (int)guidelineType {
  return _gvFlags.guidelineType;
}

- (void)setGuidelineType:(int)value {
  if (_gvFlags.guidelineType != value) {
    _gvFlags.guidelineType = value;
    [self setNeedsDisplay:YES];
  }
}

- (int)guidelineCount {
  return _gvFlags.guidelineCount;
}

- (void)setGuidelineCount:(int)value {
  if (_gvFlags.guidelineCount != value) {
    _gvFlags.guidelineCount = value;
    [self setNeedsDisplay:YES];
  }
}





// ===========================================================================
#pragma mark -
#pragma mark multiple page view stuff
// ====================== Grid settings ===========================

- (void)setMarginLineColor:(NSColor *)color {
  if (color != marginLineColor) {
    [marginLineColor autorelease];
    marginLineColor = [color copyWithZone:[self zone]];
    [self setNeedsDisplay:YES];
  }
}

- (NSColor *)marginLineColor {
  return marginLineColor;
}

- (void)setPageBackgroundColor:(NSColor *)color {
  if (color != pageBackgroundColor) {
    [pageBackgroundColor autorelease];
    pageBackgroundColor = [color copyWithZone:[self zone]];
    [self setNeedsDisplay:YES];
  }
}

- (NSColor *)pageBackgroundColor {
  return pageBackgroundColor;
}

- (int)pageCount {
  return [[self drawDocument] pageCount];
}


- (IBAction)pageDown:(id)sender
{
  
  if ([sender tag] == 19 && self.currentPage > 1)
  {
    NSLog(@"pageDown to first page");
    self.currentPage = 1;
    
    [self clearSelection];
    [self updateCurrentPageField];
    [self setNeedsDisplay:YES];
    
  } else if ([sender tag] == 11 && self.currentPage > 1) {
    
    NSLog(@"pageDown one page");
    self.currentPage--;
    
    [self clearSelection];
    [self updateCurrentPageField];
    [self setNeedsDisplay:YES];
  }
  
}

- (IBAction)pageUp:(id)sender
{
  int pageCount = [self pageCount];
  
  if ([sender tag] == 29 && self.currentPage < pageCount)
  {
    NSLog(@"pageUp to last page");
    self.currentPage = pageCount;
    
    [self clearSelection];
    [self updateCurrentPageField];
    [self setNeedsDisplay:YES];
    
  } else if ([sender tag] == 21 && self.currentPage < pageCount) {
    
    NSLog(@"pageUp one page");
    self.currentPage++;
    
    [self clearSelection];
    [self updateCurrentPageField];
    [self setNeedsDisplay:YES];
  }
}

- (IBAction)insertPageBeforeThisOne:(id)sender
{
  if (NSRunAlertPanel(@"Insert Page", @"Do you realy want to insert a new page befor this one?", @"Cancel", @"OK", nil) == NSAlertDefaultReturn) return;
  
  NSLog(@"insertPageBeforeThisOne:");
  //[pageArr insertObject:[[NSMutableArray alloc] init] atIndex:(pageToDisplayRange.location -1)];
  [[self drawDocument] insertPageAtPage:(int)self.currentPage];
  [self clearSelection];
  [self updateCurrentPageField];
  [self setNeedsDisplay:YES];
}

- (IBAction)appendPageToEnd:(id)sender
{
  if (NSRunAlertPanel(@"Append Page", @"Do you realy want to append a new page to the end?", @"Cancel", @"OK", nil) == NSAlertDefaultReturn) return;
  
  NSLog(@"appendPageToEnd:");
  //[pageArr addObject:[[NSMutableArray alloc] init]];
  [[self drawDocument] insertPageAtPage:nil];
  self.currentPage = [self pageCount];
  [self clearSelection];
  [self updateCurrentPageField];
  [self setNeedsDisplay:YES];
}

- (IBAction)deleteCurrentPage:(id)sender
{
  
  if (NSRunAlertPanel(@"Delete Page", @"Do you realy want to delete this page?", @"Cancel", @"OK", nil) == NSAlertDefaultReturn) return;
  
  NSLog(@"deleteCurrentPage:");
  
  if ([self pageCount] > 1 && [self pageCount] == self.currentPage) { //mehr als eine Seite und ich befinde mich auf der letzten
    [[self drawDocument] removePage:self.currentPage];
    self.currentPage--;
  } else {//eine oder mehr Seiten und ich befinde mich NICHT auf der letzten
    [[self drawDocument] removePage:self.currentPage];
  }
  [self clearSelection];
  [self updateCurrentPageField];
  [self setNeedsDisplay:YES];
}

- (IBAction)goToPage:(id)sender
{
  int page = [sender intValue];
  if ((page == 0) || (page > [self pageCount])) {
    NSBeep();
  } else {
    self.currentPage = page;
  }
  
  [self clearSelection];
  [self updateCurrentPageField];
  [self setNeedsDisplay:YES];
}

- (void)updateCurrentPageField {
  
  currentPageField.stringValue = [[NSString alloc] initWithFormat:@"%d of %d", self.currentPage, [self pageCount]];
}



// ===========================================================================
#pragma mark -
#pragma mark selection printing stuff
// ========================= Selection Printing ==============================

- (IBAction)printSelection:(id)sender {
  [[self drawDocument] printSelection:[self selectedGraphics]];
}

@end
