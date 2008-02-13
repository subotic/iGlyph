//
//  PageNrController.h
//  VisualGlyph
//
//  Created by Ivan Subotic on 01.12.04.
//  Copyright 2004 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGGraphicView.h"

@interface PageNrController : NSWindowController {

    IGGraphicView *_inspectingGraphicView;
    IGDrawDocument *_drawDocument;
    
    
    NSView *controlledView;
    
    IBOutlet NSComboBox *fontBox;
    IBOutlet NSStepper *fontSizeStepper;
    IBOutlet NSTextField *fontSizeTextField;
    IBOutlet NSComboBox *fontStyleBox;
    IBOutlet NSTextField *formatTextLinksField;
    IBOutlet NSTextField *formatTextRechtsField;
    IBOutlet NSTextField *initialPageNrField;
    
    IBOutlet NSComboBox *pnAlignmentBox;
    IBOutlet NSMatrix *pnPagePositionMatrix;
    IBOutlet NSTextField *firstPageNumberToShowField;
    
    IBOutlet NSButton *showPageNrButton;
}

+ (id)sharedPageNrController;

- (NSView *)controlledView;

- (void)updatePanel;

- (IBAction)pnFontChanged:(id)sender;
- (IBAction)pageNumberSizeChanged:(id)sender;
- (IBAction)pageNumberStyleChanged:(id)sender;
- (IBAction)pageNumberFormatLinksChanged:(id)sender;
- (IBAction)pageNumberFormatRechtsChanged:(id)sender;
- (IBAction)initialPageNrChanged:(id)sender;
- (IBAction)pnAlignmentChanged:(id)sender;
- (IBAction)pnPagePositionChanged:(id)sender;
- (IBAction)firstPageNumberToShowChanged:(id)sender;
- (IBAction)showPageNrChanged:(id)sender;
- (IBAction)fineTunePosition:(id)sender;



- (void)setPageNrFont:(NSString *)fontName;
//- (NSString *)pageNumberFont;

- (void)setPageNumberSize:(float)size;
//- (float)pageNumberSize;

- (void)setPageNumberStyle:(int)style;
//- (int)pageNumberStyle;

- (void)setPageNumberFormatArr:(NSMutableArray *)array;
//- (NSArray *)pageNumberFormatArr;

- (void)setInitialPageNr:(int)value;
//- (int)firstPageNumberToShow;

- (void)setPageNrAlignment:(int)value;
//- (int)pageNrAlignment;

- (void)setPageNrPosition:(int)position;
//- (int)pageNrPosition;

- (void)setFirstPageNumberToShow:(int)value;
//- (int)firstPageNrNumber;

- (void)setShowPageNumbers:(BOOL)value;
//- (BOOL)showPageNumbers;

@end
