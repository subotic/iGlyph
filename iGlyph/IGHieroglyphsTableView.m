//
//  IGHieroglyphsTableView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue Jul 20 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGHieroglyphsTableView.h"
#import "HieroglyphsController.h"


@implementation IGHieroglyphsTableView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRow:(NSInteger)row clipRect:(NSRect)rect {
    [super drawRow:row clipRect:rect]; 
}


- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    
    NSEnumerator *rowEnumerator;
    NSEnumerator *colEnumerator;
    NSNumber *rowIndex;
    NSNumber *colIndex;
    rowEnumerator = [self selectedRowEnumerator]; // should use selectedRowIndexes
    colEnumerator = [self selectedColumnEnumerator]; // should use selectedColumnIndexes
    
    while ((rowIndex = [rowEnumerator nextObject]) != nil) { 
        NSRect rowFrame; 
        rowFrame = [self rectOfRow:rowIndex.intValue]; 
        if (NSIntersectsRect(rowFrame, clipRect) == YES) { 
            while ((colIndex = [colEnumerator nextObject]) != nil) {
                NSRect colFrame;
                colFrame = [self rectOfColumn:colIndex.intValue];
                if (NSIntersectsRect(colFrame, clipRect) == YES) {
                    [[NSColor redColor] set];
                    [NSBezierPath fillRect:NSMakeRect(colFrame.origin.x, rowFrame.origin.y, colFrame.size.width, colFrame.size.height)];
                }
            }
        } 
    }
}


- (NSColor *)_highlightColorForCell:(NSCell *)cell
{
    return [NSColor whiteColor];
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    NSLog(@"Bin in meiner IGNSTableView subclase bei rightMouseDown");
    NSPoint clickAtPoint = [self convertPoint: theEvent.locationInWindow fromView: nil];
    NSInteger r = [self rowAtPoint:clickAtPoint];
    NSInteger c = [self columnAtPoint:clickAtPoint];
    NSLog(@"IGHieroglyphsTableView(mouseDown) Row: %ld, Column: %ld", (long)r, (long)c);
    
    HieroglyphsController *delegate = (HieroglyphsController*)self.delegate;
    [delegate replaceSelectedGlyphWithThisOneAtRow:r andColumn:c];
}

- (void)mouseDown:(NSEvent *)theEvent {
    //wenn ctrl gedrückt ist es wie ein rightMouseDown
    BOOL ctrlKeyDown = ((theEvent.modifierFlags & NSControlKeyMask) ? YES : NO);
    if (ctrlKeyDown) {
        NSLog(@"Bin in meiner IGNSTableView subclase bei mouseDown aber mit ctrl gedrueckt");
        NSPoint clickAtPoint = [self convertPoint: theEvent.locationInWindow fromView: nil];
        NSInteger r = [self rowAtPoint:clickAtPoint];
        NSInteger c = [self columnAtPoint:clickAtPoint];
        NSLog(@"IGHieroglyphsTableView(mouseDown) Row: %ld, Column: %ld", (long)r, (long)c);
        
        HieroglyphsController *delegate = (HieroglyphsController*)self.delegate;
        [delegate replaceSelectedGlyphWithThisOneAtRow:r andColumn:c];
        
    } else {
        NSLog(@"Bin in meiner IGNSTableView subclase bei mouseDown");
        NSPoint clickAtPoint = [self convertPoint: theEvent.locationInWindow fromView: nil];
        NSInteger r = [self rowAtPoint:clickAtPoint];
        NSInteger c = [self columnAtPoint:clickAtPoint];
        NSLog(@"IGHieroglyphsTableView(mouseDown) Row: %ld, Column: %ld", (long)r, (long)c);
        
        HieroglyphsController *delegate = (HieroglyphsController*)self.delegate;
        [delegate glyphClickedAtRow:r andColumn:c];
    }
}
@end
