///////////////////////////////////////////////////////////////////////////////
// Description
// ===========
// VisualGlyphDelegate.m
//
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////


#import "IGlyphDelegate.h"
#import "IGInspectorController.h"
#import "PreferencesController.h"
#import "HieroglyphsController.h"
#import "IGFontData.h"
#import <WebKit/WebKit.h>

NSString *IGMarginUnitsKey = @"IGMarginUnitsKey";
NSString *IGContentKey = @"IGContentKey";
NSString *IGPrintInfoKey = @"IGPrintInfoKey";
NSString *IGNumberOfColumnsKey = @"IGNumberOfColumnsKey";
NSString *IGAppBundleName = @"ch.subotic.iGlyph";


NSString *IGPrefSnapsToGridKey = @"snapsToGrid";
NSString *IGPrefGridSpacingKey = @"gridSpacing";
NSString *IGPrefShowsGridKey = @"showsGrid";
NSString *IGPrefGridColorKey = @"gridColor";

NSString *IGPrefBGImageKey = @"BGImage";
NSString *IGPrefBGColorKey = @"BGColor";

NSString *IGPrefGuideLineTypeKey = @"guideLineType";
NSString *IGPrefGuideLineCountKey = @"guideLineCount";

NSString *IGPrefAutoSaveIntervalKey = @"autoSaveInterval";
NSString *IGPrefShowToolTipsKey = @"showToolTips";


@implementation IGlyphDelegate

+ (void)initialize
{   
  //standardUserDefaults beinhalten Werte welche genommen werden falls der Benutzer
  //noch nie die Applikation gestartet hat und demzufolge auch diese Werte nicht in
  //der userDefaults zu finden sind.
  /**
  NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
  
  [defaultsDict setObject:@"0" forKey:IGPrefSnapsToGridKey];
  [defaultsDict setObject:@"8" forKey:IGPrefGridSpacingKey];
  [defaultsDict setObject:@"0" forKey:IGPrefShowsGridKey];
  [defaultsDict setObject:[NSColor lightGrayColor] forKey:IGPrefGridColorKey];
  
  [defaultsDict setObject:@"0" forKey:IGPrefBGImageKey];
  [defaultsDict setObject:[NSColor whiteColor] forKey:IGPrefBGColorKey];
  
  [defaultsDict setObject:@"0" forKey:IGPrefGuideLineTypeKey];
  [defaultsDict setObject:@"8" forKey:IGPrefGuideLineCountKey];
  
  [defaultsDict setObject:@"15" forKey:IGPrefAutoSaveIntervalKey];
  [defaultsDict setObject:@"0" forKey:IGPrefShowToolTipsKey];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
  **/
}


- (void)awakeFromNib
{
  [self loadLocalFonts];
  currentObjectsMenuFlagSetting = NO;
  currentHieroglyphsMenuFlagSetting = NO;
  currentWritingDirectionMenuFlagSetting = NO;
  currentFormatGlyphMenuFlagSetting = NO;
  currentCartoucheMenuFlagSetting = NO;
  currentLineMenuFlagSetting = NO;
  
  NSLog(@"[self showInspectorPanel:self]");
  [self showInspectorPanel:self];
  
  NSLog(@"[self showHieroglyphsPanel:self]");
  [self showHieroglyphsPanel:self];
  
  NSLog(@"IGlyphDelegate(awakeFromNib)");
  
} 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@"IGlyphDelegate(applicationDidFinishLaunching)");
  
  //NSLog(@"[self showHieroglyphsPanel:self]");
  //[self showHieroglyphsPanel:self];
  
  //NSLog(@"[self showInspectorPanel:self]");
  //[self showInspectorPanel:self];
  
  //NSLog(@"[self showObjectsPanel:self]");
  //[self showObjectsPanel:self];
  
  //muss wissen wenn ich ein anderes nsdocument angewaehlt habe
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
  
}

- (void)mainWindowChanged:(NSNotification *)notification {
    //NSLog(@"IGGlyphDelegate(mainWindowChanged)-> %@", [[NSApp mainWindow] title]);
}

- (void)mainWindowResigned:(NSNotification *)notification {
    //NSLog(@"IGGlyphDelegate(mainWindowResigned)");
}



- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}


