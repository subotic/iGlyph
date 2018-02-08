//
//  IGLine.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGGraphic.h"

@class IGGraphicView;
@class IGDrawWindowController;

@interface IGLine : IGGraphic {
  
  @private
  BOOL _startsAtLowerLeft;
  NSRect tmpBezPathBounds;
  NSSize tmpDeltaWH;
  
  NSUInteger _lineType;
  float _lineWidth;
  BOOL _rubricLine;
  NSUInteger _arrowType;
  float _arrowHead;
  NSInteger _arrowHeadSize;
  BOOL _reverseArrow;
  
}

@property (NS_NONATOMIC_IOSONLY) BOOL startsAtLowerLeft;

@property (NS_NONATOMIC_IOSONLY) NSUInteger lineType;

@property (NS_NONATOMIC_IOSONLY) float lineWidth;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;

@property (NS_NONATOMIC_IOSONLY) NSUInteger arrowType;

@property (NS_NONATOMIC_IOSONLY) float arrowHead;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadSize;

- (void)doReverseArrow;
@property (NS_NONATOMIC_IOSONLY) BOOL reverseArrow;



  //main window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) IGGraphic *theOnlySelectedGlyph;
@end
