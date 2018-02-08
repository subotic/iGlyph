//
//  IGGlyph.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Tue May 04 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGGlyph.h"
#import "FormatGlyphController.h"
#import "IGGraphicView.h"
#import "WritingDirectionController.h"

@interface NSFont(Exposing_Private_AppKit_Methods)
- (NSGlyph)_defaultGlyphForChar:(unichar)theChar;
@end

@implementation IGGlyph

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDrawsStroke:NO];
        [self setDrawsFill:YES];
        [self setFontName:@"none"];
        [self setTheGlyph:0];
        [self setGlyphASC:0];
        self.fontSize = 25;
        //[self setRubricCartouche:NO];
        [self setMirrored:NO];
        self.angle = 0;
        
        //neue Variablen
        self.stroked = FALSE;
        self.filled = TRUE;
        self.fontSize = 25;
        self.angle = 0;
        self.mirrored = FALSE;
        self.fillColor = [NSColor blackColor];
        
    }
    return self;
}

- (instancetype)copy {
    id newObj = [super copy];

    // Document is not "copied".  The new graphic will need to be inserted into a document.
    [newObj setFontName:[self fontName]];
    [newObj setTheGlyph:[self theGlyph]];
    [newObj setGlyphASC:[self glyphASC]];
    [newObj setFontSize:[self fontSize]];
    [newObj setRubricColor:[self rubricColor]];
    [newObj setMirrored:self.mirrored];
    [newObj setAngle:[self angle]];
    [newObj setGlyphBezPath:[self getOldGlyphBezPath]];

    return newObj;
}

- (void)drawInView:(IGGraphicView *)view isSelected:(BOOL)flag {
    
    NSBezierPath *glyphBezPath;
    
    //Hier ist die Idee den bezierPath neu zu berechnen im Falle das sich die Glyphe geändert hat
    //Wenn sich nur die Position und die Farbe geändert haben, müssen wir nur den alten bezierPath inm
    //neuen bound zentrieren
    if ([self bezPathShouldRecalculate] || ([self getOldGlyphBezPath] == nil)) {
        glyphBezPath = [self glyphBezierPath];
        //NSLog(@"IGGlyph(drawinView)->bezPathShouldRecalculate = YES");
    } else {
        glyphBezPath = [self getOldGlyphBezPath];
        //NSLog(@"IGGlyph(drawinView)->bezPathShouldRecalculate = NO");
    }
    
    //NSBezierPath *glyphBezPath = [self glyphBezierPath];
    
    //das einzige das wir von der Glyphe wissen müssen, ist ihre höhe und breite
    NSRect glyphBoundsRect = glyphBezPath.bounds;
    
    //origin der Bounds, sprich der Umrandung in die nacher die Glyphe dargestellt wird
    NSPoint boundsOrigin = [self bounds].origin;
    //NSLog(@"IGGlyph(drawInView) -> boundsOrigin x: %f, y: %f", boundsOrigin.x, boundsOrigin.y);
    
    //wir wollen den origin unten links haben!!!
    //boundsOrigin.y = boundsOrigin.y - glyphBoundsRect.size.height;
    //NSLog(@"IGGlyph(drawInView) -> boundsOrigin angepasst x: %f, y: %f", boundsOrigin.x, boundsOrigin.y);
    
    //jetzt müssen wir die Glyphe in die vorbereitete Bounds zentrieren
    NSAffineTransform  *centerTrans = [NSAffineTransform transform];
    
    //NSLog(@"IGGlyph(drawInView) -> glyphBezPath VOR flipTrans x: %f, y: %f, w: %f, h: %f", glyphBoundsRect.origin.x, glyphBoundsRect.origin.y, glyphBoundsRect.size.width, glyphBoundsRect.size.height);
    centerTrans.transformStruct = (NSAffineTransformStruct){1, 0, 0, 1, boundsOrigin.x - glyphBoundsRect.origin.x, boundsOrigin.y - glyphBoundsRect.origin.y};
    [glyphBezPath transformUsingAffineTransform:centerTrans];
    
    if (flag) {
        if ([view selectedGraphicCountOfClass:[self class]] == 1) {  //nur diese selected
            [self drawHandlesInView:view];
            if ([self rubricColor]) {
                self.fillColor = [NSColor redColor];
            } else {
                self.fillColor = [NSColor blackColor];
            }
        } else { //mehrere selected
            //NSLog(@"mehrere selected");
            self.fillColor = [NSColor blueColor];
        }
    } else {
        if ([self rubricColor]) {
            self.fillColor = [NSColor redColor];
        } else {
            self.fillColor = [NSColor blackColor];
        }
    }
    
    //NSLog(@"IGGlyph(drawInView) -> BOUNDS x: %f, y: %f, w: %f, h: %f", boundsOrigin.x, boundsOrigin.y, glyphBoundsRect.size.width, glyphBoundsRect.size.height);
    //NSLog(@"IGGlyph(drawInView) -> glyphBezPath nach flipTrans x: %f, y: %f, w: %f, h: %f", [glyphBezPath bounds].origin.x, [glyphBezPath bounds].origin.y, [glyphBezPath bounds].size.width, [glyphBezPath bounds].size.height);
    
    //muss es abschliessen, auf geht in create glyph
    [self setGlyphIsCreating:NO];
    
    [self.fillColor set];
    
    [glyphBezPath fill];
    
    //damit das sicher gesetzt ist. "NO" ist die Ausnahme und sollte nur gesetzt werden falls Glyphe verschoben wird oder die Farbe ändert.
    [self setGlypBezPathShouldRecalculate:NO];
}


