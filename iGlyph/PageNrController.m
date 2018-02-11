//
//  PageNrController.m
//  VisualGlyph
//
//  Created by Ivan Subotic on 01.12.04.
//  Copyright 2004 Ivan Subotic. All rights reserved.
//

#import "PageNrController.h"
#import "IGDocumentWindowController.h"
#import "IGDrawDocument.h"


@implementation PageNrController

+ (PageNrController*)sharedPageNrController
{
    static PageNrController *_sharedPageNrController = nil;
    
    if (!_sharedPageNrController) {
        _sharedPageNrController = [[PageNrController allocWithZone:NULL] init];
    }
    return _sharedPageNrController;
}

- (instancetype)init
{
    self = [super initWithWindowNibName:@"PageNr"];
    if (self) {
        self.windowFrameAutosaveName = @"PageNr";
    }
    [self setShouldCascadeWindows:NO];
    return self;
}

- (void) convertToViewController
{
  controlledView = self.window.contentView;
  [self setWindow: nil];
}

- (NSView *)controlledView
{
  return controlledView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updatePanel {
    if (self.windowLoaded && _drawDocument) {
        [self setPageNrFont:_drawDocument.pageNumberFont];
        [self setPageNumberSize:_drawDocument.pageNumberSize];
        [self setPageNumberStyle:_drawDocument.pageNumberStyle];
        [self setPageNumberFormatArr:_drawDocument.pageNumberFormatArr];
        [self setInitialPageNr:_drawDocument.initialPageNr];
        [self setPageNrAlignment:_drawDocument.pageNrAlignment];
        [self setPageNrPosition:_drawDocument.pageNrPosition];
        [self setFirstPageNumberToShow:_drawDocument.firstPageNumberToShow];
        [self setShowPageNumbers:_drawDocument.showPageNumbers];
    }
}

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = mainWindow.windowController;
    
    if (controller && [controller isKindOfClass:[IGDocumentWindowController class]]) {
        _inspectingGraphicView = ((IGDocumentWindowController *)controller).graphicView;
        _drawDocument = ((IGDocumentWindowController *)controller).document;
    } else {
        _inspectingGraphicView = nil;
        _drawDocument = nil;
    }
    [self updatePanel];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    DDLogVerbose(@"%@", NSApp.mainWindow.title);
    [self setMainWindow:notification.object];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}

