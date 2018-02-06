//
//  IGZoomScrollView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Mon Jun 7 2004.
//  Copyright (c) 2003 Ivan Subotic. All rights reserved.
//

#import "IGZoomScrollView.h"
#import "IGGraphicView.h"
#import "IGBackgroundView.h"
#import "IGSupView.h"

static NSString *_NSDefaultScaleMenuLabels[] = {/* @"Set...", */ @"10%", @"25%", @"50%", @"75%", @"100%", @"128%", @"200%", @"400%", @"800%", @"1600%"};
static float _NSDefaultScaleMenuFactors[] = {/* 0.0, */ 0.1, 0.25, 0.5, 0.75, 1.0, 1.28, 2.0, 4.0, 8.0, 16.0};
static unsigned _NSDefaultScaleMenuSelectedItemIndex = 4;
static float _NSScaleMenuFontSize = 10.0;

@implementation IGZoomScrollView

- (instancetype)initWithFrame:(NSRect)theFrame {
    self = [super initWithFrame:theFrame];
    self.backgroundColor = [NSColor lightGrayColor];
    scaleFactor = 1.0;
    return self;
}

- (void)makeScalePopUpButton {
    if (_scalePopUpButton == nil) {
        unsigned cnt, numberOfDefaultItems = (sizeof(_NSDefaultScaleMenuLabels) / sizeof(NSString *));
        id curItem;
        
        // create it
        _scalePopUpButton = [[NSPopUpButton allocWithZone:nil] initWithFrame:NSMakeRect(0.0, 0.0, 1.0, 1.0) pullsDown:NO];
        _scalePopUpButton.bezelStyle = NSShadowlessSquareBezelStyle;
        NSPopUpButtonCell *popupCell = _scalePopUpButton.cell;
        popupCell.arrowPosition = NSPopUpArrowAtBottom;
        
        // fill it
        for (cnt = 0; cnt < numberOfDefaultItems; cnt++) {
            [_scalePopUpButton addItemWithTitle:NSLocalizedStringFromTable(_NSDefaultScaleMenuLabels[cnt], @"ZoomValues", nil)];
            curItem = [_scalePopUpButton itemAtIndex:cnt];
            if (_NSDefaultScaleMenuFactors[cnt] != 0.0) {
                [curItem setRepresentedObject:@(_NSDefaultScaleMenuFactors[cnt])];
            }
        }
        [_scalePopUpButton selectItemAtIndex:_NSDefaultScaleMenuSelectedItemIndex];
        
        // hook it up
        _scalePopUpButton.target = self;
        _scalePopUpButton.action = @selector(scalePopUpAction:);
        
        // set a suitable font
        _scalePopUpButton.font = [NSFont toolTipsFontOfSize:_NSScaleMenuFontSize];
        
        // Make sure the popup is big enough to fit the cells.
        [_scalePopUpButton sizeToFit];
        
    // don't let it become first responder
    [_scalePopUpButton setRefusesFirstResponder:YES];
        
        // put it in the scrollview
        [self addSubview:_scalePopUpButton];
    }
}

- (void)awakeFromNib {
    
    [self setHasHorizontalRuler:YES];
    [self setHasVerticalRuler:YES];
    [self setHasHorizontalScroller:YES];
    [self setHasVerticalScroller:YES];
    self.borderType = ((NSInterfaceStyleForKey(nil, self) == NSWindows95InterfaceStyle) ? NSBezelBorder : NSNoBorder);
    
    /**
    int count = [[[self documentView] subviews] count];
    [graphicView setFrame:NSMakeRect(0.0,250.0*count,[[self documentView] frame].size.width,250.0)];
    [[self documentView] addSubview:graphicView];
    
    [graphicView setFrame:NSMakeRect(150.0,250.0*count,[[self documentView] frame].size.width,250.0)];
    [[self documentView] addSubview:graphicView];
    
    [self setLineScroll:250.0];
    [self setPageScroll:250.0];
    [self setAutoresizesSubviews:YES];
    
    [[self documentView] setFrame:NSMakeRect(0.0,0.0,[[self documentView] frame].size.width,250.0*(count+1))];
    **/ 
    
    self.documentView = graphicView;
    
    
    //[graphicView setPrintInfo:[self printInfo]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self.window];
}

