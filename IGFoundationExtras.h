//
//  IGFoundationExtras.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed May 05 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSObject (IGPerformExtras)

- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array;
- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set;

@end

NSRect IGRectFromPoints(NSPoint point1, NSPoint point2);
