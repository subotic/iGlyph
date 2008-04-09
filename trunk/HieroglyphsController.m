///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/HieroglyphsController.m,v $
// $Revision: 1.11 $ $Date: 2005/05/11 10:10:21 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// HieroglyphsController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////


#import "HieroglyphsController.h"
#import "IGlyphDelegate.h"
#import "IGGraphicView.h"
#import "IGDrawWindowController.h"
#import "IGFontData.h"
#import "IGGraphic.h"
#import "IGGlyph.h"

@implementation HieroglyphsController

@synthesize rowNumber;
@synthesize colNumber;
@synthesize glyphNumber;


+ (id)sharedHieroglyphsController
{
    static HieroglyphsController *_sharedHieroglyphsController = nil;
    
    if (!_sharedHieroglyphsController) {
        _sharedHieroglyphsController = [[HieroglyphsController allocWithZone:[self zone]] init];
    }
    return _sharedHieroglyphsController;
}

- (id)init
{
    self = [self initWithWindowNibName:@"Hieroglyphs"];
    if (self) {
        [self setWindowFrameAutosaveName:@"Hieroglyphs"];
    }
    [self setShouldCascadeWindows:NO];
    return self;
}


- (void) dealloc
{
    [super dealloc];
}


- (void)awakeFromNib
{
    NSLog(@"HieroglyphsController(awakeFromNib) -> start");
    
    fontData = [[NSApp delegate] sharedFontData];
    fontDataDic = [fontData getFontData];
    glyphGroupsArr = [fontData getGlyphGroups];
    selectedTitle = [glyphGroupsArr objectAtIndex:0];
    headerSelected = 0;
    
    // reset the glyphGroup pop-up
    //[glyphGroupPopUp removeAllItems];
    [self addGlyphGroupPopUpItems];
    
    NSLog(@"[self resizeTable] start");
    [self resizeTable];
    NSLog(@"[self resizeTable] end");
    
    NSLog(@"[[glyphGroupComboBox window] makeKeyAndOrderFront:nil] start");
    //[[glyphGroupComboBox window] makeKeyAndOrderFront:nil];
    NSLog(@"[[glyphGroupComboBox window] makeKeyAndOrderFront:nil] end");
    
    NSLog(@"HieroglyphsController(awakeFromNib) -> end");
    
    // Um aus dem Fenster eine View zu machen
    //[self convertToViewController];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Hieroglyphs"];
}

- (void)addGlyphGroupPopUpItems
{    
    [glyphGroupPopUp removeAllItems];
    [glyphGroupPopUp addItemsWithTitles:glyphGroupsArr];
}


- (IBAction)glyphGroupPopUpChanged:(id)sender {
  NSString *groupTitle = [glyphGroupPopUp titleOfSelectedItem];
  NSLog(@"HieroglyphsController(glyphGroupPopUpChanged)->Ausgewahlter Titel: %@", groupTitle);
  
  selectedTitle = groupTitle;
  [self resizeTable];
}

