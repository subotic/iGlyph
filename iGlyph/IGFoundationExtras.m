//
//  IGFoundationExtras.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed May 05 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGFoundationExtras.h"


@implementation NSObject (IGPerformExtras)

- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array {
    NSUInteger i, c = array.count;
    for (i=0; i<c; i++) {
        [self performSelector:sel withObject:array[i]];
    }
}

- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set {
    [self performSelector:sel withEachObjectInArray:set.allObjects];
}

@end

NSRect IGRectFromPoints(NSPoint point1, NSPoint point2) {
    return NSMakeRect(((point1.x <= point2.x) ? point1.x : point2.x),
                      ((point1.y <= point2.y) ? point1.y : point2.y),
                      ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
                      ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}
