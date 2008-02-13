///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/PreferencesController.m,v $
// $Revision: 1.10 $ $Date: 2005/03/08 16:03:13 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// PreferencesController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

#import "PreferencesController.h"
#import "IGGridView.h"
#import "IGGraphicView.h"
#import "IGDrawWindowController.h"
#import "IGlyphDelegate.h"

@implementation PreferencesController

+ (id)sharedPreferencesController
{
    static PreferencesController *_sharedPreferencesController = nil;
    
    if (!_sharedPreferencesController) {
        _sharedPreferencesController = [[PreferencesController allocWithZone:NULL] init];
    }
    return _sharedPreferencesController;
}

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        [self setWindowFrameAutosaveName:@"Preferences"];
    }
    [self setShouldCascadeWindows:NO];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

/*
- (void)updatePanel {
    if ([self isWindowLoaded]) {
        BOOL hasGraphicView = ((_inspectingGraphicView == nil) ? NO : YES);
        [snapsToGridCheckbox setState:([self snapsToGrid] ? NSOnState : NSOffState)];
        [showsGridCheckbox setState:([self showsGrid] ? NSOnState : NSOffState)];
        [gridSpacingSlider setIntValue:[self gridSpacing]];
        [gridSpacingTextField setIntValue:[self gridSpacing]];
        [gridColorWell setColor:[self gridColor]];
        [snapsToGridCheckbox setEnabled:hasGraphicView];
        [showsGridCheckbox setEnabled:hasGraphicView];
        [gridSpacingSlider setEnabled:hasGraphicView];
        [gridColorWell setEnabled:hasGraphicView];
        [gridView setNeedsDisplay:YES];
    }
}

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = [mainWindow windowController];
    
    if (controller && [controller isKindOfClass:[IGDrawWindowController class]]) {
        _inspectingGraphicView = [(IGDrawWindowController *)controller graphicView];
    } else {
        _inspectingGraphicView = nil;
    }
    [self updatePanel];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    NSLog(@"%@", [[NSApp mainWindow] title]);
    [self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}
*/

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Preferences"];
    
    //[(NSPanel *)[self window] setFloatingPanel:YES];
    //[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    //[self setMainWindow:[NSApp mainWindow]];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
    
    //NSLog(@"PreferencesController(windowDidLoad) %i", [showsGridCheckbox state]);
    
    //[self loadUserDefaults];
    
    //Toolbar starten
    [self initializeToolbar];
}

- (IBAction)snapsToGridCheckboxAction:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setSnapsToGrid:[sender state]];
        [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:IGPrefSnapsToGridKey];
    }
}

- (IBAction)showsGridCheckboxAction:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setShowsGrid:[sender state]];
        [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:IGPrefShowsGridKey];
    }
}

- (IBAction)gridSpacingSliderAction:(id)sender {
    if (_inspectingGraphicView) {
        [gridSpacingTextField setIntValue:[sender intValue]];
        [_inspectingGraphicView setGridSpacing:(float)[sender intValue]];
        [[NSUserDefaults standardUserDefaults] setFloat:[sender intValue] forKey:IGPrefGridSpacingKey];
    }
    [gridView setNeedsDisplay:YES];
}

- (IBAction)gridColorWellAction:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setGridColor:[sender color]];
        [[NSUserDefaults standardUserDefaults] setObject:[sender color] forKey:IGPrefGridColorKey];
    }
    [gridView setNeedsDisplay:YES];
}

- (IBAction)backgroundColorAction:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setPageBackgroundColor:[sender color]];
        [[NSUserDefaults standardUserDefaults] setObject:[sender color] forKey:IGPrefBGColorKey];
    }
    [_inspectingGraphicView setNeedsDisplay:YES];
}

- (void)selectGridTabView {
    [tabView selectTabViewItemWithIdentifier:(id)@"1"];
}

- (IBAction)guidelineTypeChanged:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setGuidelineType :[[sender selectedCell] tag]];
        [[NSUserDefaults standardUserDefaults] setInteger:[[sender selectedCell] tag] forKey:IGPrefGuideLineTypeKey];
    }
    [_inspectingGraphicView setNeedsDisplay:YES];
}

