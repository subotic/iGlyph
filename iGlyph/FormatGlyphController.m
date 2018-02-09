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

+ (FormatGlyphController*)sharedFormatGlyphController
{
    static FormatGlyphController *_sharedFormatGlyphController = nil;
    
    if (!_sharedFormatGlyphController) {
        _sharedFormatGlyphController = [[FormatGlyphController alloc] init];
    }
    return _sharedFormatGlyphController;
}

- (instancetype)init
{
    self = [self initWithWindowNibName:@"FormatGlyph"];
    if (self) {
        self.windowFrameAutosaveName = @"FormatGlyph";
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
    controlledView = self.window.contentView;
    //[[self window] orderOut:nil];
    [self setWindow: nil];
}

- (NSView *)controlledView
{
    return controlledView;
}

- (void)awakeFromNib
{
    angleTextField.stringValue = @"0";
    [angleTextField setEditable:TRUE];
    sizeTextField.stringValue = @"25";
    [sizeTextField setEditable:TRUE];
    
    //DDLogVerbose(@"(FormatGlyphController.m)->awakeFromNib ----");
    //DDLogVerbose(@"(FormatGlyphController.m)->awakeFromNib - %d", [sizeTextField isEditable]);
    
    [self convertToViewController];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    DDLogVerbose(@"FormatGlyphController(mainWindowChanged)-> %@", NSApp.mainWindow.title);
    [self restoreTmpFormating];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setFrameUsingName:@"FormatGlyph"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    DDLogVerbose(@"(FormatGlyphController.m)->Notification received - %@\n", notification.name);
    IGlyphDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [delegate resetMenuItemFlag:IGMenuFormatGlypTag];
}

- (IBAction)glyphAngleTextFieldAction:(id)sender
{
  [self setMainWindowAsKey];
  
  IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
  
  //den slider verschieben
  angleSlider.floatValue = [sender intValue];
  
  //den richtigen knopf auswŠhlen
  [angleButtonMatrix deselectAllCells];
  
  if ([sender intValue] == 0) {
    [angleButtonMatrix deselectSelectedCell];
    [angleButtonMatrix cellWithTag:[sender intValue]].state = NSOnState;
  } else if ([sender intValue] == 90) {
    [angleButtonMatrix deselectSelectedCell];
    [angleButtonMatrix cellWithTag:[sender intValue]].state = NSOnState;
  } else if ([sender intValue] == 180) {
    [angleButtonMatrix deselectSelectedCell];
    [angleButtonMatrix cellWithTag:[sender intValue]].state = NSOnState;
  } else if ([sender intValue] == 270) {
    [angleButtonMatrix deselectSelectedCell];
    [angleButtonMatrix cellWithTag:[sender intValue]].state = NSOnState;
  }
  
  //zum schluss die glyphe abŠndern
  if (tmpGlyph) {
    tmpGlyph.angle = [sender intValue];
    [[self theMainView] invalidateGraphic:tmpGlyph];
    [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
  }
}

- (IBAction)glyphAngle:(id)sender
{   
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];

    NSInteger tag = -1;
    NSInteger cellTag = -1;
    int sliderIntValue = -1;

    if ([sender isKindOfClass:[NSMatrix class]]) {
        NSMatrix *sndr = (NSMatrix *)sender;
        tag = [sndr tag];
        cellTag = [[sndr selectedCell] tag];
    } else if ([sender isKindOfClass:[NSTextField class]]) {
        NSTextField *sndr = (NSTextField *)sender;
        tag = [sndr tag];
        cellTag = [[sndr selectedCell] tag];
    } else if ([sender isKindOfClass:[NSSlider class]]) {
        NSSlider *sndr = (NSSlider *)sender;
        tag = [sndr tag];
        cellTag = [[sndr selectedCell] tag];
        sliderIntValue = [sndr intValue];
    } else {
        DDLogVerbose(@"unknown sender");
    }
    
    if (tag == 0) {
        DDLogVerbose(@"angle set %ld", (long)cellTag);
        angleSlider.floatValue = cellTag;
        angleTextField.integerValue = cellTag;
        [angleButtonMatrix deselectAllCells];
        [angleButtonMatrix cellWithTag:cellTag].state = NSOnState;
        
        if (tmpGlyph) {
            tmpGlyph.angle = cellTag;
            [[self theMainView] invalidateGraphic:tmpGlyph];
            [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        }

    } else {
        DDLogVerbose(@"angle set %d", sliderIntValue);
        angleTextField.stringValue = [[NSString alloc] initWithFormat:@"%d", sliderIntValue];
        [angleButtonMatrix deselectAllCells];
        
        if (sliderIntValue == 0) {
            [angleButtonMatrix deselectSelectedCell];
            [angleButtonMatrix cellWithTag:sliderIntValue].state = NSOnState;
        } else if (sliderIntValue == 90) {
            [angleButtonMatrix deselectSelectedCell];
            [angleButtonMatrix cellWithTag:sliderIntValue].state = NSOnState;
        } else if (sliderIntValue == 180) {
            [angleButtonMatrix deselectSelectedCell];
            [angleButtonMatrix cellWithTag:sliderIntValue].state = NSOnState;
        } else if (sliderIntValue == 270) {
            [angleButtonMatrix deselectSelectedCell];
            [angleButtonMatrix cellWithTag:sliderIntValue].state = NSOnState;
        }
            
        if (tmpGlyph) {
            tmpGlyph.angle = [sender intValue];
            [[self theMainView] invalidateGraphic:tmpGlyph];
            [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        }
    }
}

- (IBAction)glyphSizeStepperAction:(id)sender
{
    sizeTextField.stringValue = [[NSString alloc] initWithFormat:@"%d", [sender intValue]];
    
    IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
    if (tmpGlyph) {
        tmpGlyph.fontSize = [sender integerValue];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
    }
}

- (IBAction)glyphSizeTextFieldAction:(id)sender
{   
    if ([sender intValue] > 7 && [sender intValue] < 151) {
        stepperButton.intValue = [sender intValue];
        
        IGGraphic *tmpGlyph = [self theOnlySelectedGlyph];
        if (tmpGlyph) {
            tmpGlyph.fontSize = [sender integerValue];
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
        DDLogVerbose(@"mirrored ON");
        [[self theOnlySelectedGlyph] setMirrored:YES];
        [[self theMainView] invalidateGraphic:[self theOnlySelectedGlyph]];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        
    } else if (tmpGlyph) {
        DDLogVerbose(@"mirrored OFF");
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
        DDLogVerbose(@"rubric ON");
        [tmpGlyph setRubricColor:YES];
        [[self theMainView] invalidateGraphic:tmpGlyph];
        [[self theMainView] displayRect:NSInsetRect([tmpGlyph drawingBounds], -3, -3)];
        
    } else if (tmpGlyph) {
        DDLogVerbose(@"rubric OFF");
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
        DDLogVerbose(@"%@",tempGlyphData);
        [[self theOnlySelectedGlyph] replaceGlyph:(unichar)(0xF000 + [tempGlyphData[0] intValue]) withFont:tempGlyphData[1]];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Replacing Glyph Error"];
        [alert setInformativeText:@"Die Glyphe ... gibt es nicht."];
        [alert setAlertStyle:NSWarningAlertStyle];
    }
}

- (NSUInteger)fontSize {
    return sizeTextField.stringValue.integerValue;
}

- (void)setFontSize:(NSUInteger)value {
    stepperButton.integerValue = value;
    sizeTextField.stringValue = [[NSString alloc] initWithFormat:@"%ld", (long)value];
}

- (BOOL)rubricColor {
    return rubricCheckBoxOutlet.state;
}
- (void)setRubricColor:(BOOL)value {
    rubricCheckBoxOutlet.state = value;
}

- (BOOL)mirrored {
    return mirroredCheckBoxOutlet.state;
}

- (void)setMirrored:(BOOL)value {
    mirroredCheckBoxOutlet.state = value;
}

- (NSInteger)angle {
    return angleTextField.stringValue.integerValue;
}

- (void)setAngle:(NSInteger)value {
    angleTextField.stringValue = [[NSString alloc] initWithFormat:@"%ld", (long)value];
    [angleButtonMatrix deselectAllCells];
    if (value == 0 || value == 90 || value == 180 || value == 270) {
        [angleButtonMatrix cellWithTag:value].state = NSOnState;
    }
    angleSlider.integerValue = value;
}

//glyph formating
- (void)saveTmpFormating {
    DDLogVerbose(@"FormatGlyphController(saveTmpFormating)");
    _glyphTmpFormat.fontSize = [self fontSize];
    [[[self theMainView] drawDocument] setDocumentFontSize:[self fontSize]];
    _glyphTmpFormat.rubricColor = [self rubricColor];
    _glyphTmpFormat.mirrored = [self mirrored];
    _glyphTmpFormat.angle = [self angle];
}

- (void)showSelectedGlyphFormating {
    DDLogVerbose(@"FormatGlyphController(showSelectedGlyphFormating)");
    [self setFontSize:[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]].fontSize];
    [self setRubricColor:[[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]] rubricColor]];
    [self setMirrored:[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]].mirrored];
    [self setAngle:[[self theMainView] theOnlySelectedGraphicOfClass:[IGGlyph class]].angle];
}

- (void)restoreTmpFormating {
    DDLogVerbose(@"FormatGlyphController(restoreTmpFormating)");
    [self setFontSize:_glyphTmpFormat.fontSize];
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
  if (!NSApp.mainWindow.keyWindow) [NSApp.mainWindow makeKeyWindow];
}

- (NSWindow *)theMainWindow {
    return NSApp.mainWindow;
}

- (IGDrawWindowController *)theMainWindowController {
    return [self theMainWindow].windowController;
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
