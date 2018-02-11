///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/LineController.m,v $
// $Revision: 1.10 $ $Date: 2005/02/04 17:58:14 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// LineController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import "LineController.h"
#import "IGlyphDelegate.h"
#import "IGGraphicView.h"
#import "IGGraphic.h"
#import "IGDocumentWindowController.h"
#import "IGLine.h"



@implementation LineController

+ (LineController*)sharedLineController
{
    static LineController *_sharedLineController = nil;
    
    if (!_sharedLineController) {
        _sharedLineController = [[LineController alloc] init];
    }
    return _sharedLineController;
}

- (instancetype)init
{
    self = [self initWithWindowNibName:@"Line"];
    if (self) {
        self.windowFrameAutosaveName = @"Line";
    }
    [self setShouldCascadeWindows:NO];
    return self;
}


- (void) convertToViewController
{
    controlledView = self.window.contentView;
    //[[self window] orderOut:nil];
    [self setWindow: nil];
}

- (NSView *)controlledView
{
    return controlledView;
}


- (void)awakeFromNib
{
    
    self.lineType = 0;
    self.lineWidth = 1;
    [self setRubricLine: NO];
    [self setArrowType: 0];
    self.arrowHeadAngle = 45.0;
    self.arrowHeadSize = 15.0;
    
    _lineFlags.lineType = 0;
    _lineFlags.lineWidth = 1;
    _lineFlags.rubricLine = NO;
    _lineFlags.arrowType = 0;
    _lineFlags.arrowHeadAngle = 45.0;
    _lineFlags.arrowHeadSize = 15.0;
    
    [self convertToViewController];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"Line"];
}

- (void)windowWillClose:(NSNotification *)notification
{
    DDLogVerbose(@"(LineController.m)->Notification received - %@\n", notification.name);
    IGlyphDelegate *delegate = (IGlyphDelegate *)[NSApplication sharedApplication].delegate;
    [delegate resetMenuItemFlag:IGMenuLineTag];
}

/**
 * // Linetype: 0 - Solid, 1 - Dash, 2 - Guidline
 * @param sender
 */
- (IBAction)lineTypeChange:(id)sender
{
    IGLine *selectedLine = self.theOnlySelectedLine;
    NSMatrix *_sender = (NSMatrix *)sender;

    if (selectedLine) {
        selectedLine.lineType = _sender.selectedCell.tag;
        //[[self theKeyView] invalidateGraphic:tmpLine];
    } else {
        _lineFlags.lineType = _sender.selectedCell.tag;
    }
    
    //DDLogVerbose(@"LineController(lineTypeChange)->%i", _lineFlags.lineType);
    
}

/**
 * // Linewith: 1 , 2
 * @param sender
 */
- (IBAction)lineWidthChange:(id)sender
{
    NSMatrix *sndr = (NSMatrix *)sender;

    IGLine *selectedLine = self.theOnlySelectedLine;
    if (selectedLine) {
        DDLogVerbose(@"LineController(lineWidthChange)->%ld", (long)_lineFlags.lineWidth);
        selectedLine.lineWidth = sndr.selectedCell.tag;
        //[[self theKeyView] invalidateGraphic:tmpLine];
    } else {
        _lineFlags.lineWidth = sndr.selectedCell.tag;
    }
    
     
     
}

- (IBAction)lineRubricChange:(id)sender
{
    IGLine *selectedLine = self.theOnlySelectedLine;
    if (selectedLine) {
        selectedLine.rubricLine = [sender state];
        //[[self theKeyView] invalidateGraphic:tmpLine];
    } else {
        _lineFlags.rubricLine = [sender state];
    }
    
    //DDLogVerbose(@"LineController(lineRubricChange)->%i", _lineFlags.rubricLine);
    
}

- (IBAction)arrowTypeChange:(id)sender
{
    NSMatrix *sndr = (NSMatrix *)sender;

    IGLine *selectedLine = self.theOnlySelectedLine;
    if (selectedLine) {
        selectedLine.arrowType = sndr.selectedCell.tag;
        //[[self theKeyView] invalidateGraphic:tmpLine];
    } else {
        _lineFlags.arrowType = sndr.selectedCell.tag;
    }
    
    //DDLogVerbose(@"LineController(arrowTypeChange)->%i", _lineFlags.arrowType);
    
}

