//
//  IGDrawDocument.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//
// removeGraphic sicherheit rausgenommen....

#import "IGDrawDocument.h"
#import "IGDocumentWindowController.h"
#import "IGGraphic.h"
#import "IGRenderingView.h"
#import "IGGlyph.h"
#import "IGTextArea.h"
#import "IGCartouche.h"
#import "IGPageNr.h"
#import "IGLine.h"
#import "IGRubric.h"
#import "IGDestroyed.h"
#import "IGRectangle.h"
#import "IGCircle.h"
#import "IGArc.h"
#import "IGImage.h"
#import "IGFontData.h"
#import "PageNrController.h"
#import "IGGraphicView.h"
#import "PreferencesController.h"
#import "IGlyphDelegate.h"
#import "FormatGlyphController.h"

#import <Carbon/Carbon.h>

NSString *IGDrawDocumentType = @"iGlyph Format";
NSString *IGDrawPCDocType = @"VisualGlyph PC Format";

@implementation IGDrawDocument

- (IGDrawDocument *)init {
    self = [super init];
    if (self) {
        
        // the _documentPages array is an array that has an array for every page.
        // the page array index is the same as the page nummber and a header which is on page 0.
        // page arrays 0 and 1 are created here
        
        _selectedPageObjects = [[NSMutableArray alloc] init];
        _documentPages = [[NSMutableArray alloc] init];
        
        [self.documentPages addObject:[[NSMutableArray alloc] init]];
        [self.documentPages addObject:[[NSMutableArray alloc] init]];
        
        NSLog(@"IGDrawDocument init");
        self.printInfo.leftMargin = 72;
        self.printInfo.rightMargin = 72;
        self.printInfo.topMargin = 72;
        self.printInfo.bottomMargin = 72;
        
        //PageNr Stuff
        _showPageNumbers = NO;
        _pageNumberFont = @"Arial";
        _pageNumberSize = 12;
        _pageNumberStyle = 0;
        _pageNumberFormatArr = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
        _initialPageNr = 1;
        _pageNrAlignment = 1; //center
        _pageNrPosition = 0; //Header
        _firstPageNumberToShow = 1;
        _pnDeltaPosition = NSZeroSize;
        
        self.documentFontSize = 25;
        self.documentCharSpacing = 10;
        self.documentLineSpacing = 1;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)makeWindowControllers {
    IGDocumentWindowController *myController = [[IGDocumentWindowController alloc] init];
    [self addWindowController:myController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    NSLog(@"IGDrawDocument(windowControllerDidLoadNib)");
    [super windowControllerDidLoadNib:windowController];
    self.printInfo = [[NSPrintInfo sharedPrintInfo] copy];
    self.printInfo.horizontalPagination = NSAutoPagination;
    self.printInfo.verticalPagination = NSAutoPagination;
}

static NSString *IGGraphicsListKey = @"GraphicsList";
static NSString *IGDrawDocumentVersionKey = @"DrawDocumentVersion";
static int IGCurrentDrawDocumentVersion = 0.5;
//static NSString *IGPrintInfoKey = @"PrintInfo";
static NSString *IGDrawDocumentPageNumberingKey = @"PageNumbering";
static NSString *IGDrawDocumentDefaultValuesKey = @"DefaultValues";


- (NSDictionary *)drawDocumentDictionaryForGraphics:(NSArray *)graphics {
    NSMutableDictionary *doc = [NSMutableDictionary dictionary];
    NSMutableDictionary *pnDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dvDic = [NSMutableDictionary dictionary];
    
    NSUInteger i, pCount = graphics.count; // pages
    NSUInteger j, gCount; // graphics per page
    NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:pCount]; // all pages
    NSMutableArray *graphicsArray;
    
    for (i=0; i < pCount; i++) {
        gCount = [graphics[i] count];
        graphicsArray = [NSMutableArray arrayWithCapacity:gCount];
        for (j = 0; j < gCount; j++) {
            [graphicsArray addObject:[graphics[i][j] propertyListRepresentation]];
        }
        [pageArray addObject:graphicsArray];
    }
    
    //grafische objekte
    doc[IGGraphicsListKey] = pageArray;
    doc[IGDrawDocumentVersionKey] = [NSString stringWithFormat:@"%d", IGCurrentDrawDocumentVersion];
    doc[IGPrintInfoKey] = [NSArchiver archivedDataWithRootObject:self.printInfo];
    
    //page number stuff
    pnDic[@"showPageNumbers"] = (self.showPageNumbers ? @"YES" : @"NO");
    pnDic[@"pageNumberFont"] = self.pageNumberFont;
    pnDic[@"pageNumberSize"] = [NSString stringWithFormat:@"%ld", (long)self.pageNumberSize];
    pnDic[@"pageNumberStyle"] = [NSString stringWithFormat:@"%ld", (long)self.pageNumberStyle];
    pnDic[@"pageNumberFormatArr"] = self.pageNumberFormatArr;
    pnDic[@"firstPageNumberToShow"] = [NSString stringWithFormat:@"%ld", (long)self.firstPageNumberToShow];
    pnDic[@"pageNrAlignment"] = [NSString stringWithFormat:@"%ld", (long)self.pageNrAlignment];
    pnDic[@"pageNrPosition"] = [NSString stringWithFormat:@"%ld", (long)self.pageNrPosition];
    pnDic[@"initialPageNr"] = [NSString stringWithFormat:@"%ld", (long)self.initialPageNr];
    pnDic[@"pnDeltaPosition"] = NSStringFromSize(self.pnDeltaPosition);
    doc[IGDrawDocumentPageNumberingKey] = pnDic;
    
    //default values
    dvDic[@"fontSize"] = [NSString stringWithFormat:@"%ld", (long)self.documentFontSize];
    doc[IGDrawDocumentDefaultValuesKey] = dvDic;
    
    return doc;
}

- (NSDictionary *)drawDocumentDictionaryForGraphicsSinglePage:(NSArray *)graphics //wird für copy gebraucht
{  
    NSMutableDictionary *doc = [NSMutableDictionary dictionary];
    NSUInteger j, gCount = graphics.count; // graphics
    NSMutableArray *graphicsArray = [NSMutableArray arrayWithCapacity:gCount];
    
    for (j = 0; j < gCount; j++) {
        [graphicsArray addObject:[graphics[j] propertyListRepresentation]];
    }
    
    doc[IGGraphicsListKey] = graphicsArray;
    doc[IGDrawDocumentVersionKey] = [NSString stringWithFormat:@"%d", IGCurrentDrawDocumentVersion];
    doc[IGPrintInfoKey] = [NSArchiver archivedDataWithRootObject:self.printInfo];
    
    return doc;
}

- (NSData *)drawDocumentDataForGraphics:(NSArray *)graphics {
    NSDictionary *doc = [self drawDocumentDictionaryForGraphics:graphics];
    NSAssert(doc, @"Unable to create drawDocumentDictionaryForGraphics");
    NSString *string = doc.description;
    return [string dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)drawDocumentDataForGraphicsSinglePage:(NSArray *)graphics //wird für copy gebraucht
{
    NSDictionary *doc = [self drawDocumentDictionaryForGraphicsSinglePage:graphics];
    NSAssert(doc, @"Unable to create drawDocumentDictionaryForGraphics");
    NSString *string = doc.description;
    return [string dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSDictionary *)drawDocumentDictionaryFromData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSDictionary *doc = [string propertyList];
    return doc;
}

- (NSArray *)graphicsFromDrawDocumentDictionary:(NSDictionary *)doc {
    NSArray *graphicDicts = doc[IGGraphicsListKey];
    NSUInteger i, pCount = graphicDicts.count; //pages
    NSUInteger j, gCount; //graphics per page
    NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:pCount]; //all pages
    NSMutableArray *graphicsArray;
    
    for (i = 0; i < pCount; i++) {
        gCount = [graphicDicts[i] count];
        graphicsArray = [NSMutableArray arrayWithCapacity:gCount];
        for (j = 0; j < gCount; j++) {
            [graphicsArray addObject:[IGGraphic graphicWithPropertyListRepresentation:graphicDicts[i][j]]];
        }
        [pageArray addObject:graphicsArray];
    }
    
    return pageArray;
}

- (NSArray *)graphicsFromDrawDocumentDictionarySinglePage:(NSDictionary *)doc {
    NSArray *graphicDicts = doc[IGGraphicsListKey];
    //NSUInteger i, pCount = [graphicDicts count]; //pages
    NSUInteger j, gCount = graphicDicts.count; //graphics per page
    //NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:pCount]; //all pages
    NSMutableArray *graphicsArray = [NSMutableArray arrayWithCapacity:gCount];
    
    //for (i = 0; i < pCount; i++) {
    //gCount = [[graphicDicts objectAtIndex:i] count];
    //graphicsArray = [NSMutableArray arrayWithCapacity:gCount];
    for (j = 0; j < gCount; j++) {
        [graphicsArray addObject:[IGGraphic graphicWithPropertyListRepresentation:graphicDicts[j]]];
    }
    //[pageArray addObject:graphicsArray];
    //}
    
    //return pageArray;
    return graphicsArray;
}


- (NSRect)boundsForGraphics:(NSArray *)graphics {
    NSRect rect = NSZeroRect;
    NSUInteger i, c = graphics.count;
    for (i=0; i<c; i++) {
        if (i==0) {
            rect = [graphics[i] bounds];
        } else {
            rect = NSUnionRect(rect, [graphics[i] bounds]);
        }
    }
    return rect;
}

- (NSRect)drawingBoundsForGraphics:(NSArray *)graphics //Achtung nur graphics im array, und keine Seite mit Graphics!!!!
{
    NSRect rect = NSZeroRect;
    NSUInteger i, c = graphics.count;
    NSAssert(c > 0, @"Array ist leer was nicht sein duerfte");
    for (i=0; i < c; i++) {
        if (i==0) {
            rect = [graphics[i] drawingBounds];
        } else {
            rect = NSUnionRect(rect, [graphics[i] drawingBounds]);
        }
    }
    NSAssert(!NSEqualRects(rect,NSZeroRect), @"Null Bounds kann nicht sein!!!");
    return rect;
}

- (NSRect)wordExportBoundsForGraphics:(NSArray *)graphics //Achtung nur graphics im array, und keine Seite mit Graphics!!!!
{
    NSRect rect = NSZeroRect;
    NSUInteger i, c = graphics.count;
    NSAssert(c > 0, @"Array ist leer was nicht sein duerfte");
    for (i=0; i < c; i++) {
        if (i==0) {
            rect = NSInsetRect([graphics[i] bounds], -0.5, -0.2);
        } else {
            rect = NSUnionRect(rect, NSInsetRect([graphics[i] bounds], -0.5, -0.2));
        }
    }
    NSAssert(!NSEqualRects(rect,NSZeroRect), @"Null Bounds kann nicht sein!!!");
    return rect;
}

// MARK: -
// MARK: data representation methods (used for copy/paste)

- (NSData *)TIFFRepresentationForGraphics:(NSArray *)graphics
{
    NSRect bounds = [self drawingBoundsForGraphics:graphics];
    NSRect drawingBounds;
    NSImage *image;
    NSData *tiffData;
    NSUInteger i = graphics.count;
    NSAffineTransform *transform;
    IGGraphic *curGraphic;
    NSGraphicsContext *currentContext;
    
    if (NSIsEmptyRect(bounds)) {
        return nil;
    }
    image = [[NSImage alloc] initWithSize:bounds.size];
    
    NSLog(@"x = %f, y = %f, w = %f, h = %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    
    [image setFlipped:YES];
    [image lockFocus];
    // Get the context AFTER we lock focus
    currentContext = [NSGraphicsContext currentContext];
    transform = [NSAffineTransform transform];
    [transform translateXBy:-bounds.origin.x yBy:-bounds.origin.y];
    [transform concat];
    bounds.size.width += 1;
    bounds.size.height += 1;
    [[NSColor whiteColor] set];
    NSRectFill(bounds);
    
    while (i-- > 0) {
        // The only reason a graphic knows what view it is drawing in is so that it can draw differently
        // when being created or edited or selected.  A nil view means to draw in the standard way.
        curGraphic = graphics[i];
        drawingBounds = curGraphic.drawingBounds;
        [currentContext saveGraphicsState];
        [NSBezierPath clipRect:drawingBounds];
        [curGraphic drawInView:nil isSelected:NO];
        [currentContext restoreGraphicsState];
    }
    
    //[image setSize:NSMakeSize((int)(bounds.size.width * 72/600),(int)(bounds.size.height * 72/600))];
    [image unlockFocus];
    
    
    //[[[image representations] objectAtIndex:0] setSize:NSMakeSize((int)(bounds.size.width * 72/600),(int)(bounds.size.height * 72/600))];
    tiffData = image.TIFFRepresentation;
    return tiffData;
}

- (NSData *)PDFRepresentationForGraphics:(NSArray *)graphics {
    //NSRect bounds = [self drawingBoundsForGraphics:graphics];
    NSRect bounds = [self boundsForGraphics:graphics];
    
    NSSize paperSize = self.paperSize;
    
    //erstelle die IGRenderingView als wäre es ein Seite
    IGRenderingView *view = [[IGRenderingView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) graphics:graphics pageCount:0 document:self];
    NSData *pdfData = Nil;
    
    //Speichere den Teil mit den Glyphen als pdfData
    pdfData = [view dataWithPDFInsideRect:bounds];
    
    //NSLog(@"%@", pdfData);
    return pdfData;
}

- (NSData *)EPSRepresentationForGraphics:(NSArray *)graphics {
    NSRect bounds = [self drawingBoundsForGraphics:graphics];
    
    NSSize paperSize = self.paperSize;
    
    //erstelle die IGRenderingView als wäre es ein Seite
    IGRenderingView *view = [[IGRenderingView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) graphics:graphics pageCount:0 document:self];
    
    NSMutableData *epsData = NULL;
    
    NSPrintOperation *printOp;
    
    printOp = [NSPrintOperation PDFOperationWithView:view insideRect:bounds toData:epsData];
    [printOp setShowsPrintPanel:NO];
    [printOp setCanSpawnSeparateThread:YES];
    
    [printOp runOperation];
    
    //Speichere den Teil mit den Glyphen als epsData
    //epsData = [view dataWithEPSInsideRect:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height)];
    //[view writeEPSInsideRect:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) toPasteboard:[NSPasteboard generalPasteboard]];
    //[view writeEPSInsideRect:bounds toPasteboard:[NSPasteboard generalPasteboard]];
    
    //[view release];
    //NSLog(@"%@", epsData);
    return epsData;
    //return NULL;
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
    if ([type isEqualToString:IGDrawDocumentType]) {
        return [self drawDocumentDataForGraphics:self.documentPages];
    } else if ([type isEqualToString:NSTIFFPboardType]) {
        return [self TIFFRepresentationForGraphics:self.documentPages];
    } else if ([type isEqualToString:NSPDFPboardType]) {
        return [self PDFRepresentationForGraphics:self.documentPages];
    } else if ([type isEqualToString:NSPostScriptPboardType]) {
        return [self EPSRepresentationForGraphics:self.documentPages];
    } else {
        return nil;
    }
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
    if ([type isEqualToString:IGDrawDocumentType]) {
        NSDictionary *doc = [self drawDocumentDictionaryFromData:data];
        self.documentPages = [[NSMutableArray alloc] init];
        [self.documentPages addObjectsFromArray:[self graphicsFromDrawDocumentDictionary:doc]];
        
        data = doc[IGPrintInfoKey];
        if (data) {
            NSPrintInfo *printInfo = [NSUnarchiver unarchiveObjectWithData:data];
            if (printInfo) {
                self.printInfo = printInfo;
            }
        }
        
        id obj;
        
        NSDictionary *pnDic = doc[IGDrawDocumentPageNumberingKey];
        if (pnDic) {
            obj = pnDic[@"showPageNumbers"];
            if (obj) {
                self.showPageNumbers = [obj isEqualToString:@"YES"];
            }
            obj = pnDic[@"pageNumberFont"];
            if (obj) {
                [self setPageNumberFont:obj];
            }
            obj = pnDic[@"pageNumberSize"];
            if (obj) {
                self.pageNumberSize = [obj floatValue];
            }
            obj = pnDic[@"pageNumberStyle"];
            if (obj) {
                self.pageNumberStyle = [obj intValue];
            }
            obj = pnDic[@"pageNumberFormatArr"];
            if (obj) {
                self.pageNumberFormatArr = obj;
            }
            obj = pnDic[@"firstPageNumberToShow"];
            if (obj) {
                self.firstPageNumberToShow = [obj intValue];
            }
            obj = pnDic[@"pageNrAlignment"];
            if (obj) {
                self.pageNrAlignment = [obj intValue];
            }
            obj = pnDic[@"pageNrPosition"];
            if (obj) {
                self.pageNrPosition = [obj intValue];
            }
            obj = pnDic[@"initialPageNr"];
            if (obj) {
                self.initialPageNr = [obj intValue];
            }
            obj = pnDic[@"pnDeltaPosition"];
            if (obj) {
                _pnDeltaPosition = NSSizeFromString(obj);
            }
        }
        
        NSDictionary *dvDic = doc[IGDrawDocumentDefaultValuesKey];
        if (dvDic) {
            obj = dvDic[@"fontSize"];
            if (obj) {
                self.documentFontSize = [obj floatValue];
            }
        }
        
        [self.undoManager removeAllActions];
        
        return YES;
    }
    return NO;
}



- (void)updateChangeCount:(NSDocumentChangeType)change {
    // This clears the undo stack whenever we load or save.
    [super updateChangeCount:change];
    if (change == NSChangeCleared) {
        [self.undoManager removeAllActions];
    }
}

- (NSWindow *)appropriateWindowForDocModalOperations {
    NSArray *wcs = self.windowControllers;
    NSUInteger i, c = wcs.count;
    NSWindow *docWindow = nil;
    
    for (i=0; i<c; i++) {
        docWindow = [wcs[i] window];
        if (docWindow) {
            break;
        }
    }
    return docWindow;
}

- (NSSize)documentSize {
    NSPrintInfo *printInfo = self.printInfo;
    NSSize paperSize = printInfo.paperSize;
    paperSize.width -= (printInfo.leftMargin + printInfo.rightMargin);
    paperSize.height -= (printInfo.topMargin + printInfo.bottomMargin);
    return paperSize;
}

- (NSSize)paperSize {
    NSPrintInfo *printInfo = self.printInfo;
    NSSize paperSize = printInfo.paperSize;
    return paperSize;
}

- (void)printShowingPrintPanel:(BOOL)flag {
    
    NSPrintInfo *printInfo = self.printInfo;
    NSPrintOperation *printOp;
    NSWindow *docWindow = [self appropriateWindowForDocModalOperations];
    
    NSSize paperSize = self.paperSize;
    //Die IGRenderingView wird benutzt um die Daten für den Druck aufzubereiten....So ist es möglich die Darstellung in der IGGraphicView so zu gestallten wie man will ohne daran an den Druck achten zu müssen!!! COOL
    IGRenderingView *view = [[IGRenderingView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) graphics:self.documentPages pageCount:self.pageCount document:self];
    
    printOp = [NSPrintOperation printOperationWithView:view printInfo:printInfo];
    [printOp setShowPanels:flag];
    [printOp setCanSpawnSeparateThread:YES];
    
    if (docWindow) {
        (void)[printOp runOperationModalForWindow:docWindow delegate:nil didRunSelector:NULL contextInfo:NULL];
    } else {
        (void)[printOp runOperation];
    }
}

- (void)printSelection:(NSArray *)graphics {
    
    NSPrintInfo *printInfo = self.printInfo;
    NSPrintOperation *printOp;
    NSWindow *docWindow = [self appropriateWindowForDocModalOperations];
    
    NSSize paperSize = self.paperSize;
    //Die IGRenderingView wird benutzt um die Daten für den Druck aufzubereiten....So ist es möglich die Darstellung in der IGGraphicView so zu gestallten wie man will ohne daran an den Druck achten zu müssen!!! COOL
    IGRenderingView *view = [[IGRenderingView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) graphics:graphics pageCount:0 document:self];
    
    printOp = [NSPrintOperation printOperationWithView:view printInfo:printInfo];
    [printOp setShowPanels:YES];
    [printOp setCanSpawnSeparateThread:YES];
    
    if (docWindow) {
        (void)[printOp runOperationModalForWindow:docWindow delegate:nil didRunSelector:NULL contextInfo:NULL];
    } else {
        (void)[printOp runOperation];
    }
}

- (void)setPrintInfo:(NSPrintInfo *)printInfo {
    [[self.undoManager prepareWithInvocationTarget:self] setPrintInfo:self.printInfo];
    super.printInfo = printInfo;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Print Info", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
}



- (NSArray *)graphicsOnPage:(NSUInteger)pageNr {
    return (self.documentPages)[pageNr];
}

- (void)createGraphicOfClassGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos onPage:(NSUInteger)page {
    [self clearSelection];
    //wenn ich eine neue glyphe erstelle, will ich sie mit den standard eigenschaften erstellen und nicht wie die letzte die ich verändert habe
    //ich muss dann ins leere klicken und dann die einstellungen ändern, welche für alle neuen glyphen gelten
    [[FormatGlyphController sharedFormatGlyphController] restoreTmpFormating];
    
    IGGlyph *newGraphic = [[IGGlyph alloc] init];
    //NSLog(@"IGGraphicView(createGraphicOfClassGlyph) nach init -> %@", _creatingGraphic);
    if ([newGraphic createGlyph:glyphUniChar withFont:fontName onPosition:pos onPage:page]) {
        //NSLog(@"IGGraphicView(createGraphicOfClassGlyph) nach createGlyph -> %@", _creatingGraphic);
        
        [self insertGraphic:newGraphic atIndex:0];
        [self selectGraphic:newGraphic];
    }
}

- (void)setGraphics:(NSArray *)graphics {
    NSAssert([self.documentPages count], @"IGDrawDocument - setGraphics -> Unable to get graphics count");
    
    NSInteger pCount = self.pageCount;
    NSInteger gCount;
    
    while (pCount-- > 0) {
        gCount = [(self.documentPages)[pCount] count];
        while (gCount-- > 0) {
            [self removeGraphicAtIndex:gCount onPage:gCount];
        }
        [self.documentPages removeObjectAtIndex:pCount];
    }
    
    pCount = graphics.count;
    while (pCount-- > 0) {
        [self.documentPages insertObject:[[NSMutableArray alloc] init] atIndex:0];
        gCount = [graphics[pCount] count];
        while (gCount-- > 0) {
            IGGraphic *curGraphic = graphics[pCount][gCount];
            [(self.documentPages)[0] insertObject:curGraphic atIndex:0];
            curGraphic.document = self;
            //[self invalidateGraphic:curGraphic];
            //[self redisplayTweak:curGraphic];
        }
    }
}

- (void)setGraphics:(NSArray *)graphics onPage:(NSUInteger)pageNr {
    NSUInteger i = [(self.documentPages)[pageNr] count];
    while (i-- > 0) {
        [self removeGraphicAtIndex:i onPage:pageNr];
    }
    i = graphics.count;
    while (i-- > 0) {
        //[self insertGraphic:[[self graphicsOnPage:pageNr] objectAtIndex:i] atIndex:0];
        [self insertGraphic:graphics[i] atIndex:0];
    }
}

- (void)invalidateGraphic:(IGGraphic *)graphic {
    NSArray *windowControllers = self.windowControllers;
    [windowControllers makeObjectsPerformSelector:@selector(invalidateGraphic:) withObject:graphic];
}

- (void)redisplayTweak:(IGGraphic *)graphic {
    NSArray *windowControllers = self.windowControllers;
    [windowControllers makeObjectsPerformSelector:@selector(redisplayTweak:) withObject:graphic];
}

- (void)insertGraphic:(IGGraphic *)graphic atIndex:(NSUInteger)index {
    NSAssert([graphic pageNr], @"Unable to get PageNr");
    NSUInteger pageNr = graphic.pageNr;
    [[self.undoManager prepareWithInvocationTarget:self] removeGraphicAtIndex:index onPage:pageNr];
    [(self.documentPages)[pageNr] insertObject:graphic atIndex:index];
    graphic.document = self;
    [self invalidateGraphic:graphic];
    NSLog(@"IGDrawDocument(insertGraphic)-->IGGraphic inserted: %@", graphic);
}

- (void)removeGraphicAtIndex:(NSUInteger)index onPage:(NSUInteger)pageNr {
    id graphic = (self.documentPages)[pageNr][index];
    [(self.documentPages)[pageNr] removeObjectAtIndex:index];
    [self invalidateGraphic:graphic];
    [[self.undoManager prepareWithInvocationTarget:self] insertGraphic:graphic atIndex:index];
}

- (void)removeGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawDocument(removeGraphics)");
    //NSAssert([graphic pageNr], @"Unable to get PageNr");
    NSUInteger pageNr = graphic.pageNr;
    NSUInteger index = [(self.documentPages)[pageNr] indexOfObjectIdenticalTo:graphic];
    //if (index != NSNotFound) {
    [self removeGraphicAtIndex:index onPage:pageNr];
    //}
}

- (void)moveGraphic:(IGGraphic *)graphic toIndex:(NSUInteger)newIndex {
    NSUInteger pageNr = graphic.pageNr;
    NSUInteger curIndex = [(self.documentPages)[pageNr] indexOfObjectIdenticalTo:graphic];
    if (curIndex != newIndex) {
        [[self.undoManager prepareWithInvocationTarget:self] moveGraphic:graphic toIndex:((curIndex > newIndex) ? curIndex+1 : curIndex)];
        if (curIndex < newIndex) {
            newIndex--;
        }
        [(self.documentPages)[pageNr] removeObjectAtIndex:curIndex];
        [(self.documentPages)[pageNr] insertObject:graphic atIndex:newIndex];
        [self invalidateGraphic:graphic];
    }
}

- (void)moveGraphic:(IGGraphic *)graphic toPage:(NSUInteger)pageNr {
    [self removeGraphic:graphic];
    graphic.pageNr = pageNr;
    [(self.documentPages)[pageNr] addObject:graphic];
}

- (void)insertPageAtPage:(NSUInteger)pageNr {
    if (!pageNr) {
        [self.documentPages addObject:[[NSMutableArray alloc] init]];
    } else {
        [self.documentPages insertObject:[[NSMutableArray alloc] init] atIndex:pageNr];
        //da alle grafischen Objecte die Seite gewechselt haben, müssen sie mit der richtigen Seitenzahl geupdated werden
        NSUInteger i;
        NSUInteger count = [self graphicsOnPage:(pageNr + 1)].count;
        for (i = 0; i < count; i++) {
            [[self graphicsOnPage:(pageNr + 1)][i] setPageNr:(pageNr + 1)];
        }
    }
}

- (void)removePage:(NSUInteger)pageNr {
    if (pageNr == 1) {
        [self.documentPages removeObjectAtIndex:pageNr];
        [self.documentPages addObject:[[NSMutableArray alloc] init]];
    } else {
        [self.documentPages removeObjectAtIndex:pageNr];
    }
}

// MARK: -
// MARK: object selection

- (void)selectGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawDocument(selectGraphic)");
    
    NSUInteger curIndex = [self.selectedPageObjects indexOfObjectIdenticalTo:graphic];
    if (curIndex == NSNotFound) {
        [[self.undoManager prepareWithInvocationTarget:self] deselectGraphic:graphic];
        [self.undoManager setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
        
        [self.selectedPageObjects addObject:graphic];
        
        [self.windowControllers[0] invalidateGraphic: graphic];
    }
}

- (void)deselectGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawDocument(deselectGraphic)");
    
    NSUInteger curIndex = [self.selectedPageObjects indexOfObjectIdenticalTo:graphic];
    if (curIndex != NSNotFound) {
        [[self.undoManager prepareWithInvocationTarget:self] selectGraphic:graphic];
        [self.undoManager setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
        
        //[self willChangeSomething]; //KVO manual notification
        [self.selectedPageObjects removeObjectAtIndex:curIndex];
        //[self didChangeSomething]; //KVO manual notification
        
        [self.windowControllers[0] invalidateGraphic: graphic];
    }
    
    
}

- (void)clearSelection {
    NSLog(@"IGDrawDocument(clearSelection)");
    
    NSArray* selection = self.selectedPageObjects;
    for ( IGGraphic *oneGraphic in selection ) {
        [self.windowControllers[0] invalidateGraphic:oneGraphic];
    }
    
    [self.selectedPageObjects removeAllObjects];
}

// MARK: -
// MARK: PROPERTIES

// MARK: -
// MARK: default document properties

- (NSInteger)pageCount {
    return self.documentPages.count - 1;
}

- (void)setDocumentFontSize:(NSInteger)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setDocumentFontSize:self.documentFontSize];
    _documentFontSize = value;
    [FormatGlyphController sharedFormatGlyphController].fontSize = value;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Document Font Size", @"UndoStrings", @"Action name for changing document font size.")];
    //[[self windowControllers] makeObjectsPerformSelector:@selector(setUpGraphicView)];
    //[[FormatGlyphController sharedFormatGlyphController] updatePanel];
    
    NSLog(@"changed documentFontSize to: %ld", (long)_documentFontSize);
}

