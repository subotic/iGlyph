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
@class IGDocumentWindowController;
@class IGGraphic;
@class IGLine;

@interface LineController : NSWindowController {

    NSView *controlledView;
    
    IBOutlet NSMatrix *lineTypeMatrix;
    IBOutlet NSMatrix *lineWidthMatrix;
    IBOutlet NSButton *lineRubricButton;
    
    IBOutlet NSMatrix *arrowTypeMatrix;
    IBOutlet NSSlider *arrowHeadSlider;
    IBOutlet NSSlider *arrowHeadSizeSlider;
    
    struct __lineFlags {
        NSInteger lineType;
        NSInteger rubricLine:1;
        NSInteger lineWidth;
        NSInteger arrowType;
        NSInteger arrowHeadAngle;
        NSInteger arrowHeadSize;
    } _lineFlags;
    
}

+ (LineController*)sharedLineController;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *controlledView;

- (IBAction)lineTypeChange:(id)sender;
- (IBAction)lineWidthChange:(id)sender;
- (IBAction)lineRubricChange:(id)sender;
- (IBAction)arrowTypeChange:(id)sender;
- (IBAction)arrowHeadAngleChange:(id)sender;
- (IBAction)arrowHeadSizeChange:(id)sender;
- (IBAction)doReverseArrow:(id)sender;

@property (NS_NONATOMIC_IOSONLY) NSInteger lineType;
@property (NS_NONATOMIC_IOSONLY) NSInteger lineWidth;
@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowType;
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadAngle;
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadSize;


//line tmp formating saving
- (void)showSelectedLineFormating;
- (void)restoreTmpFormating;


//the key window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, weak) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) IGDocumentWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) IGLine *theOnlySelectedLine;
@end
