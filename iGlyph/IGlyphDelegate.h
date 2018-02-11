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

typedef NS_ENUM(NSUInteger, IGMenu) {
    IGMenuObjectsTag = 41,
    IGMenuHieroglyphsTag = 42,
    IGMenuWritingDirectionTag = 43,
    IGMenuFormatGlypTag = 44,
    IGMenuCartoucheTag = 45,
    IGMenuLineTag = 46,
    IGMenuInspectorTag = 51,
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

@property (nonatomic) NSInteger autoSaveInterval;
@property NSTimer *autoSaveTimer;


- (void)initiateAutoSave;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

- (IBAction)showPreferencesPanel:(id)sender;
- (IBAction)showPreferencesGridPanel:(id)sender;
- (IBAction)showInspectorPanel:(id)sender;
- (IBAction)showHieroglyphsPanel:(id)sender;

//internet stuff

- (IBAction)openHomeWebsite:(id)sender;

- (void)resetMenuItemFlag:(NSUInteger)value;

- (IGFontData *)sharedFontData;
- (void)loadLocalFonts;

@end
