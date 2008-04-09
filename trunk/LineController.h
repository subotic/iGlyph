///////////////////////////////////////////////////////////////////////////////
// $Source:$
// $Revision:$ $Date:$ $State:$
//-----------------------------------------------------------------------------
// Description
// ===========
// LineController.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

@class IGGraphicView;
@class IGDrawWindowController;
@class IGGraphic;

@interface LineController : NSWindowController {

    NSView *controlledView;
    
    IBOutlet NSMatrix *lineTypeMatrix;
    IBOutlet NSMatrix *lineWidthMatrix;
    IBOutlet NSButton *lineRubricButton;
    
    IBOutlet NSMatrix *arrowTypeMatrix;
    IBOutlet NSSlider *arrowHeadSlider;
    IBOutlet NSSlider *arrowHeadSizeSlider;
    
    struct __lineFlags {
        unsigned int lineType;
        unsigned int rubricLine:1;
        float lineWidth;
        unsigned int arrowType;
        float arrowHead;        
        float arrowHeadSize;
    } _lineFlags;
    
}

+ (id)sharedLineController;

- (NSView *)controlledView;

- (IBAction)lineTypeChange:(id)sender;
- (IBAction)lineWidthChange:(id)sender;
- (IBAction)lineRubricChange:(id)sender;
- (IBAction)arrowTypeChange:(id)sender;
- (IBAction)arrowHeadChange:(id)sender;
- (IBAction)arrowHeadSizeChange:(id)sender;
- (IBAction)doReverseArrow:(id)sender;

- (void)setLineType:(int)aType;
- (int)lineType;

- (void)setLineWidth:(float)aWidth;
- (float)lineWidth;

- (void)setRubricLine:(BOOL)aValue;
- (BOOL)rubricLine;

- (void)setArrowType:(int)aType;
- (int)arrowType;

- (void)setArrowHead:(float)aHead;
- (float)arrowHead;

- (void)setArrowHeadSize:(float)aHeadSize;
- (float)arrowHeadSize;


//line tmp formating saving
- (void)showSelectedLineFormating;
- (void)restoreTmpFormating;


//the key window stuff
- (NSWindow *)theMainWindow;
- (IGDrawWindowController *)theMainWindowController;
- (IGGraphicView *)theMainView;
- (IGGraphic *)theOnlySelectedLine;
@end
