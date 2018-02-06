/* IGInspectorController */

#import <Cocoa/Cocoa.h>
#import "IGEdgeDockablePanel.h"

@interface IGInspectorController : NSWindowController
{
    IBOutlet NSMatrix *inspectorButtonMatrix;
    IBOutlet NSBox *inspectorBox;
    
    IBOutlet NSView *cartoucheView;
    
}

+ (IGInspectorController*)sharedInspectorController;

- (void)setInitialInspectorView;

- (IBAction)selectedViewChanged:(id)sender;
- (void)changeToSelectedTab:(int)tag;

- (void)resizeInspectorForSelectedView:(NSView *)selectedView;

- (void)refreshInspector;


@end
