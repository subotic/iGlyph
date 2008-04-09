///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/ObjectsController.h,v $
// $Revision: 1.2 $ $Date: 2004/07/26 14:24:40 $ $State: Exp $
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

#import <Cocoa/Cocoa.h>

@interface ObjectsController : NSWindowController {

    IBOutlet NSMatrix *toolButtons;

}

+ (id)sharedObjectsController;

- (IBAction)selectToolAction:(id)sender;
- (Class)currentGraphicClass;

- (void)selectArrowTool;

@end

extern NSString *IGSelectedToolDidChangeNotification;