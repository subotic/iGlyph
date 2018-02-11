///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/WritingDirectionController.m,v $
// $Revision: 1.7 $ $Date: 2004/07/26 14:24:48 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// WritingDirectionController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////


#import "WritingDirectionController.h"
#import "IGlyphDelegate.h"
#import "FormatGlyphController.h"
#import "IGDrawDocument.h"

@implementation WritingDirectionController

+ (WritingDirectionController*)sharedWritingDirectionController
{
    static WritingDirectionController *_sharedWritingDirectionController = nil;
    
    if (!_sharedWritingDirectionController) {
        _sharedWritingDirectionController = [[WritingDirectionController alloc] init];
    }
    return _sharedWritingDirectionController;
}

- (instancetype)init
{
    self = [self initWithWindowNibName:@"WritingDirection"];
    if (self) {
        self.windowFrameAutosaveName = @"WritingDirection";
    }
    [self setShouldCascadeWindows:NO];
    return self;
}

- (void) convertToViewController
{
    controlledView = self.window.contentView;
    [self setWindow: nil];
}

- (NSView *)controlledView
{
    return controlledView;
}


- (void)awakeFromNib
{
    [verticalButtonMatrix deselectAllCells];
    [horizontalButtonMatrix deselectAllCells];
    [horizontalButtonMatrix cellWithTag:10].state = NSOnState;
    self.writingDirection = leftToRight;
    
    [self convertToViewController];
    
}

- (void)mainWindowChanged:(NSNotification *)notification {
    DDLogVerbose(@"WritingDirectionController(mainWindowChanged)-> %@", NSApp.mainWindow.title);
    //jedes document kann hier andere einstellungen habe
    charSpacingTextField.stringValue = [[NSString alloc] initWithFormat:@"%ld", [NSApp.mainWindow.windowController.document documentCharSpacing]];
    charSpacingStepperButton.integerValue = [NSApp.mainWindow.windowController.document documentCharSpacing];
    
    lineSpacingTextField.stringValue = [[NSString alloc] initWithFormat:@"%f", [NSApp.mainWindow.windowController.document documentLineSpacing]];
    lineSpacingStepperButton.floatValue = [NSApp.mainWindow.windowController.document documentLineSpacing];
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"WritingDirection"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
}


- (void)windowWillClose:(NSNotification *)notification
{
    DDLogVerbose(@"(WritingDirectionController.m)->Notification received - %@\n", notification.name);
    IGlyphDelegate *delegate = NSApplication.sharedApplication.delegate;
    [delegate resetMenuItemFlag:IGMenuWritingDirectionTag];
}

- (IBAction)writtingDirectionChanged:(id)sender
{
    NSMatrix *_sender = (NSMatrix *)sender;
    if (_sender.selectedCell.tag == 10)
    {
        DDLogVerbose(@"WritingDirection: leftToRight");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix cellWithTag:10].state = NSOnState;
        
        self.writingDirection = leftToRight;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:NO];
        [FormatGlyphController sharedFormatGlyphController].angle = 0;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];

    } else if (_sender.selectedCell.tag == 11) {
        DDLogVerbose(@"WritingDirection: rightToLeft");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix cellWithTag:11].state = NSOnState;
        
        self.writingDirection = rightToLeft;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:YES];
        [FormatGlyphController sharedFormatGlyphController].angle = 0;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];
        
    } else if (_sender.selectedCell.tag == 20) {
        DDLogVerbose(@"WritingDirection: upToDownMirr");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [verticalButtonMatrix cellWithTag:20].state = NSOnState;
        
        self.writingDirection = upToDownMirr;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:YES];
        [FormatGlyphController sharedFormatGlyphController].angle = 270;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];
        
    } else if (_sender.selectedCell.tag == 21) {
        DDLogVerbose(@"WritingDirection: upToDown");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [verticalButtonMatrix cellWithTag:21].state = NSOnState;
        
        self.writingDirection = upToDown;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:NO];
        [FormatGlyphController sharedFormatGlyphController].angle = 90;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];
        
    } else if (_sender.selectedCell.tag == 22) {
        DDLogVerbose(@"WritingDirection: upToDownVert");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [verticalButtonMatrix cellWithTag:22].state = NSOnState;
        
        self.writingDirection = upToDownVert;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:NO];
        [FormatGlyphController sharedFormatGlyphController].angle = 0;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];
                
    } else if (_sender.selectedCell.tag == 23) {
        DDLogVerbose(@"WritingDirection: upToDownVertMirr");
        [verticalButtonMatrix deselectAllCells];
        [horizontalButtonMatrix deselectAllCells];
        [verticalButtonMatrix cellWithTag:23].state = NSOnState;
        
        self.writingDirection = upToDownVertMirr;
        [[FormatGlyphController sharedFormatGlyphController] setMirrored:YES];
        [FormatGlyphController sharedFormatGlyphController].angle = 0;
        [[FormatGlyphController sharedFormatGlyphController] saveTmpFormating];
    }
    
}

- (int)writingDirection {
    return _writingDirection;
}

- (void)setWritingDirection:(int)direction {
    _writingDirection = direction;
}

//IBAction methoden fŸr spacing von char und line
- (IBAction)charSpacingStepperAction:(id)sender
{
    charSpacingTextField.stringValue = [[NSString alloc] initWithFormat:@"%i", [sender intValue]];
    [NSApp.mainWindow.windowController.document setDocumentCharSpacing:[sender intValue]];
}

- (IBAction)charSpacingTextFieldAction:(id)sender
{   
    if ([sender intValue] >= 1 && [sender intValue] <= 30) {
        charSpacingStepperButton.intValue = [sender intValue];
        [NSApp.mainWindow.windowController.document setDocumentCharSpacing:[sender intValue]];
    } else {
      NSBeep();
    }
}

- (IBAction)lineSpacingStepperAction:(id)sender
{
    lineSpacingTextField.stringValue = [[NSString alloc] initWithFormat:@"%f", [sender floatValue]];
    [NSApp.mainWindow.windowController.document setDocumentLineSpacing:[sender floatValue]];
}

- (IBAction)lineSpacingTextFieldAction:(id)sender
{   
    if ([sender intValue] >= 1.0 && [sender intValue] <= 4.0) {
        lineSpacingStepperButton.intValue = [sender floatValue];
        [NSApp.mainWindow.windowController.document setDocumentLineSpacing:[sender floatValue]];
    } else {
      NSBeep();
    }
}

@end
