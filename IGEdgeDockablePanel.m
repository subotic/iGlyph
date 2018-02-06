///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/EdgeDockablePanel.m,v $
// $Revision: 1.2 $ $Date: 2004/07/26 14:24:33 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// EdgeDockablePanel.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import "IGEdgeDockablePanel.h"
#include <unistd.h>

@implementation IGEdgeDockablePanel

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    
    //NSLog(@"(EdgeDockablePanel.m)->EdgeDockablePanel is going to init");
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    self = [super initWithContentRect:contentRect 
                  styleMask:aStyle 
                  backing:bufferingType 
                  defer:flag];

    [nc addObserver:self selector:@selector(windowMoved:) name:NSWindowDidMoveNotification object:self];
    
    return self;
}

- (void)windowMoved:(id)notification
{
    //NSLog(@"(EdgeDockablePanel.m)->Notification received - %@\n", [notification name]);

}

- (void)toolboxClosing:(id)notification
{
    //NSLog(@"(EdgeDockablePanel.m)->Notification received - %@\n", [notification name]);

}


- (BOOL)canBecomeKeyWindow
{
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    

}
@end


