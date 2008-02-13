//
//  VGMainView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed Sep 10 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
// Idee:
// Ein doppelarray für die x und y koordinaten,
// für jede glyphe geht der zähler weiter,
// schieben wird der zähler auf die neuen koordinaten gesetzt
//
// Geht aber nicht, da ich auch 2 Zeichen auf der gleichen position haben kann!!!
// neue Idee:
// ein Array, wo mehrere Elemente ein Zeichen beschreiben. Folgende Eigenschaften
// müssen pro Zeichen abgespeichert werden:
//      1. x und y koordinaten
//      2. der glyphen string selber
//      3. der Winkel
//      4. gespiegelt / nicht gespiegelt
//      5. eine fortlaufende Nummer, da die Glyphen verschiebbar sein müssen,
//          und die Eigenschaften von ihnen im Array änderbar, bzw. auffindbar sein müssen.
//          Da die Hieroglyphe ein Attributed String ist, könnte man noch ein attribut dazuhängen, welcher
//          die fortlafende Nummer in sich trägt....
//
//      so sieht das file unter windows aus:
//      1¶28.83961¶35.4542¶2.910419¶2.910419¶7.937508¶9.789593¶33¶1¶25¶0¶0¶0¶8.044821|1¶35.18962¶35.4542¶2.910419¶2.910419¶7.937508¶9.789593¶33¶1¶25¶0¶0¶0¶8.044821|1¶41.53962¶35.4542¶2.910419¶2.910419¶7.937508¶9.789593¶35¶1¶25¶0¶0¶0¶8.044821|1¶47.88963¶35.4542¶2.910419¶3.439587¶7.40834¶9.789593¶37¶1¶25¶0¶0¶0¶8.044821|1¶53.71047¶35.4542¶2.910419¶3.439587¶7.40834¶9.789593¶37¶1¶25¶0¶0¶0¶8.044821|1¶59.53131¶35.4542¶2.910419¶2.910419¶8.466675¶9.789593¶36¶1¶25¶0¶0¶0¶8.044821|1¶66.41048¶35.4542¶2.910419¶2.910419¶7.143757¶9.789593¶104¶1¶25¶0¶0¶0¶8.044821|1¶71.96674¶35.4542¶2.910419¶2.910419¶9.260426¶9.789593¶103¶1¶25¶0¶0¶0¶8.231909|1¶79.63966¶35.4542¶2.910419¶2.910419¶7.40834¶9.789593¶100¶1¶25¶0¶0¶0¶8.044821|1¶85.46049¶35.4542¶3.175003¶6.879173¶9.789593¶10.05418¶134¶2¶25¶0¶0¶0¶8.606088|1¶93.39801¶35.4542¶3.439587¶8.202091¶10.31876¶10.05418¶132¶2¶25¶0¶0¶0¶8.980265|1¶101.6001¶35.4542¶3.175003¶4.762505¶9.789593¶10.05418¶133¶2¶25¶0¶0¶0¶8.606088|1¶109.5376¶35.4542¶3.175003¶3.70417¶10.05418¶10.05418¶128¶2¶25¶0¶0¶0¶8.793177|1¶117.7397¶35.4542¶3.175003¶6.085423¶9.789593¶10.05418¶130¶2¶25¶0¶0¶0¶8.606088|1¶51.32922¶58.47297¶8.995842¶3.968754¶11.11251¶11.64168¶131¶2¶25¶0¶270¶0¶9.541532|1¶51.32922¶66.41048¶7.40834¶3.70417¶10.58334¶10.31876¶134¶2¶25¶0¶270¶0¶8.606088|1¶51.32922¶74.34799¶7.40834¶3.70417¶12.70001¶10.31876¶133¶2¶25¶0¶270¶0¶8.606088|1¶51.32922¶82.55008¶7.937508¶3.968754¶9.789593¶10.84793¶132¶2¶25¶0¶270¶1¶8.980265|1¶51.32922¶90.48759¶7.40834¶3.70417¶10.58334¶10.31876¶134¶2¶25¶0¶270¶0¶8.606088|1¶51.32922¶98.68968¶7.937508¶3.968754¶9.789593¶10.84793¶132¶2¶25¶0¶270¶1¶8.980265|1¶51.32922¶106.6272¶19.05002¶10.58334¶29.36878¶31.22086¶134¶2¶75¶1¶270¶1¶24.13446|1¶51.32922¶115.623¶8.995842¶3.968754¶11.11251¶11.64168¶131¶2¶25¶0¶270¶0¶9.541532|1¶51.32922¶123.5605¶7.40834¶3.70417¶10.58334¶10.31876¶134¶2¶25¶0¶270¶0¶8.606088|1¶51.32922¶131.498¶7.40834¶3.70417¶11.37709¶10.31876¶130¶2¶25¶0¶270¶0¶8.606088|
//

