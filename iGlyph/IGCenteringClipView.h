/* IGCenteringClipView */

#import <Cocoa/Cocoa.h>

@interface IGCenteringClipView : NSClipView
{
}

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin;

@end
