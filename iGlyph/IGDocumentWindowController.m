//
//  IGDrawWindowController.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGDrawDocument.h"
#import "IGDocumentWindowController.h"
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
#import "IGRectangle.h"
#import "IGTextArea.h"
#import "IGLine.h"
#import "IGRubric.h"
#import "IGDestroyed.h"
#import "IGCircle.h"
#import "IGArc.h"


#define POINTS_PER_INCH 72.0
#define POINTS_PER_CENTIMETER 28.3464567
#define MILLIMETERS_PER_INCH 25.4

@implementation IGDocumentWindowController

- (instancetype)init {
    self = [super initWithWindowNibName:@"DocumentWindow"];
    NSLog(@"IGDrawWindowController(init)");
    return self;
}

- (void)createGraphicOfClassGlyph:(unichar)glyphChar WithFont:(NSString *)fontName {}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


// ===========================================================================
#pragma mark -
#pragma mark window and document stuff
// ====================== window and document stuff ==========================

- (NSPrintInfo *)documentPrintInfo {
    return [self.document printInfo];
}

- (NSSize)documentSize {
    if (self.document) {
        return [self.document documentSize];
    } else {
        NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
        NSSize paperSize = printInfo.paperSize;
        paperSize.width -= (printInfo.leftMargin + printInfo.rightMargin);
        paperSize.height -= (printInfo.topMargin + printInfo.bottomMargin);
        return paperSize;
    }
}

- (NSSize)paperSize {
    if (self.document) {
        return [self.document paperSize];
    } else {
        NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
        NSSize paperSize = printInfo.paperSize;
        return paperSize;
    }
}

- (void)setUpGraphicView {
    NSLog(@"IGDrawWindowController(setUpGraphicView)");
    //NSPrintInfo *printInfo = [[self documentPrintInfo] retain];
    NSSize paperSize = self.paperSize;
    
    //NSLog(@"IGDrawWindowController(setUpGraphicView) -> paperSize w: %f, h: %f", paperSize.width, paperSize.height);
    //NSLog(@"IGDrawWindowController(setUpGraphicView) -> leftMargin: %f, rightMargin: %f, topMargin: %f, bottomMargin: %f, ", [printInfo leftMargin], [printInfo rightMargin], [printInfo topMargin], [printInfo bottomMargin]);
    
    [graphicView setFrameSize:paperSize];
    graphicView.needsDisplay = YES;
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
    
    graphicView.drawWindowController = self;
    
    [self setUpGraphicView];
    
    [self.window makeFirstResponder:graphicView];
    
    //[self selectedToolDidChange:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedToolDidChange:) name:IGSelectedToolDidChangeNotification object:[ObjectsController sharedObjectsController]];
    
    [zoomScrollView scrollRectToVisible:NSMakeRect(1,1,1,1)];
    graphicView.currentCursorPosition = NSMakePoint([graphicView documentRectForPageNumber:0].origin.x + 10, [graphicView documentRectForPageNumber:0].origin.y + 25);
    
    //damit das Fenster die Mouse-Bewegung verfolgt
    [graphicView.window setAcceptsMouseMovedEvents:YES];
    
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
    
    graphicView.showsGrid = [userDef boolForKey:IGPrefShowsGridKey];
    graphicView.snapsToGrid = [userDef boolForKey:IGPrefSnapsToGridKey];
    graphicView.gridSpacing = [userDef floatForKey:IGPrefGridSpacingKey];
    graphicView.gridColor = [userDef objectForKey:IGPrefGridColorKey];
    
    graphicView.guidelineType = [userDef integerForKey:IGPrefGuideLineTypeKey];
    graphicView.guidelineCount = [userDef integerForKey:IGPrefGuideLineCountKey];
    
    [graphicView setNeedsDisplay:YES];
}

- (void)setDocument:(NSDocument *)document {
    super.document = document;
    [self setUpGraphicView];
}


/**
 Points to the graphicView, i.e. the DocumentView

 @return IGGraphicView
 */
- (IGGraphicView *)graphicView {
    return graphicView;
}