// if the toolbar is just text, then this method is used!!!
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  int tag = menuItem.tag;
  if (tag == OBJECTS_MENU_TAG) { //Menu Item Toolboxes/Objects
    menuItem.state = (currentObjectsMenuFlagSetting ? NSOnState : NSOffState);
    return YES;
  } else if (tag == HYEROGLYPHS_MENU_TAG) { //Menu Item Toolboxes/Hieroglyphs
    menuItem.state = (currentHieroglyphsMenuFlagSetting ? NSOnState : NSOffState);
    return YES;
  } else if (tag == WRITINGDIRECTION_MENU_TAG) { //Menu Item Toolboxes/Writing Direction
    menuItem.state = (currentWritingDirectionMenuFlagSetting ? NSOnState : NSOffState);
    return YES;    
  } else if (tag == FORMATGLYPH_MENU_TAG) { //Menu Item Toolboxes/Format Glyph
    menuItem.state = (currentFormatGlyphMenuFlagSetting ? NSOnState : NSOffState);
    return YES;    
  } else if (tag == CARTOUCHE_MENU_TAG) { //Menu Item Toolboxes/Cartouche
    menuItem.state = (currentCartoucheMenuFlagSetting ? NSOnState : NSOffState);
    return YES;    
  } else if (tag == LINE_MENU_TAG) { //Menu Item Toolboxes/Line
    menuItem.state = (currentLineMenuFlagSetting ? NSOnState : NSOffState);
    return YES;    
  }
  return YES; // we'll assume anything else is OK, which is the default
}

// ===========================================================================
#pragma mark -
#pragma mark -- panel calls --
// ===========================================================================

- (IBAction)showPreferencesPanel:(id)sender
{
  [[PreferencesController sharedPreferencesController] showWindow:sender];
}

- (IBAction)showPreferencesGridPanel:(id)sender
{
  [[PreferencesController sharedPreferencesController] showWindow:sender];
  [[PreferencesController sharedPreferencesController] selectGridTabView];
}

- (IBAction)showInspectorPanel:(id)sender
{
  [[IGInspectorController sharedInspectorController] showWindow:sender];
}

- (IBAction)hideInspectorPanel:(id)sender
{
  [[IGInspectorController sharedInspectorController] showWindow:sender];
}

- (IBAction)showHieroglyphsPanel:(id)sender
{
  NSLog(@"showHieroglyphsPanel");
  currentHieroglyphsMenuFlagSetting = YES;
  [[HieroglyphsController sharedHieroglyphsController] showWindow:sender];
}



//internet stuff

- (IBAction)openHomeWebsite:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.subotic.ch/iglyph"]];
}


- (void)resetMenuItemFlag:(int)value
{
  if (value == OBJECTS_MENU_TAG) {
    currentObjectsMenuFlagSetting = NO;
  } else if (value == HYEROGLYPHS_MENU_TAG) {
    currentHieroglyphsMenuFlagSetting = NO;
  } else if (value == WRITINGDIRECTION_MENU_TAG){
    currentWritingDirectionMenuFlagSetting = NO;
  } else if (value == FORMATGLYPH_MENU_TAG){
    currentFormatGlyphMenuFlagSetting = NO;
  } else if (value == CARTOUCHE_MENU_TAG){
    currentCartoucheMenuFlagSetting = NO;
  } else if (value == LINE_MENU_TAG){
    currentLineMenuFlagSetting = NO;
  }
}

// FontToGlyphLUT Geschichten

- (instancetype)sharedFontData
{
  NSLog(@"IGlyphDelegate(sharedFontData)");
  return [IGFontData sharedFontData];
}


//- (void)loadLocalFonts
//{
//    NSString *fontsFolder;
//    if(fontsFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"IGFonta"]) {
//        NSURL *fontsURL;
//        if (fontsURL = [NSURL fileURLWithPath:fontsFolder])
//        {
//            FSRef fsRef;
//            FSSpec fsSpec;
//            CFURLGetFSRef((CFURLRef)fontsURL, &fsRef);
//            if (FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL) == noErr)
//            {
//                ATSFontActivateFromFileSpecification(&fsSpec, kATSFontContextLocal, kATSFontFormatUnspecified, NULL, kATSOptionFlagsDefault, NULL);
//            }
//        }
//    }
//}

- (void)loadLocalFonts
{
  NSString *fontsFolder = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"IGFonts"];
  if (fontsFolder) {
    NSURL *fontsURL = [NSURL fileURLWithPath:fontsFolder];
    if (fontsURL) {
      FSRef fsRef;
      FSSpec fsSpec;
      (void)CFURLGetFSRef((CFURLRef)fontsURL, &fsRef);
      OSStatus status = FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL);
      if (noErr == status) {
        FMGeneration generationCount = FMGetGeneration();
        status = ATSFontActivateFromFileSpecification(&fsSpec, kATSFontContextLocal, kATSFontFormatUnspecified, NULL, kATSOptionFlagsDefault, NULL);
        generationCount = FMGetGeneration() - generationCount;
      }
    }   
  }
}

@end
