//
//  IGDocumentWindowController.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//
/*!
    @header IGDocumentWindowController
    @abstract   (description)
    @discussion (description)
*/



typedef NS_ENUM(NSUInteger, ScrollingBehavior) { YES_SCROLL, NO_SCROLL, VERTICAL_SCROLL, AUTO_SCROLL, MANUAL_SCROLL };

#import <Cocoa/Cocoa.h>

@class IGGraphicView;
@class IGBackgroundView;
@class IGZoomScrollView;
@class IGGraphic;
@class IGMarginView;
@class IGViewSelectionData;


/*!
    @class IGDocumentWindowController
    @abstract    (brief description) what is it?
    @discussion  (comprehensive description) who knows
*/
@interface IGDocumentWindowController : NSWindowController <NSToolbarDelegate> {
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

@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *graphicView;

// Creating Graphics
// - (void)createGraphicOfClass:(Class)theClass withEvent:(NSEvent *)theEvent;
- (void)createGraphicOfClassGlyph:(unichar)glyphChar WithFont:(NSString *)fontName;
// - (void)createGraphicsOfClassGlyphFromDic:(NSDictionary *)glyphGroupDic;


- (void)invalidateGraphic:(IGGraphic *)graphic;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *selectedGraphics;
- (void)selectGraphic:(IGGraphic *)graphic;
- (void)deselectGraphic:(IGGraphic *)graphic;
- (void)clearSelection;

- (void)displayMousePos:(NSPoint)pos;

- (void)updateViewFromPreferences;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSPrintInfo *documentPrintInfo;

    /*!
    @method documentSize
     @abstract   Gets the Size of the Document
     @discussion Gets the size of the document (paper size minus the margins) from the designated document class or if there is none then calculates the document size
     @result     Gives NSSize back
     */
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize documentSize;
@property (NS_NONATOMIC_IOSONLY, readonly) NSSize paperSize;


- (IBAction)pageMargins:(id)sender;
- (IBAction)dismissMarginSheet:(id)sender;
- (IBAction)changeMarginUnits:(id)sender;
- (IBAction)useMinimumMargins:(id)sender;

- (void)prepareMarginView;
- (void)setPageMargins;
- (float)convertToPoints:(float)width;

- (void)initializeToolbar;
@end