- (void)setDocumentCharSpacing:(NSInteger)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setDocumentCharSpacing:self.documentCharSpacing];
    _documentCharSpacing = value;
    //[[FormatGlyphController sharedFormatGlyphController] setFontSize:value];
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Document Char Spacing", @"UndoStrings", @"Action name for changing document font size.")];
    //[[self windowControllers] makeObjectsPerformSelector:@selector(setUpGraphicView)];
    //[[FormatGlyphController sharedFormatGlyphController] updatePanel];
    
    NSLog(@"changed documentCharSpacing to: %ld", (long)_documentCharSpacing);
}

- (void)setDocumentLineSpacing:(CGFloat)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setDocumentLineSpacing:self.documentLineSpacing];
    _documentLineSpacing = value;
    //[[FormatGlyphController sharedFormatGlyphController] setFontSize:value];
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Document Font Size", @"UndoStrings", @"Action name for changing document font size.")];
    //[[self windowControllers] makeObjectsPerformSelector:@selector(setUpGraphicView)];
    //[[FormatGlyphController sharedFormatGlyphController] updatePanel];
    
    NSLog(@"changed documentLineSpacing to: %f", _documentLineSpacing);
}


// MARK: -
// MARK: page numbering properties

- (void)setShowPageNumbers:(BOOL)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setShowPageNumbers:self.showPageNumbers];
    _showPageNumbers = value;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Show PageNr", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
    
    
    NSLog(@"changed showPageNr to: %i", _showPageNumbers);
}

