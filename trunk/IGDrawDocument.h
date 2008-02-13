//
//  IGDrawDocument.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import <AppKit/AppKit.h>

@class IGGraphic;
@class IGGraphicView;

@interface IGDrawDocument : NSDocument {
    @private
    NSMutableArray *_graphics;
    int _pageCount; //nummber of pages in this document
    
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
    
    int _autoSaveInterval;
    NSTimer *_autoSaveTimer;
    
}

- (id)init;

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

- (NSSize)documentSize;   // Returns usable document size based on print info paper size and margins.
- (NSSize)paperSize; //Just the paper size

- (void)printShowingPrintPanel:(BOOL)flag;
- (void)printSelection:(NSArray *)graphics;

- (int)pageCount;

- (NSArray *)graphics;
- (NSArray *)graphicsOnPage:(unsigned)pageNr;

- (void)setGraphics:(NSArray *)graphics;
- (void)setGraphics:(NSArray *)graphics onPage:(unsigned)pageNr;

- (void)invalidateGraphic:(IGGraphic *)graphic;
- (void)redisplayTweak:(IGGraphic *)graphic;

- (void)insertGraphic:(IGGraphic *)graphic atIndex:(unsigned)index;
- (void)removeGraphicAtIndex:(unsigned)index onPage:(unsigned)pageNr;
- (void)removeGraphic:(IGGraphic *)graphic;
- (void)moveGraphic:(IGGraphic *)graphic toIndex:(unsigned)newIndex;
- (void)moveGraphic:(IGGraphic *)graphic toPage:(unsigned)pageNr;

- (void)insertPageAtPage:(unsigned)pageNr;
- (void)removePage:(unsigned)pageNr;


//default document values
- (void)setDocumentFontSize:(float)value;
- (float)documentFontSize;

- (void)setDocumentCharSpacing:(int)value;
- (int)documentCharSpacing;

- (void)setDocumentLineSpacing:(float)value;
- (float)documentLineSpacing;

//page numbering stuff
- (void)setShowPageNumbers:(BOOL)value;
- (BOOL)showPageNumbers;

- (void)setPageNrFont:(NSString *)fontName;
- (NSString *)pageNumberFont;

- (void)setPageNumberSize:(float)size;
- (float)pageNumberSize;

- (void)setPageNumberStyle:(int)style;
- (int)pageNumberStyle;

- (void)setPageNumberFormatArr:(NSMutableArray *)array;
- (NSMutableArray *)pageNumberFormatArr;

- (void)setInitialPageNr:(int)value;
- (int)initialPageNr;

- (void)setPageNrAlignment:(int)value;
- (int)pageNrAlignment;

- (void)setPageNrPosition:(int)position;
- (int)pageNrPosition;

- (void)setFirstPageNumberToShow:(int)value;
- (int)firstPageNumberToShow;

- (void)finetuneXParameter:(float)xValue;
- (void)finetuneYParameter:(float)yValue;
- (void)finetuneReset;
- (NSSize)pnDeltaPosition;

@end

extern NSString *IGDrawDocumentType;