///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/FormatGlyphController.m,v $
// $Revision: 1.13 $ $Date: 2005/02/04 17:58:14 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// FormatGlyphController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import "FormatGlyphController.h"
#import "IGlyphDelegate.h"
#import "IGGraphicView.h"
#import "IGGraphic.h"
#import "IGGlyph.h"
#import "IGDrawWindowController.h"
#import "IGFontData.h"
#import "IGDrawDocument.h"

@implementation FormatGlyphController

+ (id)sharedFormatGlyphController
{
    static FormatGlyphController *_sharedFormatGlyphController = nil;
    
    if (!_sharedFormatGlyphController) {
        _sharedFormatGlyphController = [[FormatGlyphController allocWithZone:[self zone]] init];
    }
    return _sharedFormatGlyphController;
}

- (id)init
{
    self = [self initWithWindowNibName:@"FormatGlyph"];
    if (self) {
        [self setWindowFrameAutosaveName:@"FormatGlyph"];
    }
    [self setShouldCascadeWindows:NO];
    
    _glyphTmpFormat.fontSize = 25;
    _glyphTmpFormat.rubricColor = NO;
    _glyphTmpFormat.mirrored = NO;
    _glyphTmpFormat.angle = 0;
        
    return self;
}

- (void) convertToViewController
{
    controlledView = [[[self window] contentView] retain];
    //[[self window] orderOut:nil];
    [self setWindow: nil];
}

- (NSView *)controlledView
{
    return controlledView;
}

- (void) dealloc
{
    [super dealloc];
    [controlledView release];
}

- (void)awakeFromNib
{
    [angleTextField setStringValue:@"0"];
    [angleTextField setEditable:TRUE];
    [sizeTextField setStringValue:@"25"];
    [sizeTextField setEditable:TRUE];
    
    //NSLog(@"(FormatGlyphController.m)->awakeFromNib ----");
    //NSLog(@"(FormatGlyphController.m)->awakeFromNib - %d", [sizeTextField isEditable]);
    
    [self convertToViewController];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    NSLog(@"FormatGlyphController(mainWindowChanged)-> %@", [[NSApp mainWindow] title]);
    [self restoreTmpFormating];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"FormatGlyph"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"(FormatGlyphController.m)->Notification received - %@\n", [notification name]);
    [[NSApp delegate] resetMenuItemFlag:FORMATGLYPH_MENU_TAG];
}

