//
//  IGLine.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGLine.h"
#import "IGGraphic.h"
#import "LineController.h"

#import "IGGraphicView.h"
#import "IGDocumentWindowController.h"

#import "math.h"
//#import "fp.h"

#import "IGGlyph.h"

@implementation IGLine


- (instancetype)init {
    self = [super init];
    if (self) {
        self.lineType = 0;
        self.lineWidth = 1;
        [self setRubricLine:NO];
        self.arrowType = 0;
        self.arrowHeadAngle = 45.0;
        self.arrowHeadSize = 15;
        [self setReverseArrow:NO];
        
        tmpDeltaWH = NSZeroSize;
        
        self.bounds = NSMakeRect(250, 350, 100, 50);
        
    }
    return self;
}

- (instancetype)copy {
    id newObj = [super copy];
    
    [newObj setStartsAtLowerLeft:self.startsAtLowerLeft];
    [newObj setLineType:self.lineType];
    // [newObj setLineWidth:[self lineWidth]]; // has problems finding
    [newObj setRubricLine:self.rubricLine];
    [newObj setArrowHeadAngle:self.arrowHeadAngle];
    // [newObj setArrowHeadSize:[self arrowHeadSize]]; // has problems finding
    [newObj setReverseArrow:self.reverseArrow];
    
    return newObj;
}

- (void)setStartsAtLowerLeft:(BOOL)flag {
    if (_startsAtLowerLeft != flag) {
        [[self.undoManager prepareWithInvocationTarget:self] setStartsAtLowerLeft:_startsAtLowerLeft];
        _startsAtLowerLeft = flag;
        [self didChange];
    }
}

- (BOOL)startsAtLowerLeft {
    return _startsAtLowerLeft;
}

- (void)flipHorizontally {
    NSLog(@"IGLine(flipHorizontally");
    self.startsAtLowerLeft = !self.startsAtLowerLeft;
    [self doReverseArrow];
    return;
}

- (void)flipVertically {
    NSLog(@"IGLine(flipVertically");
    self.startsAtLowerLeft = !self.startsAtLowerLeft;
    //[self reverseArrow];
    return;
}

- (BOOL)drawsFill {
    // IGLine never draw fill
    return NO;
}

- (BOOL)canDrawFill {
    // IGLine never draw fill
    return NO;
}

- (BOOL)hasNaturalSize {
    // IGLine have no "natural" size
    return NO;
}

