//
//  IGDrawWindowController.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGDrawDocument.h"
#import "IGDrawWindowController.h"
#import "IGGraphicView.h"
#import "IGBackgroundView.h"
#import "ObjectsController.h"
#import "IGCenteringClipView.h"
#import "IGZoomScrollView.h"
#import "IGlyphDelegate.h"
#import "PreferencesController.h"
#import "IGInspectorController.h"
#import "CartoucheController.h"

#import "IGGraphic.h"
#import "IGCartouche.h"
#import "IGTextArea.h"
#import "IGLine.h"
#import "IGRubric.h"
#import "IGDestroyed.h"
#import "IGCircle.h"
#import "IGArc.h"


#define POINTS_PER_INCH 72.0
#define POINTS_PER_CENTIMETER 28.3464567
#define MILLIMETERS_PER_INCH 25.4

@implementation IGDrawWindowController

- (id)init {
  self = [super initWithWindowNibName:@"DrawWindow"];
  NSLog(@"IGDrawWindowController(init)");
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];

}


// ===========================================================================
#pragma mark -
#pragma mark window and document stuff
// ====================== window and document stuff ==========================

- (NSPrintInfo *)documentPrintInfo {
  return [[[self document] printInfo] retain];
}

- (NSSize)documentSize {
  if ([self document]) {
    return [[self document] documentSize];
  } else {
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    NSSize paperSize = [printInfo paperSize];
    paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
    paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
    return paperSize;
  }
}

- (NSSize)paperSize {
  if ([self document]) {
    return [[self document] paperSize];
  } else {
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    NSSize paperSize = [printInfo paperSize];
    return paperSize;
  }
}

- (void)setUpGraphicView {
  NSLog(@"IGDrawWindowController(setUpGraphicView)");
  //NSPrintInfo *printInfo = [[self documentPrintInfo] retain];
  NSSize paperSize = [self paperSize];
  
  //NSLog(@"IGDrawWindowController(setUpGraphicView) -> paperSize w: %f, h: %f", paperSize.width, paperSize.height);
  //NSLog(@"IGDrawWindowController(setUpGraphicView) -> leftMargin: %f, rightMargin: %f, topMargin: %f, bottomMargin: %f, ", [printInfo leftMargin], [printInfo rightMargin], [printInfo topMargin], [printInfo bottomMargin]);
  
  [graphicView setFrameSize:paperSize];
  [graphicView setNeedsDisplay:YES];
}

/*
- (void)selectedToolDidChange:(NSNotification *)notification {
  // Just set the correct cursor
  Class theClass = [[ObjectsController sharedObjectsController] currentGraphicClass];
  NSCursor *theCursor = nil;
  if (theClass) {
    theCursor = [theClass creationCursor];
  }
  if (!theCursor) {
    theCursor = [NSCursor arrowCursor];
  }
  [[graphicView enclosingScrollView] setDocumentCursor:theCursor];
}
*/

- (void)windowDidLoad {
  [super windowDidLoad];
  
  [graphicView setDrawWindowController:self];
  
  [self setUpGraphicView];
  
  [[self window] makeFirstResponder:graphicView];
  
  //[self selectedToolDidChange:nil];
  //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedToolDidChange:) name:IGSelectedToolDidChangeNotification object:[ObjectsController sharedObjectsController]];
  
  [zoomScrollView scrollRectToVisible:NSMakeRect(1,1,1,1)];
  [graphicView setCurrentCursorPosition:NSMakePoint([graphicView documentRectForPageNumber:0].origin.x + 10, [graphicView documentRectForPageNumber:0].origin.y + 25)];
  
  //damit das Fenster die Mouse-Bewegung verfolgt
  [[graphicView window] setAcceptsMouseMovedEvents:YES];
  
  //damit die Seitenzahl stimmt
  [graphicView updateCurrentPageField];
  
  //update der View an Hand der Preferences
  [self updateViewFromPreferences];
  
  //Toolbar starten
  [self initializeToolbar];
  
  //Inspector Bindings
  //[graphicView bind: @"selectedGraphics" toObject: [[IGInspectorController sharedInspectorController] selectedGraphicsController] withKeyPath:@"selection" options:nil];
	//[graphicView bind: @"selectionIndexes" toObject: [[IGInspectorController sharedInspectorController] selectedGraphicsController] withKeyPath:@"selectionIndexes" options:nil];
  //NSLog(@"IGDrawWindowController(windowDidLoad) -> adding observer to graphicView");
  //[graphicView addObserver:[IGInspectorController sharedInspectorController] forKeyPath:@"selectedGraphics" options:0 context:NULL];
  //NSLog(@"IGDrawWindowController(windowDidLoad) -> finished adding observer to graphicView");
}