- (void)createGraphicOfClassGlyph:(unichar)glyphChar withFont:(NSString *)fontName {
    NSUInteger page = 0;
    if (NSPointInRect(graphicView.currentCursorPosition, graphicView.pageHeaderRect)) {
        page =0 ; //falls die Glyphe im Headerteil erstellt wurde, wird sie automatisch in die Headerseite eingefügt
    } else {
        page = graphicView.currentPage; //ansonsten ganz normal
    }
    
    [self.document createGraphicOfClassGlyph:glyphChar withFont:fontName onPosition:graphicView.currentCursorPosition onPage:page];
}

- (NSMutableArray *)selectedGraphics {
    NSLog(@"IGDrawWindowController(selectedGraphics)");
    return [self.document selectedPageObjects];
}

- (void)invalidateGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawWindowController(invalidateGraphic)");
    [graphicView invalidateGraphic:graphic];
}

- (void)selectGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawWindowController(selectGraphic)");
    [self.document selectGraphic: graphic];
}

- (void)deselectGraphic:(IGGraphic *)graphic {
    NSLog(@"IGDrawWindowController(deselectGraphic)");
    [self.document deselectGraphic: graphic];
}

- (void)clearSelection {
    NSLog(@"IGDrawWindowController(clearSelection)");
    [self.document clearSelection];
}


- (void)redisplayTweak:(IGGraphic *)graphic {
    [graphicView redisplayTweak:graphic];
}


- (void)displayMousePos:(NSPoint)pos {
    //NSLog(@"IGDrawWindowController(displayMousePos)");
    xCursorPosTextField.stringValue = [[NSString alloc] initWithFormat:@"%4.0f", pos.x];
    yCursorPosTextField.stringValue = [[NSString alloc] initWithFormat:@"%4.0f", pos.y];
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
    
    [window beginSheet:marginWindow completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == 1) [self setPageMargins];
    }];
}

- (void)prepareMarginView
{
    /*
     This method is the "glue code" for preparing the margin view to be displayed.
     The NSPrintInfo for the document controls the margins (among other settings).
     */
    NSPrintInfo *info = self.documentPrintInfo;
    /*
     We allow the user to store his default measurement unit.  The possibilities are inches, millimeters and points.  Since the unit is kept in user defaults, the app will always remember it.
     */
    //int units = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
    int units = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey]).intValue;
    float left = info.leftMargin;
    float right = info.rightMargin;
    float top = info.topMargin;
    float bottom = info.bottomMargin;
    
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
    
    leftMargin.floatValue = left;
    rightMargin.floatValue = right;
    topMargin.floatValue = top;
    bottomMargin.floatValue = bottom;
    
}

- (IBAction)dismissMarginSheet:(id)sender
{
    NSButton *sndr = (NSButton *)sender;
    [window endSheet:marginWindow returnCode:sndr.tag];
    [marginWindow orderOut:sender];
    
}

- (void)setPageMargins
{
    /*
     This method is called after the user clicks OK.  It simply converts the values in the fields to points, if necessary, and sets the appropriate values in the document's NSPrintInfo.
     */
    NSPrintInfo *info = self.documentPrintInfo;
    info.leftMargin = [self convertToPoints:leftMargin.floatValue];
    info.rightMargin = [self convertToPoints:rightMargin.floatValue];
    info.topMargin = [self convertToPoints:topMargin.floatValue];
    info.bottomMargin = [self convertToPoints:bottomMargin.floatValue];
    [self setUpGraphicView];
}

- (float)convertToPoints:(float)width
{
    /*
     converts a float from whatever the current units are into points.
     */
    //int currentUnits = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
    int currentUnits = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey]).intValue;
    
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
    NSUInteger newUnits = marginUnits.selectedCell.tag;
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
    
    leftMargin.floatValue = leftMargin.floatValue * factor;
    rightMargin.floatValue = rightMargin.floatValue * factor;
    topMargin.floatValue = topMargin.floatValue * factor;
    bottomMargin.floatValue = bottomMargin.floatValue * factor;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(newUnits) forKey:IGMarginUnitsKey];
}

