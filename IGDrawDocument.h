//
//  IGDrawDocument.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IGGraphic;
@class IGGraphicView;

@interface IGDrawDocument : NSDocument {
  
  NSMutableArray *selectedGraphics;
  NSMutableArray *documentGraphics;
  
  
@private
  
  NSUInteger _pageCount; //nummber of pages in this document
  
  //needed for the PageNr Stuff
  BOOL _showPageNumbers;
  NSString *_pageNumberFont;
  float _pageNumberSize;
  int _pageNumberStyle; //Normal, Bold, Italic
  NSMutableArray *_pageNumberFormatArr; //-1- oder so
  int _initialPageNr; //starting on which page
  int _pageNrAlignment; //Left, Center, Right
  int _pageNrPosition; //Header , Footer
  int _firstPageNrNumber; //count from 0 or 1 or something else
  NSSize _pnDeltaPosition; //finetune parameter
  
  float _documentFontSize;
  int _documentCharSpacing;
  float _documentLineSpacing;
  
  NSInteger _autoSaveInterval;
  NSTimer *_autoSaveTimer;
    
}

@property (copy) NSMutableArray *selectedGraphics;
@property (copy) NSMutableArray *documentGraphics;

- (instancetype)init;

- (void)makeWindowControllers;
- (void)windowControllerDidLoadNib:(NSWindowController *)windowController;

- (NSDictionary *)drawDocumentDictionaryForGraphics:(NSArray *)graphics;
- (NSDictionary *)drawDocumentDictionaryForGraphicsSinglePage:(NSArray *)graphics; //wird für copy gebraucht
- (NSData *)drawDocumentDataForGraphics:(NSArray *)graphics;
- (NSData *)drawDocumentDataForGraphicsSinglePage:(NSArray *)graphics; //wird für copy gebraucht
- (NSDictionary *)drawDocumentDictionaryFromData:(NSData *)data;
- (NSArray *)graphicsFromDrawDocumentDictionary:(NSDictionary *)doc;
- (NSArray *)graphicsFromDrawDocumentDictionarySinglePage:(NSDictionary *)doc; //paste von einzelnen graphics

- (NSRect)boundsForGraphics:(NSArray *)graphics;
- (NSRect)drawingBoundsForGraphics:(NSArray *)graphics;
- (NSRect)wordEportBoundsForGraphics:(NSArray *)graphics;
- (NSData *)TIFFRepresentationForGraphics:(NSArray *)graphics;
- (NSData *)PDFRepresentationForGraphics:(NSArray *)graphics;
- (NSData *)PICTRepresentationForGraphics:(NSArray *)graphics;
- (NSData *)EPSRepresentationForGraphics:(NSArray *)graphics;

- (NSData *)dataRepresentationOfType:(NSString *)type;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;

@property (NS_NONATOMIC_IOSONLY, readonly) NSSize documentSize;   // Returns usable document size based on print info paper size and margins.
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize paperSize; //Just the paper size

- (void)printShowingPrintPanel:(BOOL)flag;
- (void)printSelection:(NSArray *)graphics;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger pageCount;

- (NSArray *)graphicsOnPage:(NSUInteger)pageNr;

- (void)createGraphicOfClassGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos onPage:(NSUInteger)page;

- (void)setGraphics:(NSArray *)graphics;
- (void)setGraphics:(NSArray *)graphics onPage:(NSUInteger)pageNr;

- (void)invalidateGraphic:(IGGraphic *)graphic;
- (void)redisplayTweak:(IGGraphic *)graphic;

- (void)insertGraphic:(IGGraphic *)graphic atIndex:(NSUInteger)index;
- (void)removeGraphicAtIndex:(NSUInteger)index onPage:(NSUInteger)pageNr;
- (void)removeGraphic:(IGGraphic *)graphic;
- (void)moveGraphic:(IGGraphic *)graphic toIndex:(NSUInteger)newIndex;
- (void)moveGraphic:(IGGraphic *)graphic toPage:(NSUInteger)pageNr;

- (void)insertPageAtPage:(NSUInteger)pageNr;
- (void)removePage:(NSUInteger)pageNr;


// ===========================================================================
#pragma mark -
#pragma mark graphic selection
// =========================== graphic selection =============================
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;




// ===========================================================================
#pragma mark -
#pragma mark default document values
// ====================== default document values ============================
@property (NS_NONATOMIC_IOSONLY) float documentFontSize;

@property (NS_NONATOMIC_IOSONLY) int documentCharSpacing;

@property (NS_NONATOMIC_IOSONLY) float documentLineSpacing;

//page numbering stuff
@property (NS_NONATOMIC_IOSONLY) BOOL showPageNumbers;

- (void)setPageNrFont:(NSString *)fontName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *pageNumberFont;

@property (NS_NONATOMIC_IOSONLY) float pageNumberSize;

@property (NS_NONATOMIC_IOSONLY) int pageNumberStyle;

@property (NS_NONATOMIC_IOSONLY, copy) NSMutableArray *pageNumberFormatArr;

@property (NS_NONATOMIC_IOSONLY) int initialPageNr;

@property (NS_NONATOMIC_IOSONLY) int pageNrAlignment;

@property (NS_NONATOMIC_IOSONLY) int pageNrPosition;

@property (NS_NONATOMIC_IOSONLY) int firstPageNumberToShow;

- (void)finetuneXParameter:(float)xValue;
- (void)finetuneYParameter:(float)yValue;
- (void)finetuneReset;
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize pnDeltaPosition;

@end

extern NSString *IGDrawDocumentType;