- (void)setPageNumberFont:(NSString *)fontName
{
    [[self.undoManager prepareWithInvocationTarget:self] setPageNumberFont:self.pageNumberFont];
    _pageNumberFont = fontName;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change Page Number Font", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setPageNumberSize:(NSInteger)size
{    
    [[self.undoManager prepareWithInvocationTarget:self] setPageNumberSize:self.pageNumberSize];
    _pageNumberSize = size;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr Size", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setPageNumberStyle:(NSInteger)style
{
    [[self.undoManager prepareWithInvocationTarget:self] setPageNumberStyle:self.pageNumberStyle];
    _pageNumberStyle = style;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr Style", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setPageNumberFormatArr:(NSMutableArray *)array
{
    [[self.undoManager prepareWithInvocationTarget:self] setPageNumberFormatArr:self.pageNumberFormatArr];
    _pageNumberFormatArr = array;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr Format", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setInitialPageNr:(NSInteger)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setInitialPageNr:self.initialPageNr];
    _initialPageNr = value;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change first PageNr", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setPageNrAlignment:(NSInteger)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setPageNrAlignment:self.pageNrAlignment];
    _pageNrAlignment = value;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr Alignment", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)setPageNrPosition:(NSInteger)position
{
    [[self.undoManager prepareWithInvocationTarget:self] setPageNrPosition:self.pageNrPosition];
    _pageNrPosition = position;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr Position", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

//the number of the page on which the first pagenumber should show up
- (void)setFirstPageNumberToShow:(NSInteger)value
{
    [[self.undoManager prepareWithInvocationTarget:self] setFirstPageNumberToShow:self.firstPageNumberToShow];
    _firstPageNumberToShow = value;
    
    [self.undoManager setActionName:NSLocalizedStringFromTable(@"Change PageNr First Page", @"UndoStrings", @"Action name for changing print info.")];
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
    [[PageNrController sharedPageNrController] updatePanel];
}

- (void)finetuneXParameter:(float)xValue
{
    _pnDeltaPosition.width += xValue;
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
}

- (void)finetuneYParameter:(float)yValue
{
    _pnDeltaPosition.height += yValue;
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
}

- (void)finetuneReset
{
    _pnDeltaPosition = NSZeroSize;
    [self.windowControllers makeObjectsPerformSelector:@selector(setUpGraphicView)];
}
@end