- (IBAction)guidelineCountChanged:(id)sender {
    if (_inspectingGraphicView) {
        [_inspectingGraphicView setGuidelineCount:[sender intValue]];
        [[NSUserDefaults standardUserDefaults] setInteger:[[sender selectedCell] tag] forKey:IGPrefGuideLineCountKey];
    }
    [_inspectingGraphicView setNeedsDisplay:YES];
}

- (IBAction)autoSaveIntervalChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[sender title] forKey:IGPrefAutoSaveIntervalKey];
}



//Methoden fŸr update panel....hier mŸssen wir beim dokumment wechsel den panel updaten
- (BOOL)snapsToGrid {
    return (_inspectingGraphicView ? [_inspectingGraphicView snapsToGrid] : NO);
}

- (BOOL)showsGrid {
    return (_inspectingGraphicView ? [_inspectingGraphicView showsGrid] : NO);
}

- (float)gridSpacing {
    return (_inspectingGraphicView ? [_inspectingGraphicView gridSpacing] : 8);
}

- (NSColor *)gridColor {
    return (_inspectingGraphicView ? [_inspectingGraphicView gridColor] : [NSColor lightGrayColor]);
}


- (void)loadUserDefaults
{
    NSLog(@"PreferencesController(loadUserDefaults)");
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    [snapsToGridCheckbox setState:[userDef integerForKey:IGPrefSnapsToGridKey]];
    [showsGridCheckbox setState:[userDef integerForKey:IGPrefShowsGridKey]];
    [gridSpacingSlider setFloatValue:[userDef floatForKey:IGPrefGridSpacingKey]];
    [gridSpacingTextField setIntValue:[userDef integerForKey:IGPrefGridSpacingKey]];
    //[gridColorWell setColor:[userDef objectForKey:IGPrefGridColorKey]];
    
    [guidelineTypeMatrix selectCellWithTag:[userDef integerForKey:IGPrefGuideLineTypeKey]];
    [guidelineCountTextField setIntValue:[userDef integerForKey:IGPrefGuideLineCountKey]];
    
    
    [autoSaveIntervalPopup selectItemWithTitle:[userDef objectForKey:IGPrefAutoSaveIntervalKey]];
    NSLog(@"PreferencesController(loadUserDefaults end)");
    
}

- (IBAction)selectedViewChanged:(id)sender
{
  int tag = [[sender selectedCell] tag];
  NSLog(@"Tag = %i", tag);
  
  //[self changeToSelectedTab: tag];
}