- (void)updateViewFromPreferences {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  
  [graphicView setShowsGrid:[userDef boolForKey:IGPrefShowsGridKey]];
  [graphicView setSnapsToGrid:[userDef boolForKey:IGPrefSnapsToGridKey]];
  [graphicView setGridSpacing:[userDef floatForKey:IGPrefGridSpacingKey]];
  [graphicView setGridColor:[userDef objectForKey:IGPrefGridColorKey]];
  
  [graphicView setGuidelineType:[userDef integerForKey:IGPrefGuideLineTypeKey]];
  [graphicView setGuidelineCount:[userDef integerForKey:IGPrefGuideLineCountKey]];
  
  [graphicView setNeedsDisplay:YES];
}

- (void)setDocument:(NSDocument *)document {
  [super setDocument:document];
  [self setUpGraphicView];
}

- (IGGraphicView *)graphicView {
  return graphicView;
}

- (void)invalidateGraphic:(IGGraphic *)graphic {
  [graphicView invalidateGraphic:graphic];
}

- (void)redisplayTweak:(IGGraphic *)graphic {
  [graphicView redisplayTweak:graphic];
}


- (void)displayMousePos:(NSPoint)pos {
  //NSLog(@"IGDrawWindowController(displayMousePos)");
  [xCursorPosTextField setStringValue:[[NSString alloc] initWithFormat:@"%4.0f", pos.x]];
  [yCursorPosTextField setStringValue:[[NSString alloc] initWithFormat:@"%4.0f", pos.y]];
}

- (void)windowWillClose:(NSNotification *)aNotification {
  [graphicView invalidateBlinkingCursorTimer];
}

// ===========================================================================
#pragma mark -
#pragma mark page margin stuff
// ====================== Grid settings ===========================
- (IBAction)pageMargins:(id)sender {
  /*
   This action is invoked by the Margins/Columns... menu item.  Thus, the user has two ways to set margins: via an accessory view in Page Setup... and via a separate menu item.  The separate menu item gives the user an obvious place to change the margins.  The accessory view gives the user a convenient way to change the margins while changing the paper and printer settings.
   */
  [self prepareMarginView];
  
  [NSApp beginSheet:marginWindow
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(marginSheetDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)prepareMarginView
{
  /*
   This method is the "glue code" for preparing the margin view to be displayed.
   The NSPrintInfo for the document controls the margins (among other settings).
   */
  NSPrintInfo *info = [self documentPrintInfo];
  /*
   We allow the user to store his default measurement unit.  The possibilities are inches, millimeters and points.  Since the unit is kept in user defaults, the app will always remember it.
   */
  //int units = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
  int units = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey] intValue];
  float left = [info leftMargin];
  float right = [info rightMargin];
  float top = [info topMargin];
  float bottom = [info bottomMargin];
  
  [marginUnits selectCellWithTag:units];
  
  /*
   left, right, top, and bottom are all in points.  We convert them into the user's units, if necessary, and then set the marginView fields accordingly.
   */
  
  switch (units)
  {
    case 0: //inches
      left /= POINTS_PER_INCH;
      right /= POINTS_PER_INCH;
      top /= POINTS_PER_INCH;
      bottom /= POINTS_PER_INCH;
      break;
    case 1: //millimeters
      left /= POINTS_PER_CENTIMETER;
      right /= POINTS_PER_CENTIMETER;
      top /= POINTS_PER_CENTIMETER;
      bottom /= POINTS_PER_CENTIMETER;
    default: 
      break;            
  }
  
  [leftMargin setFloatValue:left];
  [rightMargin setFloatValue:right];
  [topMargin setFloatValue:top];
  [bottomMargin setFloatValue:bottom];
  
}


- (void)marginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if(returnCode == 1) [self setPageMargins];
}

- (IBAction)dismissMarginSheet:(id)sender
{   
  [marginWindow orderOut:sender];
  [NSApp endSheet:marginWindow returnCode:[sender tag]];
}


- (void)setPageMargins
{
  /*
   This method is called after the user clicks OK.  It simply converts the values in the fields to points, if necessary, and sets the appropriate values in the document's NSPrintInfo.
   */
  NSPrintInfo *info = [self documentPrintInfo];
  [info setLeftMargin:[self convertToPoints:[leftMargin floatValue]]];    
  [info setRightMargin:[self convertToPoints:[rightMargin floatValue]]];
  [info setTopMargin:[self convertToPoints:[topMargin floatValue]]];
  [info setBottomMargin:[self convertToPoints:[bottomMargin floatValue]]];
  [self setUpGraphicView];
}

- (float)convertToPoints:(float)width
{
  /*
   converts a float from whatever the current units are into points.
   */
  //int currentUnits = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
  int currentUnits = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey] intValue];
  
  switch(currentUnits)
  {
    case 0: // currently inches
      width *= POINTS_PER_INCH;
      break;
    case 1: //currently centimeters
      width *= POINTS_PER_CENTIMETER;
      break;
    default:
      break;
  }
  return width;
}

