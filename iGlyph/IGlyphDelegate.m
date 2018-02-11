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
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs

    [self loadLocalFonts];
    currentObjectsMenuFlagSetting = NO;
    currentHieroglyphsMenuFlagSetting = NO;
    currentWritingDirectionMenuFlagSetting = NO;
    currentFormatGlyphMenuFlagSetting = NO;
    currentCartoucheMenuFlagSetting = NO;
    currentLineMenuFlagSetting = NO;
    
    DDLogVerbose(@"[self showInspectorPanel:self]");
    [self showInspectorPanel:self];

    DDLogVerbose(@"[self showHieroglyphsPanel:self]");
    [self showHieroglyphsPanel:self];

    
    self.autoSaveInterval = 60*[[NSUserDefaults standardUserDefaults] integerForKey:IGPrefAutoSaveIntervalKey];
    
    
    
    DDLogVerbose(@"IGlyphDelegate(awakeFromNib)");
    
} 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DDLogVerbose(@"IGlyphDelegate(applicationDidFinishLaunching)");
    
    //DDLogVerbose(@"[self showHieroglyphsPanel:self]");
    //[self showHieroglyphsPanel:self];
    
    //DDLogVerbose(@"[self showInspectorPanel:self]");
    //[self showInspectorPanel:self];
    
    //DDLogVerbose(@"[self showObjectsPanel:self]");
    //[self showObjectsPanel:self];
    
    //muss wissen wenn ich ein anderes nsdocument angewaehlt habe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    //DDLogVerbose(@"IGGlyphDelegate(mainWindowChanged)-> %@", [[NSApp mainWindow] title]);
}

- (void)mainWindowResigned:(NSNotification *)notification {
    //DDLogVerbose(@"IGGlyphDelegate(mainWindowResigned)");
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


// if the toolbar is just text, then this method is used!!!
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSUInteger tag = menuItem.tag;
    if (tag == IGMenuObjectsTag) { //Menu Item Toolboxes/Objects
        menuItem.state = (currentObjectsMenuFlagSetting ? NSOnState : NSOffState);
        return YES;
    } else if (tag == IGMenuHieroglyphsTag) { //Menu Item Toolboxes/Hieroglyphs
        menuItem.state = (currentHieroglyphsMenuFlagSetting ? NSOnState : NSOffState);
        return YES;
    } else if (tag == IGMenuWritingDirectionTag) { //Menu Item Toolboxes/Writing Direction
        menuItem.state = (currentWritingDirectionMenuFlagSetting ? NSOnState : NSOffState);
        return YES;
    } else if (tag == IGMenuFormatGlypTag) { //Menu Item Toolboxes/Format Glyph
        menuItem.state = (currentFormatGlyphMenuFlagSetting ? NSOnState : NSOffState);
        return YES;
    } else if (tag == IGMenuCartoucheTag) { //Menu Item Toolboxes/Cartouche
        menuItem.state = (currentCartoucheMenuFlagSetting ? NSOnState : NSOffState);
        return YES;
    } else if (tag == IGMenuLineTag) { //Menu Item Toolboxes/Line
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
    DDLogVerbose(@"showHieroglyphsPanel");
    currentHieroglyphsMenuFlagSetting = YES;
    [[HieroglyphsController sharedHieroglyphsController] showWindow:sender];
}

- (void)setAutoSaveInterval:(NSInteger)autoSaveInterval {
    
    if (autoSaveInterval > 0) {
        self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:_autoSaveInterval  target:self selector:@selector(initiateAutoSave:) userInfo:nil repeats:YES];
    }
}
- (void)initiateAutoSave {
    NSLog(@"IGlyphDelegate - initiateAutoSave -> Doing autosave");
}

//internet stuff

- (IBAction)openHomeWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.subotic.ch/iglyph"]];
}


- (void)resetMenuItemFlag:(NSUInteger)value
{
    if (value == IGMenuObjectsTag) {
        currentObjectsMenuFlagSetting = NO;
    } else if (value == IGMenuHieroglyphsTag) {
        currentHieroglyphsMenuFlagSetting = NO;
    } else if (value == IGMenuWritingDirectionTag){
        currentWritingDirectionMenuFlagSetting = NO;
    } else if (value == IGMenuFormatGlypTag){
        currentFormatGlyphMenuFlagSetting = NO;
    } else if (value == IGMenuCartoucheTag){
        currentCartoucheMenuFlagSetting = NO;
    } else if (value == IGMenuLineTag){
        currentLineMenuFlagSetting = NO;
    }
}

// FontToGlyphLUT Geschichten

- (IGFontData *)sharedFontData
{
    DDLogVerbose(@"IGlyphDelegate(sharedFontData)");
    return [IGFontData sharedFontData];
}

- (void)loadLocalFonts
{
    NSString *fontsFolder = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"IGFonts"];
    NSError *error = nil;
    NSArray *fontNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontsFolder error:&error];
    DDLogVerbose(@"loadLocalFonts - fontNames: %@", fontNames);
    
    for (NSString *fontName in fontNames) {
        NSString *fontPath = [fontsFolder stringByAppendingString:[@"/" stringByAppendingString:fontName]];
        NSURL *fontURL = [NSURL URLWithString:fontPath];
        DDLogVerbose(@"loadLocalFonts - fontURL: %@", fontURL);
        assert(fontURL);
        CFErrorRef error = NULL;
        if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error))
        {
            CFShow(error);
            abort();
        }
    }
}

@end
