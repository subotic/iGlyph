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

@synthesize selectedTitle;


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
    headerSelected = 0;
    
    self.selectedTitle = [glyphGroupsArr objectAtIndex:0];
    self.colNumber = [myTableView numberOfColumns];
    self.glyphNumber = [[fontDataDic objectForKey:self.selectedTitle] count];
    
    //[myTableView 
    
    // reset the glyphGroup pop-up
    [self addGlyphGroupPopUpItems];
    
    NSLog(@"[self calculateNumberOfRowsInTableView] start");
    [self calculateNumberOfRowsInTableView];
    NSLog(@"[self calculateNumberOfRowsInTableView] end");
    
    NSLog(@"[myTableView reloadData] start");
    [myTableView reloadData];
    NSLog(@"[myTableView reloadData] end");
    
    NSLog(@"HieroglyphsController(awakeFromNib) -> end");
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
  
  self.selectedTitle = groupTitle;
  self.glyphNumber = [[fontDataDic objectForKey:groupTitle] count];
  
  [self calculateNumberOfRowsInTableView];
  [myTableView reloadData];
}

//Data Source stuff

- (void)calculateNumberOfRowsInTableView
{
    //self.rowNumber = 15;
    self.rowNumber = ceil(self.glyphNumber / self.colNumber);
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"numberOfRowsInTableView");
    return self.rowNumber;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    //NSLog(@"tableView:(NSTableView *)tableView objectValueForTableColumn start");
    int column = [[tableColumn identifier] intValue];
    int neededValue = (column + row * self.colNumber);
    
    NSMutableArray *titleData = [fontDataDic objectForKey:self.selectedTitle];
    
    //NSLog(@"HieroglyphsController(tableView) titleData ==> %@", titleData);
    
    NSMutableDictionary *attrsTxt = [NSMutableDictionary dictionary];
    NSMutableDictionary *attrsGlyph = [NSMutableDictionary dictionary];
    NSAttributedString *attribStringTxt = [[NSAttributedString alloc] init];
    NSAttributedString *attribStringGlyph = [[NSAttributedString alloc] init];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *myPara = [[NSMutableParagraphStyle alloc] init];
    [myPara setAlignment:NSCenterTextAlignment];
    unichar newChar;
    
    //Dynamische Vergršsserung des Textes und der Glyphen bei €nderung der Tabellengršsse
    int deltaSize = floor([[myTableView tableColumnWithIdentifier:@"0"] width] / 5);
    
    if (neededValue < self.glyphNumber) {
        //text Teil
        NSMutableString *txt = [[NSMutableString alloc] init];
        [txt setString:[[titleData objectAtIndex:neededValue] objectAtIndex:headerSelected]];
        [txt appendString:@"\n"];
            
        [attrsTxt setObject:[NSFont systemFontOfSize:(deltaSize * 1)] forKey:NSFontAttributeName];
        [attrsTxt setObject:myPara forKey:NSParagraphStyleAttributeName];

        [attribStringTxt initWithString:txt attributes:attrsTxt];
            
        //glyphen Teil
        newChar = (0xF000 + [[[titleData objectAtIndex:neededValue] objectAtIndex:2] intValue]);
        unichar *pNewChar = &newChar;
        NSString *glyph = [NSString stringWithCharacters:pNewChar length:1];
        NSString *font = [[titleData objectAtIndex:neededValue] objectAtIndex:1];
        
        NSAssert([NSFont fontWithName:font size:40], @"Unable to load Font. Are they installed?");	
		
        [attrsGlyph setObject:[NSFont fontWithName:font size:(deltaSize * 4)] forKey:NSFontAttributeName];
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

- (IBAction)headerChanged:(id)sender //wechselt zwischen den H'Glyph Namen oder Lauten
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
    NSArray *titleData = [fontDataDic objectForKey:self.selectedTitle];
    unichar glyphUniChar = (0xF000 + [[[titleData objectAtIndex:glyphPosInArray] objectAtIndex:2] intValue]);
    
    NSLog(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);
    
    NSString *fontName = [[titleData objectAtIndex:glyphPosInArray] objectAtIndex:1];
    
    //[[self theMainView] createGraphicOfClassGlyph:glyphUniChar WithFont:fontName];
    [[self theMainWindowController] createGraphicOfClassGlyph:glyphUniChar WithFont:fontName];
}

//wird vom IGHieroglyphsTableView aufgerufen wenn right-click oder ctr-click
- (void)replaceSelectedGlyphWithThisOneAtRow:(int)rowValue andColumn:(int)columnValue {
    
    int r = rowValue;
    int c = columnValue;
    //[myTableView deselectAll:sender];

    NSLog(@"HieroglyphsController(glyphClicked) Row: %d, Column: %d",r,c);

    int glyphPosInArray = (c + (r * colNumber));
    NSArray *titleData = [fontDataDic objectForKey:self.selectedTitle];
    unichar glyphUniChar = (0xF000 + [[[titleData objectAtIndex:glyphPosInArray] objectAtIndex:2] intValue]);

    NSLog(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);

    NSString *fontName = [[titleData objectAtIndex:glyphPosInArray] objectAtIndex:1];

    [[self theOnlySelectedGlyph] replaceGlyph:glyphUniChar withFont:fontName];
    [[self theOnlySelectedGlyph] didChange];
}

/**
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
**/

//notifications Stuff
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"HieroglyphsController(windowWillClose) -> Notification received - %@\n", [notification name]);
    [[NSApp delegate] resetMenuItemFlag:HYEROGLYPHS_MENU_TAG];
}

- (void)windowDidResize:(NSNotification *)notification
{
    //[self resizeTable];
    [myTableView setRowHeight:[[myTableView tableColumnWithIdentifier:@"0"] width]];
    [myTableView reloadData];
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
