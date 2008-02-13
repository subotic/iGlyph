#import "IGCenteringClipView.h"

@implementation IGCenteringClipView

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin {
    NSLog(@"IGCenteringClipView(constrainScrollPoint) -> x: %f, y: %f", proposedNewOrigin.x, proposedNewOrigin.y);
    return proposedNewOrigin;
}

@end
