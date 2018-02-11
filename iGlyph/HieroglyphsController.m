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
#import "IGDocumentWindowController.h"
#import "IGFontData.h"
#import "IGGraphic.h"
#import "IGGlyph.h"

@implementation HieroglyphsController

@synthesize rowNumber;
@synthesize colNumber;
@synthesize glyphNumber;

@synthesize selectedTitle;


+ (HieroglyphsController*)sharedHieroglyphsController
{
    static HieroglyphsController *_sharedHieroglyphsController = nil;
    
    if (!_sharedHieroglyphsController) {
        _sharedHieroglyphsController = [[HieroglyphsController alloc] init];
    }
    return _sharedHieroglyphsController;
}

- (instancetype)init
{
    self = [self initWithWindowNibName:@"Hieroglyphs"];
    if (self) {
        self.windowFrameAutosaveName = @"Hieroglyphs";
    }
    [self setShouldCascadeWindows:NO];
    return self;
}

- (void)awakeFromNib
{
    DDLogVerbose(@"HieroglyphsController(awakeFromNib) -> start");
    IGlyphDelegate *delegate = NSApplication.sharedApplication.delegate;
    
    fontData = delegate.sharedFontData;
    fontDataDic = fontData.getFontData;
    glyphGroupsArr = fontData.getGlyphGroups;
    headerSelected = 0;
    
    self.selectedTitle = glyphGroupsArr[0];
    self.colNumber = myTableView.numberOfColumns;
    self.glyphNumber = [fontDataDic[self.selectedTitle] count];
    
    //[myTableView 
    
    // reset the glyphGroup pop-up
    [self addGlyphGroupPopUpItems];
    
    DDLogVerbose(@"[self calculateNumberOfRowsInTableView] start");
    [self calculateNumberOfRowsInTableView];
    DDLogVerbose(@"[self calculateNumberOfRowsInTableView] end");
    
    DDLogVerbose(@"[myTableView reloadData] start");
    [myTableView reloadData];
    DDLogVerbose(@"[myTableView reloadData] end");
    
    DDLogVerbose(@"HieroglyphsController(awakeFromNib) -> end");
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"Hieroglyphs"];
}

- (void)addGlyphGroupPopUpItems
{    
    [glyphGroupPopUp removeAllItems];
    [glyphGroupPopUp addItemsWithTitles:glyphGroupsArr];
}


- (IBAction)glyphGroupPopUpChanged:(id)sender {
  NSString *groupTitle = glyphGroupPopUp.titleOfSelectedItem;
  DDLogVerbose(@"HieroglyphsController(glyphGroupPopUpChanged)->Ausgewahlter Titel: %@", groupTitle);
  
  self.selectedTitle = groupTitle;
  self.glyphNumber = [fontDataDic[groupTitle] count];
  
  [self calculateNumberOfRowsInTableView];
  [myTableView reloadData];
}

//Data Source stuff

- (void)calculateNumberOfRowsInTableView
{
    //self.rowNumber = 15;
    self.rowNumber = ceil(self.glyphNumber / self.colNumber);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    DDLogVerbose(@"numberOfRowsInTableView");
    return self.rowNumber;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    //DDLogVerbose(@"tableView:(NSTableView *)tableView objectValueForTableColumn start");
    int column = tableColumn.identifier.intValue;
    NSInteger neededValue = (column + row * self.colNumber);
    
    NSMutableArray *titleData = fontDataDic[self.selectedTitle];
    
    //DDLogVerbose(@"HieroglyphsController(tableView) titleData ==> %@", titleData);
    
    NSMutableDictionary *attrsTxt = [NSMutableDictionary dictionary];
    NSMutableDictionary *attrsGlyph = [NSMutableDictionary dictionary];
    NSAttributedString *attribStringTxt = [[NSAttributedString alloc] init];
    NSAttributedString *attribStringGlyph = [[NSAttributedString alloc] init];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *myPara = [[NSMutableParagraphStyle alloc] init];
    myPara.alignment = NSCenterTextAlignment;
    unichar newChar;
    
    //Dynamische Vergršsserung des Textes und der Glyphen bei €nderung der Tabellengršsse
    int deltaSize = floor([myTableView tableColumnWithIdentifier:@"0"].width / 5);
    
    if (neededValue < self.glyphNumber) {
        //text Teil
        NSMutableString *txt = [[NSMutableString alloc] init];
        [txt setString:titleData[neededValue][headerSelected]];
        [txt appendString:@"\n"];
            
        attrsTxt[NSFontAttributeName] = [NSFont systemFontOfSize:(deltaSize * 1)];
        attrsTxt[NSParagraphStyleAttributeName] = myPara;

        [attribStringTxt initWithString:txt attributes:attrsTxt];
            
        //glyphen Teil
        newChar = (0xF000 + [titleData[neededValue][2] intValue]);
        unichar *pNewChar = &newChar;
        NSString *glyph = [NSString stringWithCharacters:pNewChar length:1];
        NSString *font = titleData[neededValue][1];
        
        NSAssert([NSFont fontWithName:font size:40], @"Unable to load Font. Are they installed?");    
        
        attrsGlyph[NSFontAttributeName] = [NSFont fontWithName:font size:(deltaSize * 4)];
        attrsGlyph[NSParagraphStyleAttributeName] = myPara;
            
        [attribStringGlyph initWithString:glyph attributes:attrsGlyph];
            
        [attribString appendAttributedString:attribStringTxt];
        [attribString appendAttributedString:attribStringGlyph];
            
        //DDLogVerbose(@"tableView:(NSTableView *)tableView objectValueForTableColumn end 1");
        return attribString;
    } else {
           //DDLogVerbose(@"tableView:(NSTableView *)tableView objectValueForTableColumn end 2");
        return attribString;
    }
}