- (void)windowDidResize:(NSNotification *)aNotification { 
    //NSLog(@"IGZoomScrollView(windowDidResize)"); // yes, this does run. 
    
    NSWindow *window = aNotification.object;
    NSSize windowSize = window.frame.size; 
    NSSize contentSize = self.documentView.frame.size; 
    NSPoint frameOrigin; 
    
    frameOrigin.x = frameOrigin.y = 0.0; 
    
    if ( windowSize.width >= contentSize.width ) {
        frameOrigin.x=(int)((windowSize.width - contentSize.width)/2);
    }
    
    if ( windowSize.height >= contentSize.height ) {
        frameOrigin.y=(int)((windowSize.height - contentSize.height)/2);
    }
    
    //[[zoomScrollView documentView] setFrameOrigin:frameOrigin];
    //[[zoomScrollView contentView] setFrameOrigin:NSMakePoint(20, 20)];
    //NSLog(@"IGoomScrollView(windowDidResize) ->frame %f, %f, %f, %f", [[self contentView] frame].origin.x, [[self contentView] frame].origin.y, [[self contentView] frame].size.width, [[self contentView] frame].size.height);
    //[[self contentView] setFrameOrigin:frameOrigin];
}

- (void)tile {
    // Let the superclass do most of the work.
    [super tile];
    
    if (!self.hasHorizontalScroller) {
        if (_scalePopUpButton) [_scalePopUpButton removeFromSuperview];
        _scalePopUpButton = nil;
    } else {
    NSScroller *horizScroller;
    NSRect horizScrollerFrame, buttonFrame;
    
        if (!_scalePopUpButton) [self makeScalePopUpButton];
        
        horizScroller = self.horizontalScroller;
        horizScrollerFrame = horizScroller.frame;
        buttonFrame = _scalePopUpButton.frame;
        
        // Now we'll just adjust the horizontal scroller size and set the button size and location.
        horizScrollerFrame.size.width = horizScrollerFrame.size.width - buttonFrame.size.width;
        [horizScroller setFrameSize:horizScrollerFrame.size];
        
        buttonFrame.origin.x = NSMaxX(horizScrollerFrame);
        buttonFrame.size.height = horizScrollerFrame.size.height + 1.0;
        buttonFrame.origin.y = self.bounds.size.height - buttonFrame.size.height + 1.0;
        _scalePopUpButton.frame = buttonFrame;
    }
}

- (void)drawRect:(NSRect)rect {
    NSRect verticalLineRect;
    
    [super drawRect:rect];
    
    if (_scalePopUpButton.superview) {
        verticalLineRect = _scalePopUpButton.frame;
        verticalLineRect.origin.x -= 1.0;
        verticalLineRect.size.width = 1.0;
        if (NSIntersectsRect(rect, verticalLineRect)) {
            [[NSColor blackColor] set];
            NSRectFill(verticalLineRect);
        }
    }
}

- (void)scalePopUpAction:(id)sender {
    NSNumber *selectedFactorObject = [[sender selectedCell] representedObject];
    
    if (selectedFactorObject == nil) {
        NSLog(@"Scale popup action: setting arbitrary zoom factors is not yet supported.");
        return;
    } else {
        [self setScaleFactor:selectedFactorObject.floatValue adjustPopup:NO];
    }
}

- (float)scaleFactor {
    return scaleFactor;
}

- (void)setScaleFactor:(float)newScaleFactor adjustPopup:(BOOL)flag {
    if (scaleFactor != newScaleFactor) {
    NSSize curDocFrameSize, newDocBoundsSize;
    NSView *clipView = self.documentView.superview;
    
        if (flag) {    // Coming from elsewhere, first validate it
            unsigned cnt = 0, numberOfDefaultItems = (sizeof(_NSDefaultScaleMenuFactors) / sizeof(float));
            
            // We only work with some preset zoom values, so choose one of the appropriate values (Fudge a little for floating point == to work)
            while (cnt < numberOfDefaultItems && newScaleFactor * .99 > _NSDefaultScaleMenuFactors[cnt]) cnt++;
            if (cnt == numberOfDefaultItems) cnt--;
            [_scalePopUpButton selectItemAtIndex:cnt];
            scaleFactor = _NSDefaultScaleMenuFactors[cnt];
        } else {
            scaleFactor = newScaleFactor;
        }
    
    // Get the frame.  The frame must stay the same.
    curDocFrameSize = clipView.frame.size;
    
    // The new bounds will be frame divided by scale factor
    newDocBoundsSize.width = curDocFrameSize.width / scaleFactor;
    newDocBoundsSize.height = curDocFrameSize.height / scaleFactor;
    
    [clipView setBoundsSize:newDocBoundsSize];
    }
}

- (void)setHasHorizontalScroller:(BOOL)flag {
    if (!flag) [self setScaleFactor:1.0 adjustPopup:NO];
    super.hasHorizontalScroller = flag;
}

@end
