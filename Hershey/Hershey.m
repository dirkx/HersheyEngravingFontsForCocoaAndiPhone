//
//  Hershey.m
//  Hershey
//
// Copyright 2013 Dirk-Willem van Gulik, All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Hershey.h"

@implementation HersheyGlyphDefinition;
-(id)initWithPath:(NSBezierPath *)path
            glyph:(NSGlyph)glyph
               lx:(int)lx
               rx:(int)rx
            baseY:(int)baseY
          accentY:(int)accentY
{
    self = [super init];
    _path = path;
    _lx = lx;
    _rx = rx;
    _baseY = baseY;
    _accentY = accentY;
    _idx = glyph;
    return self;
}

@end

@interface Hershey () {
    NSMutableDictionary * _glyphDefinitions;
}
@end

@implementation Hershey

static int debug = 0;

static NSMutableDictionary * _cache;

NSString * const kHersheyDefaultFont = @"meteorology";
NSString * const kHersheyDefaultFontExtension = @"jhf";

#define BASEY (9)
#define ACCENTY (21)

+(NSArray *)bundledFonts {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSArray * files = [frameworkBundle pathsForResourcesOfType:kHersheyDefaultFontExtension
                                                   inDirectory:nil];
    NSMutableArray * out = [NSMutableArray arrayWithCapacity:[files count]];
    for(NSString * str in files) {
        [out addObject:[[str stringByDeletingPathExtension] lastPathComponent]];
    }
    return out;
}

-(NSArray *) orderedArrayOfGlyps {
    return [[self.glyphDefinitions allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        return [a integerValue] - [b integerValue];
    }];
}

-(id)init {
    return [self initCachedWithFont:nil];
}

-(id)initCachedWithFont:(NSString *)font {
    if (!font)
        font = kHersheyDefaultFont;

    Hershey * cacheDef = [_cache objectForKey:font];
    if (cacheDef)
        return cacheDef; // [cacheDef copyWithZone:nil ];

    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [frameworkBundle pathForResource:font ofType:kHersheyDefaultFontExtension];
    
    if (path)
        self = [self initWithPath:path];
    
    if (self) {        
        if (_cache == nil) {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                _cache = [[NSMutableDictionary alloc] initWithCapacity:25];
            });
        }
        [_cache setObject:self forKey:font];
    }
    
    return self;
}

-(id)initWithPath:(NSString *)path {
    _glyphDefinitions = [NSMutableDictionary dictionaryWithCapacity:96];
    
    // We're not going to do any fancy buffered reading - as we know that these files are
    // simple and small.
    //
    NSData * def = [NSData dataWithContentsOfFile:path];
    if (!def) {
        NSLog(@"%@ - failed to read %@.", [[self class] description], path);
        return nil;
    };
    const char * ptr = [def bytes];
    const char * eptr = [def bytes] + [def length];
    int line = 0;
    int nchar = 0;
    while (ptr < eptr) {
        line++;
        // Docs:
        //  The structure is bascially as follows: each character consists of a number 1->4000 (not all used) in column 0:4, the number of vertices in columns 5:7, the left hand position in column 8, the right hand position in column 9, and finally the vertices in single character pairs. All coordinates are given relative to the ascii value of 'R'. If the coordinate value is " R" that indicates a pen up operation.
        
        char idxbuff[5];
        if (ptr+5 >= eptr) {
            NSLog(@"%@ - failed to read line %d of %@ (no idx).", [[self class] description], line, path);
            return nil;
        }
        strncpy(idxbuff, ptr, 5);
        int idx = atoi(idxbuff);
        ptr+=5;
        
        if (debug > 1)
            NSLog(@" %04d IDX %6d", line,idx);
        
        char vcbuff[4];
        vcbuff[0] = *ptr++;
        vcbuff[1] = *ptr++;
        vcbuff[2] = *ptr++;
        vcbuff[3] = 0;
        int vc = atoi(vcbuff);
        if (vc <= 0) {
            NSLog(@"%@ - failed to read line %d of %@ (vcount parse <%s>).", [[self class] description], line, path, vcbuff);
            return nil;
        };
        
        if (ptr+2 >= eptr) {
            NSLog(@"%@ - failed to read line %d of %@ (lx/rx).", [[self class] description], line, path);
            return nil;
        };
        int lx = *ptr++ - 'R';
        int rx = *ptr++ - 'R';

        if (debug > 1)
        NSLog(@" %04d Vertices %d, left-right: %d..%d", line,vc,lx, rx);

        enum { MOVE, DRAW } ops = MOVE;
        
        NSBezierPath * path = [[NSBezierPath alloc] init];
        
        for(int i = 0; i < vc-1; i++) {
            if (*ptr == '\n') {
                ptr++;
                line++;
            }
            
            if (*ptr == ' ') {
                if (ptr[1] != 'R') {
                    NSLog(@"%@ - failed to read line %d of %@ (move).", [[self class] description], line, path);
                    return nil;
                }
                ptr += 2;
                ops = MOVE;
                continue;
            }
            if (ptr+2 >= eptr) {
                NSLog(@"%@ - failed to read line %d of %@ (xy pair).", [[self class] description], line, path);
                return nil;
            };
            int x = *ptr++ - 'R';
            int y = *ptr++ - 'R';
            
            NSPoint point = NSMakePoint(x,-y);
            switch(ops) {
                case MOVE:
                    [path moveToPoint:point];
                    break;
                case DRAW:
                    [path lineToPoint:point];
                    break;
                default:
                    NSLog(@"%@ - failed to read line %d of %@ (op).", [[self class] description], line, path);
                    return nil;
                    break;
            }
            
            if (debug > 2)
                NSLog(@"     %@ vx%04d/%04d %c%c ->  %d,%d", ops == MOVE ? @"move" : @"draw", i+1, vc,  ptr[-2], ptr[-1], x,y);
            ops = DRAW;
        }
        // Special case for exact 72 char lines.
        while(*ptr == '\n' && ptr[1] == '\n' && ptr + 2 < eptr)
            ptr++;
        
        if (*ptr != '\n') {
            NSLog(@"%@ - failed to read line %d of %@ (eol).", [[self class] description], line, path);
            NSLog(@"Left '%s'", ptr);
            return nil;
        };
        ptr++;
        
        HersheyGlyphDefinition * glDef = [[HersheyGlyphDefinition alloc] initWithPath:path
                                                                                glyph:idx
                                                                                   lx:lx
                                                                                   rx:rx
                                                                                baseY:BASEY
                                                                              accentY:ACCENTY];
        
        [_glyphDefinitions setObject:glDef
                              forKey:[NSNumber numberWithInteger:32 + nchar]];
        nchar++;
    }
    if (debug)
        NSLog(@"Fully Parsed %@ - %d chars", path, nchar);

    _name = [[path lastPathComponent] stringByDeletingPathExtension];
    _baseY = BASEY;
    _accentY = ACCENTY;
    
    return self;
}