- (void)resizeTable
{
    NSLog(@"HieroglyphsController(resizeTable) -> start");
    
    self.glyphNumber = [[fontDataDic objectForKey:selectedTitle] count];
    NSLog(@"HieroglyphsController(resizeTable) -> Anzahl der Eintraege im Array ist: %d", self.glyphNumber);
    
    NSInteger width = [myTableView frame].size.width;
    //NSLog(@"myTableView breite: %d", width);
    
    self.colNumber = width/50;
    int glyphCount = [[fontDataDic objectForKey:selectedTitle] count];
    self.rowNumber = ceilf(glyphCount / self.colNumber);
    
    // clear columns in MyTableView
    /**
    NSArray *columnsArr = [myTableView tableColumns];
    NSEnumerator *enumerator = [columnsArr objectEnumerator];
    id anObject;
    while (anObject = [enumerator nextObject])
    {
        [myTableView removeTableColumn:anObject];
    }
    **/
    NSLog(@"HieroglyphsController(resizeTable)-> vor clear columns");
    // clear columns in MyTableView
    
    NSArray *columnsArr = [myTableView tableColumns];
    for ( id anObject in columnsArr ) {
      [myTableView removeTableColumn:anObject];
    }
    NSLog(@"hier");
    
    int i;
    for (i = 0; i < colNumber; i++)
    {
        NSString *tempString = [[NSString alloc] initWithFormat:@"%d",i];// (1)
        NSLog(@"HieroglyphsController(resizeTable) tempString ==> %@", tempString);
        
        NSTableHeaderCell *cellHeader = [[NSTableHeaderCell alloc]initTextCell:tempString]; // (2)
        NSTextFieldCell *cellData = [[NSTextFieldCell alloc] initTextCell:@""]; // (3)
        [cellData setDrawsBackground:YES];
        [cellData setBezeled:YES];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:tempString]; // (4)
        [column setHeaderCell:cellHeader];
        [column setDataCell:cellData];
        
        // need to do better font calculation here
        // [column setMinWidth:44];
        // [column setMaxWidth:50];
        [column setWidth:50];
        [cellHeader release]; // (3)
        [cellData release]; // (2)
        [tempString release]; // (1)
        
        [myTableView addTableColumn:column];
        [column release]; // (0)
        [myTableView setRowHeight:50];
    }
    
    NSLog(@"HieroglyphsController(resizeTable) -> [myTableView reloadData] start");
    [myTableView reloadData];
    //NSLog(@"HieroglyphsController(resizeTable) -> [myTableView reloadData] end");
    NSLog(@"HieroglyphsController(resizeTable) -> end");
}

//Data Source stuff

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"numberOfRowsInTableView");
    return self.rowNumber;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    //NSLog(@"tableView:(NSTableView *)tableView objectValueForTableColumn start");
    int column = [[tableColumn identifier] intValue];
    int neededValue = (column + row * colNumber);
    
    NSMutableArray *titleData = [fontDataDic objectForKey:selectedTitle];
    
    //NSLog(@"HieroglyphsController(tableView) titleData ==> %@", titleData);
    
    NSMutableDictionary *attrsTxt = [NSMutableDictionary dictionary];
    NSMutableDictionary *attrsGlyph = [NSMutableDictionary dictionary];
    NSAttributedString *attribStringTxt = [[NSAttributedString alloc] init];
    NSAttributedString *attribStringGlyph = [[NSAttributedString alloc] init];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *myPara = [[NSMutableParagraphStyle alloc] init];
    [myPara setAlignment:NSCenterTextAlignment];
    unichar newChar;
    if (neededValue < glyphNumber) {
        //text Teil
        NSMutableString *txt = [[NSMutableString alloc] init];
        [txt setString:[[titleData objectAtIndex:neededValue] objectAtIndex:headerSelected]];
        [txt appendString:@"\n"];
            
        [attrsTxt setObject:[NSFont systemFontOfSize:9] forKey:NSFontAttributeName];
        [attrsTxt setObject:myPara forKey:NSParagraphStyleAttributeName];

        [attribStringTxt initWithString:txt attributes:attrsTxt];
            
        //glyphen Teil
        newChar = (0xF000 + [[[titleData objectAtIndex:neededValue] objectAtIndex:2] intValue]);
        unichar *pNewChar = &newChar;
        NSString *glyph = [NSString stringWithCharacters:pNewChar length:1];
        NSString *font = [[titleData objectAtIndex:neededValue] objectAtIndex:1];
        
        NSAssert([NSFont fontWithName:font size:36], @"Unable to load Font. Are they installed?");	
		
        [attrsGlyph setObject:[NSFont fontWithName:font size:36] forKey:NSFontAttributeName];
        [attrsGlyph setObject:myPara forKey:NSParagraphStyleAttributeName];
            
        [attribStringGlyph initWithString:glyph attributes:attrsGlyph];
            
        [attribString appendAttributedString:attribStringTxt];
        [attribString appendAttributedString:attribStringGlyph];
            
        //NSLog(@"tableView:(NSTableView *)tableView objectValueForTableColumn end 1");
        return attribString;
    } else {
       	//NSLog(@"tableView:(NSTableView *)tableView objectValueForTableColumn end 2");
    	return attribString;
    }
}

