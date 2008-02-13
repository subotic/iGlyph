///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/CartoucheController.m,v $
// $Revision: 1.10 $ $Date: 2005/02/04 17:58:14 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// CartoucheController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import "CartoucheController.h"
#import "IGlyphDelegate.h"
#import "IGGraphicView.h"
#import "IGGraphic.h"
#import "IGDrawWindowController.h"
#import "IGCartouche.h"

@implementation CartoucheController

+ (id)sharedCartoucheController
{
  static CartoucheController *_sharedCartoucheController = nil;
  
  if (!_sharedCartoucheController) {
    _sharedCartoucheController = [[CartoucheController allocWithZone:[self zone]] init];
  }
  return _sharedCartoucheController;
}


- (id)init
{
  self = [self initWithWindowNibName:@"Cartouche"];
  if (self) {
    [self setWindowFrameAutosaveName:@"Cartouche"];
  }
  [self setShouldCascadeWindows:NO];
  return self;
  
}

- (void) convertToViewController
{
  _controlledView = [[[self window] contentView] retain];
  //[[self window] orderOut:nil];
  [self setWindow: nil];
}

- (NSView *)controlledView
{
  return _controlledView;
}

- (void) dealloc
{
  [super dealloc];
  [_controlledView release];
}


- (void)awakeFromNib
{
  /*
   [self setXEdge:50];
   [self setYEdge:50];
   [self setCartoucheBorderType:1];
   [self setRubricCartouche:FALSE];
   [self setEndAlignment:4];
   
   _cartoucheFlags.xEdge = 50;
   _cartoucheFlags.yEdge = 50;
   _cartoucheFlags.borderTyp = 1;
   _cartoucheFlags.endAlignment = 4;
   _cartoucheFlags.rubricCartouche = FALSE;
   
   [xTextField setIntValue:50];
   [yTextField setIntValue:50];
   [xEdgeSlider setIntValue:50];
   [yEdgeSlider setIntValue:50];
   */
  
  [self convertToViewController];
  
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [[self window] setFrameUsingName:@"Cartouche"];
}

- (void)windowWillClose:(NSNotification *)notification
{
  //NSLog(@"(CartoucheController.m)->Notification received - %@\n", [notification name]);
  //[[NSApp delegate] resetMenuItemFlag:CARTOUCHE_MENU_TAG];
}


- (IBAction)xEdgeChange:(id)sender
{    
  IGCartouche *cartouche = [self theOnlySelectedCartouche];
  if (cartouche) {
    //[xTextField setIntValue:[sender intValue]];
    [cartouche setXEdge:[sender intValue]];
    [[self theMainView] invalidateGraphic:cartouche];
  }
}

- (IBAction)yEdgeChange:(id)sender
{    
  IGCartouche *cartouche = [self theOnlySelectedCartouche];
  if (cartouche) {
    //[yTextField setIntValue:[sender intValue]];
    [cartouche setYEdge:[sender intValue]];
    [[self theMainView] invalidateGraphic:cartouche];
  }
}

- (IBAction)borderTypeChange:(id)sender
{    
  IGCartouche *cartouche = [self theOnlySelectedCartouche];
  if (cartouche) {
    [cartouche setCartoucheBorderType:[[borderTypeMatrix selectedCell] tag]];
    [[self theMainView] invalidateGraphic:cartouche];    
  }
}

- (IBAction)endAlignmentChange:(id)sender
{    
  IGCartouche *cartouche = [self theOnlySelectedCartouche];
  if (cartouche) {
    [cartouche setEndCartoucheAlignment:[[sender selectedCell] tag]];
    [[self theMainView] invalidateGraphic:cartouche];   
  }
}

- (IBAction)rubricCartoucheChange:(id)sender
{
  IGCartouche *cartouche = [self theOnlySelectedCartouche];
  if (cartouche) {
    [cartouche setRubricCartouche:[sender state]];
    [[self theMainView] invalidateGraphic:cartouche];
  }
}


- (int)xEdge
{
  return [xEdgeSlider intValue];
}

- (void)setXEdge:(int)value
{
  [xTextField setIntValue:value];
  [xEdgeSlider setIntValue:value];
}

