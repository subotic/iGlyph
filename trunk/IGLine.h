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
  
  int _lineType;
  float _lineWidth;
  BOOL _rubricLine;
  int _arrowType;
  float _arrowHead;
  float _arrowHeadSize;
  BOOL _reverseArrow;
  
}

- (void)setStartsAtLowerLeft:(BOOL)flag;
- (BOOL)startsAtLowerLeft;

- (int)lineType;
- (void)setLineType:(int)value;

- (float)lineWidth;
- (void)setLineWidth:(float)value;

- (BOOL)rubricLine;
- (void)setRubricLine:(BOOL)value;

- (int)arrowType;
- (void)setArrowType:(int)value;

- (float)arrowHead;
- (void)setArrowHead:(float)value;

- (float)arrowHeadSize;
- (void)setArrowHeadSize:(float)value;

- (void)doReverseArrow;
- (BOOL)reverseArrow;
- (void)setReverseArrow:(BOOL)aValue;



  //main window stuff
- (NSWindow *)theMainWindow;
- (IGDrawWindowController *)theMainWindowController;
- (IGGraphicView *)theMainView;
- (IGGraphic *)theOnlySelectedGlyph;
@end
