///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/EdgeDockablePanelWithKey.m,v $
// $Revision: 1.1 $ $Date: 2005/02/01 14:58:48 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// EdgeDockablePanelWithKey.m
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import "IGEdgeDockablePanelWithKey.h"
#include <unistd.h>

@implementation IGEdgeDockablePanelWithKey

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
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

- (BOOL)setFrameUsingName:(NSString *)name {
    return [super setFrameUsingName:name];
}

- (void)windowMoved:(id)notification
{
    //NSLog(@"(EdgeDockablePanel.m)->Notification received - %@\n", [notification name]);

}

- (void)toolboxClosing:(id)notification
{
    //NSLog(@"(EdgeDockablePanel.m)->Notification received - %@\n", [notification name]);

}


- (BOOL)becomesKeyOnlyIfNeeded {
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];

}
@end


