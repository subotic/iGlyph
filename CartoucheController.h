///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/CartoucheController.h,v $
// $Revision: 1.6 $ $Date: 2005/02/04 17:58:14 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// ObjectsController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

@class IGGraphicView;
@class IGDrawWindowController;
@class IGGraphic;
@class IGCartouche;

@interface CartoucheController : NSWindowController {
  
  IBOutlet NSTextField *xTextField;
  IBOutlet NSTextField *yTextField;
  IBOutlet NSButton *rubricCartoucheButton;
  IBOutlet NSMatrix *borderTypeMatrix;
  IBOutlet NSMatrix *endAlignmentMatrix;
  IBOutlet NSSlider *xEdgeSlider;
  IBOutlet NSSlider *yEdgeSlider;
  
  //dies ist der Zwischenspeicher für diese Werte
  struct __cartoucheFlags {
    unsigned int xEdge;
    unsigned int yEdge;
    unsigned int borderTyp;
    unsigned int rubricCartouche:1;
    unsigned int endAlignment;
  } _cartoucheFlags;
  
  
  @private
    NSView *_controlledView;
}

+ (id)sharedCartoucheController;

- (NSView *)controlledView;

- (IBAction)xEdgeChange:(id)sender;
- (IBAction)yEdgeChange:(id)sender;
- (IBAction)borderTypeChange:(id)sender;
- (IBAction)endAlignmentChange:(id)sender;
- (IBAction)rubricCartoucheChange:(id)sender;

- (int)xEdge;
- (void)setXEdge:(int)value;

- (int)yEdge;
- (void)setYEdge:(int)value;

- (int)cartoucheBorderType;
- (void)setCartoucheBorderType:(int)value;

- (int)endAlignment;
- (void)setEndAlignment:(int)value;

- (BOOL)rubricCartouche;
- (void)setRubricCartouche:(BOOL)value;

  //cartouche formating
- (void)showSelectedCartoucheFormating;
- (void)restoreTmpFormating;

  //the key window stuff
- (NSWindow *)theMainWindow;
- (IGDrawWindowController *)theMainWindowController;
- (IGGraphicView *)theMainView;
- (IGCartouche *)theOnlySelectedCartouche;

//- (IGGraphic *)content;

@end
