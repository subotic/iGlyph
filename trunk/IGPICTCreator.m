//
//  IGPICTCreator.m
//  VisualGlyph
//
//  Created by Ivan Subotic on 10.06.05.
//  Copyright 2005 Ivan Subotic. All rights reserved.
//

#import "IGPICTCreator.h"


@implementation IGPICTCreator

+ (IGPICTCreator *) IGPICTCreatorWithSize:(NSSize)PICTSSize
{
    IGPICTCreator *theVGPC = [self alloc];
    if (!theVGPC) return NULL;
    theVGPC = [theVGPC initWithSize:PICTSSize];
    return [theVGPC autorelease];
}

- (id) initWithSize:(NSSize)PICTSSize
{
    theSize=PICTSSize;
    return self;
}

- (void)lockFocus
{
    Rect myRect = {0, 0, theSize.height, theSize.width};
    //Rect myRect = {0, 0, theSize.height / 50, theSize.width / 50};
    OpenCPicParams thePicParams = {myRect, 0x00480000, 0x00480000, -2, 0, 0};
    thePictHandle = OpenCPicture (&thePicParams);
}

- (void)unlockFocus
{
    ClosePicture();
}
- (NSData *)PICTRepresentation
{
    Size thePictSize=GetHandleSize((Handle)thePictHandle);
    PicPtr myPicPtr=*thePictHandle;
    return [NSData dataWithBytes:myPicPtr length:thePictSize];
}

- (void)dealloc
{
    KillPicture(thePictHandle);
    [super dealloc];
}

@end