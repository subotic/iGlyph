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
@class IGDocumentWindowController;

@interface IGLine : IGGraphic {
  
  @private
  BOOL _startsAtLowerLeft;
  NSRect tmpBezPathBounds;
  NSSize tmpDeltaWH;

  NSInteger _lineType;
  NSInteger _lineWidth;
  BOOL _rubricLine;
  NSInteger _arrowType;
  NSInteger _arrowHeadAngle;
  NSInteger _arrowHeadSize;
  BOOL _reverseArrow;
  
}
// MARK: Properties

// main window
@property (NS_NONATOMIC_IOSONLY, readonly, weak) NSWindow *theMainWindow;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) IGDocumentWindowController *theMainWindowController;
@property (NS_NONATOMIC_IOSONLY, readonly, weak) IGGraphicView *theMainView;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) IGGraphic *theOnlySelectedGlyph;


@property (NS_NONATOMIC_IOSONLY) BOOL startsAtLowerLeft;
@property (NS_NONATOMIC_IOSONLY) NSInteger lineType;
@property (NS_NONATOMIC_IOSONLY) NSInteger lineWidth;
@property (NS_NONATOMIC_IOSONLY) BOOL rubricLine;
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowType; //0-kein, 1-eine Seite, 2-zwei Seiten
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadAngle;
@property (NS_NONATOMIC_IOSONLY) NSInteger arrowHeadSize;
@property (NS_NONATOMIC_IOSONLY) BOOL reverseArrow;

//MARK: Methods
- (void)doReverseArrow;

@end