- (NSBezierPath *)bezierPath
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = self.bounds; //hier drinnen wird die Linie als Diagonale gezeichnet
    
    if (self.rubricLine) {
        self.strokeColor = [NSColor redColor];
    } else {
        self.strokeColor = [NSColor blackColor];
    }
    
    BOOL shiftKeyDown = ((NSApp.currentEvent.modifierFlags & NSShiftKeyMask) ? YES : NO);
    //NSLog(@"Shift key is %i", shiftKeyDown);
    
    CGFloat dashPattern[2];
    dashPattern[0] = 5.0;
    dashPattern [1] = 5.0;
    
    double alphaWinkel = self.arrowHeadAngle; //Oeffnungswinkel vom Pfeil
    alphaWinkel = alphaWinkel * M_PI / 180.0; //Umwandlung in Rad
    float arrowHS = self.arrowHeadSize; //grösse des Pfeiles
    
    double deltaX = -cos(alphaWinkel) * arrowHS;
    double deltaY = sin(alphaWinkel) * arrowHS;
    
    
    if (self.lineType == 0) { // Solid Line
        self.strokeLineWidth = self.lineWidth;
    } else if (self.lineType == 1) { // Dash
        self.strokeLineWidth = self.lineWidth;
        [path setLineDash:dashPattern count:2 phase:0.0];
    } else if (self.lineType == 2) { //Guidline
        self.strokeLineWidth = 0.25;
    }
    
    //damit die richtige Seite den Pfeil bekommt auch wenn flippHorizontally passiert
    NSUInteger lokalArrowType = self.arrowType;
    int lokalReverseArrow = self.reverseArrow;
    
    if (lokalArrowType == 1) {
        if (lokalReverseArrow) {
            lokalArrowType = 2;
        }
    } else if (lokalArrowType == 2) {
        if (lokalReverseArrow) {
            lokalArrowType = 1;
        }
    }
    
    //hier passe ich die nounds an , so das sich die Linie beim shiftKeyDown nur im
    //45Grad Winkel bewegt.
    //ACHTUNG!!! Berechnung mit relativen x,y Werten
    //ACHTUNG!!! Nach dem Winkel Snap muss die Linie die gleiche Länge haben
    //ACHTUNG!!! Shift muss auch vorher drückbar sein
    //ACHTUNG!!! Cursor muss sich ändern wenn über verstell Rechteck
    
    NSPoint curMainViewPoint = [self.theMainView convertPoint:NSApp.currentEvent.locationInWindow fromView:nil];
    BOOL rightSideOfLineIsMoving = (curMainViewPoint.x > bounds.origin.x ? YES : NO);
    
    if (shiftKeyDown) {
        float dX = bounds.size.width; //relatives x von meinem zu überprüfendem Punkt
        float dY = bounds.size.height; //relatives y von meinem zu überprüfendem Punkt
        float dL = sqrt(pow(dX, 2) + pow(dY, 2)); //länge der Linie welche als Diagonale vom Rechteck gezeichnet wird
        
        float tanAchtelPi = 0.41421;
        float tanDreiAchtelPi = 2.41421;
        
        float yTief = tanAchtelPi * dX;
        float yHoch = tanDreiAchtelPi * dX;
        
        float dXY = dL/1.41421356; //welches X,Y gibt mir die dL Länge
        
        if (self.startsAtLowerLeft && rightSideOfLineIsMoving) {
            NSLog(@"NSLine oben-rechts");
            NSLog(@"dX = %f, dY = %f, dL = %f", dX, dY, dL);
            if (dY < yTief) {
                NSLog(@"Snap to 0Grad , dY = %f, yTief = %f", dY, yTief);
                bounds.origin.y += bounds.size.height;
                bounds.size.height = 0;
                bounds.size.width = dL;
                self.bounds = bounds;
            } else if (dY >= yTief && dY <= yHoch) {
                NSLog(@"Snap to 45Grad, dY = %f, yTief = %f, yHoch = %f", dY, yTief, yHoch);
                bounds.origin.y += bounds.size.height - dXY;
                bounds.size.height = dXY;
                bounds.size.width = dXY;
                self.bounds = bounds;
            } else if (dY > yHoch) {
                NSLog(@"Snap to 90Grad, dY = %f, yHoch = %f", dY, yHoch);
                bounds.size.width = 0;
                self.bounds = bounds;
            }
        } else if (self.startsAtLowerLeft && !rightSideOfLineIsMoving) {
            NSLog(@"NSLine unten-links");
            NSLog(@"dX = %f, dY = %f, dL = %f", dX, dY, dL);
            if (dY < yTief) {
                NSLog(@"Snap to 0Grad , dY = %f, yTief = %f", dY, yTief);
                bounds.size.height = 0;
                self.bounds = bounds;
            } else if (dY >= yTief && dY <= yHoch) {
                NSLog(@"Snap to 45Grad, dY = %f, yTief = %f, yHoch = %f", dY, yTief, yHoch);
                bounds.origin.x += dX - dXY;
                bounds.size.height = dXY;
                bounds.size.width = dXY;
                self.bounds = bounds;
            } else if (dY > yHoch) {
                NSLog(@"Snap to 90Grad, dY = %f, yHoch = %f", dY, yHoch);
                bounds.origin.x += dX;
                bounds.size.width = 0;
                self.bounds = bounds;
            }
            
        } else if (!self.startsAtLowerLeft && !rightSideOfLineIsMoving) {
            NSLog(@"NSLine oben-links");
            NSLog(@"dX = %f, dY = %f, dL = %f", dX, dY, dL);
            if (dY < yTief) {
                NSLog(@"Snap to 0Grad , dY = %f, yTief = %f", dY, yTief);
                //bounds.
                bounds.origin.y += bounds.size.height;
                bounds.size.height = 0;
                //bounds.size.width = dL;
                self.bounds = bounds;
            } else if (dY >= yTief && dY <= yHoch) {
                NSLog(@"Snap to 45Grad, dY = %f, yTief = %f, yHoch = %f", dY, yTief, yHoch);
                bounds.origin.x += bounds.size.width - dXY;
                bounds.origin.y += bounds.size.height - dXY;
                bounds.size.height = dXY;
                bounds.size.width = dXY;
                self.bounds = bounds;
            } else if (dY > yHoch) {
                NSLog(@"Snap to 90Grad, dY = %f, yHoch = %f", dY, yHoch);
                bounds.origin.x += bounds.size.width;
                bounds.size.width = 0;
                self.bounds = bounds;
            }
        } else if (!self.startsAtLowerLeft && rightSideOfLineIsMoving) {
            NSLog(@"NSline unten-rechts");
            NSLog(@"dX = %f, dY = %f, dL = %f", dX, dY, dL);
            if (dY < yTief) {
                NSLog(@"Snap to 0Grad , dY = %f, yTief = %f", dY, yTief);
                bounds.size.height = 0;
                bounds.size.width = dL;
                self.bounds = bounds;
            } else if (dY >= yTief && dY <= yHoch) {
                NSLog(@"Snap to 45Grad, dY = %f, yTief = %f, yHoch = %f", dY, yTief, yHoch);
                bounds.size.height = dXY;
                bounds.size.width = dXY;
                self.bounds = bounds;
            } else if (dY > yHoch) {
                NSLog(@"Snap to 90Grad, dY = %f, yHoch = %f", dY, yHoch);
                bounds.size.width = 0;
                self.bounds = bounds;
            }
        }
    }
    
    
    if (self.startsAtLowerLeft) {
        //wenn die Linie von unten-links gezeichnet wird
        NSLog(@"IGLine(bezierPath) -> startsAtLoverLeft");
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
        
        
        if (lokalArrowType == 1) { //Left
            
            float XNull = NSMinX(bounds);
            float YNull = NSMaxY(bounds);
            
            double phi = atan2(bounds.size.width, -bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            
        } else if (lokalArrowType == 2) { //Right
            
            float XNull = NSMaxX(bounds);
            float YNull = NSMinY(bounds);
            
            double phi = atan2(-bounds.size.width, bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
        } else if (lokalArrowType == 3) { //Both
            
            //Pfeil Links
            float XNull = NSMinX(bounds);
            float YNull = NSMaxY(bounds);
            
            double phi = atan2(bounds.size.width, -bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            
            //Pfeil Rechts
            XNull = NSMaxX(bounds);
            YNull = NSMinY(bounds);
            
            phi = atan2(-bounds.size.width, bounds.size.height) - M_PI/2;
            
            xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
        }
        
    } else {
        //wenn die Linie von oben-links gezeichnet wird
        NSLog(@"IGLine(bezierPath) -> startsAtUpperLeft");
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
        
        if (lokalArrowType == 1) { //Left
            
            float XNull = NSMinX(bounds);
            float YNull = NSMinY(bounds);
            
            double phi = atan2(bounds.size.width, bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            
        } else if (lokalArrowType == 2) { //Right
            
            float XNull = NSMaxX(bounds);
            float YNull = NSMaxY(bounds);
            
            double phi = atan2(-bounds.size.width, -bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            
            
        } else if (lokalArrowType == 3) { //Both
            
            //Pfeil Links
            float XNull = NSMinX(bounds);
            float YNull = NSMinY(bounds);
            
            double phi = atan2(bounds.size.width, bounds.size.height) - M_PI/2;
            
            float xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            float yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            
            //Pfeil Rechts
            XNull = NSMaxX(bounds);
            YNull = NSMaxY(bounds);
            
            phi = atan2(-bounds.size.width, -bounds.size.height) - M_PI/2;
            
            xArrowPos = -deltaX * cos(phi) + deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) + deltaY * cos(phi) + YNull;
            
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
            
            //der zweite Schenkel
            [path moveToPoint:NSMakePoint(XNull, YNull)];
            
            xArrowPos = -deltaX * cos(phi) - deltaY * sin(phi) + XNull;
            yArrowPos = deltaX * sin(phi) - deltaY * cos(phi) + YNull;
            [path lineToPoint:NSMakePoint(xArrowPos, yArrowPos)];
        }
        
    }
    
    path.lineWidth = self.strokeLineWidth;
    
    //brauche ich für die Methode drawingBounds
    tmpBezPathBounds = path.bounds;
    
    return path;
}

- (NSUInteger)knobMask {
    if (self.startsAtLowerLeft) {
        return (LowerLeftKnobMask | UpperRightKnobMask);
    } else {
        return (UpperLeftKnobMask | LowerRightKnobMask);
    }
}

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected {
    if (isSelected && ([self knobUnderPoint:point] != NoKnob)) {
        return YES;
    } else {
        NSRect bounds = self.bounds;
        float halfWidth = self.strokeLineWidth / 2.0;
        halfWidth += 2.0;  // Fudge
        if (bounds.size.width == 0.0) {
            if (fabs(point.x - bounds.origin.x) <= halfWidth) {
                return YES;
            }
        } else {
            BOOL startsAtLowerLeft = self.startsAtLowerLeft;
            float slope = bounds.size.height / bounds.size.width;
            
            if (startsAtLowerLeft) {
                slope = -slope;
            }
            
            
            if (fabs(((point.x - bounds.origin.x) * slope) - (point.y - (startsAtLowerLeft ? NSMaxY(bounds) : bounds.origin.y))) <= halfWidth) {
                return YES;
            }
        }
        return NO;
    }
}

- (NSRect)drawingBounds {
    float inset = -3.0;
    float something = self.arrowHeadSize;
    
    float halfLineWidth = (self.strokeLineWidth / 2.0) + 1.0;
    if (-halfLineWidth < inset) {
        inset = -halfLineWidth;
    }
    
    NSRect bounds = self.bounds;
    
    float dW = bounds.size.width - tmpBezPathBounds.size.width;
    float dH = bounds.size.height - tmpBezPathBounds.size.height;
    
    if (dW > inset) {
        dW = inset - something;
    } else {
        dW += -something;
    }
    
    if (dH > inset) {
        dH = inset - something;
    } else {
        dH += -something;
    }
    
    if (dW >= tmpDeltaWH.width) {
        float tmp;
        tmp = dW;
        dW = tmpDeltaWH.width;
        tmpDeltaWH.width = tmp;
    } else {
        tmpDeltaWH.width = dW;
    }
    
    if (dH >= tmpDeltaWH.height) {
        float tmp;
        tmp = dH;
        dH = tmpDeltaWH.height;
        tmpDeltaWH.height = tmp;
    } else {
        tmpDeltaWH.height = dH;
    }
    
    //NSLog(@"IGGraphic(drawingBounds) -> inset = %f", inset);
    //NSLog(@"dW: %f, dH:%f", dW, dH);
    return NSInsetRect(self.bounds, dW, dH);
}


NSString *IGLineStartsAtLowerLeftKey = @"LineStartsAtLowerLeft";
NSString *IGLineTypeKey = @"LineType";
NSString *IGLineRubricKey = @"LineRubric";
NSString *IGLineWidthKey = @"LineWidth";
NSString *IGLineArrowTypeKey = @"LineArrowType";
NSString *IGLineArrowHeadKey = @"LineArrowHead";
NSString *IGLineArrowHeadSizeKey = @"LineArrowHeadSize";
NSString *IGLineReverseArrowKey = @"LineReverseArrow";

- (NSMutableDictionary *)propertyListRepresentation {
    NSMutableDictionary *dict = super.propertyListRepresentation;
    dict[IGLineStartsAtLowerLeftKey] = (self.startsAtLowerLeft ? @"YES" : @"NO");
    dict[IGLineTypeKey] = [NSString stringWithFormat:@"%ld", (long)self.lineType];
    dict[IGLineRubricKey] = (self.rubricLine ? @"YES" : @"NO");
    dict[IGLineWidthKey] = [NSString stringWithFormat:@"%ld", (long)self.lineWidth];
    dict[IGLineArrowTypeKey] = [NSString stringWithFormat:@"%ld", (long)self.arrowType];
    dict[IGLineArrowHeadKey] = [NSString stringWithFormat:@"%ld", (long)self.arrowHeadAngle];
    dict[IGLineArrowHeadSizeKey] = [NSString stringWithFormat:@"%ld", (long)self.arrowHeadSize];
    dict[IGLineReverseArrowKey] = (self.reverseArrow ? @"YES" : @"NO");
    return dict;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentation:dict];
    
    obj = dict[IGLineStartsAtLowerLeftKey];
    if (obj) {
        self.startsAtLowerLeft = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGLineTypeKey];
    if (obj) {
        self.lineType = [obj integerValue];
    }
    obj = dict[IGLineRubricKey];
    if (obj) {
        self.rubricLine = [obj isEqualToString:@"YES"];
    }
    obj = dict[IGLineWidthKey];
    if (obj) {
        self.lineWidth = [obj integerValue];
    }
    obj = dict[IGLineArrowTypeKey];
    if (obj) {
        self.arrowType = [obj integerValue];
    }
    obj = dict[IGLineArrowHeadKey];
    if (obj) {
        self.arrowHeadAngle = [obj integerValue];
    }
    obj = dict[IGLineArrowHeadSizeKey];
    if (obj) {
        self.arrowHeadSize = [obj integerValue];
    }
    obj = dict[IGLineReverseArrowKey];
    if (obj) {
        self.reverseArrow = [obj isEqualToString:@"YES"];
    }
    
}


- (NSInteger)lineType
{
    return _lineType;
}

- (void)setLineType:(NSInteger)value
{
    _lineType = value;
    NSLog(@"IGLine(setLineType)->%ld", (long)_lineType);
    //[self didChange];
}

- (NSInteger)lineWidth
{
    return _lineWidth;
}

- (void)setLineWidth:(NSInteger)value
{
    _lineWidth = value;
    NSLog(@"IGLine(setLineWidth)->%ld", (long)_lineWidth);
    //[self didChange];
}

- (BOOL)rubricLine
{
    return _rubricLine;
}

- (void)setRubricLine:(BOOL)value
{
    _rubricLine = value;
    NSLog(@"IGGraphic(setRubricLine)->%i", _rubricLine);
    //[self didChange];
}

- (NSInteger)arrowType
{
    NSLog(@"IGLine(arrowType) -> %ld", (long)_arrowType);
    return  _arrowType;
}

- (void)setArrowType:(NSInteger)value
{
    _arrowType = value;
    
    NSLog(@"++++++++++++++++++++++++++++++++++");
    NSLog(@"IGLine(setArrowType)->%ld", (long)_arrowType);
    NSLog(@"++++++++++++++++++++++++++++++++++");
    //[self didChange];
}

- (NSInteger)arrowHeadAngle
{
    return _arrowHeadAngle;
}

- (void)setArrowHeadAngle:(NSInteger)value
{
    _arrowHeadAngle = value;
    NSLog(@"IGLine(setArrowHeadAngle)->%ld", (long)_arrowHeadAngle);
    //[self didChange];
}

- (NSInteger)arrowHeadSize
{
    return _arrowHeadSize;
}

- (void)setArrowHeadSize:(NSInteger)value
{
    _arrowHeadSize = value;
    NSLog(@"IGLine(setArrowHeadSize)->%ld", (long)_arrowHeadSize);
    //[self didChange];
}

- (void)doReverseArrow
{
    _reverseArrow = (self.reverseArrow) ?  0 : 1;
    //[self didChange];
    NSLog(@"-----------------------------------------------");
    NSLog(@"IGL(reverseArrow) -> true?:%i", _reverseArrow);
    NSLog(@"-----------------------------------------------");
}


//the main window stuff
- (NSWindow *)theMainWindow {
    if (!NSApp.mainWindow.keyWindow) [NSApp.mainWindow makeKeyWindow];
    return NSApp.mainWindow;
}

- (IGDocumentWindowController *)theMainWindowController {
    return self.theMainWindow.windowController;
}

- (IGGraphicView *)theMainView {
    return self.theMainWindowController.graphicView;
}

- (IGGraphic *)theOnlySelectedGlyph {
    IGGraphic *graphic = [self.theMainView theOnlySelectedGraphicOfClass:[IGGlyph class]];
    return graphic;
}

@end