- (IBAction)useMinimumMargins:(id)sender
{
    /*
     This action is invoked when the user clicks on the Minimum Margins button.  It sends the margins so that the user's page will be centered in the imageable area (as provided by -[NSPrintInfo imageablePageBounds]) for the current printer.
     */
    //int currentUnits = [(NSNumber *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:IGAppBundleName] objectForKey:IGMarginUnitsKey] intValue];
    int currentUnits = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:IGMarginUnitsKey]).intValue;
    NSPrintInfo *info = self.documentPrintInfo;
    NSRect imageRect = info.imageablePageBounds;
    NSSize paperSize = info.paperSize;
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
    
    leftMargin.floatValue = horiz;
    rightMargin.floatValue = horiz;
    topMargin.floatValue = vert;
    bottomMargin.floatValue = vert;
}


// MARK -
// MARK -- toolbar stuff --

static NSString *MyDocumentToolbarIdentifier = @"MyDocument Toolbar";
static NSString *CartoucheToolbarItemIdentifier = @"Cartouche ToolbarItem";
static NSString *RectangleToolbarItemIdentifier = @"Rectangle ToolbarItem";
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
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;
    self.window.toolbar = toolbar;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
    
    if ([itemIdent isEqual:CartoucheToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Cartouche";
        toolbarItem.paletteLabel = @"Cartouche";
        toolbarItem.toolTip = @"Make a Cartouche";
        toolbarItem.image = [NSImage imageNamed: @"TB_Shape_Oval"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertCartouche:);
        
    } else if ([itemIdent isEqual:RectangleToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Rectangle";
        toolbarItem.paletteLabel = @"Rectangle";
        toolbarItem.toolTip = @"Make a Rectangle";
        toolbarItem.image = [NSImage imageNamed: @"TB_Square"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertRectangle:);
        
    } else if ([itemIdent isEqual:TextToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"TextArea";
        toolbarItem.paletteLabel = @"TextArea";
        toolbarItem.toolTip = @"Make a TextArea";
        toolbarItem.image = [NSImage imageNamed: @"TB_Text"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertTextArea:);
        
    } else if ([itemIdent isEqual:LineToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Line";
        toolbarItem.paletteLabel = @"Line";
        toolbarItem.toolTip = @"Make a Line";
        toolbarItem.image = [NSImage imageNamed: @"TB_Shape_Line"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertLine:);
        
    } else if ([itemIdent isEqual:RubricToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Rubric";
        toolbarItem.paletteLabel = @"Rubric";
        toolbarItem.toolTip = @"Make a Rubric";
        toolbarItem.image = [NSImage imageNamed: @"TB_Square"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertRubric:);
        
    } else if ([itemIdent isEqual:DestroyedToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Destroyed";
        toolbarItem.paletteLabel = @"Destroyed";
        toolbarItem.toolTip = @"Make Destroyed";
        toolbarItem.image = [NSImage imageNamed: @"TB_Square"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertDestroyed:);
        
    } else if ([itemIdent isEqual:CircleToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Circle";
        toolbarItem.paletteLabel = @"Circle";
        toolbarItem.toolTip = @"Make a Circle";
        toolbarItem.image = [NSImage imageNamed: @"TB_Circle"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertCircle:);
        
    } else if ([itemIdent isEqual:ArcToolbarItemIdentifier]) { // a basic button item
        toolbarItem.label = @"Arc";
        toolbarItem.paletteLabel = @"Arc";
        toolbarItem.toolTip = @"Make a Arc";
        toolbarItem.image = [NSImage imageNamed: @"TB_Circle"];
        toolbarItem.target = self;
        toolbarItem.action = @selector(insertArc:);
        
    } else if ([itemIdent isEqual:BackToFrontTolbarItemIndentifier]) { // a basic button item
        toolbarItem.label = @"Front";
        toolbarItem.paletteLabel = @"Front";
        toolbarItem.toolTip = @"Moves the selected objects to the top";
        toolbarItem.tag = 31;
        toolbarItem.image = [NSImage imageNamed: @"TB_front"];
        toolbarItem.target = self.graphicView;
        toolbarItem.action = @selector(bringToFront:);
        
    } else if ([itemIdent isEqual:FrontToBackTolbarItemIndentifier]) { // a basic button item
        toolbarItem.label = @"Back";
        toolbarItem.paletteLabel = @"Back";
        toolbarItem.toolTip = @"Moves the selected objects to the bottom";
        toolbarItem.tag = 32;
        toolbarItem.image = [NSImage imageNamed: @"TB_back"];
        toolbarItem.target = self.graphicView;
        toolbarItem.action = @selector(sendToBack:);
        
    } else if ([itemIdent isEqual:SpecialCharactersTolbarItemIndentifier]) { // a basic button item
        toolbarItem.label = @"Special Characters";
        toolbarItem.paletteLabel = @"Special Characters";
        toolbarItem.toolTip = @"Opens the Special Characters Panel";
        toolbarItem.tag = 33;
        toolbarItem.image = [NSImage imageNamed: @"TB_Characters"];
        toolbarItem.target = [NSApplication sharedApplication];
        toolbarItem.action = @selector(orderFrontCharacterPalette:);
    } else {
        return nil;
    }
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
    return @[CartoucheToolbarItemIdentifier, RectangleToolbarItemIdentifier, TextToolbarItemIdentifier, LineToolbarItemIdentifier,
             RubricToolbarItemIdentifier, DestroyedToolbarItemIdentifier, CircleToolbarItemIdentifier,
             ArcToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
             BackToFrontTolbarItemIndentifier, FrontToBackTolbarItemIndentifier,
             NSToolbarFlexibleSpaceItemIdentifier,
             NSToolbarShowFontsItemIdentifier, SpecialCharactersTolbarItemIndentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
    return @[CartoucheToolbarItemIdentifier, RectangleToolbarItemIdentifier, TextToolbarItemIdentifier, LineToolbarItemIdentifier,
             RubricToolbarItemIdentifier, DestroyedToolbarItemIdentifier, CircleToolbarItemIdentifier,
             ArcToolbarItemIdentifier, BackToFrontTolbarItemIndentifier, FrontToBackTolbarItemIndentifier,
             NSToolbarPrintItemIdentifier, NSToolbarShowColorsItemIdentifier,
             NSToolbarCustomizeToolbarItemIdentifier,
             NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier,
             NSToolbarSeparatorItemIdentifier];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
    NSToolbarItem *addedItem = notification.userInfo[@"item"];
    if ([addedItem.itemIdentifier isEqual:NSToolbarPrintItemIdentifier]) {
        addedItem.toolTip = @"Print Document";
        addedItem.target = self;
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
    NSUInteger tag = toolbarItem.tag;
    if (tag == 31) { //BackToFront
        [toolbarItem setEnabled:NO];
        return NO;
    } else if (tag == 32) { //FrontToBack
        [toolbarItem setEnabled:YES];
        return YES;
    } else if (tag == IGMenuWritingDirectionTag) { //Menu Item Toolboxes/Writing Direction
        //[toolbarItem setState:(currentWritingDirectionMenuFlagSetting ? NSOnState : NSOffState)];
        return YES;
    } else if (tag == IGMenuFormatGlypTag) { //Menu Item Toolboxes/Format Glyph
        //[toolbarItem setState:(currentFormatGlyphMenuFlagSetting ? NSOnState : NSOffState)];
        return YES;
    } else if (tag == IGMenuCartoucheTag) { //Menu Item Toolboxes/Cartouche
        //[toolbarItem setState:(currentCartoucheMenuFlagSetting ? NSOnState : NSOffState)];
        return YES;
    } else if (tag == IGMenuLineTag) { //Menu Item Toolboxes/Line
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
    IGGraphic *_newObject = [[IGCartouche allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
    [[IGInspectorController sharedInspectorController] refreshInspector];
}

-(void)insertRectangle:(id)sender
{
    IGGraphic *_newObject = [[IGRectangle allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}


-(void)insertTextArea:(id)sender
{
    IGGraphic *_newObject = [[IGTextArea allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

-(void)insertLine:(id)sender
{
    IGGraphic *_newObject = [[IGLine allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

-(void)insertRubric:(id)sender
{
    IGGraphic *_newObject = [[IGRubric allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

-(void)insertDestroyed:(id)sender
{
    IGGraphic *_newObject = [[IGDestroyed allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

-(void)insertCircle:(id)sender
{
    IGGraphic *_newObject = [[IGCircle allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

-(void)insertArc:(id)sender
{
    IGGraphic *_newObject = [[IGArc allocWithZone:[self.document zone]] init];
    _newObject.pageNr = graphicView.currentPage;
    [self.document insertGraphic:_newObject atIndex:0];
    [graphicView clearSelection];
    [graphicView selectGraphic:_newObject];
}

@end
