//
//  IGRenderingView.m
//  VisualGlyph
//
//  Created by Ivan Subotic on Wed May 05 2004.
//  Copyright (c) 2004 Ivan Subotic. All rights reserved.
//

#import "IGRenderingView.h"
#import "IGGraphic.h"
#import "IGDrawDocument.h"

@implementation IGRenderingView

@synthesize graphics;
@synthesize pageCount;
@synthesize drawDocument;

- (instancetype)initWithFrame:(NSRect)frame graphics:(NSArray *)graphicsArr pageCount:(unsigned)count document:(IGDrawDocument *)document {
    self = [super initWithFrame:frame];
    if (self) {
        self.graphics = graphicsArr;
        self.pageCount = count;
        self.drawDocument = document;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSPrintInfo *)drawDocumentPrintInfo {
    return (self.drawDocument).printInfo;
}

- (NSRect)pageHeaderRect {
    NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
    NSRect rect = NSZeroRect;
    rect.size.width = printInfo.paperSize.width;
    rect.size.height = printInfo.topMargin;
    return rect;
}

- (NSRect)pageFooterRect {
    NSPrintInfo *printInfo = [self drawDocumentPrintInfo];
    NSRect rect = NSZeroRect;
    rect.size.width = printInfo.paperSize.width;
    rect.size.height = printInfo.bottomMargin;
    rect.origin.y = printInfo.paperSize.height - rect.size.height;
    return rect;
}


- (void)drawRect:(NSRect)rect {
    int i;
    NSArray *curPageGraphics;
    IGGraphic *curGraphic;
    NSRect drawingBounds;
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    //NSAffineTransform *transform;
    //NSRect paperSizeRect = [self frame];
    
    
    
    
    [[NSColor whiteColor] set];
    NSRectFill(rect);
    
    if (self.pageCount) { //hier will ich mehrere Seiten darstellen
        int curPage;
        curPage = [NSPrintOperation currentOperation].currentPage;
        //header
        curPageGraphics = (self.graphics)[0];
        i = curPageGraphics.count;
        while (i-- > 0) {
            curGraphic = curPageGraphics[i];
            drawingBounds = [curGraphic drawingBounds];
            if (NSIntersectsRect(rect, drawingBounds)) {
                [currentContext saveGraphicsState];
                [NSBezierPath clipRect:drawingBounds];
                [curGraphic drawInView:nil isSelected:NO];
                [currentContext restoreGraphicsState];
            }
        }
        //body
        curPageGraphics = (self.graphics)[curPage];
        i = curPageGraphics.count;
        while (i-- > 0) {
            curGraphic = curPageGraphics[i];
            drawingBounds = [curGraphic drawingBounds];
            if (NSIntersectsRect(rect, drawingBounds)) {
                [currentContext saveGraphicsState];
                [NSBezierPath clipRect:drawingBounds];
                [curGraphic drawInView:nil isSelected:NO];
                [currentContext restoreGraphicsState];
            }
        }
        
        
        //----------------anfang pagenumers----------------        
        //Page Numbers
        //nicht vergessen die printversion auch anzupassen
        if ([self.drawDocument showPageNumbers]) {
            NSPrintInfo *printInfo = [self drawDocumentPrintInfo]; 
            
            
            NSMutableDictionary *pageNrAttribsDict = [NSMutableDictionary dictionary];
            NSMutableString *pnMutableString = [[NSMutableString alloc] init];
            
            NSString *pnFontName = [self.drawDocument pageNumberFont];
            float pnFontSize = [self.drawDocument pageNumberSize];
            int pnStyle = [self.drawDocument pageNumberStyle];
            NSMutableArray *pnFormatArr = [self.drawDocument pageNumberFormatArr];
            int initialPageNumber = [self.drawDocument initialPageNr]; //die Zahl ab welcher gezählt werden soll
            int firstPageNumberToShow = [self.drawDocument firstPageNumberToShow]; //die erste Seite ab wann angezeigt werden soll
            
            int pageNrAlignment = [self.drawDocument pageNrAlignment];
            int pageNrPosition = [self.drawDocument pageNrPosition];
            
            signed int pnNumberToShow = curPage - firstPageNumberToShow + initialPageNumber;
            
            NSLog(@"IGGraphicView(drawRect) -> pnStyle= %i", pnStyle);
            //Fontname and Size... fehlt nur noch Style
            NSFont *pnFont = [NSFont fontWithName:pnFontName size:pnFontSize];
            if (pnStyle == 1) {
                NSLog(@"IGGraphicView(drawRect) -> BoldFontFace");
                [pnFont autorelease];
                pnFont = [[NSFontManager sharedFontManager] convertFont:pnFont toHaveTrait:NSBoldFontMask];
            } else if (pnStyle == 2) {
                NSLog(@"IGGraphicView(drawRect) -> ItalicFontFace");
                [pnFont autorelease];
                pnFont = [[NSFontManager sharedFontManager] convertFont:pnFont toHaveTrait:NSItalicFontMask];
            }
            
            if (pnFont == nil) {
                pnFont = [NSFont fontWithName:@"Arial" size:pnFontSize];
            }
            pageNrAttribsDict[NSFontAttributeName] = pnFont;
            
            
            //links von der Seitenzahl
            if (![pnFormatArr[0] isEqualTo:@""]) {
                [pnMutableString insertString:pnFormatArr[0] atIndex:0];
            }
            //die Seitenzahl
            [pnMutableString appendString:[NSString stringWithFormat:@"%i", pnNumberToShow]];
            //rechts von der Seitenzahl
            if (![pnFormatArr[1] isEqualTo:@""]) {
                [pnMutableString appendString:pnFormatArr[1]];
            }
            
            
            NSPoint pnPosition = NSZeroPoint;
            int pnAlternate = initialPageNumber & 1; //gibt scheinbar 0 oder 1..... 0 falls gerade zahl...
            
            //NSMutableParagraphStyle *myParaStyle = [[NSMutableParagraphStyle alloc] init];
            //anpassen in X
            if (pageNrAlignment == 0) { //left
                pnPosition.x = printInfo.rightMargin;
            } else if (pageNrAlignment == 1) { //center
                pnPosition.x = NSMidX([self pageHeaderRect]) - pnFontSize + 2;
                
            } else if (pageNrAlignment == 2) { //right
                pnPosition.x = printInfo.paperSize.width - printInfo.rightMargin - pnFontSize;
                //[myParaStyle setAlignment:NSRightTextAlignment];
                
            } else if (pageNrAlignment == 3) { //alternate
                if (pnAlternate == (pnNumberToShow & 1)) {//rechts
                    pnPosition.x = printInfo.paperSize.width - printInfo.rightMargin - pnFontSize;
                } else {//links
                    pnPosition.x = printInfo.rightMargin;
                }
            } else {
                NSAssert(0, @"Houston we have a problem");
            }
            
            //anpassen in Y
            if (pageNrPosition == 0) { //Header
                
                pnPosition.y = NSMidY([self pageHeaderRect]);
                
            } else { //Footer
                pnPosition.y = NSMidY([self pageFooterRect]);
            }
            
            //anpassen um die fontgrösse
            pnPosition.y -= pnFontSize;
            
            //PNr finetune
            NSSize pnDelta = [self.drawDocument pnDeltaPosition];
            pnPosition.x += pnDelta.width;
            pnPosition.y += pnDelta.height;
            
            //[pageNrAttribsDict setObject:myParaStyle forKey:NSParagraphStyleAttributeName];
            NSAttributedString *pageNumberObject = [[NSAttributedString alloc] initWithString:pnMutableString attributes:pageNrAttribsDict];
            
            //damit die Seitenzahl erst aber der gewünschten Seite angezeigt wird
            if (curPage >= firstPageNumberToShow) {
                [pageNumberObject drawAtPoint:pnPosition];
            }
            
            [pnMutableString release];
        }
        //----------------ende pagenumers---------------- 
        
        
    } else { //der fall wo ich nur eine auswahl von graphics darstellen will zBsp bei der PDFRepresantation
        i = (self.graphics).count;
        while (i-- > 0) {
            curGraphic = (self.graphics)[i];
            drawingBounds = [curGraphic drawingBounds];
            if (NSIntersectsRect(rect, drawingBounds)) {
                [currentContext saveGraphicsState];
                [NSBezierPath clipRect:drawingBounds];
                [curGraphic drawInView:nil isSelected:NO];
                [currentContext restoreGraphicsState];
            }
        }
    }
}

- (NSRect)rectForPage:(int)page {
    return NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
}

- (BOOL)knowsPageRange:(NSRangePointer)aRange {
    aRange->location = 1;
    aRange->length = (self.pageCount == 0 ? 1 : self.pageCount); //dieser murks ist nötig da ich oben pageCount = 0 setze wenn ich nur eine selection drucken möchte, weshalb ich es hier wieder richten muss
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)isFlipped {
    return YES;
}

@end