- (IBAction)changeMarginUnits:(id)sender
{
  /*
   This action is invoked when the user switches units, e.g., from inches to points.  It converts all the values in the text fields to the new units and stores the new unit type in NSUserDefaults.
   */
  int newUnits = [[marginUnits selectedCell] tag];
  float factor = [self convertToPoints:1.0];
  
  switch(newUnits)        
  {
    case 0: // convert to inches
      factor /= POINTS_PER_INCH;
      break;
    case 1:
      factor /= POINTS_PER_CENTIMETER;
      break;
    default:
      break;
  }
  
  [leftMargin setFloatValue:[leftMargin floatValue] * factor];
  [rightMargin setFloatValue:[rightMargin floatValue] * factor];
  [topMargin setFloatValue:[topMargin floatValue] * factor];
  [bottomMargin setFloatValue:[bottomMargin floatValue] * factor];
  
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newUnits] forKey:IGMarginUnitsKey];
}

- (IBAction)useMinimumMargins:(id)sender
{
  /*
   This action is invoked when the user clicks on the Minimum Margins button.  It sends the margins so that the user's page will be centered in the imageable area (as provided by -[NSPrintInfo imageablePageBounds]) for the current printer.
   */
  //int currentUnits = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
  int currentUnits = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey] intValue];
  NSPrintInfo *info = [self documentPrintInfo];
  NSRect imageRect = [info imageablePageBounds];
  NSSize paperSize = [info paperSize];
  float vert = (paperSize.height - imageRect.size.height)/2.0;
  float horiz = (paperSize.width - imageRect.size.width)/2.0;
  float factor = 1.0;
  
  switch(currentUnits)
  {
    case 0:
      factor = POINTS_PER_INCH;
      break;
    case 1:
      factor = POINTS_PER_CENTIMETER;
      break;
    default:
      break;
  }
  
  vert /= factor;
  horiz/= factor;
  
  [leftMargin setFloatValue:horiz];
  [rightMargin setFloatValue:horiz];
  [topMargin setFloatValue:vert];
  [bottomMargin setFloatValue:vert];
}

// ===========================================================================
#pragma mark -
#pragma mark -- toolbar stuff --
//==================================Toolbar Stuff=============================

static NSString *MyDocumentToolbarIdentifier = @"MyDocument Toolbar";
static NSString *CartoucheToolbarItemIdentifier = @"Cartouche ToolbarItem";
static NSString *TextToolbarItemIdentifier = @"Text ToolbarItem";
static NSString *LineToolbarItemIdentifier = @"Line ToolbarItem";
static NSString *RubricToolbarItemIdentifier = @"Rubric ToolbarItem";
static NSString *DestroyedToolbarItemIdentifier = @"Destroyed ToolbarItem";
static NSString *CircleToolbarItemIdentifier = @"Circle ToolbarItem";
static NSString *ArcToolbarItemIdentifier = @"Arc ToolbarItem";

static NSString *BackToFrontTolbarItemIndentifier = @"Back to Front TolbarItem";
static NSString *FrontToBackTolbarItemIndentifier = @"Front to Back TolbarItem";
static NSString *SpecialCharactersTolbarItemIndentifier = @"Special Characters TolbarItem";