- (IBAction)headerChanged:(id)sender //wechselt zwischen den H'Glyph Namen oder Lauten
{
    headerSelected = (headerSelected == 0) ? 3 : 0;
    DDLogVerbose(@"HieroglyphsController(headerChanged) headerSelected = %ld", (long)headerSelected);
    [myTableView reloadData];
}


//wird vom IGHieroglyphsTableView aufgerufen
- (void)glyphClickedAtRow:(NSInteger)rowValue andColumn:(NSInteger)columnValue
{
    DDLogVerbose(@"glyphClicked action");
    NSInteger r = rowValue;
    NSInteger c = columnValue;
    //[myTableView deselectAll:sender];
    
    DDLogVerbose(@"HieroglyphsController(glyphClicked) Row: %ld, Column: %ld", (long)r, (long)c);
    
    NSInteger glyphPosInArray = (c + (r * colNumber));
    NSArray *titleData = fontDataDic[self.selectedTitle];
    unichar glyphUniChar = (0xF000 + [titleData[glyphPosInArray][2] intValue]);
    
    DDLogVerbose(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);
    
    NSString *fontName = titleData[glyphPosInArray][1];
    
    //[[self theMainView] createGraphicOfClassGlyph:glyphUniChar WithFont:fontName];
    [self.theMainWindowController createGraphicOfClassGlyph:glyphUniChar WithFont:fontName];
}

//wird vom IGHieroglyphsTableView aufgerufen wenn right-click oder ctr-click
- (void)replaceSelectedGlyphWithThisOneAtRow:(NSInteger)rowValue andColumn:(NSInteger)columnValue {
    
    NSInteger r = rowValue;
    NSInteger c = columnValue;
    //[myTableView deselectAll:sender];

    DDLogVerbose(@"HieroglyphsController(glyphClicked) Row: %ld, Column: %ld", (long)r, (long)c);

    NSInteger glyphPosInArray = (c + (r * colNumber));
    NSArray *titleData = fontDataDic[self.selectedTitle];
    unichar glyphUniChar = (0xF000 + [titleData[glyphPosInArray][2] intValue]);

    DDLogVerbose(@"HieroglyphsController(glyphClicked) glyphUniChar: %u", glyphUniChar);

    NSString *fontName = titleData[glyphPosInArray][1];

    [self.theOnlySelectedGlyph replaceGlyph:glyphUniChar withFont:fontName];
    [self.theOnlySelectedGlyph didChange];
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
    //DDLogVerbose(@"Sollte bei jeder zelle aufgerufen werden!!!");
    if ([cell respondsToSelector:@selector(setBackgroundColor:)])
    {
        //DDLogVerbose(@"Bin bei der Farbzuweisung drinnen");
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
        DDLogVerbose(@"Bin bei der Farbzuweisung NICHT drinnen");
    }
} 
**/

//notifications Stuff
- (void)windowWillClose:(NSNotification *)notification
{
    DDLogVerbose(@"HieroglyphsController(windowWillClose) -> Notification received - %@\n", notification.name);
    IGlyphDelegate *delegate = [NSApplication sharedApplication].delegate;
    [delegate resetMenuItemFlag:IGMenuHieroglyphsTag];
}

- (void)windowDidResize:(NSNotification *)notification
{
    //[self resizeTable];
    myTableView.rowHeight = [myTableView tableColumnWithIdentifier:@"0"].width;
    [myTableView reloadData];
}

//the main window stuff
- (NSWindow *)theMainWindow {
    if (!NSApp.mainWindow.keyWindow) [NSApp.mainWindow makeKeyWindow];
    return NSApp.mainWindow;
}

- (IGDocumentWindowController *)theMainWindowController {
    return self.theMainWindow.windowController;
}

- (IGGraphicView *)theMainView {
    return self.theMainWindowController.graphicView;
}

- (IGGlyph *)theOnlySelectedGlyph {
    IGGlyph *selectedGlyph = (IGGlyph *)[self.theMainView theOnlySelectedGraphicOfClass:[IGGlyph class]];
    return selectedGlyph;
}

// dynamische columns
// http://www.geocities.com/Jeff_Louie/SQLQuery.htm
//
@end
