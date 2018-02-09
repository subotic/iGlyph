#import "IGInspectorController.h"
#import "HieroglyphsController.h"
#import "WritingDirectionController.h"
#import "FormatGlyphController.h"
#import "CartoucheController.h"
#import "LineController.h"
#import "PageNrController.h"

@implementation IGInspectorController

+ (IGInspectorController *)sharedInspectorController {
    static IGInspectorController *_sharedObjectsController = nil;

    if (!_sharedObjectsController) {
        _sharedObjectsController = [[IGInspectorController allocWithZone:nil] init];
    }
    return _sharedObjectsController;
}

- (instancetype)init {
    self = [self initWithWindowNibName:@"Inspector"];
    if (self) {
        self.windowFrameAutosaveName = @"Inspector";
    }
    [self setShouldCascadeWindows:NO];

    return self;

}

- (void)windowDidLoad {
    DDLogVerbose(@"IGInspectorController(windowDidLoad)");
    [self setInitialInspectorView];
}

- (void)windowWillClose:(NSNotification *)notification {
    DDLogVerbose(@"(InspectorController.m)->Notification received - %@\n", notification.name);
    //[[NSApp delegate] resetMenuItemFlag:INSPECTOR_MENU_TAG];
}

// ===========================================================================
#pragma mark -
#pragma mark bindings stuff
// ============================ bindings stuff ===============================


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"selectedGraphics"]) {
        DDLogVerbose(@"IGInspectorController(observeValueForKeyPath) -> selectedGraphics");

    }
}

// ===========================================================================
#pragma mark -
//#pragma mark 
// ============================ bindings stuff ===============================


- (void)setInitialInspectorView {

    DDLogVerbose(@"IGInspectorController(setInitalInspectorView)");
    [inspectorButtonMatrix selectCellAtRow:0 column:0];
    DDLogVerbose(@"hier0");
    [[WritingDirectionController sharedWritingDirectionController] showWindow:Nil];
    DDLogVerbose(@"hier1");
    [[FormatGlyphController sharedFormatGlyphController] showWindow:Nil];
    DDLogVerbose(@"hier2");
    [[CartoucheController sharedCartoucheController] showWindow:Nil];
    DDLogVerbose(@"hier3");
    [[LineController sharedLineController] showWindow:Nil];
    DDLogVerbose(@"hier4");
    [[PageNrController sharedPageNrController] showWindow:Nil];


    [self changeToSelectedTab:0];
}


- (IBAction)selectedViewChanged:(id)sender {

    NSMatrix *sndr = (NSMatrix *) sender;

    NSUInteger tag = [[sndr selectedCell] tag];
    DDLogVerbose(@"IGInspectorController - selectedViewChanged - tag = %ld", (long) tag);

    [self changeToSelectedTab:tag];

}

- (void)changeToSelectedTab:(NSUInteger)tag {
    //muss zuerst die contenView reseten, damit ich bei der Grössenanpassung nicht die vorhergehende View clippe
    [inspectorBox setContentView:Nil];
    NSView *newContentView = Nil;

    switch (tag) {
        case 0:
            DDLogVerbose(@"Tag 0 -> Writing Direction");
            self.window.title = @"Writing Direction";
            newContentView = [WritingDirectionController sharedWritingDirectionController].controlledView;
            break;

        case 1:
            DDLogVerbose(@"Tag 1 -> Format Glyph");

            self.window.title = @"Format Glyph";
            newContentView = [FormatGlyphController sharedFormatGlyphController].controlledView;
            break;

        case 2:
            DDLogVerbose(@"Tag 2 -> Cartouche");
            self.window.title = @"Cartouche";
            newContentView = [CartoucheController sharedCartoucheController].controlledView;

            break;

        case 3:
            self.window.title = @"Line";
            newContentView = [LineController sharedLineController].controlledView;

            break;

        case 4:
            self.window.title = @"Page Nr.";
            newContentView = [PageNrController sharedPageNrController].controlledView;

            break;

        case 5:
            self.window.title = @"Styles";

            break;

        case 6:
            self.window.title = @"Text";

            break;

        case 7:
            self.window.title = @"Layout";

            break;
    }

    [self resizeInspectorForSelectedView:newContentView];
    inspectorBox.contentView = newContentView;
    [self.window.contentView setNeedsDisplay:YES];
    [self.window setViewsNeedDisplay:YES];
}


- (void)resizeInspectorForSelectedView:(NSView *)selectedView {

    NSRect inspectorWindowRect = self.window.frame;
    NSRect inspectorBoxRect = inspectorBox.frame;
    NSSize minimumInspectorSize = self.window.minSize;

    NSRect selectedViewRect = selectedView.frame;
    if (NSIsEmptyRect(selectedViewRect)) {
        DDLogVerbose(@"selectedViewRect is empty!!!");
        selectedViewRect = NSMakeRect(0, 0, minimumInspectorSize.width, minimumInspectorSize.height - 25);
    }

    //Window size und position anpassen
    //box size und position anpassen

    DDLogVerbose(@"-> inspectorWindowRect: %f, %f, %f, %f", inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height);
    DDLogVerbose(@"-> inspectorBoxRect: %f, %f, %f, %f", inspectorBoxRect.origin.x, inspectorBoxRect.origin.y, inspectorBoxRect.size.width, inspectorBoxRect.size.height);
    DDLogVerbose(@"-> selectedViewRect: %f, %f, %f, %f", selectedViewRect.origin.x, selectedViewRect.origin.y, selectedViewRect.size.width, selectedViewRect.size.height);
    DDLogVerbose(@"-> minimumInspectorSize: %f, %f", minimumInspectorSize.width, minimumInspectorSize.height);


    if (minimumInspectorSize.height > selectedViewRect.size.height) {
        DDLogVerbose(@"neue View ist KLEINER als die Mindestgroesse");

        inspectorWindowRect.origin.y += inspectorWindowRect.size.height - 41 - minimumInspectorSize.height;
        inspectorWindowRect.size.height = minimumInspectorSize.height + 41;

        [self.window setFrame:NSMakeRect(inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height) display:YES animate:YES];

        [inspectorBox setFrameSize:minimumInspectorSize];
    } else {
        DDLogVerbose(@"neue View ist GROESSER als die Mindestgroesse");

        inspectorWindowRect.origin.y += inspectorWindowRect.size.height - 41 - selectedViewRect.size.height;
        inspectorWindowRect.size.height = selectedViewRect.size.height + 41;
        [self.window setFrame:NSMakeRect(inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height) display:YES animate:YES];

        inspectorBoxRect.size.height = selectedViewRect.size.height;
        [inspectorBox setFrameSize:inspectorBoxRect.size];
    }

    DDLogVerbose(@"-> inspectorWindowRect after resize: %f, %f, %f, %f", inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height);
    DDLogVerbose(@"-> inspectorBoxRect after resize: %f, %f, %f, %f", inspectorBoxRect.origin.x, inspectorBoxRect.origin.y, inspectorBoxRect.size.width, inspectorBoxRect.size.height);
}


- (BOOL)canBecomeKeyWindow {
    return TRUE;
}

- (NSBox *)inspectorBox {
    return inspectorBox;
}

- (void)refreshInspector {
    [cartoucheView display];
}


@end