- (NSBezierPath *)glyphBezierPath {
    
    //Die ID der gesuchten Glyphe im Font
    NSGlyph theGlyph = [self theGlyph];
    
    //Erstellen einer Bezier Kurve mit der Glyphe dir wir darstellen wollen. Dazu brauchen wir die ID der Glyphe im Font
    //Sie Idee ist das ein bezierPath zu erstellen, welcher unabhängig ist vom Erstellungsort und der fill Farbe
    //So kann ich Ihn dann Verschieben und anders Färben ohne neu erstellen zu müssen
    NSBezierPath *glyphBezPath = [NSBezierPath bezierPath];
    // [glyphBezPath setCachesBezierPath:YES];
    [glyphBezPath moveToPoint:NSMakePoint(0,0)];
    [glyphBezPath appendBezierPathWithGlyph:theGlyph inFont:[self getFont:[self fontName] withSize:self.fontSize]];
    
    //the glyph is still on the head
    //wir müssen ja jede Glyphe flippen da die NSView geflipped ist
    NSAffineTransform  *flipTrans = [NSAffineTransform transform];
    flipTrans.transformStruct = (NSAffineTransformStruct){1, 0, 0, -1, 0, 0};
    
    if (self.mirrored) {
        //Vert Mirror Transformation
        NSAffineTransform  *mirrorTrans = [NSAffineTransform transform];
        mirrorTrans.transformStruct = (NSAffineTransformStruct){-1, 0, 0, 1, 0, 0};
        [flipTrans appendTransform:mirrorTrans];
    }
    
    if (self.angle) {
        //Angle Transformation. muss zum schluss angehängt werden!
        NSAffineTransform * angleTrans = [NSAffineTransform transform];
        [angleTrans rotateByDegrees:self.angle];
        [flipTrans appendTransform:angleTrans];
    }
    
    [glyphBezPath transformUsingAffineTransform:flipTrans]; //mirrored und angle zusammen
    
    
    //Hier werden die alten Bounds and die veränderte Glyphe angepasst
    NSRect newBounds = [self bounds];
    newBounds.size  = glyphBezPath.bounds.size;
    
    
    
    
    //wir wollen den origin unten links haben auch wenn wir die glyphe drehen
    if (!NSEqualSizes(_oldGlyphBoundsSize , newBounds.size)) {
        NSSize temp;
        temp = _oldGlyphBoundsSize;
        _oldGlyphBoundsSize = newBounds.size;
        newBounds.origin.y = newBounds.origin.y + temp.height - newBounds.size.height;
    }
    
    
    [self startBoundsManipulation];
    [self setBounds:newBounds];
    //[self setBoundsDangerous:newBounds];
    [self stopBoundsManipulation];
    
    //der hergestellte path wird zwischengespeichert
    [self setGlyphBezPath:glyphBezPath];
    
    return glyphBezPath;
}

- (BOOL)replaceGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName {
    [self setFontName:fontName];
    [self setTheGlyph:[self getTheGlyph:glyphUniChar forFont:fontName andSize:self.fontSize]]; //um zeit zu Sparen
    [self setGlyphASC:(int)(glyphUniChar - 0xF000)];
    return YES;
}

- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName onPosition:(NSPoint)pos onPage:(NSUInteger)page
{
    // Hier wollen wir die Graphic (in unserem Fall immer eine Glyphe) auf die Cursorposition setzen
    // Dafür müssen wir die aktuelle Cursorposition aus der view abfragen und damit die bounds setzen.
    NSPoint mainCursor = pos;
    //NSLog(@"mainCursor und boundsOrigin müssen gleich sein");
    //NSLog(@"IGGlyph(createGlyph) -> mainCursor x: %f, y: %f", mainCursor.x, mainCursor.y);
    //damit wir die Glyphe auch später (nach save/load, copy/paste, usw.) noch Zeichnen können, muss
    //das Object alle dafür nötigen Angaben in sich speichern.
    [self setFontName:fontName];
    self.fontSize = [[FormatGlyphController sharedFormatGlyphController] fontSize];
    [self setRubricColor:[[FormatGlyphController sharedFormatGlyphController] rubricColor]];
    self.mirrored = [[FormatGlyphController sharedFormatGlyphController] mirrored];
    self.angle = [[FormatGlyphController sharedFormatGlyphController] angle];
    [self setTheGlyph:[self getTheGlyph:glyphUniChar forFont:fontName andSize:self.fontSize]]; //um zeit zu Sparen
    [self setGlyphASC:(int)(glyphUniChar - 0xF000)];
    //ich will nacher die bounds manipulieren aber nur bei neu erstellten glyphen
    //da ich auch glyphen die ich lade darstelle/erstelle, muss ich das unterscheiden können
    [self setGlyphIsCreating:YES];
    
    //Das erste Mal müssen wir die Glyphe erstellen und deren bezPath abspeichern
    NSBezierPath *glyphBezPath = [self glyphBezierPath];
    [self setGlyphBezPath:glyphBezPath];
    
    //Abhängig in welche Richtung die Glyphe geschrieben wird, muss sie ein bisschen anders positioniert werden
    //dies ist deshalb so, da der Cursor je nach Schreibrichtung unten links / unten rechts / oben links die position
    //der nächsten Glyphe anzeigt. Deshalb muss der origin der bounds in der die Glyphe nacher positioniert wird, angepasst werden
    //Dies darf aber nur einmal beim erstellen der Glyphe passieren.
    NSRect glyphBoundsRect = glyphBezPath.bounds;
    NSPoint tempCursor = mainCursor;
    
    int wd = [[WritingDirectionController sharedWritingDirectionController] writingDirection];
    
    if (wd == upToDown | wd == upToDownMirr | wd == upToDownVert | wd == upToDownVertMirr)
    {
        NSLog(@"IGGlyph(createGlyph) -> I'm in down");
        //tempCursor.y = mainCursor.y + glyphBounds.size.height + ( glyphBounds.size.height * 0.15);
        tempCursor.y = mainCursor.y + glyphBoundsRect.size.height;
    }
    
    if (wd == rightToLeft)
    {
        NSLog(@"IGGlyph(createGlyph) -> I'm in left");
        //tempCursor.x = mainCursor.x - glyphBounds.size.width - (glyphBounds.size.width * 0.15);
        tempCursor.x = mainCursor.x - glyphBoundsRect.size.width;
    }
    
    if (wd == leftToRight)
    {
        NSLog(@"IGGlyph(createGlyph) -> I'm in right");
        tempCursor.x = mainCursor.x;
    }
    
    [self startBoundsManipulation];
    //Achtung!!! Origin ist oben links
    [self setBounds:NSMakeRect(tempCursor.x, tempCursor.y - glyphBoundsRect.size.height, glyphBoundsRect.size.width, glyphBoundsRect.size.height)];
    [self stopBoundsManipulation];
    
    NSRect bounds = [self bounds];
    if ((bounds.size.width > 0.0) || (bounds.size.height > 0.0)) {
        //NSLog(@"IGGlyph(createGlyph) -> BOUNDS abgefragt und OK: YES");
        //NSLog(@"IGGlyph(createGlyph) -> BOUNDS x: %f, y: %f, w: %f, h: %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
        //NSLog(@"sehe ich den fontname %@", [self fontName]);
        return YES;
    } else {
        //NSLog(@"BOUNDS abgefragt und OK: NO");
        return NO;
    }
}

// FIXME: this implementation is missing but I don't know why and how it should be correctly implemented
- (BOOL)createGlyph:(unichar)glyphUniChar withFont:(NSString *)fontName inView:(IGGraphicView *)view
{
    return [self createGlyph:glyphUniChar withFont:fontName onPosition:NSZeroPoint onPage:view.currentPage];
}