- (IBAction)glyphAngleTextFieldAction:(id)sender
{
  [self setMainWindowAsKey];
  
  IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
  
  //den slider verschieben
  [angleSlider setFloatValue:[sender intValue]];
  
  //den richtigen knopf auswŠhlen
  [angleButtonMatrix deselectAllCells];
  
  if ([sender intValue] == 0) {
    [angleButtonMatrix deselectSelectedCell];
    [[angleButtonMatrix cellWithTag:[sender intValue]] setState:NSOnState];
  } else if ([sender intValue] == 90) {
    [angleButtonMatrix deselectSelectedCell];
    [[angleButtonMatrix cellWithTag:[sender intValue]] setState:NSOnState];
  } else if ([sender intValue] == 180) {
    [angleButtonMatrix deselectSelectedCell];
    [[angleButtonMatrix cellWithTag:[sender intValue]] setState:NSOnState];
  } else if ([sender intValue] == 270) {
    [angleButtonMatrix deselectSelectedCell];
    [[angleButtonMatrix cellWithTag:[sender intValue]] setState:NSOnState];
  }
  
  //zum schluss die glyphe abŠndern
  if (tmpGlyph) {
    [tmpGlyph setAngle:[sender intValue]];
    [[self theMainView] invalidateGraphic:tmpGlyph];
    [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
  }
}

- (IBAction)glyphAngle:(id)sender
{   
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
    
    
    if ( [sender tag] == 0) {
        int _cellTag = [[sender selectedCell] tag];
        NSLog(@"angle set %i", _cellTag);
        [angleSlider setFloatValue:_cellTag];
        [angleTextField setIntValue:_cellTag];
        [angleButtonMatrix deselectAllCells];
        [[angleButtonMatrix cellWithTag:_cellTag] setState:NSOnState];
        
        if (tmpGlyph) {
            [tmpGlyph setAngle:_cellTag];
            [[self theMainView] invalidateGraphic:tmpGlyph];
            [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        }
        
        
    } else {
        int _sliderIntValue = [sender intValue];
        NSLog(@"angle set %d", _sliderIntValue);
        [angleTextField setStringValue:[[NSString alloc] initWithFormat:@"%d", _sliderIntValue]];
        [angleButtonMatrix deselectAllCells];
        
        if (_sliderIntValue == 0) {
            [angleButtonMatrix deselectSelectedCell];
            [[angleButtonMatrix cellWithTag:_sliderIntValue] setState:NSOnState];
        } else if (_sliderIntValue == 90) {
            [angleButtonMatrix deselectSelectedCell];
            [[angleButtonMatrix cellWithTag:_sliderIntValue] setState:NSOnState];
        } else if (_sliderIntValue == 180) {
            [angleButtonMatrix deselectSelectedCell];
            [[angleButtonMatrix cellWithTag:_sliderIntValue] setState:NSOnState];
        } else if (_sliderIntValue == 270) {
            [angleButtonMatrix deselectSelectedCell];
            [[angleButtonMatrix cellWithTag:_sliderIntValue] setState:NSOnState];
        }
            
        if (tmpGlyph) {
            [tmpGlyph setAngle:[sender intValue]];
            [[self theMainView] invalidateGraphic:tmpGlyph];
            [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        }
    }
}

- (IBAction)glyphSizeStepperAction:(id)sender
{
    [sizeTextField setStringValue:[[NSString alloc] initWithFormat:@"%d", [sender intValue]]];
    
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
    if (tmpGlyph) {
        [tmpGlyph setFontSize:(float)[sender intValue]];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
    }
}

- (IBAction)glyphSizeTextFieldAction:(id)sender
{   
    if ([sender intValue] > 7 && [sender intValue] < 151) {
        [stepperButton setIntValue:[sender intValue]];
        
        IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
        if (tmpGlyph) {
            [tmpGlyph setFontSize:(float)[sender intValue]];
            [[self theMainView] invalidateGraphic:tmpGlyph];
            [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        }
    }
}


- (IBAction)mirroredCheckBox:(id)sender
{   
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
    
    if ([sender state] && tmpGlyph)
    {
        NSLog(@"mirrored ON");
        [[self theOnlySelectedGlyph] setMirrored:YES];
        [[self theMainView] invalidateGraphic:[self theOnlySelectedGlyph]];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        
    } else if (tmpGlyph) {
        NSLog(@"mirrored OFF");
        [tmpGlyph setMirrored:NO];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
    }
}

- (IBAction)rubricCheckBox:(id)sender
{   
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
    
    if ([sender state] && tmpGlyph)
    {
        NSLog(@"rubric ON");
        [tmpGlyph setRubricColor:YES];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        
    } else if (tmpGlyph) {
        NSLog(@"rubric OFF");
        [tmpGlyph setRubricColor:NO];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
    }
}

- (IBAction)changeGlyphAction:(id)sender {
    [self setMainWindowAsKey];
    NSArray *tempGlyphData; //gesuchte Glyphe umgewandelt in charNummber und fontName
    tempGlyphData = [[IGFontData sharedFontData] getGlyphForSymbol:[sender stringValue]];
    if (tempGlyphData) {
        NSLog(@"%@",tempGlyphData);
        [[self theOnlySelectedGlyph] replaceGlyph:(unichar)(0xF000 + [[tempGlyphData objectAtIndex:0] intValue]) withFont:[tempGlyphData objectAtIndex:1]];
    } else {
        NSRunAlertPanel(@"Replacing Glyph Error",@"Die Glyphe ... gibt es nicht",@"OK",nil,nil);
    }
    
}

- (float)fontSize {
    return [[sizeTextField stringValue] floatValue];
}

- (void)setFontSize:(float)value {
    [stepperButton setIntValue:(int)value];
    [sizeTextField setStringValue:[[NSString alloc] initWithFormat:@"%d", (int)value]];
}

- (BOOL)rubricColor {
    return [rubricCheckBoxOutlet state];
}
- (void)setRubricColor:(BOOL)value {
    [rubricCheckBoxOutlet setState:value];
}

- (BOOL)mirrored {
    return [mirroredCheckBoxOutlet state];
}

- (void)setMirrored:(BOOL)value {
    [mirroredCheckBoxOutlet setState:value];
}

- (int)angle {
    return [[angleTextField stringValue] intValue];
}

- (void)setAngle:(int)value {
    [angleTextField setStringValue:[[NSString alloc] initWithFormat:@"%d", value]];
    [angleButtonMatrix deselectAllCells];
    if (value == 0 || value == 90 || value == 180 || value == 270) {
        [[angleButtonMatrix cellWithTag:value] setState:NSOnState];
    }
    [angleSlider setIntValue:value];
}

//glyph formating
- (void)saveTmpFormating {
    NSLog(@"FormatGlyphController(saveTmpFormating)");
    _glyphTmpFormat.fontSize = (int)[self fontSize];
    [[[self theMainView] drawDocument] setDocumentFontSize:[self fontSize]];
    _glyphTmpFormat.rubricColor = [self rubricColor];
    _glyphTmpFormat.mirrored = [self mirrored];
    _glyphTmpFormat.angle = [self angle];
}

- (void)showSelectedGlyphFormating {
    NSLog(@"FormatGlyphController(showSelectedGlyphFormating)");
    [self setFontSize:[[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]] fontSize]];
    [self setRubricColor:[[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]] rubricColor]];
    [self setMirrored:[[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]] mirrored]];
    [self setAngle:[[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]] angle]];
}

- (void)restoreTmpFormating {
    NSLog(@"FormatGlyphController(restoreTmpFormating)");
    [self setFontSize:(float)_glyphTmpFormat.fontSize];
    [self setFontSize:[[[self theMainView] drawDocument] documentFontSize]];
    [self setRubricColor:_glyphTmpFormat.rubricColor];
    [self setMirrored:_glyphTmpFormat.mirrored];
    [self setAngle:_glyphTmpFormat.angle];
}

//the key window stuff

- (BOOL)canBecomeKeyWindow {
  return TRUE;
}


-(void)setMainWindowAsKey {
  if (![[NSApp mainWindow] isKeyWindow]) [[NSApp mainWindow] makeKeyWindow];
}

- (NSWindow *)theMainWindow {
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
    if (!graphic) {
        //wenn nichts ausgewŠhlt ist, speichere ich den neuen wert ab!!
        [self saveTmpFormating];
    }
    return graphic;
}
@end
