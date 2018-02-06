///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/ObjectsController.m,v $
// $Revision: 1.3 $ $Date: 2004/12/07 00:09:41 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// ObjectsController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

#import "ObjectsController.h"
#import "IGGraphic.h"
#import "IGGlyph.h"
#import "IGTextArea.h"
#import "IGCartouche.h"
#import "IGRubric.h"
#import "IGDestroyed.h"
#import "IGRectangle.h"
#import "IGCircle.h"
#import "IGArc.h"
#import "IGlyphDelegate.h"

enum {
    IGPointerToolRow = 0,
    IGTextToolRow,
    IGCartoucheToolRow,
    IGLineToolRow,
    IGRubricToolRow,
    IGDestroyedToolRow,
    IGRectangleToolRow,
    IGCircleToolRow,
    IGArcToolRow,
};

NSString *IGSelectedToolDidChangeNotification = @"IGSelectedToolDidChange";

@implementation ObjectsController

+ (instancetype)sharedObjectsController
{
    static ObjectsController *_sharedObjectsController = nil;
    
    if (!_sharedObjectsController) {
        _sharedObjectsController = [[ObjectsController allocWithZone:nil] init];
    }
    return _sharedObjectsController;
}

- (instancetype)init
{
    self = [self initWithWindowNibName:@"Objects"];
    if (self) {
        self.windowFrameAutosaveName = @"Objects";
    }
    [self setShouldCascadeWindows:NO];
    return self;
    
}

- (void)windowDidLoad {
    NSArray *cells = toolButtons.cells;
    NSUInteger i, c = cells.count;
    
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"Objects"];
    
    
    for (i=0; i < c; i++) {
        [cells[i] setRefusesFirstResponder:YES];
    }
    [(NSPanel *)self.window setFloatingPanel:YES];
    [(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
    
    //[toolButtons setIntercellSpacing:NSMakeSize(0.0,0.0)];
    //[toolButtons sizeToFit]];
    //[[self window] setContentSize:[toolButtons frame].size];
    //[toolButtons setFrameOrigin:NSMakePoint(0.0,0.0)];
}


-(IBAction)selectToolAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IGSelectedToolDidChangeNotification object:self];
}


- (Class)currentGraphicClass {
    
    NSInteger row = toolButtons.selectedRow;
    Class theClass = nil;
    if (row == IGTextToolRow) { //Text
        theClass = [IGTextArea class];
    } else if (row == IGCartoucheToolRow) { //Cartouche
        theClass = [IGCartouche class];
    } else if (row == IGLineToolRow) { //Line
        theClass = [IGCartouche class];
    } else if (row == IGRubricToolRow) { //Rubric
        theClass = [IGRubric class];
    } else if (row == IGDestroyedToolRow) { //Destroyed
        theClass = [IGDestroyed class];
    } else if (row == IGRectangleToolRow) { //Rectangle
        theClass = [IGRectangle class];
    } else if (row == IGCircleToolRow) { //Circle
        theClass = [IGCircle class];
    } else if (row == IGArcToolRow) { //Arc
        theClass = [IGArc class];
    }
    return theClass;
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"(ObjectsController.m)->Notification received - %@\n", notification.name);
    IGlyphDelegate *delegate = [NSApplication sharedApplication].delegate;
    [delegate resetMenuItemFlag:OBJECTS_MENU_TAG];
}

- (void)selectArrowTool {
    [toolButtons selectCellAtRow:IGPointerToolRow column:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:IGSelectedToolDidChangeNotification object:self];
}

@end
