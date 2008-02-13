///////////////////////////////////////////////////////////////////////////////
// Description
// ===========
// VisualGlyphDelegate.h
//
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
@class IGFontData;
@class IGGraphicView;
@class WebDownload;

enum {
    OBJECTS_MENU_TAG = 41,
    HYEROGLYPHS_MENU_TAG = 42,
    WRITINGDIRECTION_MENU_TAG = 43,
    FORMATGLYPH_MENU_TAG = 44,
    CARTOUCHE_MENU_TAG = 45,
    LINE_MENU_TAG = 46,
    INSPECTOR_MENU_TAG = 51,
};

extern NSString *IGMarginUnitsKey;
extern NSString *IGContentKey;
extern NSString *IGPrintInfoKey;
extern NSString *IGNumberOfColumnsKey;
extern NSString *IGAppBundleName;


extern NSString *IGPrefSnapsToGridKey;
extern NSString *IGPrefGridSpacingKey;
extern NSString *IGPrefShowsGridKey;
extern NSString *IGPrefGridColorKey;

extern NSString *IGPrefBGImageKey;
extern NSString *IGPrefBGColorKey;

extern NSString *IGPrefGuideLineTypeKey;
extern NSString *IGPrefGuideLineCountKey;

extern NSString *IGPrefAutoSaveIntervalKey;
extern NSString *IGPrefShowToolTipsKey;



@interface IGlyphDelegate : NSObject
{
    BOOL currentObjectsMenuFlagSetting;
    BOOL currentHieroglyphsMenuFlagSetting;
    BOOL currentWritingDirectionMenuFlagSetting;
    BOOL currentFormatGlyphMenuFlagSetting;
    BOOL currentCartoucheMenuFlagSetting;
    BOOL currentLineMenuFlagSetting;
    
    NSString *serverFileName;
    WebDownload *download;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

- (IBAction)showPreferencesPanel:(id)sender;
- (IBAction)showPreferencesGridPanel:(id)sender;
- (IBAction)showInspectorPanel:(id)sender;
- (IBAction)showHieroglyphsPanel:(id)sender;

//internet stuff

- (IBAction)openHomeWebsite:(id)sender;

- (void)resetMenuItemFlag:(int)value;

- (id)sharedFontData;
- (void)loadLocalFonts;

@end