NSString *IGFontNameKey = @"FontName";
NSString *IGTheGlyphKey = @"TheGlyph";
NSString *IGGlyphASCKey = @"GlyphASC"; //dieser Wert ist im PC Format gespeichert
NSString *IGFontSizeKey = @"FontSize";
NSString *IGGlyphRubricColorKey = @"GlyphRubricColor";
NSString *IGMirroredKey = @"Mirrored";
NSString *IGAngleKey = @"Angle";


- (NSMutableDictionary *)propertyListRepresentation {
    NSMutableDictionary *dict = [super propertyListRepresentation];
    
    dict[IGFontNameKey] = [self fontName];
    dict[IGTheGlyphKey] = [NSString stringWithFormat:@"%i", [self theGlyph]];
    dict[IGGlyphASCKey] = [NSString stringWithFormat:@"%i", [self glyphASC]];
    dict[IGFontSizeKey] = [NSString stringWithFormat:@"%ld", (long)self.fontSize];
    dict[IGGlyphRubricColorKey] = ([self rubricColor] ? @"YES" : @"NO");
    dict[IGMirroredKey] = (self.mirrored ? @"YES" : @"NO");
    dict[IGAngleKey] = [NSString stringWithFormat:@"%ld", (long)self.angle];
    
    return dict;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentation:dict];
    
    obj = dict[IGFontNameKey];
    if (obj) {
        [self setFontName:obj];
    }
    obj = dict[IGTheGlyphKey];
    if (obj) {
        [self setTheGlyph:[obj intValue]];
    }
    obj = dict[IGGlyphASCKey];
    if (obj) {
        [self setGlyphASC:[obj intValue]];
    }
    obj = dict[IGFontSizeKey];
    if (obj) {
        self.fontSize = [obj integerValue];
    }
    obj = dict[IGGlyphRubricColorKey];
    if (obj) {
        [self setRubricColor:([obj isEqualToString:@"YES"] ? 1 : 0)];
    }
    obj = dict[IGMirroredKey];
    if (obj) {
        self.mirrored = ([obj isEqualToString:@"YES"] ? 1 : 0);
    }
    obj = dict[IGAngleKey];
    if (obj) {
        self.angle = [obj intValue];
    }
    return;
}

- (void)loadPropertyListRepresentationFromPC:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentationFromPC:dict];
    
    obj = dict[IGFontNameKey];
    if (obj) {
        [self setFontName:obj];
    }
    obj = dict[IGTheGlyphKey];
    if (obj) {
        [self setTheGlyph:[obj intValue]];
    }
    obj = dict[IGGlyphASCKey];
    if (obj) {
        [self setGlyphASC:[obj intValue]];
    }
    obj = dict[IGFontSizeKey];
    if (obj) {
        self.fontSize = [obj integerValue];
    }
    obj = dict[IGGlyphRubricColorKey];
    if (obj) {
        [self setRubricColor:([obj isEqualToString:@"YES"] ? 1 : 0)];
    }
    obj = dict[IGMirroredKey];
    if (obj) {
        self.mirrored = ([obj isEqualToString:@"YES"] ? 1 : 0);
    }
    obj = dict[IGAngleKey];
    if (obj) {
        self.angle = [obj intValue];
    }
    
    //nun habe ich alle Werte an ihrem Ort. Jetzt muss ich theGlyph richtig berechnen,
    //da ich im Moment dort den ASC Wert habe
    unichar tmpUnichar = [self glyphASC] + 0xF000;
    [self setTheGlyph:[self getTheGlyph:tmpUnichar forFont:[self fontName] andSize:self.fontSize]];
    
    return;
}

- (NSGlyph)getTheGlyph:(unichar)glyphUniChar forFont:(NSString *)fontName andSize:(float)size
{
    NSGlyph theGlyph = [[self getFont:fontName withSize:size] _defaultGlyphForChar:glyphUniChar];
    
    return theGlyph;
}

- (NSFont *)getFont:(NSString *)name withSize:(float)size
{
    if ([NSFont fontWithName:name size:size])
    {
        return [NSFont fontWithName:name size:size];
    }
    else
    {
        NSLog(@"FONT NICHT VERFUEGBAR name: %@ , groesse: %f ", name, size);
    }
    return [NSFont systemFontOfSize:size];
}

- (NSUInteger)knobMask {
    return LowerLeftKnobMask;
    //return AllKnobsMask;
}
@end
