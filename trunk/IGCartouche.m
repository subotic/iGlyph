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


- (id)init
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
      [self setXEdge:100];
      [self setYEdge:50];
      [self setCartoucheBorderType:1];
      [self setEndCartoucheAlignment:4];
      [self setRubricCartouche:FALSE];
      
      [self setBounds:NSMakeRect(250, 350, 100, 50)];
      
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
    
    NSRect bounds = [self bounds];
    float xEdge = [self xEdge];
    float yEdge = [self yEdge];
    
    ([self rubricCartouche] ? [self setStrokeColor:[NSColor redColor]] : [self setStrokeColor:[NSColor blackColor]]);
    [self setStrokeLineWidth:[self cartoucheBorderType]];
    
    //Linie
    NSBezierPath *path = [NSBezierPath bezierPath];
    if ([self endCartoucheAlignment] == 1) {
        [path moveToPoint:NSMakePoint([self xPosition] , [self yPosition])];
        [path lineToPoint:NSMakePoint([self xPosition] + [self width] , [self yPosition])];
    } else if ([self endCartoucheAlignment] == 2) {
        [path moveToPoint:NSMakePoint([self xPosition] + [self width] , [self yPosition])];
        [path lineToPoint:NSMakePoint([self xPosition] + [self width] , [self yPosition] + [self height])];
    } else if ([self endCartoucheAlignment] == 3) {
        [path moveToPoint:NSMakePoint([self xPosition] + [self width] , [self yPosition] + [self height])];
        [path lineToPoint:NSMakePoint([self xPosition], [self height] + [self yPosition])];
    } else if ([self endCartoucheAlignment] == 4){
        [path moveToPoint:NSMakePoint([self xPosition], [self height] + [self yPosition])];
        [path lineToPoint:NSMakePoint([self xPosition] , [self yPosition])];
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
    [path setLineWidth:[self strokeLineWidth]];
    
    
    return path;
}

- (unsigned)knobMask
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

- (int)xEdge { return _xEdge; }
- (void)setXEdge:(int)value
{
  _xEdge = value;
}


- (int)yEdge { return _yEdge; }
- (void)setYEdge:(int)value
{
  _yEdge = value;
}


- (int)cartoucheBorderType { return _cartoucheBorderType; }
- (void)setCartoucheBorderType:(int)value
{
  _cartoucheBorderType = value;
}


- (int)endCartoucheAlignment { return _endCartoucheAlignment; }
- (void)setEndCartoucheAlignment:(int)value
{
  _endCartoucheAlignment = value;
}


- (BOOL)rubricCartouche { return _rubricCartouche; }
- (void)setRubricCartouche:(BOOL)value
{
  _rubricCartouche = value;
}

@end
