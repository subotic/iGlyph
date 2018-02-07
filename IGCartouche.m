//
//  IGCartouche.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGCartouche.h"
#import "CartoucheController.h"

@implementation IGCartouche


- (instancetype)init
{
    self = [super init];
    if (self) {
      /*  
      [self setXEdge:[[CartoucheController sharedCartoucheController] xEdge]];
      [self setYEdge:[[CartoucheController sharedCartoucheController] yEdge]];
      [self setCartoucheBorderType:[[CartoucheController sharedCartoucheController] cartoucheBorderType]];
      [self setRubricCartouche:[[CartoucheController sharedCartoucheController] rubricCartouche]];
      [self setEndCartoucheAlignment:[[CartoucheController sharedCartoucheController] endAlignment]];
      */  
      self.xEdge = 100;
      self.yEdge = 50;
      self.cartoucheBorderType = 1;
      self.endCartoucheAlignment = 4;
      [self setRubricCartouche:FALSE];
      
      self.bounds = NSMakeRect(250, 350, 100, 50);
      
      self.cornerRadius = 30;
      self.cartoucheOrientation = 0;
      self.stroked = TRUE;
      self.strokeType = 0;
      self.strokeThickness = 1.0;
      self.filled = FALSE;
      
    }
    return self;
}



- (NSBezierPath *)bezierPath
{    
    NSLog(@"IGCartouche(bezierPath)");
    
    NSRect bounds = self.bounds;
    float xEdge = self.xEdge;
    float yEdge = self.yEdge;
    
    if (self.rubricCartouche) {
        self.strokeColor = [NSColor redColor];
    } else {
        self.strokeColor = [NSColor blackColor];
    }
    
    self.strokeLineWidth = self.cartoucheBorderType;
    
    //Linie
    NSBezierPath *path = [NSBezierPath bezierPath];
    if (self.endCartoucheAlignment == 1) {
        [path moveToPoint:NSMakePoint(self.xPosition , self.yPosition)];
        [path lineToPoint:NSMakePoint(self.xPosition + self.width , self.yPosition)];
    } else if (self.endCartoucheAlignment == 2) {
        [path moveToPoint:NSMakePoint(self.xPosition + self.width , self.yPosition)];
        [path lineToPoint:NSMakePoint(self.xPosition + self.width , self.yPosition + self.height)];
    } else if (self.endCartoucheAlignment == 3) {
        [path moveToPoint:NSMakePoint(self.xPosition + self.width , self.yPosition + self.height)];
        [path lineToPoint:NSMakePoint(self.xPosition, self.height + self.yPosition)];
    } else if (self.endCartoucheAlignment == 4){
        [path moveToPoint:NSMakePoint(self.xPosition, self.height + self.yPosition)];
        [path lineToPoint:NSMakePoint(self.xPosition , self.yPosition)];
    }
    
    if (bounds.size.width < (2 * xEdge)) {
        xEdge = bounds.size.width / 2;
    }
    
    if (bounds.size.height < (2 * yEdge)) {
        yEdge = bounds.size.height / 2;
    }
    
    //Oben Links
    [path moveToPoint:NSMakePoint(bounds.origin.x , bounds.origin.y + yEdge)];
    [path curveToPoint:NSMakePoint(bounds.origin.x  + xEdge , bounds.origin.y) controlPoint1:NSMakePoint(bounds.origin.x , bounds.origin.y + yEdge * 0.3) controlPoint2:NSMakePoint(bounds.origin.x + xEdge * 0.3 , bounds.origin.y)];
    
    //Oben Rechts
    [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - xEdge , bounds.origin.y)];
    [path curveToPoint:NSMakePoint(bounds.origin.x  + bounds.size.width , bounds.origin.y + yEdge) controlPoint1:NSMakePoint(bounds.origin.x + bounds.size.width - xEdge * 0.3 , bounds.origin.y) controlPoint2:NSMakePoint(bounds.origin.x + bounds.size.width , bounds.origin.y + yEdge * 0.3)];
    
    //Unten Rechts
    [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width , bounds.origin.y + bounds.size.height - yEdge)];
    [path curveToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - xEdge , bounds.origin.y + bounds.size.height) controlPoint1:NSMakePoint(bounds.origin.x + bounds.size.width , bounds.origin.y + bounds.size.height - yEdge * 0.3) controlPoint2:NSMakePoint(bounds.origin.x + bounds.size.width - xEdge * 0.3, bounds.origin.y + bounds.size.height)];
    
    //Unten Links
    [path lineToPoint:NSMakePoint(bounds.origin.x + xEdge, bounds.origin.y + bounds.size.height)];
    [path curveToPoint:NSMakePoint(bounds.origin.x , bounds.origin.y + bounds.size.height - yEdge) controlPoint1:NSMakePoint(bounds.origin.x + xEdge * 0.3 , bounds.origin.y + bounds.size.height) controlPoint2:NSMakePoint(bounds.origin.x , bounds.origin.y + bounds.size.height - yEdge * 0.3)];
    
    [path lineToPoint:NSMakePoint(bounds.origin.x , bounds.origin.y + yEdge)];
    
    //NSLog(@"x: %f, y: %f, w: %f, h: %f", [self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height); 
    path.lineWidth = self.strokeLineWidth;
    
    
    return path;
}

- (NSUInteger)knobMask
{
    return LowerLeftKnobMask + UpperRightKnobMask + UpperLeftKnobMask + LowerRightKnobMask;
}

- (BOOL)drawsFill {
    // IGCartouche never draw fill
    return NO;
}

- (BOOL)canDrawFill {
    // IGCartouche never draw fill
    return NO;
}

- (BOOL)hasNaturalSize {
    // IGCartouche have no "natural" size
    return NO;
}

// ==================================================================================
#pragma mark -
#pragma mark -- bindings stuff --
// ============================== bindings stuff=====================================

- (NSInteger)xEdge { return _xEdge; }
- (void)setXEdge:(NSInteger)value
{
  _xEdge = value;
}


- (NSInteger)yEdge { return _yEdge; }
- (void)setYEdge:(NSInteger)value
{
  _yEdge = value;
}


- (NSInteger)cartoucheBorderType { return _cartoucheBorderType; }
- (void)setCartoucheBorderType:(NSInteger)value
{
  _cartoucheBorderType = value;
}


- (NSInteger)endCartoucheAlignment { return _endCartoucheAlignment; }
- (void)setEndCartoucheAlignment:(NSInteger)value
{
  _endCartoucheAlignment = value;
}


- (BOOL)rubricCartouche { return _rubricCartouche; }
- (void)setRubricCartouche:(BOOL)value
{
  _rubricCartouche = value;
}

@end