- (IBAction)arrowHeadAngleChange:(id)sender
{
    IGLine *selectedLine = self.theOnlySelectedLine;
    if (selectedLine) {
        selectedLine.arrowHeadAngle = [sender integerValue];
        //[[self theKeyView] invalidateGraphic:tmpLine];
        DDLogVerbose(@"LineController(arrowHeadChange) - hier darf ich nicht sein fals das erste mal auf Linie geklickt");
    } else {
        _lineFlags.arrowHeadAngle = [sender integerValue];
    }
    
    DDLogVerbose(@"LineController(arrowHeadAngleChange)->%ld", (long)_lineFlags.arrowHeadAngle);
    
}

- (IBAction)arrowHeadSizeChange:(id)sender
{
    IGLine *selectedLine = self.theOnlySelectedLine;
    if (selectedLine) {
        selectedLine.arrowHeadSize = [sender integerValue];
        //[[self theKeyView] invalidateGraphic:tmpLine];
    } else {
        _lineFlags.arrowHeadSize = [sender integerValue];
    }
    
    DDLogVerbose(@"LineController(arrowHeadSizeChange)->%ld", (long)_lineFlags.arrowHeadSize);
    
}

- (IBAction)doReverseArrow:(id)sender
{
    IGGraphic *tmpLine = self.theOnlySelectedLine;
    if (tmpLine) {
        [self.theOnlySelectedLine doReverseArrow];
        //[[self theKeyView] invalidateGraphic:tmpLine];
    }        
}


- (void)setLineType:(NSInteger)aType
{
    [lineTypeMatrix selectCellWithTag:aType];
}

- (NSInteger)lineType
{
    return lineTypeMatrix.selectedCell.tag;
}

- (void)setLineWidth:(NSInteger)aWidth
{
    [lineWidthMatrix selectCellWithTag:aWidth];
}

- (NSInteger)lineWidth
{
    return lineWidthMatrix.selectedCell.tag;
}

- (void)setRubricLine:(BOOL)aValue
{
    lineRubricButton.state = aValue;
}

- (BOOL)rubricLine
{
    return lineRubricButton.state;
}

- (void)setArrowType:(NSInteger)aType
{
    [arrowTypeMatrix selectCellWithTag:aType];
}

- (NSInteger)arrowType
{
    return arrowTypeMatrix.selectedCell.tag;
}

- (void)setArrowHeadAngle:(NSInteger)aHead
{
    arrowHeadSlider.integerValue = aHead;
}

- (NSInteger)arrowHeadAngle
{
    return arrowHeadSlider.integerValue;
}

- (void)setArrowHeadSize:(NSInteger)aHeadSize
{
    arrowHeadSizeSlider.integerValue = aHeadSize;
}

- (NSInteger)arrowHeadSize
{
    return arrowHeadSizeSlider.integerValue;
}

//line tmp formating saving
- (void)showSelectedLineFormating
{
    DDLogVerbose(@"LineControler(showSelectedLineFormating)");
    self.lineType = self.theOnlySelectedLine.lineType;
    self.lineWidth = self.theOnlySelectedLine.lineWidth;
    self.rubricLine = self.theOnlySelectedLine.rubricLine;
    self.arrowType = self.theOnlySelectedLine.arrowType;
    self.arrowHeadAngle = self.theOnlySelectedLine.arrowHeadAngle;
    self.arrowHeadSize = self.theOnlySelectedLine.arrowHeadSize;
        
}

- (void)restoreTmpFormating
{
    DDLogVerbose(@"LineControler(restoreTmpFormating)");
    self.lineType = _lineFlags.lineType;
    self.lineWidth = _lineFlags.lineWidth;
    self.rubricLine = _lineFlags.rubricLine;
    self.arrowType = _lineFlags.arrowType;
    self.arrowHeadAngle = _lineFlags.arrowHeadAngle;
    self.arrowHeadSize = _lineFlags.arrowHeadSize;
    [self.theMainView invalidateGraphic:self.theOnlySelectedLine];
}



//the key window stuff
- (NSWindow *)theMainWindow {
    if (!NSApp.mainWindow.keyWindow) [NSApp.mainWindow makeKeyWindow];
    return NSApp.mainWindow;
}

- (IGDocumentWindowController *)theMainWindowController {
    return self.theMainWindow.windowController;
}

- (IGGraphicView *)theMainView {
    return self.theMainWindowController.graphicView;
}

- (IGLine *)theOnlySelectedLine {
    if (self.theMainView.selectedGraphics.count == 1) {
        if ([self.theMainView.selectedGraphics[0] class] == [IGLine class]) {
            IGLine *selectedLine = (IGLine *)self.theMainView.selectedGraphics[0];
            return selectedLine;
        }
    }
    return nil;
}
@end