- (void)showPreferencePane:(id)sender
{
  //muss zuerst die contenView reseten, damit ich bei der Gršssenanpassung nicht die vorhergehende View clippe
  
  float oldHeight = [[[self window] contentView] frame].size.height;
  [[self window] setContentView:Nil];
  NSView *newContentView = Nil;
  
  switch ([sender tag]) 
  {
    case 0:
      NSLog(@"Tag 0 -> General");
      
      [[self window] setTitle:@"General Preferences"];
      newContentView = generalPrefsView;
      
      break;
      
    case 1:
      NSLog(@"Tag 1 -> Text Editing");
      
      [[self window] setTitle:@"Editing Preferences"];
      newContentView = textEditingPrefsView;
      
      break;
      
    case 2:
      NSLog(@"Tag 2 -> Fonts & Colors");
      [[self window] setTitle:@"Styles Preferences"];
      newContentView = fontsColorsPrefsView;
      
      break;
      
    case 3:
      NSLog(@"Tag 3 -> Update");
      [[self window] setTitle:@"Update Preferences"];
      newContentView = updatePrefsView;
      
      break;
      
    case 4:
      [[self window] setTitle:@"Advanced Preferences"];
      newContentView = advancedPrefsView;
      
      break;
      
    case 5:
      //[[self window] setTitle:@"Metric"];
      //newContentView = formatGlyphView;
      
      break;
      
    case 6:
      //[[self window] setTitle:@"Text"];
      
      break;
      
    case 7:
      //[[self window] setTitle:@"Layout"];
      
      break;
  }
  
  float heightChange = [newContentView frame].size.height - oldHeight;
  NSRect newWindowFrame = [[self window] frame];
  newWindowFrame.size.height += heightChange;
  newWindowFrame.origin.y -= heightChange;
  
  [[self window] setFrame: newWindowFrame display: YES animate: YES];
  [[self window] setContentView: newContentView];
  
  //[[[self window] contentView] setNeedsDisplay:YES];
  //[[self window] setViewsNeedDisplay:YES];
}


 - (void)resizePreferencesWindowForSelectedView:(NSView *)selectedView 
 {
  NSRect preferencesWindowRect = [[self window] frame];
  NSSize minimumPreferencesSize = [[self window] minSize];
    
  NSRect selectedViewRect = [selectedView frame];
  if (NSIsEmptyRect(selectedViewRect)) {
    NSLog(@"selectedViewRect is empty!!!");
    selectedViewRect = NSMakeRect(0, 0, minimumPreferencesSize.width, minimumPreferencesSize.height - 30);
  }
      
  //Window size und position anpassen
  //box size und position anpassen
  
  NSLog (@"-> preferencesWindowRect: %f, %f, %f, %f", preferencesWindowRect.origin.x, preferencesWindowRect.origin.y, preferencesWindowRect.size.width, preferencesWindowRect.size.height);
  //NSLog (@"-> preferencesBoxRect: %f, %f, %f, %f", preferencesBoxRect.origin.x, preferencesBoxRect.origin.y, preferencesBoxRect.size.width, preferencesBoxRect.size.height);
  NSLog (@"-> selectedViewRect: %f, %f, %f, %f", selectedViewRect.origin.x, selectedViewRect.origin.y, selectedViewRect.size.width, selectedViewRect.size.height);
  NSLog (@"-> minimumPreferencesSize: %f, %f", minimumPreferencesSize.width, minimumPreferencesSize.height);

  
  if (minimumPreferencesSize.height > selectedViewRect.size.height) {
    NSLog(@"neue View ist KLEINER als die Mindestgroesse");
    
    preferencesWindowRect.origin.y += preferencesWindowRect.size.height - 41 - minimumPreferencesSize.height;
    preferencesWindowRect.size.height = minimumPreferencesSize.height + 41;
    
    [[self window] setFrame:NSMakeRect(preferencesWindowRect.origin.x, preferencesWindowRect.origin.y, preferencesWindowRect.size.width, preferencesWindowRect.size.height) display:YES animate:YES];
    
  } else {
    NSLog(@"neue View ist GROESSER als die Mindestgroesse");
    
    preferencesWindowRect.origin.y += preferencesWindowRect.size.height - 41 - selectedViewRect.size.height;
    preferencesWindowRect.size.height = selectedViewRect.size.height + 41;
    [[self window] setFrame:NSMakeRect(preferencesWindowRect.origin.x, preferencesWindowRect.origin.y, preferencesWindowRect.size.width, preferencesWindowRect.size.height) display:YES animate:YES];
  }
   
  NSLog (@"-> preferencesWindowRect after resize: %f, %f, %f, %f", preferencesWindowRect.origin.x, preferencesWindowRect.origin.y, preferencesWindowRect.size.width, preferencesWindowRect.size.height);
  //NSLog (@"-> preferencesBoxRect after resize: %f, %f, %f, %f", preferencesBoxRect.origin.x, preferencesBoxRect.origin.y, preferencesBoxRect.size.width, preferencesBoxRect.size.height);
 }


// ===========================================================================
#pragma mark -
#pragma mark -- toolbar stuff --
//==================================Toolbar Stuff=============================

