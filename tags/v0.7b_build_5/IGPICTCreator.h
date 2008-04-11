//
//  IGPICTCreator.h
//  VisualGlyph
//
//  Created by Ivan Subotic on 10.06.05.
//  Copyright 2005 Ivan Subotic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface IGPICTCreator : NSObject {
    NSSize theSize;
    PicHandle thePictHandle;
}

+ (IGPICTCreator *) IGPICTCreatorWithSize:(NSSize)PICTSSize;
- (id) initWithSize:(NSSize)PICTSSize;
- (void) lockFocus;
- (void) unlockFocus;
- (NSData *) PICTRepresentation;

@end