-(HersheyGlyphDefinition *)glyph:(NSGlyph)idx {
    return [_glyphDefinitions objectForKey:[NSNumber numberWithInteger:idx]];
}

+(void)transformBezierPath:(NSBezierPath *)path withTransform:(NSPoint (^)(NSPoint p))transform {
    for(NSInteger i = 0; i < [path elementCount]; i++) {
        NSPoint pa[3];
        NSBezierPathElement e = [path elementAtIndex:i associatedPoints:pa];

        int n = 0;
        switch (e) {
            case NSMoveToBezierPathElement:
            case NSLineToBezierPathElement:
                n = 1;
                break;
            case NSCurveToBezierPathElement:
                n = 3;
                break;
            case NSClosePathBezierPathElement:
            default:
                break;
        }
        
        for(int j = 0; j < n; j++)
            pa[j] = transform(pa[j]);
        
        [path setAssociatedPoints:pa atIndex:i];
    }   
}

-(NSBezierPath *)copyOfPathForString:(NSString *)txt
                      withSize:(double)pointSize
{
    return [self copyOfPathForString:txt withSize:pointSize withTransform:nil];
}

-(NSBezierPath *)copyOfPathForString:(NSString *)txt
                      withSize:(double)pointSize
                 withTransform:(NSPoint (^)(NSPoint p))transformOrNil
{

    NSBezierPath * path = [[NSBezierPath alloc] init];
    double dx = 0;
    
    for(NSInteger i = 0; i < [txt length]; i++) {
        NSGlyph c = [txt characterAtIndex:i];
        HersheyGlyphDefinition * def = [self glyph:c];

        // We copy the path - as we're likely to change it
        // during transformations.
        //
        NSBezierPath * gc = [def.path copy];
        
        double s = pointSize / def.accentY / 4.; // didot point is 4mm - though 5.35 is closer to modern/Helvetica.
        
        NSAffineTransform * shift = [[NSAffineTransform alloc] init];
        [shift translateXBy:dx-def.lx
                        yBy:def.baseY];
        [shift scaleBy:s];
        [gc transformUsingAffineTransform:shift];
        
        [path appendBezierPath:gc];
        
        dx += s*(def.rx - def.lx);
    }
    if (transformOrNil)
        [Hershey transformBezierPath:path withTransform:transformOrNil];

    return path;
}
@end