int myStringSort(NSString *string1, NSString *string2, void *context) {
    return [string1 compare:string2];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"PageNr"];
    
    [(NSPanel *)self.window setFloatingPanel:YES];
    [(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
    [self setMainWindow:NSApp.mainWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
    
    //Loading the Fonts
    NSArray *availableFontsArr = [NSFontManager sharedFontManager].availableFontFamilies;
    NSArray *sortedArray = [availableFontsArr sortedArrayUsingFunction:myStringSort context:NULL];
    
    NSEnumerator *enumerator = [sortedArray objectEnumerator];
    id anObject;

    while (anObject = [enumerator nextObject]) {
        [fontBox addItemWithObjectValue:anObject];
    }
    [fontBox selectItemWithObjectValue:@"Arial"];
    fontSizeStepper.floatValue = 12;
    [fontStyleBox selectItemAtIndex:0];
    initialPageNrField.stringValue = @"1";
    [pnAlignmentBox selectItemAtIndex:1];
    [pnPagePositionMatrix selectCellWithTag:0];
    firstPageNumberToShowField.stringValue = @"1";
    
    
    //zuerst alles einstellen und dann updatePanel aufrufen damit etwas angezeigt wird falls kein Dokument geladen ist
    [self updatePanel];
    [self convertToViewController];
}

- (IBAction)pnFontChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController(pnFontChanged) %@",[sender objectValueOfSelectedItem]);
        _drawDocument.pageNumberFont = [sender objectValueOfSelectedItem];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pageNumberSizeChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController(pageNumberSizeChanged) %f",[sender floatValue]);
        _drawDocument.pageNumberSize = [sender floatValue];
        fontSizeTextField.floatValue = [sender floatValue];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pageNumberStyleChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        _drawDocument.pageNumberStyle = [sender indexOfSelectedItem];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pageNumberFormatLinksChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        [_drawDocument.pageNumberFormatArr removeObjectAtIndex:0];
        [_drawDocument.pageNumberFormatArr insertObject:[sender stringValue] atIndex:0];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pageNumberFormatRechtsChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        [_drawDocument.pageNumberFormatArr removeObjectAtIndex:1];
        [_drawDocument.pageNumberFormatArr insertObject:[sender stringValue] atIndex:1];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)initialPageNrChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        _drawDocument.initialPageNr = [sender intValue];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pnAlignmentChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        _drawDocument.pageNrAlignment = [sender indexOfSelectedItem];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)pnPagePositionChanged:(id)sender
{
    NSMatrix *sndr = (NSMatrix *)sender;

    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        _drawDocument.pageNrPosition = sndr.selectedCell.tag;
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)firstPageNumberToShowChanged:(id)sender
{
    if (_drawDocument) {
        DDLogVerbose(@"PageNrController()");
        _drawDocument.firstPageNumberToShow = [sender intValue];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}


- (IBAction)showPageNrChanged:(id)sender
{
    if (_drawDocument) {
        _drawDocument.showPageNumbers = [sender state];
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

- (IBAction)fineTunePosition:(id)sender
{
    NSMatrix *sndr = (NSMatrix *)sender;

    if (_drawDocument) {
        if (sndr.selectedCell.tag == 1) {
            [_drawDocument finetuneYParameter:-0.4];
        } else if (sndr.selectedCell.tag == 3) {
            [_drawDocument finetuneXParameter:-0.4];
        } else if (sndr.selectedCell.tag == 4) {
            [_drawDocument finetuneReset];
        } else if (sndr.selectedCell.tag == 5) {
            [_drawDocument finetuneXParameter:0.4];
        } else if (sndr.selectedCell.tag == 7) {
            [_drawDocument finetuneYParameter:0.4];
        }
        [_inspectingGraphicView setNeedsDisplay:YES];
    }
}

//---------------------------------------------------------------------------------

- (void)setPageNrFont:(NSString *)fontName
{
    [fontBox selectItemWithObjectValue:fontName];
}

/*
- (NSString *)pageNumberFont
{
    return _pageNumberFont;
}
*/

- (void)setPageNumberSize:(NSUInteger)size
{
    fontSizeStepper.integerValue = size;
    fontSizeTextField.integerValue = size;
}

/*
- (float)pageNumberSize
{
    return _pageNumberSize;
}
*/

- (void)setPageNumberStyle:(NSUInteger)style
{
    [fontStyleBox selectItemAtIndex:style];
}

/*
- (int)pageNumberStyle
{
    return _pageNumberStyle;
}
*/

- (void)setPageNumberFormatArr:(NSMutableArray *)array
{
    formatTextLinksField.stringValue = array[0];
    formatTextRechtsField.stringValue = array[1];
}

/*
- (NSArray *)pageNumberFormatArr
{
    return _pageNumberFormatArr;
}
*/

- (void)setInitialPageNr:(NSUInteger)value
{
    initialPageNrField.stringValue = [NSString stringWithFormat:@"%ld", (long)value];
}

/*
- (int)firstPageNumberToShow
{
    return _firstPageNumberToShow;
}
*/

- (void)setPageNrAlignment:(NSUInteger)value
{
    [pnAlignmentBox selectItemAtIndex:value];
}

/*
- (int)pageNrAlignment
{
    return _pageNrAlignment;
}
*/

- (void)setPageNrPosition:(NSUInteger)position
{
    [pnPagePositionMatrix selectCellWithTag:position];
}

/*
- (int)pageNrPosition
{
    return _pageNrPosition;
}
*/

- (void)setFirstPageNumberToShow:(NSUInteger)value
{
    firstPageNumberToShowField.stringValue = [NSString stringWithFormat:@"%ld", (long)value];
}

/*
- (int)firstPageNrNumber
{
    return _firstPageNrNumber;
}
*/

- (void)setShowPageNumbers:(BOOL)value
{
    showPageNrButton.state = value;
}

/*
 - (BOOL)showPageNumbers
 {
     return [showPageNrButton state];
 }
 */

@end