#import "VGMainView.h"
#import "VisualGlyphDelegate.h"

static NSString *MyAppToolbarIdentifier = @"MyApp Toolbar";

NSRect RectFromPoints(NSPoint point1, NSPoint point2) {
    return NSMakeRect(((point1.x <= point2.x) ? point1.x : point2.x), 
    ((point1.y <= point2.y) ? point1.y : point2.y), 
    ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x), 
    ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}

@implementation VGMainView

- (id)initWithFrame:(NSRect)frame
{
    _DEBUGlog = 1;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        if (_DEBUGlog) NSLog(@"VGMainView(init)->Init the VGMainView");
    }   
    return self;
}

- (void)awakeFromNib
{
    movingTrackingRect = NO;
    
    if (_DEBUGlog) NSLog(@"VGMainView(awakeFromNib)");
    [[self window] makeFirstResponder:self];
    
    selectionStateDic = [[NSMutableDictionary alloc] init];
    
    [self initializeToolbar];
    [[NSApp delegate] drawAll];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
    [self lockFocus];
    [[NSApp delegate] drawAll];
    [self unlockFocus];
}


// DotView changes location on mouse up, but here we choose to do so
// on mouse down and mouse drags, so the text will follow the mouse.

- (void)rightMouseDown:(NSEvent *)event
{
    NSPoint eventLocation = [event locationInWindow];
    cursor = [self convertPoint:eventLocation fromView:nil];
    cursor.x = cursor.x;
    cursor.y = cursor.y;
    if (_DEBUGlog) NSLog(@"-------------------------");
    if (_DEBUGlog) NSLog(@"VGMainView(rightMouseDown)");
    if (_DEBUGlog) NSLog(@"neue posX: %f, posY: %f", cursor.x, cursor.y);
    [[NSApp delegate] setRightClickCursorXY:cursor];
}

