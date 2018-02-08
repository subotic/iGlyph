//
//  IGCartouche.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"


@interface IGCartouche : IGGraphic {
  NSInteger _xEdge;
  NSInteger _yEdge;
  NSInteger _cartoucheBorderType;
  NSInteger _endCartoucheAlignment;
  BOOL _rubricCartouche;
  
}
@property (NS_NONATOMIC_IOSONLY) NSInteger xEdge;

@property (NS_NONATOMIC_IOSONLY) NSInteger yEdge;

@property (NS_NONATOMIC_IOSONLY) NSInteger cartoucheBorderType;

@property (NS_NONATOMIC_IOSONLY) NSInteger endCartoucheAlignment;

@property (NS_NONATOMIC_IOSONLY) BOOL rubricCartouche;

@end
