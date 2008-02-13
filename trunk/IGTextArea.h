//
//  IGTextArea.h
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGraphic.h"


@interface IGTextArea : IGGraphic {
    @private
    NSTextStorage *_contents;
}
// setContents: is typed to take an id since it accepts either a string or an attributed string.
- (void)setContents:(id)contents;
- (NSTextStorage *)contents;
@end