- (IBAction)headerChanged:(id)sender //wechselt zwischen den HGlyph Namen oder Laut
{
    headerSelected = (headerSelected == 0) ? 3 : 0;
    NSLog(@"HieroglyphsController(headerChanged) headerSelected = %d", headerSelected);
    [myTableView reloadData];
}


//wird vom IGHieroglyphsTableView aufgerufen
- (void)glyphClickedAtRow:(int)rowValue andColumn:(int)columnValue
{
    NSLog(@"glyphClicked action");
    int r = rowValue;
    int c = columnValue;
    //[myTableView deselectAll:sender];
	
    NSLog(@"HieroglyphsController(glyphClicked) Row: %d, Column: %d",r,c);
    
    int glyphPosInArray = (c + (r * colNumber));
    NSArray *titleData = [fontDataDic objectForKey:selectedTitle];
    unichar glyphUniChar = (0xF000 + [[[titleData objectAtIndex:glyphPosInArray] objectAtIndex:2] intValue]);
    
    NSLog(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);
    
    NSString *fontName = [[titleData objectAtIndex:glyphPosInArray] objectAtIndex:1];
    
    [[self theMainView] createGraphicOfClassGlyph:glyphUniChar WithFont:fontName];
}

//wird vom IGHieroglyphsTableView aufgerufen wenn right-click oder ctr-click
- (void)replaceSelectedGlyphWithThisOneAtRow:(int)rowValue andColumn:(int)columnValue {
    
    int r = rowValue;
    int c = columnValue;
    //[myTableView deselectAll:sender];

    NSLog(@"HieroglyphsController(glyphClicked) Row: %d, Column: %d",r,c);

    int glyphPosInArray = (c + (r * colNumber));
    NSArray *titleData = [fontDataDic objectForKey:selectedTitle];
    unichar glyphUniChar = (0xF000 + [[[titleData objectAtIndex:glyphPosInArray] objectAtIndex:2] intValue]);

    NSLog(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);

    NSString *fontName = [[titleData objectAtIndex:glyphPosInArray] objectAtIndex:1];

    [[self theOnlySelectedGlyph] replaceGlyph:glyphUniChar withFont:fontName];
    [[self theOnlySelectedGlyph] didChange];
}

//table color and stuff
- (NSColor *)oddRowColor
{
    return [NSColor whiteColor];
}

- (NSColor *)evenRowColor
{
    static NSColor *evenColor = nil;
    if (!evenColor)
    {
        evenColor = [NSColor colorWithCalibratedRed:1 green:1 blue:0.627 alpha:1];
        [evenColor retain];
    }
    //return evenColor;
    return [NSColor yellowColor];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    //NSLog(@"Sollte bei jeder zelle aufgerufen werden!!!");
    if ([cell respondsToSelector:@selector(setBackgroundColor:)])
    {
        //NSLog(@"Bin bei der Farbzuweisung drinnen");
        if (row % 2 == 0)
        {
            [cell setBackgroundColor:[NSColor whiteColor]];
        }
        else
        {
            [cell setBackgroundColor:[NSColor whiteColor]];
        }
    }
    else
    {
        NSLog(@"Bin bei der Farbzuweisung NICHT drinnen");
    }
} 

//notifications Stuff
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"HieroglyphsController(windowWillClose) -> Notification received - %@\n", [notification name]);
    [[NSApp delegate] resetMenuItemFlag:HYEROGLYPHS_MENU_TAG];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [self resizeTable];
}

//the main window stuff
- (NSWindow *)theMainWindow {
    if (![[NSApp mainWindow] isKeyWindow]) [[NSApp mainWindow] makeKeyWindow];
    return [NSApp mainWindow];
}

- (IGDrawWindowController *)theMainWindowController {
    return [[self theMainWindow] windowController];
}

- (IGGraphicView *)theMainView {
    return [[self theMainWindowController] graphicView];
}

- (IGGraphic *)theOnlySelectedGlyph {
    IGGraphic *graphic = [[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]];
    return graphic;
}

// dynamische columns
// http://www.geocities.com/Jeff_Louie/SQLQuery.htm
//
@end