// It starts here
- (void)initializeToolbar
{
  NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:MyDocumentToolbarIdentifier];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setAutosavesConfiguration:YES];
  [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
  [toolbar setDelegate:self];
  [[self window] setToolbar:toolbar];
  [toolbar release];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
  NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
  
  [toolbarItem autorelease];
  if ([itemIdent isEqual:CartoucheToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Cartouche"];
    [toolbarItem setPaletteLabel: @"Cartouche"];
    [toolbarItem setToolTip:@"Make a Cartouche"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Shape_Oval"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertCartouche:)];
    
  } else if ([itemIdent isEqual:TextToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"TextArea"];
    [toolbarItem setPaletteLabel: @"TextArea"];
    [toolbarItem setToolTip:@"Make a TextArea"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Text"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertTextArea:)];
    
  } else if ([itemIdent isEqual:LineToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Line"];
    [toolbarItem setPaletteLabel: @"Line"];
    [toolbarItem setToolTip:@"Make a Line"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Shape_Line"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertLine:)];
    
  } else if ([itemIdent isEqual:RubricToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Rubric"];
    [toolbarItem setPaletteLabel: @"Rubric"];
    [toolbarItem setToolTip:@"Make a Rubric"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Square"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertRubric:)];
    
  } else if ([itemIdent isEqual:DestroyedToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Destroyed"];
    [toolbarItem setPaletteLabel: @"Destroyed"];
    [toolbarItem setToolTip:@"Make Destroyed"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Square"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertDestroyed:)];
    
  } else if ([itemIdent isEqual:CircleToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Circle"];
    [toolbarItem setPaletteLabel: @"Circle"];
    [toolbarItem setToolTip:@"Make a Circle"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Circle"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertCircle:)];
    
  } else if ([itemIdent isEqual:ArcToolbarItemIdentifier]) { // a basic button item
    [toolbarItem setLabel: @"Arc"];
    [toolbarItem setPaletteLabel: @"Arc"];
    [toolbarItem setToolTip:@"Make a Arc"];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Circle"]];
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(insertArc:)];
    
  } else if ([itemIdent isEqual:BackToFrontTolbarItemIndentifier]) { // a basic button item
    [toolbarItem setLabel: @"Front"];
    [toolbarItem setPaletteLabel: @"Front"];
    [toolbarItem setToolTip:@"Moves the selected objects to the top"];
    [toolbarItem setTag:31];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_front"]];
    [toolbarItem setTarget: [self graphicView]];
    [toolbarItem setAction: @selector(bringToFront:)];
    
  } else if ([itemIdent isEqual:FrontToBackTolbarItemIndentifier]) { // a basic button item
    [toolbarItem setLabel: @"Back"];
    [toolbarItem setPaletteLabel: @"Back"];
    [toolbarItem setToolTip:@"Moves the selected objects to the bottom"];
    [toolbarItem setTag:32];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_back"]];
    [toolbarItem setTarget: [self graphicView]];
    [toolbarItem setAction: @selector(sendToBack:)];
    
  } else if ([itemIdent isEqual:SpecialCharactersTolbarItemIndentifier]) { // a basic button item
    [toolbarItem setLabel: @"Special Characters"];
    [toolbarItem setPaletteLabel: @"Special Characters"];
    [toolbarItem setToolTip:@"Opens the Special Characters Panel"];
    [toolbarItem setTag:33];
    [toolbarItem setImage:[NSImage imageNamed: @"TB_Characters"]];
    [toolbarItem setTarget: [NSApplication sharedApplication]];
    [toolbarItem setAction: @selector(orderFrontCharacterPalette:)];
  } else {
    return nil;
  }
  return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
  return [NSArray arrayWithObjects:
    CartoucheToolbarItemIdentifier, TextToolbarItemIdentifier, LineToolbarItemIdentifier,
    RubricToolbarItemIdentifier, DestroyedToolbarItemIdentifier, CircleToolbarItemIdentifier,
    ArcToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
    BackToFrontTolbarItemIndentifier, FrontToBackTolbarItemIndentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarShowFontsItemIdentifier, SpecialCharactersTolbarItemIndentifier, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
  return [NSArray arrayWithObjects:
    CartoucheToolbarItemIdentifier, TextToolbarItemIdentifier, LineToolbarItemIdentifier,
    RubricToolbarItemIdentifier, DestroyedToolbarItemIdentifier, CircleToolbarItemIdentifier,
    ArcToolbarItemIdentifier, BackToFrontTolbarItemIndentifier, FrontToBackTolbarItemIndentifier,
    NSToolbarPrintItemIdentifier, NSToolbarShowColorsItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier,
    NSToolbarSeparatorItemIdentifier, nil];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
  NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
  if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier]) {
    [addedItem setToolTip: @"Print Document"];
    [addedItem setTarget:self];
  }
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
  return YES; // we'll assume anything else is OK, which is the default
}

// ===========================================================================
#pragma mark -
#pragma mark -- toolbar item selector stuff --
//==================================Toolbar Item Selector Stuff=============================

-(void)insertCartouche:(id)sender
{
  IGGraphic *_newObject = [[IGCartouche allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
  [[IGInspectorController sharedInspectorController] refreshInspector];
}

-(void)insertTextArea:(id)sender
{
  IGGraphic *_newObject = [[IGTextArea allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

-(void)insertLine:(id)sender
{
  IGGraphic *_newObject = [[IGLine allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

-(void)insertRubric:(id)sender
{
  IGGraphic *_newObject = [[IGRubric allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

-(void)insertDestroyed:(id)sender
{
  IGGraphic *_newObject = [[IGDestroyed allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

-(void)insertCircle:(id)sender
{
  IGGraphic *_newObject = [[IGCircle allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

-(void)insertArc:(id)sender
{
  IGGraphic *_newObject = [[IGArc allocWithZone:[[self document] zone]] init];
  [_newObject setPageNr:[[self graphicView] currentPage]];
  [[self document] insertGraphic:_newObject atIndex:0];
  [graphicView clearSelection];
  [graphicView selectGraphic:_newObject];
}

@end