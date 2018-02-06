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
@property (NS_NONATOMIC_IOSONLY) int xEdge;

@property (NS_NONATOMIC_IOSONLY) int yEdge;

@property (NS_NONATOMIC_IOSONLY) int cartoucheBorderType;

@property (NS_NONATOMIC_IOSONLY) int endCartoucheAlignment;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricCartouche;

@end
