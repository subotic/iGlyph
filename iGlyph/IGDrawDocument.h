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

@private
  
    /*
  NSUInteger _pageCount; //nummber of pages in this document
  
  //needed for the PageNr Stuff
  BOOL _showPageNumbers;
  NSString *_pageNumberFont;
  NSUInteger _pageNumberSize;
  NSUInteger _pageNumberStyle; //Normal, Bold, Italic
  NSMutableArray *_pageNumberFormatArr; //-1- oder so
  NSUInteger _initialPageNr; //starting on which page
  NSUInteger _pageNrAlignment; //Left, Center, Right
  NSUInteger _pageNrPosition; //Header , Footer
  NSUInteger _firstPageNrNumber; //count from 0 or 1 or something else
  NSSize _pnDeltaPosition; //finetune parameter
  
  NSUInteger _documentFontSize;
  NSUInteger _documentCharSpacing;
  CGFloat _documentLineSpacing;
  
  NSUInteger _autoSaveInterval;
  NSTimer *_autoSaveTimer;
     */
    
}

@property (strong) NSMutableArray *selectedPageObjects; // [Objects] -- Objects are IGGraphic subclasses
@property (strong) NSMutableArray *documentPages; // [Page][Objects] -- Each page holds objects which are IGGraphic subclasses
@property (readonly) NSInteger pageCount;
@property (readonly) NSSize documentSize;   // Returns usable document size based on print info paper size and margins.
@property (readonly) NSSize paperSize; //Just the paper size

// default document values
@property (nonatomic) NSInteger documentFontSize;
@property (nonatomic) NSInteger documentCharSpacing;
@property (nonatomic) CGFloat documentLineSpacing;

//page numbering
@property (nonatomic) BOOL showPageNumbers;
@property (nonatomic) NSString *pageNumberFont;
@property (nonatomic) NSInteger pageNumberSize;
@property (nonatomic) NSInteger pageNumberStyle;
@property (nonatomic) NSMutableArray *pageNumberFormatArr;
@property (nonatomic) NSInteger initialPageNr;
@property (nonatomic) NSInteger pageNrAlignment;
@property (nonatomic) NSInteger pageNrPosition;
@property (nonatomic) NSInteger firstPageNumberToShow;
@property (readonly) NSSize pnDeltaPosition;

- (IGDrawDocument *)init;

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
- (NSRect)wordExportBoundsForGraphics:(NSArray *)graphics;
- (NSData *)TIFFRepresentationForGraphics:(NSArray *)graphics;
- (NSData *)PDFRepresentationForGraphics:(NSArray *)graphics;
- (NSData *)EPSRepresentationForGraphics:(NSArray *)graphics;

- (NSData *)dataRepresentationOfType:(NSString *)type;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;

- (void)printShowingPrintPanel:(BOOL)flag;
- (void)printSelection:(NSArray *)graphics;

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

// graphic selection
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;

// page number fintune
- (void)finetuneXParameter:(float)xValue;
- (void)finetuneYParameter:(float)yValue;
- (void)finetuneReset;

@end

extern NSString *IGDrawDocumentType;
