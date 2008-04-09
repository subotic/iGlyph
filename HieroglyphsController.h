///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/HieroglyphsController.h,v $
// $Revision: 1.5 $ $Date: 2005/02/04 17:58:14 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// HieroglyphsController.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@class IGFontData;
@class IGGraphicView;
@class IGDrawWindowController;
@class IGGraphic;

@interface HieroglyphsController : NSWindowController {
  
  IBOutlet NSPopUpButton *glyphGroupPopUp;
  IBOutlet NSTableView *myTableView;
  
  IGFontData *fontData;
  NSMutableDictionary *fontDataDic;
  NSMutableArray *glyphGroupsArr;
  
  NSInteger rowNumber;
  NSInteger colNumber;
  NSInteger glyphNumber;
  
  int headerSelected;
  
  NSString *selectedTitle;
}

@property (assign) NSInteger rowNumber;
@property (assign) NSInteger colNumber;
@property (assign) NSInteger glyphNumber;

- (id)init;
- (void)awakeFromNib;
- (void)dealloc;

+ (id)sharedHieroglyphsController;

- (void)addGlyphGroupPopUpItems;

- (void)resizeTable;

- (IBAction)glyphGroupPopUpChanged:(id)sender;

- (IBAction)headerChanged:(id)sender;

- (void)glyphClickedAtRow:(int)rowValue andColumn:(int)columnValue;
- (void)replaceSelectedGlyphWithThisOneAtRow:(int)rowValue andColumn:(int)columnValue;   


  //table color and stuff
- (NSColor *)oddRowColor;
- (NSColor *)evenRowColor;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;


  //Data Source stuff
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;

  //key window stuff
- (NSWindow *)theMainWindow;
- (IGDrawWindowController *)theMainWindowController;
- (IGGraphicView *)theMainView;
- (IGGraphic *)theOnlySelectedGlyph;
@end