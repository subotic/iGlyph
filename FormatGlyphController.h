///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/FormatGlyphController.h,v $
// $Revision: 1.8 $ $Date: 2005/02/01 14:58:57 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// FormatGlyphController.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

@class IGGraphicView;
@class IGDrawWindowController;
@class IGGraphic;


@interface FormatGlyphController : NSWindowController {
    @private
    
    NSView *controlledView;
    
    IBOutlet NSButton *rubricCheckBoxOutlet;
    IBOutlet NSButton *mirroredCheckBoxOutlet;
    
    IBOutlet NSTextField *angleTextField;
    IBOutlet NSSlider *angleSlider;
    IBOutlet NSMatrix *angleButtonMatrix;
    
    IBOutlet NSTextField *sizeTextField;
    IBOutlet NSStepper *stepperButton;
    
    struct __glyphTmpFormat {
        NSUInteger fontSize;
        NSUInteger rubricColor:1;
        NSUInteger mirrored:1;
        NSUInteger angle;
    } _glyphTmpFormat;
    
    
}

+ (FormatGlyphController*)sharedFormatGlyphController;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *controlledView;

- (IBAction)glyphAngleTextFieldAction:(id)sender;
- (IBAction)glyphAngle:(id)sender;

- (IBAction)glyphSizeStepperAction:(id)sender;
- (IBAction)glyphSizeTextFieldAction:(id)sender;


- (IBAction)mirroredCheckBox:(id)sender;
- (IBAction)rubricCheckBox:(id)sender;

- (IBAction)changeGlyphAction:(id)sender;

@property (NS_NONATOMIC_IOSONLY) float fontSize;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricColor;

@property (NS_NONATOMIC_IOSONLY) BOOL mirrored;

@property (NS_NONATOMIC_IOSONLY) int angle;

//glyph formating
- (void)saveTmpFormating;
- (void)showSelectedGlyphFormating;
- (void)restoreTmpFormating;
    

//key window stuff
- (void)setMainWindowAsKey;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphic *theOnlySelectedGlyph;

@end
