//
//  IGZoomScrollView.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Mon Jun 7 2004.
//  Copyright (c) 2003 Ivan Subotic. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class IGGraphicView;
@class IGBackgroundView;
@class IGSupView;

@interface IGZoomScrollView : NSScrollView
{
    IBOutlet IGGraphicView *graphicView;
    IBOutlet IGBackgroundView *backgroundView;
    IBOutlet IGSupView *supView;
    NSPopUpButton *_scalePopUpButton;
    double scaleFactor;
}

- (instancetype)initWithFrame:(NSRect)theFrame;
- (void)awakeFromNib;

// View Zoom Methods
- (void)tile;
- (void)scalePopUpAction:(id)sender;
- (void)setScaleFactor:(float)factor adjustPopup:(BOOL)flag;
@property (NS_NONATOMIC_IOSONLY, readonly) float scaleFactor;

@end
