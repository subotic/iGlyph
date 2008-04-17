//
//  IGDrawWindowController.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//
/*!
    @header IGDrawWindowController
    @abstract   (description)
    @discussion (description)
*/



typedef enum { YES_SCROLL, NO_SCROLL, VERTICAL_SCROLL, AUTO_SCROLL, MANUAL_SCROLL } ScrollingBehavior;

#import <Cocoa/Cocoa.h>

@class IGGraphicView;
@class IGBackgroundView;
@class IGZoomScrollView;
@class IGGraphic;
@class IGMarginView;
@class IGViewSelectionData;


/*!
    @class IGDrawWindowController
    @abstract    (brief description) what is it?
    @discussion  (comprehensive description) who knows
*/
@interface IGDrawWindowController : NSWindowController {
    @public
    IBOutlet NSWindow *window;
    IBOutlet IGGraphicView *graphicView;
    IBOutlet IGZoomScrollView *zoomScrollView;
    IBOutlet NSTextField *xCursorPosTextField;
    IBOutlet NSTextField *yCursorPosTextField;
    IBOutlet NSTextField *currentPageField;
    
    IBOutlet NSTextField *columnField;
    IBOutlet NSTextField *leftMargin;
    IBOutlet NSTextField *rightMargin;
    IBOutlet NSTextField *topMargin;
    IBOutlet NSTextField *bottomMargin;
    IBOutlet NSMatrix *marginUnits;
    IBOutlet NSView *marginView;
    IBOutlet NSWindow *marginWindow;
    
    IBOutlet NSTextField *glyphGroupTextField;
}

- (IGGraphicView *)graphicView;

// Creating Graphics
//- (void)createGraphicOfClass:(Class)theClass withEvent:(NSEvent *)theEvent;
- (void)createGraphicOfClassGlyph:(unichar)glyphChar WithFont:(NSString *)fontName;
//- (void)createGraphicsOfClassGlyphFromDic:(NSDictionary *)glyphGroupDic;


- (void)invalidateGraphic:(IGGraphic *)graphic;

- (NSMutableArray *)selectedGraphics;
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;

- (void)displayMousePos:(NSPoint)pos;

- (void)updateViewFromPreferences;

- (NSPrintInfo *)documentPrintInfo;

    /*!
    @method documentSize
     @abstract   Gets the Size of the Document
     @discussion Gets the size of the document (paper size minus the margins) from the designated document class or if there is none then calculates the document size
     @result     Gives NSSize back
     */
- (NSSize)documentSize;
- (NSSize)paperSize;


- (IBAction)pageMargins:(id)sender;
- (IBAction)dismissMarginSheet:(id)sender;
- (IBAction)changeMarginUnits:(id)sender;
- (IBAction)useMinimumMargins:(id)sender;

- (void)prepareMarginView;
- (void)setPageMargins;
- (void)marginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (float)convertToPoints:(float)width;

- (void)initializeToolbar;
@end
