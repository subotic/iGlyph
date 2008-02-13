//
//  VGMainView.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed Sep 10 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface VGMainView : NSView {
        
    NSPoint cursor;
    NSSize selectionRectSize;
    NSRect selectionRect;
    NSRect selectionMovingFieldRect;
    NSRect tempSelectionMovingFieldRect;
    NSMutableDictionary *selectionStateDic;
    
    NSTrackingRectTag selectionMovingFieldRectTag;
    BOOL movingTrackingRect;
    BOOL selectionOngoing;
    
    BOOL _DEBUGlog;
}

// Standard view create/free methods
- (id)initWithFrame:(NSRect)frame;
- (void)awakeFromNib;
- (void)dealloc;

// Drawing
- (void)drawRect:(NSRect)rect;



// Event handling
- (void)rightMouseDown:(NSEvent *)event;
//- (void)mouseDragged:(NSEvent *)event;

- (void)mouseDown:(NSEvent *)event;
- (void)setTrackingRectForSelectedListRect:(NSRect)selRect;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)event;

- (void)deleteSelectedList;
- (void)removeAnySelection;

- (BOOL)isFlipped;
- (BOOL)resignFirstResponder;
- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse;

- (NSPoint)getCursor;
- (void)setCursorXpos:(float)xPosition;
- (void)setCursorYpos:(float)yPosition;

//Toolbar Stuff
- (void)initializeToolbar;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@end
