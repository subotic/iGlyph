
#import "IGFontData.h"

@implementation IGFontData

static IGFontData *_sharedFontData = nil;

+ (id)sharedFontData
{
    if (!_sharedFontData)
    {
        _sharedFontData = [[self allocWithZone:[self zone]] init];
    }
    
    return _sharedFontData;
}

- (id)init
{
    self = [super init];
    NSLog(@"IGFontData(init)");
    
    //int n = [_fontDataDic count];
    //NSLog(@"Die Anzahl der Einträge ist: %d", n);
    
    _glyphGroupsArr = [[NSMutableArray alloc]init];
    _fontDataDic = [[NSMutableDictionary alloc] init];
    _ggGlyphDic = [[NSMutableDictionary alloc] init];
    _glyphLauteDic = [[NSMutableDictionary alloc] init];
    _fontsDic = [[NSMutableDictionary alloc] init];
    
    [self readVGGlyphCodes];
    
    return self;
}

-(void)readVGGlyphCodes
{
    //should create a few NSMutableArrays with the contents of IG_GlyphCodes.txt
    NSLog(@"IGFontData(readVGGlyphCodes)");
    
    NSString *filePath, *resPath, *fileString, *zeilenString;
    NSRange r, rr;
    unsigned start, end1, end2;
    int part, linecnt;
	
    resPath = [[NSBundle mainBundle] resourcePath];
    filePath = [resPath stringByAppendingString:@"/IG_GlyphCodes.txt"];
    
    fileString = [NSString stringWithContentsOfFile:filePath];
    
    if (!fileString) {
        NSLog(@"IG_GlyphCodes.txt not found at path: %@", filePath);
    }
    
    NSString *active_group = nil;
    NSMutableArray *rows = nil;
	
    linecnt = 0;
    part = 0; // we start before header information;
    end1 = 1;
    while (end1 < [fileString length]) {
        r.location = end1;
        r.length = 1;
        [fileString getLineStart:&start end:&end1 contentsEnd:&end2 forRange:r];
        rr.location = start;
        rr.length = end2 - start;
        zeilenString = [fileString substringWithRange:rr];
        linecnt++;
		
            if ([zeilenString length] == 0) continue; //skip empty lines....
            if (part == 0) {
			if ([zeilenString isEqualToString:@"[Visual Glyph]"]) {
				//
				// we got to the header info
				//
				part = 1;
				NSLog (@"VisualGlyph header found!");
			}
		}
		else if (part == 1) {
			if ([zeilenString isEqualToString:@"[Fonts]"]) {
				//
				// we got to the font part
				//
				part = 2;
			}
			else {
				//
				// process the header info (e.g. version string...)
				//
				const char *cstr = [zeilenString cString];
				char version[32];
				
				if (sscanf (cstr, "Version=%s", version) == 1) {
					[_fontDataDic setObject:[NSString stringWithCString:version] forKey:@"Version"];
				}
				else {
					NSLog (@"Header: %@", zeilenString);
				}
			}
		}
		else if (part == 2) {
			if ([zeilenString isEqualToString:@"[Signs]"]) {
				//
				// we got to the list of signs...
				//
				part = 3;
			}
			else {
				//
				// let's process the font list...
				//
				NSArray *listItems = [zeilenString componentsSeparatedByString:@"="];
				[_fontsDic setObject:[listItems objectAtIndex:1] forKey:[listItems objectAtIndex:0]];
				NSLog (@"FONT: %@", zeilenString);
			}
		}
		else if (part == 3) {
			const char *cstr = [zeilenString cString];
			if (cstr[0] == '*') {
				//
				// we found a new group
				//
				if (rows != nil) {
					[_fontDataDic setObject:rows forKey:active_group];
				}
				if (strcmp ("*EOF", cstr) != 0) {
					active_group = [NSString stringWithCString:(cstr + 1)];
					[_glyphGroupsArr addObject:active_group];
					rows = [NSMutableArray array];
					NSLog (@"New group: %@", active_group);
				}
			}
			else {
				//
				// a new sign within the actual group
				//
				NSMutableArray *items = [NSMutableArray arrayWithArray:[zeilenString componentsSeparatedByString:@","]];
                                if ([items count] == 4) {
                                    NSString *tmpFontName = [_fontsDic objectForKey:[items objectAtIndex:1]];
                                    [items replaceObjectAtIndex:1 withObject:tmpFontName];
				
                                        /**
                                        NSLog (@"gname=%@ font=%@ pnum=%@ laut=%@",
                                               [items objectAtIndex:0],
                                               [items objectAtIndex:1],
                                               [items objectAtIndex:2],
                                               [items objectAtIndex:3]);
                                         **/
                                
                                
                                    [rows addObject:items];
                                    [_ggGlyphDic setObject:[NSArray arrayWithObjects:[[items objectAtIndex:2] retain], [[items objectAtIndex:1] retain], nil] forKey:[[items objectAtIndex:0] retain]];
                                    if ([items objectAtIndex:3] != @"") [_ggGlyphDic setObject:[NSArray arrayWithObjects:[[items objectAtIndex:2] retain], [[items objectAtIndex:1] retain], nil] forKey:[[items objectAtIndex:3] retain]];
                                }
                        }
		}
    }
}

- (NSMutableArray *)getGlyphGroups
{
    //should return an NSMutableArray with glyph groups
    return _glyphGroupsArr;
}

- (NSMutableDictionary *)getFontData
{
    //should return an NSMutableDictionary with the whole stuff
    //aber auch nur wenn das sharedFontGroupData mal aufgerufen worden ist
    return _fontDataDic;
}

- (NSString *)getFontNameFromIntValue:(NSString *)fontNameIntValue {
    //den intValue in den Stringnamen umwandeln
    return [_fontsDic objectForKey:fontNameIntValue];
}

- (NSMutableDictionary *)getGGGlyphDic {
    return _ggGlyphDic;
}

- (NSMutableDictionary *)getGlyphLauteDic {
    return _glyphLauteDic;
}

- (NSArray *)getGlyphForSymbols:(NSArray *)symbolStringArray {

    //NSLog(@"%@", _ggGlyphDic);
    //NSLog(@"%@", [self getGlyphLauteDict]);
    NSMutableArray *resultArray = [NSMutableArray array];
    
    int i;
    for (i = 0; i < [symbolStringArray count]; i++) {
        NSArray *tmpArray = [[self getGGGlyphDic] objectForKey:[symbolStringArray objectAtIndex:i]];
        if (tmpArray == nil) {
            return nil;
        }
        //tmpArray (charNummber and fontName) - charNummber as defined in the IG_GlyphCodes.txt
        [resultArray addObject:[tmpArray copy]];
    }
    return resultArray;
}

- (NSArray *)getGlyphForSymbol:(NSString *)symbolString {
    
    //NSLog(@"%@", _ggGlyphDic);
    //NSLog(@"%@", [self getGlyphLauteDict]);
    NSMutableArray *resultArray = [NSMutableArray array];
    NSArray *tmpArray = [[self getGGGlyphDic] objectForKey:symbolString];
    if (tmpArray == nil) {
        return nil;
    }
    //tmpArray (charNummber and fontName) - charNummber as defined in the IG_GlyphCodes.txt
    [resultArray addObject:[[tmpArray objectAtIndex:0] copy]];
    [resultArray addObject:[[tmpArray objectAtIndex:1] copy]];
    return resultArray;
}

@end
