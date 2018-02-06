///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/TipsController.m,v $
// $Revision: 1.2 $ $Date: 2004/07/26 14:24:48 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// TipsController.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////


#import "TipsController.h"


@implementation TipsController

- (instancetype)init
{
    self = [self initWithWindowNibName:@"Tips"];
    if (self) {
        self.windowFrameAutosaveName = @"Tips";
    }
    [self setShouldCascadeWindows:NO];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setFrameUsingName:@"Tips"];
}

+ (TipsController*)sharedTipsController
{
    static TipsController *_sharedTipsController = nil;
    
    if (!_sharedTipsController) {
        _sharedTipsController = [[TipsController allocWithZone:nil] init];
    }
    return _sharedTipsController;
}

@end
