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

  NSInteger _lineType;
  NSInteger _lineWidth;
  BOOL _rubricLine;
  NSInteger _arrowType;
  NSInteger _arrowHead;
  NSInteger _arrowHeadSize;
  BOOL _reverseArrow;
  
}

@property (NS_NONATOMIC_IOSONLY) BOOL startsAtLowerLeft;

@property (NS_NONATOMIC_IOSONLY) NSInteger lineType;

@property (NS_NONATOMIC_IOSONLY) NSInteger lineWidth;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowType;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHead;

@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadSize;

- (void)doReverseArrow;
@property (NS_NONATOMIC_IOSONLY) BOOL reverseArrow;



  //main window stuff
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGDrawWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) IGGraphic *theOnlySelectedGlyph;
@end
