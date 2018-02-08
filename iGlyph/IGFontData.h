/* IGFontData */

/*!
   @class IGFontData
   @abstract reading the IG_GlyphCodes.txt.
   @discussion An NSPrinter object describes a printer's capabilities, such as whether the printer can print in color and whether it provides a particular font. An NSPrinter object represents...  
*/


#import <Cocoa/Cocoa.h>

@interface IGFontData : NSObject
{
    
    NSMutableArray *_glyphGroupsArr;
    NSMutableDictionary *_fontDataDic;
    NSMutableDictionary *_ggGlyphDic; //dictionary mit key = glyphSymbol (z.B. A2) und object = array(fontChar, font)
    NSMutableDictionary *_glyphLauteDic; //dictionary mit key = glyph laut (z.B. bz) und object = array(fontChar, font)
    NSMutableDictionary *_fontsDic; //fontname und int nummer

}

/*! 
   @method sharedFontGroupData   
   @abstract Creates and returns a calendar date initialized with the date 
             specified in the string description. 
   @discussion [An extended description of the method...]
   @param description  A string specifying the date.
   @param format  Conversion specifiers similar to those used in strftime().
   @result  Returns the newly initialized date object or nil on error.
*/

+ (instancetype)sharedFontData;

- (void)readVGGlyphCodes;

@property (NS_NONATOMIC_IOSONLY, getter=getGlyphGroups, readonly, copy) NSMutableArray *glyphGroups;
@property (NS_NONATOMIC_IOSONLY, getter=getFontData, readonly, copy) NSMutableDictionary *fontData;

- (NSString *)getFontNameFromIntValue:(NSString *)fontNameIntValue;

@property (NS_NONATOMIC_IOSONLY, getter=getGGGlyphDic, readonly, copy) NSMutableDictionary *GGGlyphDic;
@property (NS_NONATOMIC_IOSONLY, getter=getGlyphLauteDic, readonly, copy) NSMutableDictionary *glyphLauteDic;

- (NSArray *)getGlyphForSymbols:(NSArray *)symbolStringArray;
- (NSArray *)getGlyphForSymbol:(NSString *)symbolString;

@end

@interface NSFont(Exposing_Private_AppKit_Methods)
- (NSGlyph)_defaultGlyphForChar:(unichar)theChar;
@end
