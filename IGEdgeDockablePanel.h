///////////////////////////////////////////////////////////////////////////////
// $Source: /Volumes/data1/cvsroot/VisualGlyph/EdgeDockablePanel.h,v $
// $Revision: 1.2 $ $Date: 2004/07/26 14:24:34 $ $State: Exp $
//-----------------------------------------------------------------------------
// Description
// ===========
// EdgeDockablePanel.h
// VisualGlyphApp
//
// Created by Ivan Subotic on Tue Aug 12 2003.
// Copyright (c) 2003 Ivan Subotic. All rights reserved.
///////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

@interface IGEdgeDockablePanel : NSPanel {

}

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canBecomeKeyWindow;

@end
