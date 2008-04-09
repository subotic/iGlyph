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
        unsigned int fontSize;
        unsigned int rubricColor:1;
        unsigned int mirrored:1;
        unsigned int angle;
    } _glyphTmpFormat;
    
    
}

+ (id)sharedFormatGlyphController;

- (NSView *)controlledView;

- (IBAction)glyphAngleTextFieldAction:(id)sender;
- (IBAction)glyphAngle:(id)sender;

- (IBAction)glyphSizeStepperAction:(id)sender;
- (IBAction)glyphSizeTextFieldAction:(id)sender;


- (IBAction)mirroredCheckBox:(id)sender;
- (IBAction)rubricCheckBox:(id)sender;

- (IBAction)changeGlyphAction:(id)sender;

- (float)fontSize;
- (void)setFontSize:(float)value;

- (BOOL)rubricColor;
- (void)setRubricColor:(BOOL)value;

- (BOOL)mirrored;
- (void)setMirrored:(BOOL)value;

- (int)angle;
- (void)setAngle:(int)value;

//glyph formating
- (void)saveTmpFormating;
- (void)showSelectedGlyphFormating;
- (void)restoreTmpFormating;
    

//key window stuff
- (void)setMainWindowAsKey;
- (NSWindow *)theMainWindow;
- (IGDrawWindowController *)theMainWindowController;
- (IGGraphicView *)theMainView;
- (IGGraphic *)theOnlySelectedGlyph;

@end
