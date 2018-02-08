///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/WritingDirectionController.h,v $
// $Revision: 1.2 $ $Date: 2004/07/26 14:24:48 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// WritingDirectionController.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

enum {
    leftToRight = 0,
    rightToLeft,
    upToDownMirr,
    upToDown,
    upToDownVert,
    upToDownVertMirr,
};


@interface WritingDirectionController : NSWindowController {
    
    NSView *controlledView;
    
    IBOutlet NSMatrix *horizontalButtonMatrix;
    IBOutlet NSMatrix *verticalButtonMatrix;
    
    IBOutlet NSTextField *charSpacingTextField;
    IBOutlet NSStepper *charSpacingStepperButton;
    
    IBOutlet NSTextField *lineSpacingTextField;
    IBOutlet NSStepper *lineSpacingStepperButton;
    
    int _writingDirection;

}

+ (WritingDirectionController*)sharedWritingDirectionController;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *controlledView;

- (void)mainWindowChanged:(NSNotification *)notification;

- (IBAction)writtingDirectionChanged:(id)sender;
@property (NS_NONATOMIC_IOSONLY) int writingDirection;


- (IBAction)charSpacingStepperAction:(id)sender;
- (IBAction)charSpacingTextFieldAction:(id)sender;

- (IBAction)lineSpacingStepperAction:(id)sender;
- (IBAction)lineSpacingTextFieldAction:(id)sender;



@end
