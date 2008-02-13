#import "IGInspectorController.h"
#import "HieroglyphsController.h"
#import "WritingDirectionController.h"
#import "FormatGlyphController.h"
#import "CartoucheController.h"
#import "LineController.h"
#import "PageNrController.h"

@implementation IGInspectorController

+ (id)sharedInspectorController
{
  static IGInspectorController *_sharedObjectsController = nil;
  
  if (!_sharedObjectsController) {
    _sharedObjectsController = [[IGInspectorController allocWithZone:[self zone]] init];
  }
  return _sharedObjectsController;
}

- (id)init
{
  self = [self initWithWindowNibName:@"Inspector"];
  if (self) {
    [self setWindowFrameAutosaveName:@"Inspector"];
  }
  [self setShouldCascadeWindows:NO];
  
  return self;
  
}

- (void)windowDidLoad {
  NSLog(@"IGInspectorController(windowDidLoad)");
  [self setInitialInspectorView];
}

- (void)windowWillClose:(NSNotification *)notification
{
  NSLog(@"(InspectorController.m)->Notification received - %@\n", [notification name]);
  //[[NSApp delegate] resetMenuItemFlag:INSPECTOR_MENU_TAG];
}

// ===========================================================================
#pragma mark -
#pragma mark bindings stuff
// ============================ bindings stuff ===============================


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqual:@"selectedGraphics"]) {
    NSLog(@"IGInspectorController(observeValueForKeyPath) -> selectedGraphics");
    
  }
}

// ===========================================================================
#pragma mark -
//#pragma mark 
// ============================ bindings stuff ===============================


- (void)setInitialInspectorView
{ 
  
  NSLog(@"IGInspectorController(setInitalInspectorView)");
  [inspectorButtonMatrix selectCellAtRow:0 column:0];
  NSLog(@"hier0");
  [[WritingDirectionController sharedWritingDirectionController] showWindow:Nil];
  NSLog(@"hier1");
  [[FormatGlyphController sharedFormatGlyphController] showWindow:Nil];
  NSLog(@"hier2");
  [[CartoucheController sharedCartoucheController] showWindow:Nil];
  NSLog(@"hier3");
  [[LineController sharedLineController] showWindow:Nil];
  NSLog(@"hier4");
  [[PageNrController sharedPageNrController] showWindow:Nil];
  
  
  [self changeToSelectedTab: 0];
}


- (IBAction)selectedViewChanged:(id)sender
{
  
  int tag = [[sender selectedCell] tag];
  NSLog(@"Tag = %i", tag);
  
  [self changeToSelectedTab: tag];
  
}

- (void)changeToSelectedTab:(int)tag
{
  //muss zuerst die contenView reseten, damit ich bei der Grössenanpassung nicht die vorhergehende View clippe
  [inspectorBox setContentView: Nil];
  NSView *newContentView = Nil;
  
  switch (tag) 
  {
    case 0:
      NSLog(@"Tag 0 -> Writing Direction");
      [[self window] setTitle:@"Writing Direction"];
      newContentView = [[WritingDirectionController sharedWritingDirectionController] controlledView];
      break;
      
    case 1:
      NSLog(@"Tag 1 -> Format Glyph");
      
      [[self window] setTitle:@"Format Glyph"];
      newContentView = [[FormatGlyphController sharedFormatGlyphController] controlledView];
      break;
      
    case 2:
      NSLog(@"Tag 2 -> Cartouche");
      [[self window] setTitle:@"Cartouche"];
      newContentView = [[CartoucheController sharedCartoucheController] controlledView];
      
      break;
      
    case 3:
      [[self window] setTitle:@"Line"];
      newContentView = [[LineController sharedLineController] controlledView];
      
      break;
      
    case 4:
      [[self window] setTitle:@"Page Nr."];
      newContentView = [[PageNrController sharedPageNrController] controlledView];
      
      break;
      
    case 5:
      [[self window] setTitle:@"irgendwas"];
      //newContentView = cartoucheView;
      
      break;
      
    case 6:
      [[self window] setTitle:@"Text"];
      
      break;
      
    case 7:
      [[self window] setTitle:@"Layout"];
      
      break;
  }
  
  [self resizeInspectorForSelectedView:newContentView];
  [inspectorBox setContentView: newContentView];
  [[[self window] contentView] setNeedsDisplay:YES];
  [[self window] setViewsNeedDisplay:YES];
}


- (void)resizeInspectorForSelectedView:(NSView *)selectedView 
{
  
  NSRect inspectorWindowRect = [[self window] frame];
  NSRect inspectorBoxRect = [inspectorBox frame];
  NSSize minimumInspectorSize = [[self window] minSize];
  
  NSRect selectedViewRect = [selectedView frame];
  if (NSIsEmptyRect(selectedViewRect)) {
    NSLog(@"selectedViewRect is empty!!!");
    selectedViewRect = NSMakeRect(0, 0, minimumInspectorSize.width, minimumInspectorSize.height - 25);
  }
  
  //Window size und position anpassen
  //box size und position anpassen
  
  NSLog (@"-> inspectorWindowRect: %f, %f, %f, %f", inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height);
  NSLog (@"-> inspectorBoxRect: %f, %f, %f, %f", inspectorBoxRect.origin.x, inspectorBoxRect.origin.y, inspectorBoxRect.size.width, inspectorBoxRect.size.height);
  NSLog (@"-> selectedViewRect: %f, %f, %f, %f", selectedViewRect.origin.x, selectedViewRect.origin.y, selectedViewRect.size.width, selectedViewRect.size.height);
  NSLog (@"-> minimumInspectorSize: %f, %f", minimumInspectorSize.width, minimumInspectorSize.height);
  
  
  if (minimumInspectorSize.height > selectedViewRect.size.height) {
    NSLog(@"neue View ist KLEINER als die Mindestgroesse");
    
    inspectorWindowRect.origin.y += inspectorWindowRect.size.height - 41 - minimumInspectorSize.height;
    inspectorWindowRect.size.height = minimumInspectorSize.height + 41;
    
    [[self window] setFrame:NSMakeRect(inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height) display:YES animate:YES];
    
    [inspectorBox setFrameSize:minimumInspectorSize];
  } else {
    NSLog(@"neue View ist GROESSER als die Mindestgroesse");
    
    inspectorWindowRect.origin.y += inspectorWindowRect.size.height - 41 - selectedViewRect.size.height;
    inspectorWindowRect.size.height = selectedViewRect.size.height + 41;
    [[self window] setFrame:NSMakeRect(inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height) display:YES animate:YES];
    
    inspectorBoxRect.size.height = selectedViewRect.size.height;
    [inspectorBox setFrameSize:inspectorBoxRect.size];
  }
  
  NSLog (@"-> inspectorWindowRect after resize: %f, %f, %f, %f", inspectorWindowRect.origin.x, inspectorWindowRect.origin.y, inspectorWindowRect.size.width, inspectorWindowRect.size.height);
  NSLog (@"-> inspectorBoxRect after resize: %f, %f, %f, %f", inspectorBoxRect.origin.x, inspectorBoxRect.origin.y, inspectorBoxRect.size.width, inspectorBoxRect.size.height);
}


- (BOOL)canBecomeKeyWindow {
  return TRUE;
}

- (NSBox *)inspectorBox
{
  return inspectorBox;
}

- (void)refreshInspector
{
  [cartoucheView display];
}


@end
