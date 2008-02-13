//
//  IGCartouche.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"


@interface IGCartouche : IGGraphic {
  int _xEdge;
  int _yEdge;
  int _cartoucheBorderType;
  int _endCartoucheAlignment;
  BOOL _rubricCartouche;
  
}
- (int)xEdge;
- (void)setXEdge:(int)value;

- (int)yEdge;
- (void)setYEdge:(int)value;

- (int)cartoucheBorderType;
- (void)setCartoucheBorderType:(int)value;

- (int)endCartoucheAlignment;
- (void)setEndCartoucheAlignment:(int)value;

- (BOOL)rubricCartouche;
- (void)setRubricCartouche:(BOOL)value;

@end