static NSString *PreferencesToolbarIdentifier = @"Preferences Toolbar";
static NSString *GeneralPrefPaneToolbarItemIdentifier = @"General PrefPane ToolbarItem";
static NSString *TextEditingPrefPaneToolbarItemIdentifier = @"TextEditing PrefPane ToolbarItem";
static NSString *FontsColorsPrefPaneToolbarItemIdentifier = @"FontsColors PrefPane ToolbarItem";
static NSString *UpdatePrefPaneToolbarItemIdentifier = @"Update PrefPane ToolbarItem";
static NSString *AdvancedPrefPaneToolbarItemIdentifier = @"Advanced PrefPane ToolbarItem";

// It starts here
- (void)initializeToolbar
{
  NSToolbar *prefToolbar = [[NSToolbar alloc] initWithIdentifier:PreferencesToolbarIdentifier];
  [prefToolbar setAllowsUserCustomization:NO];
  [prefToolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
  [prefToolbar setDelegate:self];
  [prefToolbar setSelectedItemIdentifier:GeneralPrefPaneToolbarItemIdentifier];
  [[self window] setToolbar:prefToolbar];
  [prefToolbar release];
  
  [[self window] setContentView:generalPrefsView];
  
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
  NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
  
  [toolbarItem autorelease];
  if ([itemIdent isEqual:GeneralPrefPaneToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"General"];
    [toolbarItem setPaletteLabel: @"General"];
    [toolbarItem setToolTip:@"General"];
    [toolbarItem setImage:[NSImage imageNamed: @"PrefTB_General"]];
    [toolbarItem setTag:0];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showPreferencePane:)];
    
  } else if ([itemIdent isEqual:TextEditingPrefPaneToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Editing"];
    [toolbarItem setPaletteLabel: @"Editing"];
    [toolbarItem setToolTip:@"Editing"];
    [toolbarItem setImage:[NSImage imageNamed: @"PrefTB_TextEditing"]];
    [toolbarItem setTag:1];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showPreferencePane:)];
    
  } else if ([itemIdent isEqual:FontsColorsPrefPaneToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Styles"];
    [toolbarItem setPaletteLabel: @"Styles"];
    [toolbarItem setToolTip:@"Styles"];
    [toolbarItem setImage:[NSImage imageNamed: @"PrefTB_FontsColors"]];
    [toolbarItem setTag:2];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showPreferencePane:)];
    
  } else if ([itemIdent isEqual:UpdatePrefPaneToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Update"];
    [toolbarItem setPaletteLabel: @"Update"];
    [toolbarItem setToolTip:@"Update"];
    [toolbarItem setImage:[NSImage imageNamed: @"PrefTB_SoftwareUpdate"]];
    [toolbarItem setTag:3];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showPreferencePane:)];
    
  } else if ([itemIdent isEqual:AdvancedPrefPaneToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Advanced"];
    [toolbarItem setPaletteLabel: @"Advanced"];
    [toolbarItem setToolTip:@"Advanced"];
    [toolbarItem setImage:[NSImage imageNamed: @"PrefTB_Advanced"]];
    [toolbarItem setTag:4];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showPreferencePane:)];
    
  } else {
    return nil;
  }
  return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
  return [NSArray arrayWithObjects:
    GeneralPrefPaneToolbarItemIdentifier, TextEditingPrefPaneToolbarItemIdentifier, FontsColorsPrefPaneToolbarItemIdentifier, UpdatePrefPaneToolbarItemIdentifier, AdvancedPrefPaneToolbarItemIdentifier, nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{ // sent to discover the selectable item identifiers for a toolbar
  return [NSArray arrayWithObjects:
    GeneralPrefPaneToolbarItemIdentifier, TextEditingPrefPaneToolbarItemIdentifier, FontsColorsPrefPaneToolbarItemIdentifier, UpdatePrefPaneToolbarItemIdentifier, AdvancedPrefPaneToolbarItemIdentifier, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
  return [NSArray arrayWithObjects:
    GeneralPrefPaneToolbarItemIdentifier, TextEditingPrefPaneToolbarItemIdentifier, FontsColorsPrefPaneToolbarItemIdentifier, UpdatePrefPaneToolbarItemIdentifier, AdvancedPrefPaneToolbarItemIdentifier, nil];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
  /*
  NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
  if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier]) {
    [addedItem setToolTip: @"Print Document"];
    [addedItem setTarget:self];
  }
   */
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification
{ // handle removal of items.  We have an item that could be a target, so that needs to be reset
  //NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];
  /*
   if (removedItem == angleItem) {
     [angleField setTarget:nil];
   }
   */
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{ // works just like menu item validation, but for the toolbar.
  /*
  int tag = [toolbarItem tag];
  if (tag == 31) { //BackToFront
    [toolbarItem setEnabled:NO];
    return NO;
  } else if (tag == 32) { //FrontToBack
    [toolbarItem setEnabled:YES];
    return YES;
  } else if (tag == WRITINGDIRECTION_MENU_TAG) { //Menu Item Toolboxes/Writing Direction
                                                 //[toolbarItem setState:(currentWritingDirectionMenuFlagSetting ? NSOnState : NSOffState)];
    return YES;    
  } else if (tag == FORMATGLYPH_MENU_TAG) { //Menu Item Toolboxes/Format Glyph
                                            //[toolbarItem setState:(currentFormatGlyphMenuFlagSetting ? NSOnState : NSOffState)];
    return YES;    
  } else if (tag == CARTOUCHE_MENU_TAG) { //Menu Item Toolboxes/Cartouche
                                          //[toolbarItem setState:(currentCartoucheMenuFlagSetting ? NSOnState : NSOffState)];
    return YES;    
  } else if (tag == LINE_MENU_TAG) { //Menu Item Toolboxes/Line
                                     //[toolbarItem setState:(currentLineMenuFlagSetting ? NSOnState : NSOffState)];
    return YES;    
  }
   */
  return YES; // we'll assume anything else is OK, which is the default
}

@end


// ===========================================================================
#pragma mark -
#pragma mark -- functions --
//==================================Toolbar Stuff=============================


void IGDrawGridWithSettingsInRect(float spacing, NSColor *color, NSRect rect, NSPoint gridOrigin) {
    int curColumn, endColumn, curRow, endRow;
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    
    [color set];
    /*
    // Columns
    curLine = ceil((NSMinX(rect) - gridOrigin.x) / spacing);
    endLine = floor((NSMaxX(rect) - gridOrigin.x) / spacing);
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint((curLine * spacing) + gridOrigin.x, NSMinY(rect))];
        [gridPath lineToPoint:NSMakePoint((curLine * spacing) + gridOrigin.x, NSMaxY(rect))];
    }
    // Rows
    curLine = ceil((NSMinY(rect) - gridOrigin.y) / spacing);
    endLine = floor((NSMaxY(rect) - gridOrigin.y) / spacing);
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint(NSMinX(rect), (curLine * spacing) + gridOrigin.y)];
        [gridPath lineToPoint:NSMakePoint(NSMaxX(rect), (curLine * spacing) + gridOrigin.y)];
    }
    */
    
    // Columns
    curColumn = floor((NSMinX(rect) - gridOrigin.x) / spacing);
    endColumn = floor((NSMaxX(rect) - gridOrigin.x) / spacing);
    for (; curColumn<=endColumn; curColumn++) {
        curRow = floor((NSMinY(rect) - gridOrigin.y) / spacing);
        endRow = floor((NSMaxY(rect) - gridOrigin.y) / spacing);
        for (; curRow<=endRow; curRow++) {
            [gridPath moveToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x - 0.05, (curRow * spacing) + gridOrigin.y - 0.05)];
            [gridPath lineToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x + 0.1, (curRow * spacing) + gridOrigin.y)];
            [gridPath lineToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x , (curRow * spacing) + gridOrigin.y + 0.1)];
            [gridPath lineToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x - 0.1, (curRow * spacing) + gridOrigin.y)];
            [gridPath lineToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x , (curRow * spacing) + gridOrigin.y - 0.1)];
            [gridPath lineToPoint:NSMakePoint((curColumn * spacing) + gridOrigin.x + 0.1, (curRow * spacing) + gridOrigin.y + 0.1)];
            
        }
    }
    
    [gridPath setLineWidth:0.0];
    [gridPath stroke];
}