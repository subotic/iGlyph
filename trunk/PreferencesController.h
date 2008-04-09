///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/PreferencesController.h,v $
// $Revision: 1.6 $ $Date: 2005/03/08 16:03:13 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// PreferencesController.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@class IGGridView;
@class IGGraphicView;
@class IGDrawDocument;


@interface PreferencesController : NSWindowController {
    @private
    IBOutlet NSButton *showsGridCheckbox;
    IBOutlet NSButton *snapsToGridCheckbox;
    IBOutlet NSSlider *gridSpacingSlider;
    IBOutlet NSTextField *gridSpacingTextField;
    IBOutlet NSColorWell *gridColorWell;
    IBOutlet IGGridView *gridView;
    IBOutlet NSTabView *tabView;
    
    IBOutlet NSMatrix *guidelineTypeMatrix;
    IBOutlet NSTextField *guidelineCountTextField;
    
    IBOutlet NSPopUpButton *autoSaveIntervalPopup;
    
    IBOutlet NSView *generalPrefsView;
    IBOutlet NSView *textEditingPrefsView;
    IBOutlet NSView *fontsColorsPrefsView;
    IBOutlet NSView *updatePrefsView;
    IBOutlet NSView *advancedPrefsView;
    
    IGGraphicView *_inspectingGraphicView;
}

+ (id)sharedPreferencesController;

- (IBAction)snapsToGridCheckboxAction:(id)sender;
- (IBAction)showsGridCheckboxAction:(id)sender;
- (IBAction)gridSpacingSliderAction:(id)sender;
- (IBAction)gridColorWellAction:(id)sender;
- (IBAction)backgroundColorAction:(id)sender;
- (void)selectGridTabView;

- (IBAction)guidelineTypeChanged:(id)sender;
- (IBAction)guidelineCountChanged:(id)sender;

- (IBAction)autoSaveIntervalChanged:(id)sender;

- (BOOL)snapsToGrid;
- (BOOL)showsGrid;
- (float)gridSpacing;
- (NSColor *)gridColor;

- (void)loadUserDefaults;

- (void)showPreferencePane:(id)sender;
- (void)resizePreferencesWindowForSelectedView:(NSView *)selectedView;

- (void)initializeToolbar;

@end

extern void IGDrawGridWithSettingsInRect(float spacing, NSColor *color, NSRect rect, NSPoint gridOrigin);
