#import "IGCenteringClipView.h"

@implementation IGCenteringClipView

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin {
    DDLogVerbose(@"IGCenteringClipView(constrainScrollPoint) -> x: %f, y: %f", proposedNewOrigin.x, proposedNewOrigin.y);
    return proposedNewOrigin;
}

@end