- (void)mouseDown:(NSEvent*)theEvent
{   
    NSPoint origPoint, curPoint;
    curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if ([self mouse:curPoint inRect:selectionRect]) {
        
        float dX, dY;
        
        [[NSCursor pointingHandCursor] set];
        
        [selectionStateDic setObject:@"1" forKey:@"selectionIsMovingState"];
        [selectionStateDic setObject:@"1" forKey:@"selectionMovingFieldExistingState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
        
        origPoint = curPoint;
        
        for (;;) {
            theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            
            dX = curPoint.x - origPoint.x;
            dY = curPoint.y - origPoint.y;
            
            origPoint = curPoint;
            
            [[NSApp delegate] moveSelecionBy:NSMakePoint(dX,dY)];
            
            [self setNeedsDisplay:YES];
            
            if ([theEvent type] == NSLeftMouseUp) {
                if (_DEBUGlog) NSLog(@"NSLeftMouseUp");
                [[NSCursor arrowCursor] set];
                [selectionStateDic setObject:@"0" forKey:@"selectionIsMovingState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
                
                break;
            }
        }
        
    } else if ([self mouse:curPoint inRect:selectionMovingFieldRect] != 1) {
        
        //beim click ausserhalb soll die auswahlverschiebbox gelöscht werden
        if (selectionOngoing) {
            
            [self removeAnySelection];
        }
        
        NSRect tmpSelectionRect;
    
        origPoint = curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
        for (;;) {
            theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

            tmpSelectionRect = RectFromPoints(origPoint, curPoint);
            [[NSApp delegate] setSelectionRect:tmpSelectionRect];
            
            [selectionStateDic setObject:@"0" forKey:@"selectionEndedState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
            
            [self setNeedsDisplay:YES];
            
            if ([theEvent type] == NSLeftMouseUp) {
                
                [selectionStateDic setObject:@"1" forKey:@"selectionEndedState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
                
                break;
            }
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    unichar theChar = [[event characters] characterAtIndex:0];
    if (theChar == NSDeleteFunctionKey) {
        if (_DEBUGlog) NSLog(@"pressed the delete button");
        [self deleteSelectedList];
    }
    [self setNeedsDisplay:YES];
}

- (void)deleteSelectedList
{
    [[NSApp delegate] deleteSelectedList];
    
    [selectionStateDic setObject:@"0" forKey:@"selectionIsMovingState"];
    [selectionStateDic setObject:@"0" forKey:@"selectionMovingFieldExistingState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
    
    if (_DEBUGlog) NSLog(@"VGMainView(setSelectedListRect) removing tracking rect");
    [self removeTrackingRect:selectionMovingFieldRectTag];
    selectionMovingFieldRectTag = NULL;
}

- (void)setTrackingRectForSelectedListRect:(NSRect)selRect
{
    if (_DEBUGlog) NSLog(@"VGMainView(setTrackingRectForSelectedListRect) add tracking rect");
    selectionRectSize = selRect.size;
    selectionRect = selRect;
    selectionMovingFieldRect = NSMakeRect(selRect.origin.x, selRect.origin.y + selectionRectSize.height - 2, 5, 5);
    selectionOngoing = 1;
    
    //[self removeCursorRect:tempSelectionMovingFieldRect cursor:[NSCursor pointingHandCursor]];
    //[self addCursorRect:selectionMovingFieldRect cursor:[NSCursor pointingHandCursor]];
    
    /*
    if (!selectionMovingFieldRectTag)
    {
        selectionMovingFieldRectTag = [self addTrackingRect:selectionMovingFieldRect owner:self userData:@"selectionMovingField" assumeInside:NO];
    } else {
        if (_DEBUGlog) NSLog(@"VGMainView(setSelectedListRect) removing tracking rect and making a new one");
        [self removeTrackingRect:selectionMovingFieldRectTag];
        selectionMovingFieldRectTag = [self addTrackingRect:selectionMovingFieldRect owner:self userData:@"selectionMovingField" assumeInside:NO];
    }
    */
    //tempSelectionMovingFieldRect = selectionMovingFieldRect;
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    movingTrackingRect = YES;
    if (_DEBUGlog) NSLog(@"VGMainView(mouseEntered) bin IN der tracking rect");
}

- (void)mouseExited:(NSEvent *)theEvent
{
    movingTrackingRect = NO;
    if (_DEBUGlog) NSLog(@"VGMainView(mouseExited) bin RAUS aus der tracking rect");
}

- (void)removeAnySelection
{
    
    if (_DEBUGlog) NSLog(@"VGMainView(removeAnySelection) removing tracking rect and reseting cursor");
    
    [selectionStateDic setObject:@"0" forKey:@"selectionIsMovingState"];
    [selectionStateDic setObject:@"0" forKey:@"selectionMovingFieldExistingState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionStateChanged" object:self userInfo:selectionStateDic];
    
    [[NSApp delegate] updateToolboxesWithGlobalAttribs];
    
    //[self removeCursorRect:selectionMovingFieldRect cursor:[NSCursor pointingHandCursor]];
    //[self removeTrackingRect:selectionMovingFieldRectTag];
    
    //selectionMovingFieldRectTag = NULL;
    selectionOngoing = 0;
    selectionRect = NSZeroRect;
}


- (BOOL)isFlipped
{
    return YES;
}

-(BOOL)resignFirstResponder
{
    if (_DEBUGlog) NSLog(@"VGMainView(resignFirstResponder)");
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    if (_DEBUGlog) NSLog(@"VGMainView(acceptsFirstResponder)");
    return YES;
}

- (BOOL)acceptsFirstMouse
{
    if (_DEBUGlog) NSLog(@"VGMainView(acceptsFirstMouse)");
    return YES;
}

- (NSPoint)getCursor
{
    return cursor;
}

- (void)setCursorXpos:(float)xPosition
{
    cursor.x = xPosition;
}

- (void)setCursorYpos:(float)yPosition
{
    cursor.y = yPosition;
}

//Toolbar stuff
- (void)initializeToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:MyAppToolbarIdentifier];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeLabelOnly];
    [toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setDelegate:[NSApp delegate]];
    [[self window] setToolbar:toolbar];
    [toolbar release];
}

- (IBAction)cut:(id)sender
{
    if (_DEBUGlog) NSLog(@"CUT selection");
}

- (IBAction)copy:(id)sender
{
    if ([sender tag] == 0) {
        if (_DEBUGlog) NSLog(@"normal copy to pasteboard");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectionCopy" object:self];
    } else if ([sender tag] == 1) {
        if (_DEBUGlog) NSLog(@"image copy to pasteboard");
        
        BOOL success;
        NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSGeneralPboard];
        NSArray *types = [NSArray arrayWithObjects:NSPostScriptPboardType, NSPDFPboardType, nil];
        [pb declareTypes:types owner:self];
        success = [pb setData:[self dataWithEPSInsideRect:selectionRect] forType:NSPostScriptPboardType];
        success = [pb setData:[self dataWithPDFInsideRect:selectionRect] forType:NSPDFPboardType];
        success = [pb setData:[self dataWithPDFInsideRect:selectionRect] forType:NSPDFPboardType];
        if (!success) NSBeep();
    }
}

- (IBAction)paste:(id)sender
{
    if (_DEBUGlog) NSLog(@"paste selection");
}


@end
