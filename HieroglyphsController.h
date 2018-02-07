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
    
    NSInteger headerSelected;
    
}

@property (assign) NSInteger rowNumber;
@property (assign) NSInteger colNumber;
@property (assign) NSInteger glyphNumber;

@property (assign) NSString *selectedTitle;

- (instancetype)init;
- (void)awakeFromNib;

+ (HieroglyphsController*)sharedHieroglyphsController;

- (void)addGlyphGroupPopUpItems;

- (IBAction)glyphGroupPopUpChanged:(id)sender;

- (IBAction)headerChanged:(id)sender;

- (void)glyphClickedAtRow:(NSInteger)rowValue andColumn:(NSInteger)columnValue;
- (void)replaceSelectedGlyphWithThisOneAtRow:(NSInteger)rowValue andColumn:(NSInteger)columnValue;

//Data Source stuff
- (void)calculateNumberOfRowsInTableView;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;

//key window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphic *theOnlySelectedGlyph;
@end
