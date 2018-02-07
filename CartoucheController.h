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
    NSUInteger xEdge;
    NSUInteger yEdge;
    NSUInteger borderTyp;
    NSUInteger rubricCartouche:1;
    NSUInteger endAlignment;
  } _cartoucheFlags;
  
  
  @private
    NSView *_controlledView;
}

+ (CartoucheController*)sharedCartoucheController;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *controlledView;

- (IBAction)xEdgeChange:(id)sender;
- (IBAction)yEdgeChange:(id)sender;
- (IBAction)borderTypeChange:(id)sender;
- (IBAction)endAlignmentChange:(id)sender;
- (IBAction)rubricCartoucheChange:(id)sender;

@property (NS_NONATOMIC_IOSONLY) int xEdge;

@property (NS_NONATOMIC_IOSONLY) int yEdge;

@property (NS_NONATOMIC_IOSONLY) int cartoucheBorderType;

@property (NS_NONATOMIC_IOSONLY) int endAlignment;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricCartouche;

  //cartouche formating
- (void)showSelectedCartoucheFormating;
- (void)restoreTmpFormating;

  //the key window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGCartouche *theOnlySelectedCartouche;

//- (IGGraphic *)content;

@end