- (int)yEdge
{
  return [yEdgeSlider intValue];
}

- (void)setYEdge:(int)value
{
  [yTextField setIntValue:value];
  [yEdgeSlider setIntValue:value];
}

- (int)cartoucheBorderType
{
  return [[borderTypeMatrix selectedCell] tag];
}

- (void)setCartoucheBorderType:(int)value
{
  [borderTypeMatrix selectCellWithTag:value];
}

- (int)endAlignment
{
  //1 - Up, 2 - Right, 3 - Down, 4 - Left
  
  return [[endAlignmentMatrix selectedCell] tag];
}

- (void)setEndAlignment:(int)value
{
  [endAlignmentMatrix selectCellWithTag:value];
}

- (BOOL)rubricCartouche
{
  return [rubricCartoucheButton state];
}

- (void)setRubricCartouche:(BOOL)value
{
  (value ? [rubricCartoucheButton setState:NSOnState] : [rubricCartoucheButton setState:NSOffState]);
}


//cartouche tmp formating saving
- (void)showSelectedCartoucheFormating {
  //NSLog(@"CartoucheController(am Anfang showSelectedCartoucheFormating) x:%i, y:%i", [[self theOnlySelectedCartouche] xEdge], [[self theOnlySelectedCartouche] yEdge]);
  NSLog(@"CartoucheController(showSelectedCartoucheFormating)");
  [self setXEdge:[[self theOnlySelectedCartouche] xEdge]];
  [self setYEdge:[[self theOnlySelectedCartouche] yEdge]];
  [self setCartoucheBorderType:[[self theOnlySelectedCartouche] cartoucheBorderType]];
  [self setEndAlignment:[[self theOnlySelectedCartouche] endCartoucheAlignment]];
  [self setRubricCartouche:[[self theOnlySelectedCartouche] rubricCartouche]];
  //NSLog(@"CartoucheController(am Ende showSelectedCartoucheFormating) x:%i, y:%i", [[self theOnlySelectedCartouche] xEdge], [[self theOnlySelectedCartouche] yEdge]);
}

- (void)restoreTmpFormating {
  //NSLog(@"CartoucheController(am Anfang restoreTmpFormating) x:%i, y:%i", [[self theOnlySelectedCartouche] xEdge], [[self theOnlySelectedCartouche] yEdge]);
  NSLog(@"CartoucheController(restoreTmpFormating)");
  [self setXEdge:_cartoucheFlags.xEdge];
  [self setYEdge:_cartoucheFlags.yEdge];
  [self setCartoucheBorderType:_cartoucheFlags.borderTyp];
  [self setEndAlignment:_cartoucheFlags.endAlignment];
  [self setRubricCartouche:_cartoucheFlags.rubricCartouche];
  //NSLog(@"CartoucheController(am Ende restoreTmpFormating) x:%i, y:%i", [[self theOnlySelectedCartouche] xEdge], [[self theOnlySelectedCartouche] yEdge]);
}


//the key window stuff
- (NSWindow *)theMainWindow {
  if (![[NSApp mainWindow] isKeyWindow]) [[NSApp mainWindow] makeKeyWindow];
  return [NSApp mainWindow];
}

- (IGDrawWindowController *)theMainWindowController
{
  return [[self theMainWindow] windowController];
}

- (IGGraphicView *)theMainView
{
  return [[self theMainWindowController] graphicView];
}

- (IGCartouche *)theOnlySelectedCartouche
{
  if ([[[self theMainView] selectedGraphics] count] == 1) {
    if ([[[[self theMainView] selectedGraphics] objectAtIndex:0] class] == [IGCartouche class]) {
      return [[[self theMainView] selectedGraphics] objectAtIndex:0];
    }
  }
  return nil;
}

/*
 - (IGGraphic *)content
 {
   if ([[[self theMainView] selectedGraphics] count] == 1) {
     if ([[[[self theMainView] selectedGraphics] objectAtIndex:0] class] == [IGCartouche class]) {
       return [[[self theMainView] selectedGraphics] objectAtIndex:0];
     }
   }
   return nil;
 }
 */

@end
