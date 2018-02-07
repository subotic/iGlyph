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
        NSUInteger lineType;
        NSUInteger rubricLine:1;
        float lineWidth;
        NSUInteger arrowType;
        float arrowHead;        
        float arrowHeadSize;
    } _lineFlags;
    
}

+ (LineController*)sharedLineController;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *controlledView;

- (IBAction)lineTypeChange:(id)sender;
- (IBAction)lineWidthChange:(id)sender;
- (IBAction)lineRubricChange:(id)sender;
- (IBAction)arrowTypeChange:(id)sender;
- (IBAction)arrowHeadChange:(id)sender;
- (IBAction)arrowHeadSizeChange:(id)sender;
- (IBAction)doReverseArrow:(id)sender;

@property (NS_NONATOMIC_IOSONLY) int lineType;

@property (NS_NONATOMIC_IOSONLY) float lineWidth;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;

@property (NS_NONATOMIC_IOSONLY) int arrowType;

@property (NS_NONATOMIC_IOSONLY) float arrowHead;

@property (NS_NONATOMIC_IOSONLY) float arrowHeadSize;


//line tmp formating saving
- (void)showSelectedLineFormating;
- (void)restoreTmpFormating;


//the key window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphic *theOnlySelectedLine;
@end
